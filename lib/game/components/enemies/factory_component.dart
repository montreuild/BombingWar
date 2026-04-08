import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../projectiles/bullet_component.dart';
import 'enemy_component.dart';

/// Underground Factory — boss target.
/// Only destroyable by penetrator bombs. Spawns infantry reinforcements.
class FactoryComponent extends EnemyComponent {
  FactoryComponent({required super.game, required super.position})
      : super(enemyData: EnemyData.factory);

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
    final double alpha = 1.0;

    // 1. Underground Foundation (Deeper base)
    final foundationPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2A3520), Color(0xFF1A2510)],
      ).createShader(Rect.fromLTWH(0, size.y * 0.7, size.x, size.y * 0.3));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.y * 0.7, size.x, size.y * 0.3),
        const Radius.circular(4),
      ),
      foundationPaint,
    );

    // 2. Main Building Structure (Metallic/Industrial)
    final buildingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF556644), Color(0xFF3A4A30)],
      ).createShader(Rect.fromLTWH(size.x * 0.05, size.y * 0.3, size.x * 0.9, size.y * 0.5));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.05, size.y * 0.3, size.x * 0.9, size.y * 0.5),
        const Radius.circular(2),
      ),
      buildingPaint,
    );

    // 3. Industrial details (Windows/Vents)
    final detailPaint = Paint()..color = Colors.black.withValues(alpha: 0.3);
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(size.x * (0.15 + i * 0.28), size.y * 0.45, size.x * 0.15, size.y * 0.2),
        detailPaint,
      );
    }

    // 4. Chimney stacks with glowing tops
    final chimPaint = Paint()..color = const Color(0xFF222222);
    final glowPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.4 + pulse * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Left Chimney
    canvas.drawRect(Rect.fromLTWH(size.x * 0.15, size.y * 0.1, 10, size.y * 0.3), chimPaint);
    canvas.drawCircle(Offset(size.x * 0.15 + 5, size.y * 0.1), 4, glowPaint);
    
    // Right Chimney
    canvas.drawRect(Rect.fromLTWH(size.x * 0.75, size.y * 0.05, 10, size.y * 0.35), chimPaint);
    canvas.drawCircle(Offset(size.x * 0.75 + 5, size.y * 0.05), 4, glowPaint);

    // 5. Warning lights (pulsing red)
    final lightPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3 + pulse * 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.x * (0.2 + i * 0.2), size.y * 0.35),
        3,
        lightPaint,
      );
    }
  }
}

/// Simple infantry spawned by the factory — no onDefeated callback needed.
class _FactoryInfantry extends EnemyComponent {
  _FactoryInfantry({required super.game, required super.position})
      : super(enemyData: EnemyData.infantry);

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
