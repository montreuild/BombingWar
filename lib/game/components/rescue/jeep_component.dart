import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../bombing_war_game.dart';
import 'pilot_component.dart';

class JeepComponent extends PositionComponent {
  JeepComponent({required super.position, required this.game})
      : super(size: Vector2(40, 20), anchor: Anchor.center);

  final BombingWarGame game;
  final double speed = 80.0;

  @override
  void update(double dt) {
    super.update(dt);
    
    // Find the pilot
    final pilot = game.children.whereType<PilotComponent>().firstOrNull;
    if (pilot != null && pilot.isOnGround) {
      final direction = (pilot.position.x - position.x).sign;
      position.x += direction * speed * dt;

      // Kill pilot if close
      if (position.distanceTo(pilot.position) < 20) {
        pilot.die();
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey[800]!;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 5, 40, 15), const Radius.circular(4)), paint);
    canvas.drawRect(const Rect.fromLTWH(10, 0, 20, 10), paint); // Cabin
    
    final wheelPaint = Paint()..color = Colors.black;
    canvas.drawCircle(const Offset(8, 20), 4, wheelPaint);
    canvas.drawCircle(const Offset(32, 20), 4, wheelPaint);
  }
}
