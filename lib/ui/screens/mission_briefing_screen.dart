import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../game/managers/save_manager.dart';
import '../../models/aircraft_data.dart';
import 'game_screen.dart';

/// Pre-mission briefing screen with conflict narrative and character cards.
class MissionBriefingScreen extends StatelessWidget {
  const MissionBriefingScreen({
    super.key,
    required this.saveManager,
    required this.selectedAircraft,
  });

  final SaveManager saveManager;
  final AircraftData selectedAircraft;

  static const List<_MissionInfo> _missions = [
    _MissionInfo(
      codename: 'EPIC COLLAPSE — ALPHA',
      objective: 'Neutraliser les positions avancées de la Garde du Croissant dans la zone Delta.',
      zone: 'ZONE DELTA — CÔTE OUEST',
      threat: 'MODÉRÉE',
      threatColor: Color(0xFF44FF88),
      vsGuard: true,
    ),
    _MissionInfo(
      codename: 'EPIC COLLAPSE — BRAVO',
      objective: 'Détruire les lanceurs mobiles avant le tir préventif. Fenêtre : 4 minutes.',
      zone: 'ZONE SIERRA — PLAINE CENTRALE',
      threat: 'ÉLEVÉE',
      threatColor: Color(0xFFFFCC44),
      vsGuard: true,
    ),
    _MissionInfo(
      codename: 'EPIC COLLAPSE — CHARLIE',
      objective: 'Supprimer les défenses anti-aériennes et ouvrir un corridor pour les bombardiers lourds.',
      zone: 'ZONE KILO — COULOIR NORD',
      threat: 'ÉLEVÉE',
      threatColor: Color(0xFFFFCC44),
      vsGuard: false,
    ),
    _MissionInfo(
      codename: 'EPIC COLLAPSE — DELTA',
      objective: 'Détruire le Site Fortifié souterrain. Seul le Stealth X-26 peut percer les couches de béton.',
      zone: 'ZONE OMÉGA — PROFONDEUR ENNEMIE',
      threat: 'CRITIQUE',
      threatColor: Color(0xFFFF4444),
      vsGuard: true,
    ),
    _MissionInfo(
      codename: 'EPIC COLLAPSE — ECHO',
      objective: 'Éliminer les renforts de la Garde du Croissant. Empêcher leur consolidation au sol.',
      zone: 'ZONE ALPHA — FRONT ACTIF',
      threat: 'MODÉRÉE',
      threatColor: Color(0xFF44FF88),
      vsGuard: true,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(mission, level),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                // Character cards
                _buildCharacterRow(mission),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildSection('ZONE D\'OPÉRATION', mission.zone),
                const SizedBox(height: 12),
                _buildSection('OBJECTIF', mission.objective),
                const SizedBox(height: 12),
                _buildThreatRow(mission),
                const SizedBox(height: 12),
                _buildSection('APPAREIL ASSIGNÉ', selectedAircraft.name),
                const SizedBox(height: 16),
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

  // ---------------------------------------------------------------------------
  // Character row
  // ---------------------------------------------------------------------------

  Widget _buildCharacterRow(_MissionInfo mission) {
    return Row(
      children: [
        const Expanded(child: _WesternLeaderCard()),
        const SizedBox(width: 12),
        Expanded(
          child: mission.vsGuard
              ? const _GuardSoldierCard()
              : const _NeutralCard(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

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
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFB800),
                  letterSpacing: 1,
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
            style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white54),
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
              fontSize: 9, color: Colors.white38, letterSpacing: 3),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
              fontSize: 12, color: Colors.white, letterSpacing: 0.5),
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
              Text('NIVEAU DE MENACE',
                  style: GoogleFonts.orbitron(
                      fontSize: 9, color: Colors.white38, letterSpacing: 3)),
              const SizedBox(height: 4),
              Text(mission.threat,
                  style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: mission.threatColor,
                      letterSpacing: 1)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENNEMI',
                style: GoogleFonts.orbitron(
                    fontSize: 9, color: Colors.white38, letterSpacing: 3)),
            const SizedBox(height: 4),
            Text('GARDE DU CROISSANT',
                style: GoogleFonts.orbitron(
                    fontSize: 11,
                    color: const Color(0xFFFF6644),
                    letterSpacing: 1)),
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
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFFCC44), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Les Sites Fortifiés ne peuvent être détruits que par le GBU-28 Bunker Buster du B-21 Raider.',
              style: GoogleFonts.orbitron(
                  fontSize: 9, color: Colors.white54, letterSpacing: 0.5),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 3),
        ),
      ),
    );
  }
}

