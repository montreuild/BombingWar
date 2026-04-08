import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';

/// Underground L1 Bunker — standard, takes 3 hits to destroy.
/// Passive target, no attack behavior.
class BunkerL1Component extends EnemyComponent {
  BunkerL1Component({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.bunkerL1,
        );

  @override
  void onUpdate(double dt, bool canFire) {
    // Passive — no behavior
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Underground bunker structure
    // Outer shell
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 18),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF5A5A4A),
    );

    // Inner chamber
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 12),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF3A3A2A),
    );

    // Armored top
    canvas.drawLine(
      Offset(cx - 12, cy - 9),
      Offset(cx + 12, cy - 9),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 3,
    );

    // Rivets
    for (double x = -8; x <= 8; x += 8) {
      canvas.drawCircle(
        Offset(cx + x, cy - 9),
        1.5,
        Paint()..color = Colors.grey.shade500,
      );
    }
  }
}
