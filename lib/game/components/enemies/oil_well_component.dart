import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';

/// Oil Well — bonus target, explodes with persistent fire + smoke.
class OilWellComponent extends EnemyComponent {
  OilWellComponent({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.oilWell,
        );

  double _pumpAngle = 0.0;

  @override
  void onUpdate(double dt, bool canFire) {
    // Animate oil pump
    _pumpAngle += dt * 1.5;
  }

  @override
  void onKilled() {
    // Spawn persistent fire effect
    game.spawnPersistentFire(position);
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Oil derrick frame
    final framePaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // A-frame structure
    canvas.drawLine(Offset(cx - 6, cy + 8), Offset(cx, cy - 8), framePaint);
    canvas.drawLine(Offset(cx + 6, cy + 8), Offset(cx, cy - 8), framePaint);
    canvas.drawLine(Offset(cx - 5, cy), Offset(cx + 5, cy), framePaint);
    canvas.drawLine(Offset(cx - 3, cy - 4), Offset(cx + 3, cy - 4), framePaint);

    // Pump arm (animated)
    canvas.save();
    canvas.translate(cx, cy - 8);
    final pumpY = math.sin(_pumpAngle) * 3;
    canvas.drawLine(
      Offset.zero,
      Offset(8, pumpY),
      Paint()
        ..color = Colors.grey.shade800
        ..strokeWidth = 2,
    );
    canvas.restore();

    // Base platform
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 9), width: 16, height: 4),
      Paint()..color = const Color(0xFF3A3A3A),
    );
  }
}
