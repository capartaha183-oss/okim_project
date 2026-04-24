import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../core/app_colors.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final TextEditingController passController = TextEditingController();

  bool obscure = true;
  bool loading = false;

  Future<void> loginWithBiometric() async {
    final enabled = await storage.read(key: "biometric_enabled");
    if (enabled == "false") {
      showMsg("Biyometrik giriş kapalı.");
      return;
    }

    try {
      setState(() => loading = true);

      final bool ok = await auth.authenticate(
        localizedReason: 'OKIM sistemine giriş yapmak için doğrulama yapın',
      );

      if (ok) goHome();
    } catch (_) {
      showMsg("Biyometrik doğrulama kullanılamıyor.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loginWithPassword() async {
    final savedPass = await storage.read(key: "app_password") ?? "1234";

    if (passController.text.trim() == savedPass) {
      goHome();
    } else {
      showMsg("Şifre hatalı.");
    }
  }

  void goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 22),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "OKIM Mobil Giriş",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: passController,
                obscureText: obscure,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Mobil şifrenizi girin",
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : loginWithPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Giriş Yap",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: loading ? null : loginWithBiometric,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(
                    loading ? "Doğrulanıyor..." : "Biyometrik Doğrulama",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Varsayılan şifre: 1234",
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}