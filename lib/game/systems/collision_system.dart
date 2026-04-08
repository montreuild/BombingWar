import 'dart:math';

import 'package:flame/components.dart';

import '../bombing_war_game.dart';
import '../components/enemies/enemy_component.dart';
import '../components/projectiles/projectile_component.dart';

/// Manages collision detection between projectiles, enemies and the player.
/// Uses simple circle-overlap checks each frame (no Flame collision callbacks).
class CollisionSystem {
  CollisionSystem({required this.game});

  final BombingWarGame game;

  void update(double dt) {
    _checkProjectilesVsEnemies();
    _checkEnemyProjectilesVsPlayer();
  }

  void _checkProjectilesVsEnemies() {
    final projectiles = game.children
        .whereType<ProjectileComponent>()
        .where((p) => p.isPlayerProjectile && !p.isRemoved)
        .toList();

    final enemies = game.children
        .whereType<EnemyComponent>()
        .where((e) => !e.isRemoved && e.isAlive)
        .toList();

    for (final projectile in projectiles) {
      for (final enemy in enemies) {
        if (_circleOverlap(
          projectile.position,
          projectile.radius,
          enemy.position,
          enemy.hitRadius,
        )) {
          final killed = enemy.takeDamage(
            projectile.damage,
            isPenetrator: projectile.isPenetrator,
          );
          if (killed) {
            game.registerKill(enemy.scoreValue);
          }

          // Area-of-effect for bombs
          if (projectile.explosionRadius > 0) {
            _applyAoeExplosion(
              projectile.position,
              projectile.explosionRadius,
              projectile.damage,
              enemy,
              isPenetrator: projectile.isPenetrator,
            );
          }

          game.spawnExplosion(
            projectile.position,
            radius: projectile.explosionRadius > 0
                ? projectile.explosionRadius
                : 20.0,
          );

          projectile.removeFromParent();
          break; // One projectile hits one enemy
        }
      }
    }
  }

  void _checkEnemyProjectilesVsPlayer() {
    final player = game.playerAircraft;
    if (player == null || player.isRemoved || player.isInvincible) return;

    final enemyProjectiles = game.children
        .whereType<ProjectileComponent>()
        .where((p) => !p.isPlayerProjectile && !p.isRemoved)
        .toList();

    for (final projectile in enemyProjectiles) {
      if (_circleOverlap(
        projectile.position,
        projectile.radius,
        player.position,
        player.hitRadius,
      )) {
        player.takeDamage(projectile.damage);
        game.spawnExplosion(projectile.position);
        projectile.removeFromParent();
      }
    }
  }

  void _applyAoeExplosion(
    Vector2 center,
    double radius,
    double damage,
    EnemyComponent primary, {
    bool isPenetrator = false,
  }) {
    final enemies = game.children
        .whereType<EnemyComponent>()
        .where((e) => !e.isRemoved && e.isAlive && e != primary)
        .toList();

    for (final enemy in enemies) {
      final dist = _dist(center, enemy.position);
      if (dist <= radius) {
        final falloff = 1.0 - (dist / radius);
        final killed = enemy.takeDamage(
          damage * falloff,
          isPenetrator: isPenetrator,
        );
        if (killed) game.registerKill(enemy.scoreValue);
      }
    }
  }

  bool _circleOverlap(Vector2 a, double aR, Vector2 b, double bR) {
    return _dist(a, b) < aR + bR;
  }

  double _dist(Vector2 a, Vector2 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }
}
