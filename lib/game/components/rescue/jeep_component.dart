import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';
import 'pilot_component.dart';

/// Enemy jeep that hunts ejected pilot.
/// Collision jeep × pilot → kidnapping → Game Over immédiat.
class JeepComponent extends PositionComponent {
  JeepComponent({required super.position, required this.game})
      : super(size: Vector2(40, 20), anchor: Anchor.center);

  final BombingWarGame game;

  @override
  void update(double dt) {
    super.update(dt);

    // Find the active pilot
    final pilot = game.activePilot;
    if (pilot != null && pilot.isOnGround) {
      final direction = (pilot.position.x - position.x).sign;
      position.x += direction * GameConfig.jeepSpeed * GameConfig.huntPilotSpeedMultiplier * dt;

      // Kidnap pilot if close
      if (position.distanceTo(pilot.position) < 20) {
        pilot.kidnapped();
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey[800]!;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 5, 40, 15), const Radius.circular(4)),
        paint);
    canvas.drawRect(const Rect.fromLTWH(10, 0, 20, 10), paint); // Cabin

    final wheelPaint = Paint()..color = Colors.black;
    canvas.drawCircle(const Offset(8, 20), 4, wheelPaint);
    canvas.drawCircle(const Offset(32, 20), 4, wheelPaint);
  }
}
