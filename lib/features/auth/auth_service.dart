import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  
  return ref.watch(authServiceProvider).getUserData(user.uid);
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Create user document in Firestore
      await _createUserDocument(credential.user!.uid, email, displayName);
      
      // Update display name
      await credential.user!.updateDisplayName(displayName);
      
      return credential;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Check if this is a new user
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create user document in Firestore
        await _createUserDocument(
          userCredential.user!.uid,
          userCredential.user!.email!,
          userCredential.user!.displayName ?? 'User',
          userCredential.user!.photoURL,
        );
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // Create user document in Firestore
  Future<void> _createUserDocument(String uid, String email, String displayName, [String? photoUrl]) async {
    final userModel = UserModel(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      projectIds: [],
    );
    
    await _firestore.collection('users').doc(uid).set(userModel.toMap());
  }
  
  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(String uid, {String? displayName, String? photoUrl}) async {
    final updates = <String, dynamic>{};
    
    if (displayName != null) {
      updates['displayName'] = displayName;
      await _auth.currentUser?.updateDisplayName(displayName);
    }
    
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    }
    
    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }
  }
}