import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../game/managers/save_manager.dart';
import '../../models/aircraft_data.dart';
import '../widgets/ad_banner_widget.dart';
import 'mission_briefing_screen.dart';

class LevelCompleteScreen extends StatelessWidget {
  const LevelCompleteScreen({
    super.key,
    required this.score,
    required this.coins,
    required this.level,
    required this.saveManager,
    required this.selectedAircraft,
  });

  final int score;
  final int coins;
  final int level;
  final SaveManager saveManager;
  final AircraftData selectedAircraft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001A00), Color(0xFF0A2A0A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'MISSION COMPLETE',
                          style: GoogleFonts.orbitron(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF44FF88),
                            letterSpacing: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'LEVEL $level',
                          style: GoogleFonts.orbitron(
                              fontSize: 14, color: Colors.white54),
                        ),
                        const SizedBox(height: 40),
                        _statRow('SCORE', '$score pts', const Color(0xFFFFCC44)),
                        const SizedBox(height: 12),
                        _statRow('COINS EARNED', '+$coins',
                            const Color(0xFFFFB800)),
                        const SizedBox(height: 12),
                        _statRow('TOTAL SCORE',
                            '${saveManager.progress.totalScore}',
                            Colors.white70),
                        const SizedBox(height: 48),
                        _buildButton(
                          context,
                          'PROCHAINE MISSION',
                          const Color(0xFF44FF88),
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MissionBriefingScreen(
                                saveManager: saveManager,
                                selectedAircraft: selectedAircraft,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildButton(
                          context,
                          'MAIN MENU',
                          Colors.white38,
                          () => Navigator.of(context).popUntil((r) => r.isFirst),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.orbitron(
                fontSize: 12, color: Colors.white54)),
        Text(value,
            style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.orbitron(color: color, letterSpacing: 2),
        ),
      ),
    );
  }
}
