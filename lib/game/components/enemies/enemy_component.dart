import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../models/enemy_data.dart';
import '../../bombing_war_game.dart';

/// Abstract base class for all enemy units.
abstract class EnemyComponent extends PositionComponent {
  EnemyComponent({
    required this.game,
    required Vector2 position,
    required this.enemyData,
  }) : super(
          position: position,
          size: Vector2.all(enemyData.size),
          anchor: Anchor.center,
        );

  final BombingWarGame game;
  final EnemyData enemyData;

  late double _health;
  double fireCooldown = 0.0;

  /// Callback invoked when this enemy is destroyed.
  void Function()? onDefeated;

  bool get isAlive => _health > 0;
  double get hitRadius => enemyData.size * 0.45;
  int get scoreValue => enemyData.scoreValue;

  /// Factories require a penetrator bomb to destroy.
  bool get requiresPenetrator => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _health = enemyData.health;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (fireCooldown > 0) fireCooldown -= dt;
    onUpdate(dt, fireCooldown <= 0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawHealthBar(canvas);
    onRender(canvas);
  }

  /// Subclasses implement their per-frame behaviour here.
  void onUpdate(double dt, bool canFire);

  /// Subclasses draw their appearance here.
  void onRender(Canvas canvas);

  /// Returns true if the enemy was killed by this hit.
  bool takeDamage(double amount, {bool isPenetrator = false}) {
    if (!isAlive) return false;
    if (requiresPenetrator && !isPenetrator) return false; // Immune unless penetrator

    _health -= amount;
    if (_health <= 0) {
      _health = 0;
      _die();
      return true;
    }
    return false;
  }

  void resetFireCooldown(double cooldown) {
    fireCooldown = cooldown;
  }

  void _die() {
    game.spawnExplosion(position, radius: enemyData.size * 0.8);
    onDefeated?.call();
    onKilled();
    removeFromParent();
  }

  /// Subclasses can override this to perform actions when killed.
  void onKilled() {}

  void _drawHealthBar(Canvas canvas) {
    if (_health >= enemyData.health) return; // No bar at full health
    final barWidth = enemyData.size;
    const double barH = 3.0;
    const double barY = -8.0;

    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2 + size.x / 2, barY, barWidth, barH),
      Paint()..color = Colors.black54,
    );
    final pct = (_health / enemyData.health).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(
          -barWidth / 2 + size.x / 2, barY, barWidth * pct, barH),
      Paint()..color = Colors.red,
    );
  }
}
