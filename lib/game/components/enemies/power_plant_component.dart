import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';

/// Power Plant — bonus target. When destroyed: blackout local effect,
/// nearby enemies lose ALERT state (become BLIND/IDLE temporarily).
class PowerPlantComponent extends EnemyComponent {
  PowerPlantComponent({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.powerPlant,
        );

  double _lightFlicker = 0.0;

  @override
  void onUpdate(double dt, bool canFire) {
    _lightFlicker += dt * 4;
  }

  @override
  void onKilled() {
    // Trigger blackout effect on nearby enemies
    game.onPowerPlantDestroyed(position, GameConfig.powerPlantBlackoutRadius);
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Building body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 2), width: 22, height: 16),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF5A5A5A),
    );

    // Roof
    canvas.drawRect(
      Rect.fromLTWH(cx - 12, cy - 8, 24, 3),
      Paint()..color = const Color(0xFF4A4A4A),
    );

    // Power lines / antenna
    canvas.drawLine(
      Offset(cx - 8, cy - 8),
      Offset(cx - 8, cy - 14),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(cx + 8, cy - 8),
      Offset(cx + 8, cy - 14),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1.5,
    );
    // Wire between poles
    canvas.drawLine(
      Offset(cx - 8, cy - 14),
      Offset(cx + 8, cy - 14),
      Paint()
        ..color = Colors.grey.shade500
        ..strokeWidth = 0.8,
    );

    // Electricity spark effect (animated)
    final sparkAlpha = (0.4 + 0.3 * math.sin(_lightFlicker)).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(cx, cy - 14),
      3,
      Paint()
        ..color = Colors.yellow.withValues(alpha: sparkAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Warning sign
    canvas.drawLine(
      Offset(cx - 3, cy + 2),
      Offset(cx + 3, cy + 2),
      Paint()
        ..color = Colors.yellow.shade700
        ..strokeWidth = 2,
    );
  }
}
