import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lightweight ad banner displayed at the bottom of non-gameplay screens.
/// Self-contained: dismissible per session, zero impact on gameplay.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  bool _dismissed = false;

  static const _mockAds = [
    'UPGRADE YOUR ARSENAL — VISIT THE HANGAR',
    'ENJOY THE GAME? SHARE IT WITH FRIENDS',
    'NEW AIRCRAFT UNLOCKED EVERY LEVEL',
  ];

  String get _adText {
    final seed = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return _mockAds[seed % _mockAds.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1A0A),
        border: Border(
          top: BorderSide(color: Color(0xFF1E3A1E), width: 1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'AD',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _adText,
              style: GoogleFonts.orbitron(
                fontSize: 9,
                color: Colors.white38,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Icon(Icons.close, size: 13, color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }
}
