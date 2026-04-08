import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';
import '../projectiles/bullet_component.dart';

/// Pilot ejection component.
/// Falls with parachute (gravity + drift), lands on ground.
/// On ground: auto-fires pistol at enemies in range.
/// Enemies enter HUNT_PILOT state.
/// Collision jeep × pilot → kidnapping → Game Over.
class PilotComponent extends PositionComponent {
  PilotComponent({required Vector2 position, required this.game})
      : super(position: position, size: Vector2(20, 20), anchor: Anchor.center);

  final BombingWarGame game;
  bool isOnGround = false;
  double _swingTimer = 0.0;
  double _pistolCooldown = 0.0;
  double _velocityY = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isOnGround) {
      _swingTimer += dt * 2;

      // Parachute physics: gravity + drift
      _velocityY += GameConfig.pilotGravity * dt;
      // Parachute drag limits fall speed
      _velocityY = _velocityY.clamp(0, 60.0);

      position.y += _velocityY * dt;
      position.x += math.sin(_swingTimer) * GameConfig.pilotDrift * dt;

      if (position.y >= GameConfig.groundLevel - 15) {
        position.y = GameConfig.groundLevel - 15;
        isOnGround = true;
        _velocityY = 0;
      }
    } else {
      // On ground: auto-fire pistol at nearby enemies
      _pistolCooldown -= dt;
      if (_pistolCooldown <= 0) {
        _tryFirePistol();
      }
    }
  }

  void _tryFirePistol() {
    // Find nearest enemy in pistol range
    final nearestEnemy = game.findNearestEnemyInRange(
      position,
      GameConfig.pilotPistolRange,
    );
    if (nearestEnemy != null) {
      final dir = (nearestEnemy.position - position).normalized();
      game.addToWorld(BulletComponent(
        position: position.clone(),
        direction: dir,
        damage: GameConfig.pilotPistolDamage,
        isPlayerProjectile: true,
      ));
      _pistolCooldown = GameConfig.pilotPistolCooldown;
    }
  }

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF556644);
    final skinPaint = Paint()..color = const Color(0xFFFFDBAC);
    final helmetPaint = Paint()..color = Colors.white;
    final linePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.0;

    if (!isOnGround) {
      // Parachute canopy
      final parachutePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawArc(
          Rect.fromCenter(
              center: const Offset(10, -20), width: 40, height: 25),
          3.14,
          3.14,
          true,
          parachutePaint);

      // Parachute lines
      canvas.drawLine(const Offset(-10, -20), const Offset(10, 5), linePaint);
      canvas.drawLine(const Offset(30, -20), const Offset(10, 5), linePaint);
    }

    // Pilot body
    canvas.drawCircle(const Offset(10, 5), 4, skinPaint);
    canvas.drawArc(Rect.fromCircle(center: const Offset(10, 5), radius: 5),
        -3.14, 3.14, true, helmetPaint);
    // Visor
    canvas.drawRect(
        const Rect.fromLTWH(8, 3, 5, 2), Paint()..color = Colors.black54);

    // Torso
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(6, 9, 8, 10), const Radius.circular(2)),
        bodyPaint);

    // Legs
    canvas.drawRect(const Rect.fromLTWH(7, 19, 2, 4), bodyPaint);
    canvas.drawRect(const Rect.fromLTWH(11, 19, 2, 4), bodyPaint);

    // Pistol (visible when on ground)
    if (isOnGround) {
      canvas.drawLine(
        const Offset(14, 12),
        const Offset(20, 10),
        Paint()
          ..color = Colors.grey.shade700
          ..strokeWidth = 1.5,
      );

      // Crumpled parachute
      canvas.drawOval(
          const Rect.fromLTWH(18, 18, 15, 6),
          Paint()..color = Colors.white.withValues(alpha: 0.6));
    }
  }

  /// Called when a jeep reaches the pilot → kidnapping → Game Over.
  void kidnapped() {
    game.scoreSystem.registerPilotCaptured();
    game.onPilotKilled();
    removeFromParent();
  }

  void die() {
    game.spawnExplosion(position);
    removeFromParent();
    game.onPilotKilled();
  }
}
