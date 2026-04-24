import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'kimdi_camera_screen.dart';
import 'manage_people_screen.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void openPage(Widget page) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => page),
    );
  }

  Widget iosCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.subtitle,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.shield_fill,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(height: 18),
          Text(
            "OKIM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Güvenli kişi tanıma ve haber akışı sistemi",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget miniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget smallInfoCards() {
    return Row(
      children: [
        Expanded(
          child: miniCard(
            title: "Koruma",
            value: "Aktif",
            icon: CupertinoIcons.lock_shield_fill,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: miniCard(
            title: "Sistem",
            value: "Hazır",
            icon: CupertinoIcons.checkmark_seal_fill,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "OKIM",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColors.background,
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            statusCard(),
            const SizedBox(height: 16),
            smallInfoCards(),
            const SizedBox(height: 24),
            const Text(
              "İşlemler",
              style: TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),

            iosCard(
              icon: CupertinoIcons.person_crop_circle_badge_checkmark,
              title: "Kimdi?",
              subtitle: "Kamera ile kayıtlı kişiyi tanı",
              color: AppColors.primary,
              onTap: () => openPage(const KimdiCameraScreen()),
            ),

            iosCard(
              icon: CupertinoIcons.person_2_fill,
              title: "Kayıtlı Kişiler",
              subtitle: "Yeni kişi ekle, listele veya sil",
              color: const Color(0xFF2563EB),
              onTap: () => openPage(const ManagePeopleScreen()),
            ),

            iosCard(
              icon: CupertinoIcons.news_solid,
              title: "Gizli Haberler",
              subtitle: "Koruma modunda haber akışını görüntüle",
              color: AppColors.accent,
              onTap: () => openPage(const MessagesScreen()),
            ),

            iosCard(
              icon: CupertinoIcons.settings_solid,
              title: "Ayarlar",
              subtitle: "Şifre, güvenlik ve uygulama ayarları",
              color: const Color(0xFF374151),
              onTap: () => openPage(const SettingsScreen()),
            ),

            iosCard(
              icon: CupertinoIcons.camera_fill,
              title: "Kamera",
              subtitle: "Kamera modülü ve tarama ekranı",
              color: const Color(0xFF7C3AED),
              onTap: () => openPage(const KimdiCameraScreen()),
            ),
          ],
        ),
      ),
    );
  }
}