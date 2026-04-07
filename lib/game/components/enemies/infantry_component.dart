import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../../bombing_war_game.dart';
import '../projectiles/bullet_component.dart';
import 'enemy_component.dart';

/// Light infantry unit that pops from cover and fires bullets upward.
class InfantryComponent extends EnemyComponent {
  InfantryComponent({required super.game, required Vector2 position})
      : super(position: position, enemyData: EnemyData.infantry);

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
    final paint = Paint()..color = const Color(0xFF885522);
    // Body
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.35,
      paint,
    );
    // Weapon indicator
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.55, size.y * 0.3, size.x * 0.35, size.y * 0.1),
      Paint()..color = const Color(0xFF333333),
    );
  }
}
