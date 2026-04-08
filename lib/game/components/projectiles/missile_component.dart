import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';
import '../enemies/enemy_component.dart';
import 'projectile_component.dart';

/// Homing missile — steers toward the nearest valid target each frame.
class MissileComponent extends ProjectileComponent {
  MissileComponent({
    required super.position,
    required super.damage,
    required super.isPlayerProjectile,
    required this.game,
  }) : super(
          size: GameConfig.missileSize,
          explosionRadius: GameConfig.missileExplosionRadius,
        );

  final BombingWarGame game;
  Vector2 _velocity = Vector2(1, 0); // Initial direction: forward

  @override
  double get maxLifespan =>
      GameConfig.missileRange / GameConfig.missileSpeed;

  @override
  void update(double dt) {
    _steerTowardTarget(dt);
    position += _velocity * GameConfig.missileSpeed * dt;
    // Rotate sprite to face movement direction
    angle = atan2(_velocity.x, -_velocity.y);
    super.update(dt);
  }

  void _steerTowardTarget(double dt) {
    Vector2? targetPos;

    if (isPlayerProjectile) {
      // Player missile targets nearest enemy
      double best = double.infinity;
      for (final child in game.worldChildren) {
        if (child is EnemyComponent && child.isAlive && !child.isRemoved) {
          final dist = position.distanceTo(child.position);
          if (dist < best) {
            best = dist;
            targetPos = child.position;
          }
        }
      }
    } else {
      // Enemy missile targets the player aircraft
      final player = game.playerAircraft;
      if (player != null && !player.isRemoved) {
        targetPos = player.position;
      }
    }

    if (targetPos == null) return;

    final desired = (targetPos - position).normalized();
    final maxTurn =
        GameConfig.missileHomingStrength * dt * pi / 180.0;
    _velocity = _rotateToward(_velocity, desired, maxTurn).normalized();
  }

  /// Rotates [from] toward [to] by at most [maxAngle] radians.
  Vector2 _rotateToward(Vector2 from, Vector2 to, double maxAngle) {
    final currentAngle = atan2(from.y, from.x);
    final targetAngle = atan2(to.y, to.x);
    var diff = targetAngle - currentAngle;
    // Wrap to [-pi, pi]
    while (diff > pi) {
      diff -= 2 * pi;
    }
    while (diff < -pi) {
      diff += 2 * pi;
    }
    final clamped = diff.clamp(-maxAngle, maxAngle);
    final newAngle = currentAngle + clamped;
    return Vector2(cos(newAngle), sin(newAngle));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = isPlayerProjectile
          ? const Color(0xFF88DDFF)
          : const Color(0xFFFF8844);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.2, 0, size.x * 0.6, size.y * 0.7),
        const Radius.circular(3),
      ),
      paint,
    );

    // Exhaust glow
    canvas.drawCircle(
      Offset(size.x / 2, size.y * 0.85),
      3,
      Paint()
        ..color = const Color(0xFFFF6600).withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
}
