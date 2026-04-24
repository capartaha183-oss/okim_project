import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF123A6F);
  static const Color secondary = Color(0xFF1D5FA7);
  static const Color accent = Color(0xFFE30613);

  static const Color background = Color(0xFFF3F6FA);
  static const Color card = Colors.white;

  static const Color text = Color(0xFF111827);
  static const Color subtitle = Color(0xFF6B7280);

  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFB91C1C);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      Color(0xFF123A6F),
      Color(0xFF1D5FA7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}