import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;
  final String correctPassword = "1234";

  Future<void> biometricLogin() async {
    try {
      setState(() => loading = true);

      final bool success = await auth.authenticate(
        localizedReason: 'OKIM uygulamasına giriş yapmak için doğrulama yap',
      );

      if (success) {
        goHome();
      }
    } catch (e) {
      showMessage("Bu cihazda biyometrik giriş desteklenmeyebilir.");
    } finally {
      setState(() => loading = false);
    }
  }

  void passwordLogin() {
    if (passwordController.text.trim() == correctPassword) {
      goHome();
    } else {
      showMessage("Şifre yanlış. Varsayılan şifre: 1234");
    }
  }

  void goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFDEFF4),
              Color(0xFFE9F0FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 75,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "OKIM",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D4F8F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Güvenli giriş yap",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : biometricLogin,
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(
                          loading
                              ? "Kontrol ediliyor..."
                              : "Face ID / Parmak İzi",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D4F8F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("veya"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Şifre gir",
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: passwordLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D7D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Şifre ile Giriş Yap",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Text(
                      "Varsayılan şifre: 1234",
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}