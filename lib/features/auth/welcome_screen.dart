reimport 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk pola topografi jika SVG

import 'login_screen.dart'; // Akan diupdate nanti

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Bagian atas: coral-peach background dengan pola topografi
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.4, // Sesuaikan tinggi background
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
            top: screenHeight * 0.4 - 50, // Posisi wave agar sedikit overlap
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipperWelcome(),
              child: Container(
                height: 100, // Tinggi wave
                color: Colors.white,
              ),
            ),
          ),
          // Area konten putih
          Positioned(
            top: screenHeight * 0.4, // Mulai dari bawah wave
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul “Welcome”
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 28, // h3 (perkiraan)
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SansSerif', // Ganti dengan font Anda
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subteks
                  const Text(
                    'Lorem ipsum dolor sit amet consectetur. Lorem id sit',
                    style: TextStyle(
                      fontSize: 14, // caption (perkiraan)
                      color: Colors.grey,
                      fontFamily: 'SansSerif', // Ganti dengan font Anda
                    ),
                  ),
                  const Spacer(), // Mendorong tombol ke bawah
                  // Tombol “Continue →”
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()), // Akan diupdate
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9AA33),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // rounded-pill
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SansSerif', // Ganti dengan font Anda
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // iPhone-style notch (Placeholder - sesuaikan dengan kebutuhan)
          // Ini hanya contoh visual, implementasi notch yang sebenarnya lebih kompleks
          // dan biasanya ditangani oleh Flutter secara otomatis pada perangkat dengan notch.
          // Untuk simulasi, Anda bisa menambahkan container hitam di atas.
          // Positioned(
          //   top: 0,
          //   left: screenWidth * 0.25,
          //   right: screenWidth * 0.25,
          //   height: 30, // Tinggi notch
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.only(
          //         bottomLeft: Radius.circular(15),
          //         bottomRight: Radius.circular(15),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// CustomClipper untuk efek gelombang di WelcomeScreen
class WaveClipperWelcome extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.6); // Mulai dari kiri, sedikit di atas tengah wave
    // Kurva ke atas (puncak wave)
    path.quadraticBezierTo(size.width / 4, size.height * 0.2, size.width / 2, size.height * 0.5);
    // Kurva ke bawah (lembah wave)
    path.quadraticBezierTo(size.width * 3 / 4, size.height * 0.8, size.width, size.height * 0.6);
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