import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';
import '../projectiles/missile_component.dart';

/// Rocket launcher — static, fires curved rockets at player.
class RocketLauncherComponent extends EnemyComponent {
  RocketLauncherComponent({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.rocketLauncher,
        );

  @override
  void onUpdate(double dt, bool canFire) {
    if (aiState == EnemyAIState.attack && canFire) {
      _fire();
    }
  }

  void _fire() {
    game.addToWorld(MissileComponent(
      position: position.clone() + Vector2(0, -5),
      damage: GameConfig.rocketLauncherDamage,
      isPlayerProjectile: false,
      game: game,
    ));
    resetFireCooldown(GameConfig.rocketLauncherFireCooldown);
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Soldier body (kneeling)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 3, cy + 2), width: 6, height: 8),
      Paint()..color = const Color(0xFF5A5A3A),
    );
    // Head
    canvas.drawCircle(
      Offset(cx - 3, cy - 4),
      3,
      Paint()..color = const Color(0xFF5A5A3A),
    );
    // RPG launcher tube
    canvas.drawLine(
      Offset(cx + 2, cy - 2),
      Offset(cx + 10, cy - 8),
      Paint()
        ..color = const Color(0xFF3A3A2A)
        ..strokeWidth = 3,
    );
    // Exhaust cone
    canvas.drawCircle(
      Offset(cx + 2, cy - 2),
      2,
      Paint()..color = Colors.orange.withValues(alpha: 0.5),
    );
  }
}
