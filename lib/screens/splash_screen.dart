import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fade;
  late Animation<double> slide;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    slide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget logoBox() {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 62,
            color: AppColors.primary,
          ),
          Positioned(
            right: 20,
            bottom: 22,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: fade,
            child: AnimatedBuilder(
              animation: slide,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, slide.value),
                  child: child,
                );
              },
              child: Column(
                children: [
                  const Spacer(),

                  logoBox(),

                  const SizedBox(height: 28),

                  const Text(
                    "OKIM",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Kişi Tanıma ve Güvenli Bilgi Sistemi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 34),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Text(
                      "Güvenli bağlantı hazırlanıyor...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "OKIM Mobil Hizmetler",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}