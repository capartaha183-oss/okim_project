import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../core/app_colors.dart';
import 'kimdi_camera_screen.dart';
import 'manage_people_screen.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? tag;
  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.tag,
  });
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String detail;
  final String time;
  final Color color;
  final bool isAlert;
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
    this.isAlert = false,
  });
}

class _AlertBanner {
  final String message;
  final Color color;
  final IconData icon;
  const _AlertBanner({
    required this.message,
    required this.color,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _heroController;
  late AnimationController _pulseController;
  late AnimationController _cardsController;
  late AnimationController _shieldRotateController;
  late AnimationController _scoreController;
  late AnimationController _bannerController;
  late AnimationController _fabController;

  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _pulse;
  late Animation<double> _shieldScale;
  late Animation<double> _scoreAnim;
  late Animation<Offset> _bannerSlide;
  late Animation<double> _fabScale;

  // State
  DateTime _now = DateTime.now();
  Timer? _clockTimer;
  bool _showBanner = true;
  final int _unreadCount = 3;
  final double _securityScore = 0.87;

  // Mock data
  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
      title: "Ahmet Yılmaz tanındı",
      detail: "Ana Kamera • Başarılı",
      time: "2 dk önce",
      color: Color(0xFF13A463),
    ),
    _ActivityItem(
      icon: CupertinoIcons.exclamationmark_shield_fill,
      title: "Bilinmeyen kişi algılandı",
      detail: "Arka Kapı • Uyarı",
      time: "18 dk önce",
      color: Color(0xFFE03131),
      isAlert: true,
    ),
    _ActivityItem(
      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
      title: "Mehmet Demir tanındı",
      detail: "Ana Kamera • Başarılı",
      time: "1 sa önce",
      color: Color(0xFF0057D9),
    ),
    _ActivityItem(
      icon: CupertinoIcons.lock_shield_fill,
      title: "Sistem taraması tamamlandı",
      detail: "Güvenlik • Temiz",
      time: "3 sa önce",
      color: Color(0xFF00A3FF),
    ),
  ];

  final List<_ActionItem> _actions = const [
    _ActionItem(
      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
      title: "Kimdi?",
      subtitle: "Kamera ile kayıtlı kişiyi tanı",
      color: Color(0xFF0057D9),
      tag: "YENİ",
    ),
    _ActionItem(
      icon: CupertinoIcons.person_2_fill,
      title: "Kayıtlı Kişiler",
      subtitle: "Kişi ekle, listele veya sil",
      color: Color(0xFF2F80ED),
      tag: null,
    ),
    _ActionItem(
      icon: CupertinoIcons.news_solid,
      title: "Gizli Haberler",
      subtitle: "Koruma modunda haber akışını görüntüle",
      color: Color(0xFF00A3FF),
      tag: "GİZLİ",
    ),
    _ActionItem(
      icon: CupertinoIcons.settings_solid,
      title: "Ayarlar",
      subtitle: "Şifre ve güvenlik ayarları",
      color: Color(0xFF0B1F3A),
      tag: null,
    ),
  ];

