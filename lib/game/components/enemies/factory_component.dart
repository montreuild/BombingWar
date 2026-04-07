import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../../bombing_war_game.dart';
import '../projectiles/bullet_component.dart';
import 'enemy_component.dart';

/// Underground Factory — boss target.
/// Only destroyable by penetrator bombs. Spawns infantry reinforcements.
class FactoryComponent extends EnemyComponent {
  FactoryComponent({required super.game, required Vector2 position})
      : super(position: position, enemyData: EnemyData.factory);

  double _pulseTimer = 0.0;
  double _spawnTimer = 0.0;

  @override
  bool get requiresPenetrator => true;

  @override
  void onUpdate(double dt, bool canFire) {
    _pulseTimer += dt;

    // Periodic auto-gun defense fire
    if (canFire && game.playerAircraft != null) {
      _fireDefenseGuns();
      resetFireCooldown(1.2);
    }

    // Spawn infantry reinforcements periodically
    _spawnTimer += dt;
    if (_spawnTimer >= GameConfig.factoryRespawnInterval) {
      _spawnTimer = 0;
      _spawnReinforcement();
    }
  }

  void _fireDefenseGuns() {
    final player = game.playerAircraft!;
    final dir = (player.position - position).normalized();
    // Fire spread of 3 bullets
    for (int i = -1; i <= 1; i++) {
      final spread = Vector2(-dir.y * i * 0.15, dir.x * i * 0.15);
      game.add(BulletComponent(
        position: position.clone(),
        direction: (dir + spread).normalized(),
        damage: EnemyData.infantry.damage,
        isPlayerProjectile: false,
      ));
    }
  }

  void _spawnReinforcement() {
    // Notify wave system to add one infantry near the factory
    // (Direct spawn for simplicity; wave system handles the count)
    final spawnPos = position + Vector2(40, 0);
    game.add(_FactoryInfantry(game: game, position: spawnPos));
  }

  @override
  void onRender(Canvas canvas) {
    final pulse = ((_pulseTimer * 2).remainder(1.0));

    // Main building
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.05, size.y * 0.3, size.x * 0.9, size.y * 0.65),
      Paint()..color = const Color(0xFF556644),
    );

    // Underground indicator
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * 0.7, size.x, size.y * 0.3),
      Paint()..color = const Color(0xFF3A4A30),
    );

    // Warning lights that pulse
    final lightPaint = Paint()
      ..color = Color.fromRGBO(255, 50, 0, 0.5 + pulse * 0.5);
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.x * (0.15 + i * 0.23), size.y * 0.25),
        4,
        lightPaint,
      );
    }

    // Chimney stacks
    final chimPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRect(
        Rect.fromLTWH(size.x * 0.15, size.y * 0.05, 8, size.y * 0.3),
        chimPaint);
    canvas.drawRect(
        Rect.fromLTWH(size.x * 0.75, size.y * 0.05, 8, size.y * 0.3),
        chimPaint);

    // "REQUIRES PENETRATOR" label hint (small text via canvas)
    // Skipped for clarity; HUD threat system informs player instead
  }
}

/// Simple infantry spawned by the factory — no onDefeated callback needed.
class _FactoryInfantry extends EnemyComponent {
  _FactoryInfantry({required super.game, required Vector2 position})
      : super(position: position, enemyData: EnemyData.infantry);

  @override
  void onUpdate(double dt, bool canFire) {
    final player = game.playerAircraft;
    if (player == null) return;
    final dir = (player.position - position).normalized();
    position += dir * enemyData.speed * dt;
    if (canFire) {
      game.add(BulletComponent(
        position: position.clone(),
        direction: dir,
        damage: enemyData.damage,
        isPlayerProjectile: false,
      ));
      resetFireCooldown(GameConfig.infantryFireCooldown);
    }
  }

  @override
  void onRender(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.35,
      Paint()..color = const Color(0xFF775533),
    );
  }
}
