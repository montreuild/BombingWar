import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../../bombing_war_game.dart';

/// Abstract base class for all enemy units with AI state machine.
/// States: IDLE → ALERT → ATTACK → HUNT_PILOT
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
  EnemyAIState aiState = EnemyAIState.idle;

  /// Callback invoked when this enemy is destroyed.
  void Function()? onDefeated;

  bool get isAlive => _health > 0;
  double get hitRadius => enemyData.size * 0.45;
  int get scoreValue => enemyData.scoreValue;

  /// L2 bunkers require GBU-57 to destroy.
  bool get requiresGBU => false;

  /// Whether this enemy is blinded (power plant destroyed nearby).
  bool isBlinded = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _health = enemyData.health;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (fireCooldown > 0) fireCooldown -= dt;

    // Update AI state based on conditions
    _updateAIState();

    onUpdate(dt, fireCooldown <= 0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawHealthBar(canvas);
    onRender(canvas);
  }

  /// AI state machine logic.
  void _updateAIState() {
    if (isBlinded) {
      aiState = EnemyAIState.idle;
      return;
    }

    // Check if there's an ejected pilot to hunt
    if (game.isRescueMissionActive && _canHuntPilot()) {
      aiState = EnemyAIState.huntPilot;
      return;
    }

    final aircraft = game.playerAircraft;
    if (aircraft == null || !aircraft.isAlive) {
      aiState = EnemyAIState.idle;
      return;
    }

    final distToPlayer = position.distanceTo(aircraft.position);

    if (distToPlayer <= GameConfig.enemyAttackRange) {
      aiState = EnemyAIState.attack;
    } else if (distToPlayer <= GameConfig.enemyDetectionRange || _isRadarAlerted()) {
      aiState = EnemyAIState.alert;
    } else {
      aiState = EnemyAIState.idle;
    }
  }

  /// Check if a nearby radar is active and alerting this enemy.
  bool _isRadarAlerted() {
    // Radar doubles detection range for nearby enemies
    // Check through game's active radar list
    return game.isEnemyRadarAlerted(this);
  }

  /// Only jeeps can hunt pilots.
  bool _canHuntPilot() => enemyData.type == EnemyType.jeep;

  /// Subclasses implement their per-frame behaviour here.
  void onUpdate(double dt, bool canFire);

  /// Subclasses draw their appearance here.
  void onRender(Canvas canvas);

  /// Returns true if the enemy was killed by this hit.
  bool takeDamage(double amount, {bool isGBU = false}) {
    if (!isAlive) return false;
    if (requiresGBU && !isGBU) {
      // Show "BLINDÉ" feedback
      game.showFeedback('BLINDÉ', position);
      return false;
    }

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
    if (_health >= enemyData.health) return;
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

  /// Get direction towards player aircraft.
  Vector2 directionToPlayer() {
    final aircraft = game.playerAircraft;
    if (aircraft == null) return Vector2.zero();
    return (aircraft.position - position).normalized();
  }
}
