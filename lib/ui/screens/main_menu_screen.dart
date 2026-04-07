import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/managers/save_manager.dart';
import '../../models/aircraft_data.dart';
import '../widgets/ad_banner_widget.dart';
import 'hangar_screen.dart';
import 'game_screen.dart';
import 'mission_briefing_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.saveManager});

  final SaveManager saveManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1A0A), Color(0xFF1A2A1A), Color(0xFF0A1510)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const Spacer(),
              _buildHighScore(),
              const SizedBox(height: 40),
              _buildButtons(context),
              const Spacer(),
              _buildVersion(),
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'BOMBING WAR',
      style: GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: const Color(0xFFFFB800),
        letterSpacing: 4,
        shadows: const [
          Shadow(color: Color(0xFFFF4400), blurRadius: 20),
          Shadow(color: Color(0xFFFF4400), blurRadius: 40),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          'OPÉRATION : EPIC COLLAPSE',
          style: GoogleFonts.orbitron(
            fontSize: 11,
            color: const Color(0xFFFF8844),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ALLIANCE OCCIDENTALE  ✦  CONFLIT DU GOLFE',
          style: GoogleFonts.orbitron(
            fontSize: 9,
            color: Colors.white24,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildHighScore() {
    return Text(
      'HIGH SCORE: ${saveManager.progress.highScore}',
      style: GoogleFonts.orbitron(
        fontSize: 14,
        color: const Color(0xFFFFCC44),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _MenuButton(
            label: 'PLAY MISSION',
            color: const Color(0xFFFFB800),
            onTap: () => _startGame(context),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            label: 'HANGAR',
            color: const Color(0xFF44AAFF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HangarScreen(saveManager: saveManager),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuButton(
            label: 'LEADERBOARD',
            color: const Color(0xFF44FF88),
            onTap: () => _showLeaderboard(context),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context) {
    // Use the last selected aircraft or default to interceptor
    final selectedId = saveManager.progress.unlockedAircraftIds.last;
    final aircraft = AircraftData.all.firstWhere(
      (a) => a.id == selectedId,
      orElse: () => AircraftData.interceptor,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionBriefingScreen(
          saveManager: saveManager,
          selectedAircraft: aircraft,
        ),
      ),
    );
  }

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A1A),
        title: Text(
          'LEADERBOARD',
          style: GoogleFonts.orbitron(color: const Color(0xFFFFB800)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _leaderboardRow(1, 'YOU', saveManager.progress.highScore),
            const Divider(color: Colors.white24),
            _leaderboardRow(2, 'FANTÔME', 8500),
            _leaderboardRow(3, 'VIPÈRE', 7200),
            _leaderboardRow(4, 'FAUCON', 5100),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE',
                style: GoogleFonts.orbitron(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _leaderboardRow(int rank, String name, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#$rank',
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(name,
                style:
                    const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Text('$score pts',
              style: const TextStyle(
                  color: Color(0xFFFFCC44), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildVersion() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'v1.0.0',
        style: const TextStyle(color: Colors.white24, fontSize: 10),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
