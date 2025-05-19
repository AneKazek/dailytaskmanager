import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that initializes Firebase
final firebaseInitializerProvider = FutureProvider<FirebaseApp>((ref) async {
  return await Firebase.initializeApp();
});

/// A widget that initializes Firebase before running the app
class FirebaseInitializer extends ConsumerWidget {
  final Widget Function(BuildContext, AsyncValue<FirebaseApp>) builder;

  const FirebaseInitializer({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInitializer = ref.watch(firebaseInitializerProvider);

    return firebaseInitializer.when(
      data: (firebaseApp) => builder(context, AsyncValue.data(firebaseApp)),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing Firebase: $error'),
          ),
        ),
      ),
    );
  }
}