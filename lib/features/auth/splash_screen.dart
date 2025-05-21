import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'welcome_screen.dart'; // Akan dibuat nanti

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final waveAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );
    final logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    final logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    useEffect(() {
      animationController.forward();
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const WelcomeScreen(), // Akan dibuat nanti
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFFF9AA33), // Dominant coral-peach background
      body: Stack(
        children: [
          // Wave Reveal Animation
          AnimatedBuilder(
            animation: waveAnimation,
            builder: (context, child) {
              return ClipPath(
                clipper: WaveClipper(waveAnimation.value),
                child: Container(
                  color: Colors.white, // Wave color
                ),
              );
            },
          ),
          // Logo/App Icon Animation
          Center(
            child: ScaleTransition(
              scale: logoScaleAnimation,
              child: Opacity(
                opacity: logoOpacityAnimation.value,
                child: SvgPicture.asset(
                  'assets/images/app_logo.svg', // Path ke logo aplikasi Anda
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter untuk efek gelombang (WaveClipper)
class WaveClipper extends CustomClipper<Path> {
  final double animationValue; // Nilai animasi dari 0.0 hingga 1.0

  WaveClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    final path = Path();
    // Mulai dari kiri bawah
    path.lineTo(0, size.height);

    // Titik kontrol pertama untuk kurva bezier (mengontrol bentuk gelombang)
    var firstControlPoint = Offset(size.width / 4, size.height - (100 * animationValue));
    // Titik akhir pertama untuk kurva bezier (puncak gelombang pertama)
    var firstEndPoint = Offset(size.width / 2.25, size.height - (50 * animationValue) - (50 * (1-animationValue)));

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    // Titik kontrol kedua untuk kurva bezier
    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - (10 * animationValue) - (90 * (1-animationValue)));
    // Titik akhir kedua untuk kurva bezier (lembah gelombang)
    var secondEndPoint = Offset(size.width, size.height - (40 * animationValue));

    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    // Menuju kanan atas
    path.lineTo(size.width, 0);
    path.lineTo(0,0); // Kembali ke kiri atas untuk menutup path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // Selalu reclip karena animasi berubah
  }
}