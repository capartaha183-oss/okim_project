import 'package:flutter/material.dart';
import '../widgets/wave_header.dart';
import 'kimdi_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  Widget topButton(String text) {
    return Container(
      width: 118,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4C6AA7),
            Color(0xFF6C8FD1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget centerButton() {
    return Container(
      width: 145,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF4D7D),
            Color(0xFFFF7A9A),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "a ats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget infoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE9F0FF),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF4A6FB3),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "Premium sürüm aktif.\nAlt menüden özellik seç.",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem navItem(
    IconData icon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8EE),
      body: SafeArea(
        child: Column(
          children: [
            const WaveHeader(),

            const SizedBox(height: 20),

            infoCard(),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                topButton("KİM"),
                const SizedBox(width: 14),
                topButton("OLAY"),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                topButton("KİM"),
                const SizedBox(width: 14),
                topButton("KİME"),
              ],
            ),

            const SizedBox(height: 24),

            centerButton(),

            const Spacer(),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFFF4D7D),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          onTap: (index) {
  setState(() {
    selectedIndex = index;
  });

  if (index == 0) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KimdiCameraScreen(),
      ),
    );
  }
},
          items: [
            navItem(Icons.phone_rounded, "Kimdi"),
            navItem(Icons.search_rounded, "Aramalar"),
            navItem(Icons.camera_alt_rounded, "Kamera"),
            navItem(Icons.message_rounded, "Mesajlar"),
          ],
        ),
      ),
    );
  }
}