import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../../bombing_war_game.dart';
import '../projectiles/missile_component.dart';
import 'enemy_component.dart';

/// RPG unit — fires slow homing rockets at the player.
class RpgUnitComponent extends EnemyComponent {
  RpgUnitComponent({required super.game, required Vector2 position})
      : super(position: position, enemyData: EnemyData.rpgUnit);

  @override
  void onUpdate(double dt, bool canFire) {
    // Slow drift toward player for pressure
    final player = game.playerAircraft;
    if (player != null) {
      final dir = (player.position - position).normalized();
      position += dir * enemyData.speed * dt;
    }

    if (canFire && player != null) {
      _fireRocket();
      resetFireCooldown(GameConfig.rpgFireCooldown);
    }
  }

  void _fireRocket() {
    game.add(MissileComponent(
      position: position.clone(),
      damage: enemyData.damage,
      isPlayerProjectile: false,
      game: game,
    ));
    game.audioManager.playMissile().catchError((_) {});
  }

  @override
  void onRender(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFAA3333);
    // Truck body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            size.x * 0.1, size.y * 0.2, size.x * 0.8, size.y * 0.6),
        const Radius.circular(3),
      ),
      paint,
    );
    // Rocket tube
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.35, 0, size.x * 0.3, size.y * 0.4),
      Paint()..color = const Color(0xFF555555),
    );
  }
}