  final _AlertBanner _alert = const _AlertBanner(
    message: "Bilinmeyen kişi algılandı! Arka kamera görüntüsünü kontrol edin.",
    color: Color(0xFFE03131),
    icon: CupertinoIcons.exclamationmark_triangle_fill,
  );

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _cardsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _shieldRotateController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _scoreController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _bannerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _heroFade = CurvedAnimation(parent: _heroController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _heroSlide = Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic));
    _pulse = Tween<double>(begin: 0.94, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _shieldScale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _heroController, curve: const Interval(0.2, 0.85, curve: Curves.elasticOut)));
    _scoreAnim = Tween<double>(begin: 0.0, end: _securityScore)
        .animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic));
    _bannerSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bannerController, curve: Curves.easeOutBack));
    _fabScale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _heroController.forward();
      if (_showBanner) _bannerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _cardsController.forward();
      _scoreController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _fabController.forward();
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _pulseController.dispose();
    _cardsController.dispose();
    _shieldRotateController.dispose();
    _scoreController.dispose();
    _bannerController.dispose();
    _fabController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void openPage(Widget page) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => page));
  }

  void _dismissBanner() {
    _bannerController.reverse().then((_) {
      if (mounted) setState(() => _showBanner = false);
    });
  }

  String get _formattedTime {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _formattedDate {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return '${days[_now.weekday - 1]}, ${_now.day} ${months[_now.month - 1]} ${_now.year}';
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildFAB(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_showBanner) ...[
                  const SizedBox(height: 16),
                  _buildAlertBanner(),
                ],
                const SizedBox(height: 20),
                _buildStatusRow(),
                const SizedBox(height: 20),
                _buildSecurityScoreCard(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildSectionTitle("Son Aktiviteler"),
                const SizedBox(height: 12),
                _buildActivityFeed(),
                const SizedBox(height: 24),
                _buildSectionTitle("Hizmetler"),
                const SizedBox(height: 14),
                ..._actions.asMap().entries.map((e) => _buildActionCard(e.key, e.value)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SLIVER APP BAR ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 290,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.bell_fill, color: Colors.white),
              onPressed: () {},
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE03131),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
        background: FadeTransition(
          opacity: _heroFade,
          child: SlideTransition(position: _heroSlide, child: _buildHeroBanner()),
        ),
        title: AnimatedBuilder(
          animation: _heroController,
          builder: (_, __) => Opacity(
            opacity: _heroController.value < 0.5 ? 0 : 1,
            child: const Text(
              "OKIM",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2),
            ),
          ),
        ),
      ),
    );
  }

  // ─── HERO BANNER ───────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.deepGradient),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: AnimatedBuilder(
              animation: _shieldRotateController,
              builder: (_, child) => Transform.rotate(
                angle: _shieldRotateController.value * 2 * math.pi,
                child: child,
              ),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 44),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 10,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 32),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _shieldScale,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(19),
                            boxShadow: [
                              BoxShadow(color: Colors.white.withValues(alpha: 0.25), blurRadius: 22, spreadRadius: 4),
                            ],
                          ),
                          child: const Icon(CupertinoIcons.shield_fill, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "OKIM",
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "GÜVENLİ MOD AKTİF",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Canlı saat
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          _formattedDate,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 9, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  "Akıllı Güvenlik ve Dijital Hizmet Platformu",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ALERT BANNER ──────────────────────────────────────────────────────────

  Widget _buildAlertBanner() {
    return SlideTransition(
      position: _bannerSlide,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _alert.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _alert.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
              child: Icon(_alert.icon, color: _alert.color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _alert.message,
                style: TextStyle(color: _alert.color, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _dismissBanner,
              child: Icon(CupertinoIcons.xmark_circle_fill, color: _alert.color.withValues(alpha: 0.6), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATUS ROW ────────────────────────────────────────────────────────────

  Widget _buildStatusRow() {
    return _animateIn(
      startDelay: 0.0,
      child: Row(
        children: [
          Expanded(child: _buildStatCard(icon: CupertinoIcons.lock_shield_fill, label: "Koruma", value: "Aktif", color: AppColors.success)),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard(icon: CupertinoIcons.checkmark_seal_fill, label: "Sistem", value: "Hazır", color: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard(icon: CupertinoIcons.eye_slash_fill, label: "Gizlilik", value: "Tam", color: AppColors.accent)),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.success.withValues(alpha: 0.5 * _pulse.value), blurRadius: 6, spreadRadius: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.subtitle, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── SECURITY SCORE ────────────────────────────────────────────────────────

  Widget _buildSecurityScoreCard() {
    return _animateIn(
      startDelay: 0.1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.deepGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _scoreAnim,
              builder: (_, __) => SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: _ScoreRingPainter(progress: _scoreAnim.value),
                    ),
                    Text(
                      '${(_scoreAnim.value * 100).round()}',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Güvenlik Skoru",
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text("Mükemmel",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedBuilder(
                      animation: _scoreAnim,
                      builder: (_, __) => LinearProgressIndicator(
                        value: _scoreAnim.value,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text("Son güncelleme: bugün 09:41",
                      style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATS ROW ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return _animateIn(
      startDelay: 0.15,
      child: Row(
        children: [
          Expanded(child: _buildMiniStat(label: "Bugün Tanınan", value: "12", icon: CupertinoIcons.person_crop_circle_badge_checkmark, color: AppColors.success)),
          const SizedBox(width: 10),
          Expanded(child: _buildMiniStat(label: "Uyarı", value: "1", icon: CupertinoIcons.exclamationmark_triangle_fill, color: AppColors.danger)),
          const SizedBox(width: 10),
          Expanded(child: _buildMiniStat(label: "Kayıtlı Kişi", value: "48", icon: CupertinoIcons.person_2_fill, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildMiniStat({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.subtitle, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── ACTIVITY FEED ─────────────────────────────────────────────────────────

  Widget _buildActivityFeed() {
    return _animateIn(
      startDelay: 0.2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: _activities.asMap().entries.map((entry) {
            final isLast = entry.key == _activities.length - 1;
            return _buildActivityTile(entry.value, isLast: isLast);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityTile(_ActivityItem item, {required bool isLast}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.background, width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: item.isAlert ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: item.isAlert
                ? AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, child) => Transform.scale(scale: _pulse.value * 0.97, child: child),
                    child: Icon(item.icon, color: item.color, size: 20),
                  )
                : Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(item.detail, style: const TextStyle(color: AppColors.subtitle, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(item.time, style: const TextStyle(color: AppColors.subtitle, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── SECTION TITLE ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(gradient: AppColors.mainGradient, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
      ],
    );
  }

  // ─── ACTION CARD ───────────────────────────────────────────────────────────

  Widget _buildActionCard(int index, _ActionItem item) {
    final delay = index * 0.14;
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (_, child) {
        final t = ((_cardsController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(offset: Offset(0, 28 * (1 - curve)), child: child),
        );
      },
      child: _ActionCard(
        item: item,
        onTap: () {
          switch (index) {
            case 0: openPage(const KimdiCameraScreen()); break;
            case 1: openPage(const ManagePeopleScreen()); break;
            case 2: openPage(const MessagesScreen()); break;
            case 3: openPage(const SettingsScreen()); break;
          }
        },
      ),
    );
  }

  // ─── FAB ───────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return ScaleTransition(
      scale: _fabScale,
      child: GestureDetector(
        onTap: () => openPage(const KimdiCameraScreen()),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Transform.scale(scale: 0.97 + (_pulse.value - 0.95) * 0.4, child: child),
            child: const Icon(CupertinoIcons.camera_viewfinder, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  // ─── HELPER ────────────────────────────────────────────────────────────────

  Widget _animateIn({required Widget child, double startDelay = 0.0}) {
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (_, c) {
        final t = ((_cardsController.value - startDelay) / (1.0 - startDelay)).clamp(0.0, 1.0);
        final curve = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curve,
          child: Transform.translate(offset: Offset(0, 18 * (1 - curve)), child: c),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score Ring Painter
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  _ScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Card
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
  final _ActionItem item;
  final VoidCallback onTap;
  const _ActionCard({required this.item, required this.onTap});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.962)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) { _pressController.reverse(); widget.onTap(); },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          margin: const EdgeInsets.only(bottom: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: widget.item.color.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 7)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.item.color, widget.item.color.withValues(alpha: 0.35)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 15, 15),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(widget.item.icon, color: widget.item.color, size: 25),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(widget.item.title,
                                    style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w800)),
                                if (widget.item.tag != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.mainGradient,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(widget.item.tag!,
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(widget.item.subtitle,
                                style: const TextStyle(color: AppColors.subtitle, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(CupertinoIcons.chevron_right, color: AppColors.subtitle, size: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
