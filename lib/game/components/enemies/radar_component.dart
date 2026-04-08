import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';

/// Radar — reveals aircraft to nearby enemies, animated antenna.
/// When active: alertRange × 2 on all enemies in its radius.
/// Destroying it = bonus target (doesn't count for 80% ratio).
class RadarComponent extends EnemyComponent {
  RadarComponent({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.radar,
        );

  double _antennaAngle = 0.0;

  /// Returns true if the given enemy is within this radar's alert range.
  bool isInRange(EnemyComponent enemy) {
    return position.distanceTo(enemy.position) <= GameConfig.radarAlertRange;
  }

  @override
  void onUpdate(double dt, bool canFire) {
    // Animate antenna rotation
    _antennaAngle += dt * 2.0; // radians per second
    if (_antennaAngle > 2 * math.pi) _antennaAngle -= 2 * math.pi;
  }

  @override
  void onKilled() {
    game.onRadarDestroyed(this);
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Base
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 14, height: 6),
      Paint()..color = const Color(0xFF4A4A4A),
    );

    // Pole
    canvas.drawLine(
      Offset(cx, cy + 1),
      Offset(cx, cy - 6),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 2,
    );

    // Rotating antenna dish
    canvas.save();
    canvas.translate(cx, cy - 6);
    canvas.rotate(_antennaAngle);
    canvas.drawLine(
      const Offset(-8, 0),
      const Offset(8, 0),
      Paint()
        ..color = Colors.green.shade400
        ..strokeWidth = 1.5,
    );
    // Dish
    final dishPath = Path()
      ..moveTo(-6, -2)
      ..quadraticBezierTo(0, -5, 6, -2);
    canvas.drawPath(
      dishPath,
      Paint()
        ..color = Colors.green.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();

    // Pulsing detection ring (visual feedback)
    final alpha = (0.2 + 0.1 * math.sin(_antennaAngle * 3)).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(cx, cy),
      GameConfig.radarAlertRange * 0.15, // scaled for rendering
      Paint()
        ..color = Colors.green.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
