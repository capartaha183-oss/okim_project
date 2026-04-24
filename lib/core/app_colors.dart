import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0057D9);
  static const Color primaryDark = Color(0xFF003E9C);
  static const Color secondary = Color(0xFF2F80ED);
  static const Color accent = Color(0xFF00A3FF);

  static const Color background = Color(0xFFF5F9FF);
  static const Color card = Colors.white;

  static const Color text = Color(0xFF0B1F3A);
  static const Color subtitle = Color(0xFF6B7A90);

  static const Color success = Color(0xFF13A463);
  static const Color danger = Color(0xFFE03131);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      Color(0xFF0057D9),
      Color(0xFF00A3FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepGradient = LinearGradient(
    colors: [
      Color(0xFF003E9C),
      Color(0xFF0057D9),
      Color(0xFF00A3FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}