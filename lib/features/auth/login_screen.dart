import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import '../../main.dart'; // Import untuk DailyTaskManager

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// ignore: duplicate_import
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk logo Google jika SVG

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "demo@email.com"); // Placeholder
  final _passwordController = TextEditingController(text: "enter your password"); // Placeholder
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear placeholder text before submitting if they are still default
    final email = _emailController.text.trim() == "demo@email.com" ? "" : _emailController.text.trim();
    final password = _passwordController.text.trim() == "enter your password" ? "" : _passwordController.text.trim();

    // Basic validation after clearing placeholders
    if (email.isEmpty || !email.contains('@')) {
        setState(() {
            _errorMessage = 'Please enter a valid email';
        });
        return;
    }
    if (password.isEmpty || password.length < 6) {
        setState(() {
            _errorMessage = 'Password must be at least 6 characters';
        });
        return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Login
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
            email,
            password,
          );
      // Navigasi setelah login berhasil
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DailyTaskManager()), // Menggunakan DailyTaskManager sebagai layar utama
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? 'Login failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final userCredential = await ref.read(authServiceProvider).signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DailyTaskManager()), // Menggunakan DailyTaskManager sebagai layar utama
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message ?? 'Google sign-in failed.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred during Google sign-in.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width; // Tidak terpakai saat ini

    // Gaya teks umum
    const textStyleRegular = TextStyle(fontFamily: 'SansSerif', color: Colors.black87);
    const textStyleBold = TextStyle(fontFamily: 'SansSerif', fontWeight: FontWeight.bold, color: Colors.black87);
    const placeholderStyle = TextStyle(fontFamily: 'SansSerif', color: Colors.grey);

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang utama putih
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Bagian atas: coral-peach background dengan pola topografi
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.35, // Ketinggian background coral-peach
              child: Container(
                color: const Color(0xFFF9AA33), // Dominant coral-peach background
                child: Opacity(
                  opacity: 0.1, // Opasitas pola topografi
                  child: Image.asset(
                    'assets/images/topography_pattern.png', // Path ke pola topografi Anda
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Wave curve memisahkan background coral dan konten putih
            Positioned(
              top: screenHeight * 0.35 - 50, // Posisi wave agar sedikit overlap
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: WaveClipperLogin(), // Clipper khusus untuk LoginScreen
                child: Container(
                  height: 100, // Tinggi wave
                  color: Colors.white,
                ),
              ),
            ),
            // Area konten utama
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.35 + 20, left: 24, right: 24, bottom: 24), // Mulai dari bawah wave
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Judul “Sign in”
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 28, // h3 (perkiraan)
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SansSerif',
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFF9AA33),
                        decorationThickness: 2.0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Form field Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'demo@email.com',
                        hintStyle: placeholderStyle,
                        prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      style: textStyleRegular,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || value == 'demo@email.com') {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onTap: () {
                        if (_emailController.text == 'demo@email.com') {
                          _emailController.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Form field Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'enter your password',
                        hintStyle: placeholderStyle,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: _obscurePassword,
                      style: textStyleRegular,
                      validator: (value) {
                        if (value == null || value.isEmpty || value == 'enter your password') {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onTap: () {
                        if (_passwordController.text == 'enter your password') {
                          _passwordController.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFFF9AA33),
                                checkColor: Colors.white,
                                side: BorderSide(color: Colors.grey[400]!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember Me', style: TextStyle(fontFamily: 'SansSerif', color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implementasi Forgot Password
                            // Contoh: ref.read(authServiceProvider).resetPassword(_emailController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Forgot Password link pressed. Implement reset password logic.')),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFFF9AA33), fontFamily: 'SansSerif', fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontFamily: 'SansSerif'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Tombol Login
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF9AA33))))
                        : SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9AA33),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30), // rounded-pill
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.white, fontFamily: 'SansSerif', fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    // Tombol Google Sign-In
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: SvgPicture.asset('assets/images/app_logo.svg', height: 20, colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcIn)), // Ganti dengan logo Google jika ada
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.black54, fontFamily: 'SansSerif', fontWeight: FontWeight.normal),
                        ),
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Footer: Don’t have an Account ? Sign up
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigasi ke halaman Sign Up
                          // Contoh: Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sign Up link pressed. Implement navigation to Sign Up screen.')),
                            );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.grey, fontFamily: 'SansSerif', fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(text: "Don’t have an Account ? "),
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(color: Color(0xFFF9AA33), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Padding bawah tambahan
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomClipper untuk efek gelombang di LoginScreen
class WaveClipperLogin extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.6); // Mulai dari kiri, sedikit di atas tengah wave
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.2, size.width * 0.5, size.height * 0.5); // Puncak lebih landai
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.8, size.width, size.height * 0.6); // Lembah lebih landai
    path.lineTo(size.width, 0); // Ke kanan atas
    path.lineTo(0, 0); // Ke kiri atas untuk menutup path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // Tidak perlu reclip karena statis
  }
}

// Pastikan Anda memiliki 'assets/images/topography_pattern.png'
// dan 'assets/images/app_logo.svg' (atau ganti dengan logo Google jika diinginkan untuk tombol Google)