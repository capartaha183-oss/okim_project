import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final storage = const FlutterSecureStorage();

  final oldPass = TextEditingController();
  final newPass = TextEditingController();

  bool biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final bio = await storage.read(key: "biometric_enabled");
    setState(() {
      biometricEnabled = bio != "false";
    });
  }

  Future<void> saveBiometric(bool value) async {
    await storage.write(key: "biometric_enabled", value: value.toString());
    setState(() => biometricEnabled = value);
  }

  Future<void> changePassword() async {
    final current = await storage.read(key: "app_password") ?? "1234";

    if (oldPass.text.trim() != current) {
      showMsg("Eski şifre hatalı.");
      return;
    }

    if (newPass.text.trim().length < 4) {
      showMsg("Yeni şifre en az 4 karakter olmalı.");
      return;
    }

    await storage.write(key: "app_password", value: newPass.text.trim());

    oldPass.clear();
    newPass.clear();

    showMsg("Şifre başarıyla değiştirildi.");
  }

  void showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    oldPass.dispose();
    newPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Ayarlar", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.background,
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.lock_shield_fill,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Biyometrik Giriş",
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    value: biometricEnabled,
                    onChanged: saveBiometric,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Şifre Değiştir",
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: oldPass,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Eski şifre",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Yeni şifre",
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
              height: 54,
              child: ElevatedButton(
                onPressed: changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Şifreyi Güncelle",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}