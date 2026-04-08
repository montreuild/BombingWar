import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../game/managers/save_manager.dart';
import '../../models/level_data.dart';
import '../widgets/ad_banner_widget.dart';
import 'mission_briefing_screen.dart';

/// Animated mission debrief screen (military style, line by line).
class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({
    super.key,
    required this.report,
    required this.level,
    required this.saveManager,
  });

  final MissionReport report;
  final int level;
  final SaveManager saveManager;

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _visibleLines = 0;
  bool _allVisible = false;

  final List<_ReportLine> _lines = [];

  @override
  void initState() {
    super.initState();
    _buildReportLines();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _lines.length * 400),
    )..addListener(() {
        final newLines = (_controller.value * _lines.length).floor();
        if (newLines != _visibleLines) {
          setState(() => _visibleLines = newLines);
        }
      });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _allVisible = true);
      }
    });
    _controller.forward();
  }

  void _buildReportLines() {
    final r = widget.report;
    _lines.addAll([
      _ReportLine('MISSION ${widget.level}',
          r.missionSuccess ? 'SUCCÈS' : 'ÉCHEC',
          r.missionSuccess ? const Color(0xFF44FF88) : Colors.red),
      _ReportLine('RATING', r.rating,
          r.rating == 'EXCELLENT'
              ? Colors.amber
              : r.rating == 'GOOD'
                  ? const Color(0xFF44FF88)
                  : Colors.red),
      _ReportLine('', '', Colors.transparent), // spacer
      _ReportLine('Ennemis éliminés', '${r.enemiesKilled} / ${r.totalEnemies}',
          Colors.white),
      _ReportLine('Bunkers détruits', '${r.bunkersDestroyed}', Colors.white70),
      _ReportLine('Bunkers renforcés', '${r.reinforcedBunkersDestroyed}',
          Colors.white70),
      _ReportLine('Usines détruites', '${r.factoriesDestroyed}', Colors.white70),
      _ReportLine(
          'Cibles bonus', '${r.bonusTargetsDestroyed}', Colors.amber),
      _ReportLine('', '', Colors.transparent), // spacer
      _ReportLine('Drones interceptés', '${r.dronesIntercepted}',
          const Color(0xFF44CCFF)),
      _ReportLine('Drones échappés', '${r.dronesEscaped}', Colors.orange),
      _ReportLine('Lanceurs détruits', '${r.droneLaunchersDestroyed}',
          const Color(0xFF44CCFF)),
      _ReportLine('', '', Colors.transparent), // spacer
      _ReportLine('Pilotes éjectés', '${r.pilotsEjected}', Colors.white70),
      _ReportLine('Pilotes sauvés', '${r.pilotsSurvived}',
          const Color(0xFF44FF88)),
      _ReportLine('Avions perdus', '${r.planesLost}', Colors.red.shade300),
      _ReportLine('', '', Colors.transparent), // spacer
      _ReportLine('Gains bruts', '\$${r.dollarGross}', const Color(0xFF44FF44)),
      _ReportLine('Pénalités', '\$${r.dollarPenalties}', Colors.red),
      _ReportLine('', '', Colors.transparent), // spacer
      _ReportLine(
          'SCORE FINAL', '\$${r.dollarNet}', const Color(0xFFFFCC44)),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (!_allVisible) {
            _controller.forward(from: 1.0);
            setState(() {
              _visibleLines = _lines.length;
              _allVisible = true;
            });
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0A1A), Color(0xFF1A1A0A)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  widget.report.missionSuccess
                      ? 'MISSION COMPLETE'
                      : 'MISSION FAILED',
                  style: GoogleFonts.orbitron(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: widget.report.missionSuccess
                        ? const Color(0xFF44FF88)
                        : Colors.red,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                // Animated report lines
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    itemCount: _visibleLines.clamp(0, _lines.length),
                    itemBuilder: (context, i) {
                      final line = _lines[i];
                      if (line.label.isEmpty) {
                        return const SizedBox(height: 8);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              line.label,
                              style: GoogleFonts.orbitron(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                            Text(
                              line.value,
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: line.valueColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Buttons (shown only when all lines visible)
                if (_allVisible) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        if (widget.report.missionSuccess)
                          _buildButton(
                            context,
                            'PROCHAINE MISSION',
                            const Color(0xFF44FF88),
                            () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MissionBriefingScreen(
                                  saveManager: widget.saveManager,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        _buildButton(
                          context,
                          'MENU PRINCIPAL',
                          Colors.white38,
                          () => Navigator.of(context)
                              .popUntil((r) => r.isFirst),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const AdBannerWidget(),
              ],
            ),
          ),
        ),
      ),
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
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.orbitron(
              color: color, letterSpacing: 2, fontSize: 12),
        ),
      ),
    );
  }
}

class _ReportLine {
  const _ReportLine(this.label, this.value, this.valueColor);
  final String label;
  final String value;
  final Color valueColor;
}
