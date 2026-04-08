import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../projectiles/bullet_component.dart';
import 'enemy_component.dart';

/// Light infantry unit that pops from cover and fires bullets upward.
class InfantryComponent extends EnemyComponent {
  InfantryComponent({required super.game, required super.position})
      : super(enemyData: EnemyData.infantry);

  // Patrol movement
  double _moveTimer = 0.0;
  Vector2 _moveDir = Vector2(1, 0);

  @override
  void onUpdate(double dt, bool canFire) {
    // Slow lateral patrol along the ground
    _moveTimer += dt;
    if (_moveTimer > 2.0) {
      _moveDir = Vector2(-_moveDir.x, 0);
      _moveTimer = 0;
    }
    position.x += _moveDir.x * enemyData.speed * dt;

    // Stay on the ground surface
    position.x = position.x.clamp(
        GameConfig.spawnMargin,
        GameConfig.worldWidth - GameConfig.spawnMargin);
    position.y = GameConfig.groundLevel - enemyData.size / 2;

    if (canFire && game.playerAircraft != null) {
      _fireBullet();
      resetFireCooldown(GameConfig.infantryFireCooldown);
    }
  }

  void _fireBullet() {
    // Aim loosely toward player
    final player = game.playerAircraft!;
    final dir = (player.position - position).normalized();
    game.add(BulletComponent(
      position: position.clone(),
      direction: dir,
      damage: enemyData.damage,
      isPlayerProjectile: false,
    ));
  }

  @override
  void onRender(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF4B5320); // Army Green
    final skinPaint = Paint()..color = const Color(0xFFFFDBAC);
    final blackPaint = Paint()..color = Colors.black;

    // Head & Helmet
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.3), 5, skinPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.x * 0.5, size.y * 0.3), radius: 6), -3.14, 3.14, true, bodyPaint);
    
    // Body (Torso)
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.x * 0.35, size.y * 0.45, 8, 12), const Radius.circular(2)), bodyPaint);
    
    // Legs
    canvas.drawRect(Rect.fromLTWH(size.x * 0.4, size.y * 0.7, 3, 6), bodyPaint);
    canvas.drawRect(Rect.fromLTWH(size.x * 0.55, size.y * 0.7, 3, 6), bodyPaint);

    // Rifle
    canvas.save();
    canvas.translate(size.x * 0.5, size.y * 0.55);
    final rifleAngle = _moveDir.x > 0 ? 0.2 : -0.2;
    canvas.rotate(rifleAngle);
    canvas.drawRect(const Rect.fromLTWH(0, -1, 15, 3), blackPaint);
    canvas.restore();
  }
}
