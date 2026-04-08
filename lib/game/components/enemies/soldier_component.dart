import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';
import '../projectiles/bullet_component.dart';

/// Soldier — patrols side-to-side, fires rifle at player.
class SoldierComponent extends EnemyComponent {
  SoldierComponent({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.soldier,
        );

  double _patrolDirection = 1.0;
  final double _patrolRange = 60.0;
  late double _startX;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _startX = position.x;
  }

  @override
  void onUpdate(double dt, bool canFire) {
    switch (aiState) {
      case EnemyAIState.idle:
        _patrol(dt);
        break;
      case EnemyAIState.alert:
        _patrol(dt);
        break;
      case EnemyAIState.attack:
        _patrol(dt);
        if (canFire) _fire();
        break;
      case EnemyAIState.huntPilot:
        break;
    }
  }

  void _patrol(double dt) {
    position.x += _patrolDirection * GameConfig.soldierSpeed * dt;
    if ((position.x - _startX).abs() > _patrolRange) {
      _patrolDirection *= -1;
    }
  }

  void _fire() {
    final dir = directionToPlayer();
    game.add(BulletComponent(
      position: position.clone(),
      direction: dir,
      damage: GameConfig.soldierDamage,
      isPlayerProjectile: false,
    ));
    resetFireCooldown(GameConfig.soldierFireCooldown);
  }

  @override
  void onRender(Canvas canvas) {
    // Soldier silhouette
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Body
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 6, height: 10),
      Paint()..color = const Color(0xFF4A6A2A),
    );
    // Head with helmet
    canvas.drawCircle(
      Offset(cx, cy - 5),
      3,
      Paint()..color = const Color(0xFF4A6A2A),
    );
    // Rifle
    canvas.drawLine(
      Offset(cx + 3, cy),
      Offset(cx + 8, cy - 3),
      Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 1.5,
    );
    // Legs
    canvas.drawLine(
      Offset(cx - 1, cy + 7),
      Offset(cx - 3, cy + 10),
      Paint()..color = const Color(0xFF4A6A2A)..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(cx + 1, cy + 7),
      Offset(cx + 3, cy + 10),
      Paint()..color = const Color(0xFF4A6A2A)..strokeWidth = 1.5,
    );
  }
}
