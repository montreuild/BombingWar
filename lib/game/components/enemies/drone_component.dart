import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';

/// Drone — autonomous flying enemy, small hitbox, fast.
/// Behaviour: SEEK_PLAYER → flies towards aircraft in sinusoidal trajectory.
/// Can also target ejected pilot.
class DroneComponent extends EnemyComponent {
  DroneComponent({
    required super.game,
    required super.position,
  }) : super(
          enemyData: EnemyData.drone,
        );

  double _sinePhase = 0.0;
  bool _hasHitTarget = false;

  @override
  void onUpdate(double dt, bool canFire) {
    _sinePhase += dt * 5.0;

    // Determine target: pilot on ground if ejected, otherwise aircraft
    Vector2? targetPos;
    if (game.isRescueMissionActive && game.activePilot != null) {
      targetPos = game.activePilot!.position;
    } else if (game.playerAircraft != null && game.playerAircraft!.isAlive) {
      targetPos = game.playerAircraft!.position;
    }

    if (targetPos != null) {
      final dir = (targetPos - position).normalized();
      // Sinusoidal trajectory
      final sineOffset = math.sin(_sinePhase) * 20.0;
      final perpDir = Vector2(-dir.y, dir.x) * sineOffset;
      position += (dir * GameConfig.droneSpeed + perpDir) * dt;

      // Check collision with player
      if (game.playerAircraft != null &&
          !_hasHitTarget &&
          position.distanceTo(game.playerAircraft!.position) < hitRadius + game.playerAircraft!.hitRadius) {
        _hitPlane();
      }
    } else {
      // No target — fly right and escape
      position.x += GameConfig.droneSpeed * dt;
    }

    // Check if escaped screen
    if (position.x > game.cameraX + GameConfig.worldWidth + GameConfig.despawnMargin ||
        position.x < game.cameraX - GameConfig.despawnMargin) {
      game.onDroneEscaped();
      removeFromParent();
    }
  }

  void _hitPlane() {
    _hasHitTarget = true;
    game.playerAircraft?.takeDamage(GameConfig.droneDamage);
    game.scoreSystem.registerDroneHitPlane();
    game.spawnExplosion(position, radius: 15.0);
    removeFromParent();
  }

  @override
  void onKilled() {
    game.onDroneIntercepted();
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Drone body (small diamond/delta shape)
    final bodyPath = Path()
      ..moveTo(cx + 6, cy)
      ..lineTo(cx, cy - 4)
      ..lineTo(cx - 6, cy)
      ..lineTo(cx, cy + 3)
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()..color = const Color(0xFF2A2A2A),
    );

    // Wings
    canvas.drawLine(
      Offset(cx - 2, cy),
      Offset(cx - 6, cy - 2),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(cx - 2, cy),
      Offset(cx - 6, cy + 2),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1,
    );

    // Red LED indicator
    canvas.drawCircle(
      Offset(cx + 4, cy),
      1.5,
      Paint()..color = Colors.red,
    );

    // Propeller blur (back)
    canvas.drawCircle(
      Offset(cx - 6, cy),
      3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
}
