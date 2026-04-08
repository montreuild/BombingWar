import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';

/// Fortification — absorbs multiple hits, bonus target.
class FortificationComponent extends EnemyComponent {
  FortificationComponent({
    required BombingWarGame game,
    required Vector2 position,
  }) : super(
          game: game,
          position: position,
          enemyData: EnemyData.fortification,
        );

  @override
  void onUpdate(double dt, bool canFire) {
    // Static defensive structure — no behavior
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Thick concrete walls
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 20),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF6A6A5A),
    );

    // Sandbag top
    for (int i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - 8 + i * 8.0, cy - 10),
          width: 10,
          height: 6,
        ),
        Paint()..color = const Color(0xFF9A8A60),
      );
    }

    // Dark interior
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 22, height: 10),
      Paint()..color = const Color(0xFF3A3A2A),
    );

    // Gun slit
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - 3), width: 8, height: 2),
      Paint()..color = Colors.black,
    );
  }
}
