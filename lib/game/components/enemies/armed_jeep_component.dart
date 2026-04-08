import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';
import '../projectiles/bullet_component.dart';

/// Armed Jeep — mobile, turret ±45°, hunts pilot when ejected.
class ArmedJeepComponent extends EnemyComponent {
  ArmedJeepComponent({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.jeep,
        );

  double _turretAngle = 0.0;

  @override
  void onUpdate(double dt, bool canFire) {
    switch (aiState) {
      case EnemyAIState.idle:
        // Patrol slowly
        position.x += GameConfig.jeepSpeed * 0.3 * dt;
        break;
      case EnemyAIState.alert:
        // Move towards player slowly
        final dir = directionToPlayer();
        position.x += dir.x * GameConfig.jeepSpeed * 0.5 * dt;
        break;
      case EnemyAIState.attack:
        // Aim and fire turret
        _aimTurret();
        if (canFire) _fire();
        break;
      case EnemyAIState.huntPilot:
        // Rush towards pilot at accelerated speed
        _huntPilot(dt);
        break;
    }
  }

  void _aimTurret() {
    final dir = directionToPlayer();
    final angle = math.atan2(dir.y, dir.x);
    // Clamp turret to ±45°
    _turretAngle = angle.clamp(
      -GameConfig.jeepTurretAngle * math.pi / 180,
      GameConfig.jeepTurretAngle * math.pi / 180,
    );
  }

  void _fire() {
    final dir = Vector2(math.cos(_turretAngle), math.sin(_turretAngle));
    game.addToWorld(BulletComponent(
      position: position.clone() + Vector2(0, -8),
      direction: dir,
      damage: GameConfig.jeepDamage,
      isPlayerProjectile: false,
    ));
    resetFireCooldown(GameConfig.jeepFireCooldown);
  }

  void _huntPilot(double dt) {
    final pilot = game.activePilot;
    if (pilot == null) return;
    final dir = (pilot.position - position).normalized();
    position.x += dir.x * GameConfig.jeepSpeed * GameConfig.huntPilotSpeedMultiplier * dt;
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Jeep body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 2), width: 24, height: 10),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF5A6A3A),
    );

    // Cabin
    canvas.drawRect(
      Rect.fromLTWH(cx - 4, cy - 6, 10, 8),
      Paint()..color = const Color(0xFF4A5A2A),
    );

    // Wheels
    canvas.drawCircle(Offset(cx - 8, cy + 8), 4, Paint()..color = Colors.grey.shade800);
    canvas.drawCircle(Offset(cx + 8, cy + 8), 4, Paint()..color = Colors.grey.shade800);

    // Turret
    canvas.save();
    canvas.translate(cx, cy - 4);
    canvas.rotate(_turretAngle);
    canvas.drawLine(
      Offset.zero,
      const Offset(12, 0),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 2,
    );
    canvas.restore();
  }
}
