import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OkimApp());
}

class OkimApp extends StatelessWidget {
  const OkimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OKIM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}