import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';
import 'pilot_component.dart';

class RescueHelicopterComponent extends PositionComponent {
  RescueHelicopterComponent({required this.game})
      : super(size: Vector2(60, 30), anchor: Anchor.center);

  final BombingWarGame game;
  bool isHovering = false;
  bool isDeparting = false;
  double _hoverTimer = 0.0;
  final double speed = 120.0;

  @override
  void update(double dt) {
    super.update(dt);
    
    final pilot = game.worldChildren.whereType<PilotComponent>().firstOrNull;
    if (pilot == null) {
       // Pilot gone (killed or rescued already?), fly away
       position.x += speed * dt;
       position.y -= speed * 0.2 * dt;
       if (position.x > GameConfig.worldWidth + 100) removeFromParent();
       return;
    }

    if (!isHovering && !isDeparting) {
      // Fly towards pilot
      final target = Vector2(pilot.position.x, GameConfig.groundLevel - 60);
      final dir = (target - position).normalized();
      position += dir * speed * dt;
      
      if (position.distanceTo(target) < 5) {
        isHovering = true;
      }
    } else if (isHovering) {
      _hoverTimer += dt;
      if (_hoverTimer >= 2.0) {
        isHovering = false;
        isDeparting = true;
        pilot.removeFromParent(); // Pilot "enters" helicopter
        game.onPilotRescued();
      }
    } else if (isDeparting) {
      position.x -= speed * dt;
      position.y -= speed * 0.5 * dt;
      if (position.x < -100) removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = Colors.blueGrey[700]!;
    // Fuselage
    canvas.drawOval(const Rect.fromLTWH(0, 5, 45, 20), bodyPaint);
    // Tail
    canvas.drawRect(const Rect.fromLTWH(40, 10, 20, 5), bodyPaint);
    // Rotor
    final rotorPaint = Paint()..color = Colors.black..strokeWidth = 2;
    final rotorAnim = (DateTime.now().millisecondsSinceEpoch % 100) / 100;
    canvas.drawLine(const Offset(22, 5), const Offset(22, 0), rotorPaint);
    canvas.save();
    canvas.translate(22, 0);
    canvas.rotate(rotorAnim * 6.28);
    canvas.drawLine(const Offset(-25, 0), const Offset(25, 0), rotorPaint);
    canvas.restore();
  }
}
