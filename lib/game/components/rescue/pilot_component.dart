import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

class PilotComponent extends PositionComponent {
  PilotComponent({required Vector2 position, required this.game})
      : super(position: position, size: Vector2(20, 20), anchor: Anchor.center);

  final BombingWarGame game;
  bool isOnGround = false;
  final double _fallSpeed = 50.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isOnGround) {
      position.y += _fallSpeed * dt;
      if (position.y >= GameConfig.groundLevel - 10) {
        position.y = GameConfig.groundLevel - 10;
        isOnGround = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isOnGround) {
      // Parachute
      final parachutePaint = Paint()..color = Colors.white;
      canvas.drawArc(Rect.fromLTWH(-10, -25, 40, 30), 3.14, 3.14, true, parachutePaint);
      canvas.drawLine(const Offset(10, -10), const Offset(0, 0), Paint()..color = Colors.grey);
      canvas.drawLine(const Offset(10, -10), const Offset(20, 0), Paint()..color = Colors.grey);
    }

    // Pilot body
    canvas.drawCircle(const Offset(10, 10), 5, Paint()..color = Colors.orange);
    canvas.drawRect(const Rect.fromLTWH(7, 15, 6, 8), Paint()..color = Colors.green);
  }

  void die() {
    game.spawnExplosion(position);
    removeFromParent();
    game.onPilotKilled();
  }
}
