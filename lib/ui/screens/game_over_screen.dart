import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/managers/save_manager.dart';
import '../../models/aircraft_data.dart';
import 'game_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.score,
    required this.level,
    required this.saveManager,
  });

  final int score;
  final int level;
  final SaveManager saveManager;

  @override
  Widget build(BuildContext context) {
    final isHighScore = score >= saveManager.progress.highScore;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0000), Color(0xFF2A0A0A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MISSION FAILED',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFF4444),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isHighScore)
                    Text(
                      'NEW HIGH SCORE!',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        color: const Color(0xFFFFCC00),
                        letterSpacing: 2,
                      ),
                    ),
                  const SizedBox(height: 40),
                  _statRow('SCORE', '$score', const Color(0xFFFFCC44)),
                  const SizedBox(height: 12),
                  _statRow('REACHED LEVEL', '$level', Colors.white70),
                  const SizedBox(height: 12),
                  _statRow(
                    'HIGH SCORE',
                    '${saveManager.progress.highScore}',
                    const Color(0xFFFFB800),
                  ),
                  const SizedBox(height: 48),
                  _buildButton(
                    context,
                    'RETRY',
                    const Color(0xFFFF4444),
                    () {
                      final aircraft = AircraftData.all.firstWhere(
                        (a) =>
                            a.id ==
                            saveManager.progress.unlockedAircraftIds.last,
                        orElse: () => AircraftData.interceptor,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            saveManager: saveManager,
                            selectedAircraft: aircraft,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    context,
                    'MAIN MENU',
                    Colors.white38,
                    () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ],
              ),
            ),
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
