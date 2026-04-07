import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/managers/save_manager.dart';
import '../../models/aircraft_data.dart';
import 'game_screen.dart';

/// Pre-mission briefing screen providing operational context for the conflict.
class MissionBriefingScreen extends StatelessWidget {
  const MissionBriefingScreen({
    super.key,
    required this.saveManager,
    required this.selectedAircraft,
  });

  final SaveManager saveManager;
  final AircraftData selectedAircraft;

  // Rotating mission objectives based on level number
  static const List<_MissionInfo> _missions = [
    _MissionInfo(
      codename: 'AURORE-1',
      objective: 'Neutraliser les positions avancées de la Garde du Croissant dans la zone Delta.',
      zone: 'ZONE DELTA — CÔTE OUEST',
      threat: 'MODÉRÉE',
      threatColor: Color(0xFF44FF88),
    ),
    _MissionInfo(
      codename: 'AURORE-2',
      objective: 'Détruire les lanceurs mobiles Shahine avant le tir préventif. Fenêtre : 4 minutes.',
      zone: 'ZONE SIERRA — PLAINE CENTRALE',
      threat: 'ÉLEVÉE',
      threatColor: Color(0xFFFFCC44),
    ),
    _MissionInfo(
      codename: 'AURORE-3',
      objective: 'Supprimer les défenses anti-aériennes et ouvrir un corridor pour les bombardiers lourds.',
      zone: 'ZONE KILO — COULOIR NORD',
      threat: 'ÉLEVÉE',
      threatColor: Color(0xFFFFCC44),
    ),
    _MissionInfo(
      codename: 'AURORE-4',
      objective: 'Détruire le Site Fortifié souterrain. Seul le Fantôme SR-X peut percer les couches de béton.',
      zone: 'ZONE OMÉGA — PROFONDEUR ENNEMIE',
      threat: 'CRITIQUE',
      threatColor: Color(0xFFFF4444),
    ),
    _MissionInfo(
      codename: 'AURORE-5',
      objective: 'Éliminer les renforts de la Garde du Croissant. Empêcher leur consolidation au sol.',
      zone: 'ZONE ALPHA — FRONT ACTIF',
      threat: 'MODÉRÉE',
      threatColor: Color(0xFF44FF88),
    ),
  ];

  _MissionInfo get _currentMission {
    final level = saveManager.progress.currentLevel;
    return _missions[level % _missions.length];
  }

  @override
  Widget build(BuildContext context) {
    final mission = _currentMission;
    final level = saveManager.progress.currentLevel;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050F14), Color(0xFF0A1A20), Color(0xFF060C10)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(mission, level),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildSection('ZONE D\'OPÉRATION', mission.zone),
                const SizedBox(height: 16),
                _buildSection('OBJECTIF', mission.objective),
                const SizedBox(height: 16),
                _buildThreatRow(mission),
                const SizedBox(height: 16),
                _buildSection('APPAREIL ASSIGNÉ', selectedAircraft.name),
                const Spacer(),
                _buildDivider(),
                const SizedBox(height: 8),
                _buildIntelNote(),
                const SizedBox(height: 20),
                _buildLaunchButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_MissionInfo mission, int level) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ALLIANCE OCCIDENTALE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: const Color(0xFF44AAFF),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'BRIEFING — ${mission.codename}',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFB800),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'NIV. $level',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFFFFB800), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 9,
            color: Colors.white38,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 13,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildThreatRow(_MissionInfo mission) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NIVEAU DE MENACE',
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  color: Colors.white38,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mission.threat,
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: mission.threatColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ENNEMI',
              style: GoogleFonts.orbitron(
                fontSize: 9,
                color: Colors.white38,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'GARDE DU CROISSANT',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                color: const Color(0xFFFF6644),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntelNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFFCC44), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Les Sites Fortifiés ne peuvent être détruits que par le Perforateur GBU-28 du Fantôme SR-X.',
              style: GoogleFonts.orbitron(
                fontSize: 9,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB800),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
              saveManager: saveManager,
              selectedAircraft: selectedAircraft,
            ),
          ),
        ),
        child: Text(
          'LANCER LA MISSION',
          style: GoogleFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}

class _MissionInfo {
  const _MissionInfo({
    required this.codename,
    required this.objective,
    required this.zone,
    required this.threat,
    required this.threatColor,
  });

  final String codename;
  final String objective;
  final String zone;
  final String threat;
  final Color threatColor;
}
