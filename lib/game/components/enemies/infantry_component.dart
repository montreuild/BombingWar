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
    // Slow lateral patrol
    _moveTimer += dt;
    if (_moveTimer > 2.0) {
      _moveDir = Vector2(-_moveDir.x, 0);
      _moveTimer = 0;
    }
    position += _moveDir * enemyData.speed * dt;

    // Clamp to upper half of world
    position.x = position.x.clamp(
        GameConfig.spawnMargin,
        GameConfig.worldWidth - GameConfig.spawnMargin);
    position.y = position.y.clamp(
        GameConfig.spawnMargin,
        GameConfig.worldHeight * 0.45);

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
    // 1. Drop shadow
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.7),
      size.x * 0.3,
      Paint()..color = Colors.black.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // 2. Body (Camo green/brown gradient)
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF885522), Color(0xFF443311)],
      ).createShader(Rect.fromCircle(center: Offset(size.x * 0.5, size.y * 0.5), radius: size.x * 0.4));
    
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.35,
      bodyPaint,
    );

    // 3. Helmet detail
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.x * 0.5, size.y * 0.5), radius: size.x * 0.35),
      -3.14,
      3.14,
      true,
      Paint()..color = const Color(0xFF556644),
    );

    // 4. Weapon (Rifle pointing towards player movement)
    final weaponPaint = Paint()..color = const Color(0xFF111111);
    canvas.save();
    canvas.translate(size.x * 0.5, size.y * 0.5);
    // Point weapon in move direction
    final angle = _moveDir.x > 0 ? 0.3 : -0.3;
    canvas.rotate(angle);
    canvas.drawRect(
      const Rect.fromLTWH(0, -2, 12, 4),
      weaponPaint,
    );
    canvas.restore();
  }
}
