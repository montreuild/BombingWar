import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../../bombing_war_game.dart';
import '../projectiles/missile_component.dart';
import 'enemy_component.dart';

enum _BunkerState { closed, opening, open, firing, closing }

/// Pop-up missile bunker — opens, fires a missile salvo, then closes.
class BunkerComponent extends EnemyComponent {
  BunkerComponent({required super.game, required Vector2 position})
      : super(position: position, enemyData: EnemyData.bunker);

  _BunkerState _state = _BunkerState.closed;
  double _stateTimer = 0.0;
  int _missilesFired = 0;
  double _openAmount = 0.0; // 0 = closed, 1 = fully open

  @override
  void onUpdate(double dt, bool canFire) {
    _stateTimer += dt;

    switch (_state) {
      case _BunkerState.closed:
        if (_stateTimer >= GameConfig.bunkerSalvoCooldown) {
          _state = _BunkerState.opening;
          _stateTimer = 0;
        }
      case _BunkerState.opening:
        _openAmount = (_stateTimer / GameConfig.bunkerOpenDuration).clamp(0, 1);
        if (_stateTimer >= GameConfig.bunkerOpenDuration) {
          _state = _BunkerState.open;
          _stateTimer = 0;
          _missilesFired = 0;
        }
      case _BunkerState.open:
        if (_missilesFired < GameConfig.bunkerSalvoCount) {
          if (_stateTimer >= 0.4) {
            _fireMissile();
            _missilesFired++;
            _stateTimer = 0;
          }
        } else {
          _state = _BunkerState.closing;
          _stateTimer = 0;
        }
      case _BunkerState.firing:
        break; // Not used — firing happens in open state
      case _BunkerState.closing:
        _openAmount = (1.0 - _stateTimer / GameConfig.bunkerOpenDuration).clamp(0, 1);
        if (_stateTimer >= GameConfig.bunkerOpenDuration) {
          _state = _BunkerState.closed;
          _stateTimer = 0;
          _openAmount = 0;
        }
    }
  }

  void _fireMissile() {
    game.add(MissileComponent(
      position: position.clone(),
      damage: GameConfig.bunkerMissileDamage,
      isPlayerProjectile: false,
      game: game,
    ));
    game.audioManager.playMissile().catchError((_) {});
  }

  @override
  void onRender(Canvas canvas) {
    // Underground base plate (always visible)
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * 0.6, size.x, size.y * 0.4),
      Paint()..color = const Color(0xFF445544),
    );

    // Armored doors that open upward
    final doorHeight = size.y * 0.6;
    final openOffset = doorHeight * _openAmount;

    // Left door
    canvas.drawRect(
      Rect.fromLTWH(0, openOffset, size.x * 0.48, doorHeight - openOffset),
      Paint()..color = const Color(0xFF556655),
    );
    // Right door
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.52, openOffset, size.x * 0.48,
          doorHeight - openOffset),
      Paint()..color = const Color(0xFF556655),
    );

    // Missile launcher visible when open
    if (_openAmount > 0.5) {
      canvas.drawRect(
        Rect.fromLTWH(size.x * 0.38, 0, size.x * 0.24, size.y * 0.5),
        Paint()..color = const Color(0xFF333333),
      );
    }
  }
}