// =============================================================================
// Western Leader card — muscular man in suit, blond hair, blue eyes
// =============================================================================

class _WesternLeaderCard extends StatelessWidget {
  const _WesternLeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E30),
        border: Border.all(color: const Color(0xFF44AAFF).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 90,
            child: CustomPaint(painter: _WesternLeaderPainter()),
          ),
          const SizedBox(height: 8),
          // Speech bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A55),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: const Color(0xFF44AAFF).withValues(alpha: 0.3)),
            ),
            child: Text(
              '"God Bless Me!"',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 9,
                color: const Color(0xFF44AAFF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'COMMANDANT\nDE L\'ALLIANCE',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
                fontSize: 7, color: Colors.white38, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

/// Draws a muscular blond-haired, blue-eyed man in a dark suit.
class _WesternLeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // --- Body / suit (wide trapezoid = muscular) ---
    final suitPaint = Paint()..color = const Color(0xFF1A2A4A);
    final suitPath = Path()
      ..moveTo(cx - 28, size.height)
      ..lineTo(cx + 28, size.height)
      ..lineTo(cx + 20, size.height * 0.55)
      ..lineTo(cx - 20, size.height * 0.55)
      ..close();
    canvas.drawPath(suitPath, suitPaint);

    // Suit lapels
    final lapelPaint = Paint()..color = const Color(0xFF0D1A30);
    canvas.drawPath(
      Path()
        ..moveTo(cx, size.height * 0.58)
        ..lineTo(cx - 10, size.height * 0.55)
        ..lineTo(cx - 5, size.height * 0.72)
        ..close(),
      lapelPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, size.height * 0.58)
        ..lineTo(cx + 10, size.height * 0.55)
        ..lineTo(cx + 5, size.height * 0.72)
        ..close(),
      lapelPaint,
    );

    // Tie (red — patriotic)
    final tiePaint = Paint()..color = const Color(0xFFCC2222);
    canvas.drawPath(
      Path()
        ..moveTo(cx, size.height * 0.58)
        ..lineTo(cx - 4, size.height * 0.62)
        ..lineTo(cx, size.height * 0.82)
        ..lineTo(cx + 4, size.height * 0.62)
        ..close(),
      tiePaint,
    );

    // Neck
    final skinPaint = Paint()..color = const Color(0xFFE8C49A);
    canvas.drawRect(
      Rect.fromLTWH(cx - 6, size.height * 0.46, 12, size.height * 0.12),
      skinPaint,
    );

    // --- Head ---
    const headRadius = 18.0;
    final headCenter = Offset(cx, size.height * 0.28);
    canvas.drawCircle(headCenter, headRadius, skinPaint);

    // Blond hair (top + sides)
    final hairPaint = Paint()..color = const Color(0xFFFFD700);
    // Top hair sweep
    canvas.drawPath(
      Path()
        ..addArc(
          Rect.fromCircle(center: headCenter, radius: headRadius + 2),
          math.pi * 1.1,
          math.pi * 0.8,
        )
        ..lineTo(headCenter.dx + 4, headCenter.dy - headRadius - 4)
        ..lineTo(headCenter.dx - 4, headCenter.dy - headRadius - 4)
        ..close(),
      hairPaint,
    );
    // Side hair puffs
    canvas.drawOval(
      Rect.fromLTWH(
          headCenter.dx - headRadius - 5, headCenter.dy - 8, 10, 14),
      hairPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(headCenter.dx + headRadius - 5, headCenter.dy - 8, 10, 14),
      hairPaint,
    );

    // Blue eyes
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyePaint = Paint()..color = const Color(0xFF3A8FE8);
    final pupilPaint = Paint()..color = Colors.black;
    for (final double dx in [-6.0, 6.0]) {
      canvas.drawCircle(
          Offset(headCenter.dx + dx, headCenter.dy - 2), 4, eyeWhitePaint);
      canvas.drawCircle(
          Offset(headCenter.dx + dx, headCenter.dy - 2), 2.5, eyePaint);
      canvas.drawCircle(
          Offset(headCenter.dx + dx, headCenter.dy - 2), 1.2, pupilPaint);
    }

    // Eyebrows (blond)
    final browPaint = Paint()
      ..color = const Color(0xFFCCAA00)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(headCenter.dx - 9, headCenter.dy - 7),
      Offset(headCenter.dx - 3, headCenter.dy - 8),
      browPaint,
    );
    canvas.drawLine(
      Offset(headCenter.dx + 3, headCenter.dy - 8),
      Offset(headCenter.dx + 9, headCenter.dy - 7),
      browPaint,
    );

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(headCenter.dx, headCenter.dy + 4),
          width: 12,
          height: 6),
      0,
      math.pi,
      false,
      smilePaint,
    );

    // Muscular shoulders / arms
    final musclePaint = Paint()..color = const Color(0xFF253A5E);
    canvas.drawOval(
      Rect.fromLTWH(cx - 36, size.height * 0.52, 18, 24),
      musclePaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(cx + 18, size.height * 0.52, 18, 24),
      musclePaint,
    );

    // Stars on suit (American flag vibes)
    final starPaint = Paint()..color = const Color(0xFFFFDD44);
    _drawStar(canvas, Offset(cx - 12, size.height * 0.65), 3, starPaint);
    _drawStar(canvas, Offset(cx + 12, size.height * 0.65), 3, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final inner = r * 0.4;
      final outerPt = Offset(
          center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      final innerAngle = angle + math.pi / 5;
      final innerPt = Offset(center.dx + inner * math.cos(innerAngle),
          center.dy + inner * math.sin(innerAngle));
      if (i == 0) {
        path.moveTo(outerPt.dx, outerPt.dy);
      } else {
        path.lineTo(outerPt.dx, outerPt.dy);
      }
      path.lineTo(innerPt.dx, innerPt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// Guard Soldier card — military uniform, black headband
// =============================================================================

class _GuardSoldierCard extends StatelessWidget {
  const _GuardSoldierCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A0A),
        border: Border.all(color: const Color(0xFFFF4444).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 90,
            child: CustomPaint(painter: _GuardSoldierPainter()),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A0A0A),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: const Color(0xFFFF4444).withValues(alpha: 0.3)),
            ),
            child: Text(
              '"The virgins are\nwaiting for you!"',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 8,
                color: const Color(0xFFFF6644),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'GARDE DU\nCROISSANT',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
                fontSize: 7, color: Colors.white38, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

/// Draws a soldier in military uniform with a black headband.
class _GuardSoldierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // --- Body / military uniform ---
    final uniformPaint = Paint()..color = const Color(0xFF2D3A1E);
    final bodyPath = Path()
      ..moveTo(cx - 22, size.height)
      ..lineTo(cx + 22, size.height)
      ..lineTo(cx + 16, size.height * 0.55)
      ..lineTo(cx - 16, size.height * 0.55)
      ..close();
    canvas.drawPath(bodyPath, uniformPaint);

    // Uniform details — pockets
    final detailPaint = Paint()..color = const Color(0xFF1E2A12);
    canvas.drawRect(
        Rect.fromLTWH(cx - 14, size.height * 0.62, 8, 7), detailPaint);
    canvas.drawRect(
        Rect.fromLTWH(cx + 6, size.height * 0.62, 8, 7), detailPaint);

    // Belt
    final beltPaint = Paint()..color = const Color(0xFF5C4A1A);
    canvas.drawRect(
        Rect.fromLTWH(cx - 16, size.height * 0.75, 32, 5), beltPaint);
    // Belt buckle
    canvas.drawRect(
        Rect.fromLTWH(cx - 4, size.height * 0.75, 8, 5),
        Paint()..color = const Color(0xFFAA8833));

    // Neck
    final skinPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawRect(
      Rect.fromLTWH(cx - 5, size.height * 0.46, 10, size.height * 0.12),
      skinPaint,
    );

    // --- Head ---
    const headRadius = 17.0;
    final headCenter = Offset(cx, size.height * 0.28);
    canvas.drawCircle(headCenter, headRadius, skinPaint);

    // Dark hair
    final hairPaint = Paint()..color = const Color(0xFF1A1008);
    canvas.drawPath(
      Path()
        ..addArc(
          Rect.fromCircle(center: headCenter, radius: headRadius),
          math.pi * 1.1,
          math.pi * 0.8,
        )
        ..lineTo(headCenter.dx + 3, headCenter.dy - headRadius)
        ..lineTo(headCenter.dx - 3, headCenter.dy - headRadius)
        ..close(),
      hairPaint,
    );

    // BLACK HEADBAND — key detail
    final headbandPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawPath(
      Path()
        ..addArc(
          Rect.fromCircle(center: headCenter, radius: headRadius - 1),
          math.pi * 1.05,
          math.pi * 0.9,
        )
        ..arcTo(
          Rect.fromCircle(center: headCenter, radius: headRadius + 3),
          math.pi * 0.05,
          -math.pi * 0.9,
          false,
        )
        ..close(),
      headbandPaint,
    );
    // Headband knot/tail on the side
    canvas.drawOval(
      Rect.fromLTWH(headCenter.dx + headRadius - 2, headCenter.dy - 6, 8, 5),
      headbandPaint,
    );
    // Arabic-style script hint on headband (decorative lines)
    final scriptPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(headCenter.dx - 9, headCenter.dy - headRadius + 1),
      Offset(headCenter.dx + 9, headCenter.dy - headRadius + 1),
      scriptPaint,
    );

    // Eyes (dark, intense)
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyePaint = Paint()..color = const Color(0xFF2A1A08);
    for (final double dx in [-5.5, 5.5]) {
      canvas.drawCircle(
          Offset(headCenter.dx + dx, headCenter.dy - 1), 3.5, eyeWhitePaint);
      canvas.drawCircle(
          Offset(headCenter.dx + dx, headCenter.dy - 1), 2.2, eyePaint);
    }

    // Eyebrows (dark, furrowed)
    final browPaint = Paint()
      ..color = const Color(0xFF1A1008)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(headCenter.dx - 9, headCenter.dy - 6),
      Offset(headCenter.dx - 3, headCenter.dy - 8),
      browPaint,
    );
    canvas.drawLine(
      Offset(headCenter.dx + 3, headCenter.dy - 8),
      Offset(headCenter.dx + 9, headCenter.dy - 6),
      browPaint,
    );

    // Beard stubble
    final beardPaint = Paint()..color = const Color(0xFF2A1A08).withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(headCenter.dx, headCenter.dy + 6), width: 18, height: 8),
      beardPaint,
    );

    // Shoulders
    final shoulderPaint = Paint()..color = const Color(0xFF243018);
    canvas.drawOval(
        Rect.fromLTWH(cx - 30, size.height * 0.52, 16, 20), shoulderPaint);
    canvas.drawOval(
        Rect.fromLTWH(cx + 14, size.height * 0.52, 16, 20), shoulderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// Neutral card — shown when mission doesn't involve the Guard directly
// =============================================================================

class _NeutralCard extends StatelessWidget {
  const _NeutralCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Icon(Icons.radar, color: Colors.white24, size: 40),
          const SizedBox(height: 16),
          Text(
            'ZONE\nSÉCURISÉE',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
                fontSize: 9, color: Colors.white24, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// =============================================================================
// Data model
// =============================================================================

class _MissionInfo {
  const _MissionInfo({
    required this.codename,
    required this.objective,
    required this.zone,
    required this.threat,
    required this.threatColor,
    required this.vsGuard,
  });

  final String codename;
  final String objective;
  final String zone;
  final String threat;
  final Color threatColor;
  final bool vsGuard;
}
