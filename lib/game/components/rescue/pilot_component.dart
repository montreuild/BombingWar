import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

class PilotComponent extends PositionComponent {
  PilotComponent({required Vector2 position, required this.game})
      : super(position: position, size: Vector2(20, 20), anchor: Anchor.center);

  final BombingWarGame game;
  bool isOnGround = false;
  final double _fallSpeed = 40.0;
  double _swingTimer = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isOnGround) {
      _swingTimer += dt * 2;
      // Slight swaying while falling
      position.x += math.sin(_swingTimer) * 10 * dt;
      position.y += _fallSpeed * dt;
      
      if (position.y >= GameConfig.groundLevel - 15) {
        position.y = GameConfig.groundLevel - 15;
        isOnGround = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF556644); // Flight suit
    final skinPaint = Paint()..color = const Color(0xFFFFDBAC);
    final helmetPaint = Paint()..color = Colors.white;
    final linePaint = Paint()..color = Colors.white70..strokeWidth = 1.0;

    if (!isOnGround) {
      // Parachute canopy
      final parachutePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(10, -20), width: 40, height: 25),
        3.14, 3.14, true, parachutePaint
      );
      
      // Parachute lines
      canvas.drawLine(const Offset(-10, -20), const Offset(10, 5), linePaint);
      canvas.drawLine(const Offset(30, -20), const Offset(10, 5), linePaint);
    }

    // Pilot body
    // Head & Helmet
    canvas.drawCircle(const Offset(10, 5), 4, skinPaint);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(10, 5), radius: 5),
      -3.14, 3.14, true, helmetPaint
    );
    // Visor
    canvas.drawRect(const Rect.fromLTWH(8, 3, 5, 2), Paint()..color = Colors.black54);
    
    // Torso (Flight suit)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(6, 9, 8, 10), const Radius.circular(2)),
      bodyPaint
    );
    
    // Legs
    canvas.drawRect(const Rect.fromLTWH(7, 19, 2, 4), bodyPaint);
    canvas.drawRect(const Rect.fromLTWH(11, 19, 2, 4), bodyPaint);

    // If on ground, draw a small white crumpled parachute next to him
    if (isOnGround) {
      canvas.drawOval(
        const Rect.fromLTWH(18, 18, 15, 6),
        Paint()..color = Colors.white.withValues(alpha: 0.6)
      );
    }
  }

  void die() {
    game.spawnExplosion(position);
    removeFromParent();
    game.onPilotKilled();
  }
}
