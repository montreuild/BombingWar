import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';

/// Reinforced Bunker (Underground L2) — GBU-57 only.
/// Other weapons show "BLINDÉ" feedback with zero damage.
class ReinforcedBunkerL2Component extends EnemyComponent {
  ReinforcedBunkerL2Component({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.reinforcedBunkerL2,
        );

  @override
  bool get requiresGBU => true;

  @override
  void onUpdate(double dt, bool canFire) {
    // Passive — deep underground, no behavior
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Heavy reinforced structure
    // Outer shell (thick armor)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 34, height: 22),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF4A4A4A),
    );

    // Armor plating lines
    final platePaint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double dx = -12; dx <= 12; dx += 8) {
      canvas.drawLine(
        Offset(cx + dx, cy - 10),
        Offset(cx + dx, cy + 10),
        platePaint,
      );
    }

    // Inner vault
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 14),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF2A2A1A),
    );

    // Armored top (double thickness)
    canvas.drawLine(
      Offset(cx - 16, cy - 11),
      Offset(cx + 16, cy - 11),
      Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 4,
    );

    // Heavy rivets
    for (double x = -12; x <= 12; x += 6) {
      canvas.drawCircle(
        Offset(cx + x, cy - 11),
        2,
        Paint()..color = Colors.grey.shade600,
      );
    }

    // Warning symbol ("BLINDÉ" indicator)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: 8, height: 8),
      Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
