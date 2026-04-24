import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const OkimApp());
}

class OkimApp extends StatelessWidget {
  const OkimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OKIM',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8E8EE),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6FB3),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}