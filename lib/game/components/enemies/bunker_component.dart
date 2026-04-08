import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../projectiles/missile_component.dart';
import 'enemy_component.dart';

enum _BunkerState { closed, opening, open, firing, closing }

/// Pop-up missile bunker — opens, fires a missile salvo, then closes.
class BunkerComponent extends EnemyComponent {
  BunkerComponent({required super.game, required super.position})
      : super(enemyData: EnemyData.bunker);

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
    // 1. Underground base plate with depth
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2A352A), Color(0xFF445544)],
      ).createShader(Rect.fromLTWH(0, size.y * 0.6, size.x, size.y * 0.4));
    
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * 0.6, size.x, size.y * 0.4),
      basePaint,
    );

    // 2. Missile launcher / Interior (Visible when opening)
    if (_openAmount > 0.05) {
      final interiorRect = Rect.fromLTWH(size.x * 0.2, size.y * 0.1, size.x * 0.6, size.y * 0.6);
      canvas.drawRect(interiorRect, Paint()..color = const Color(0xFF1A1A1A));
      
      // Warning Glow when open
      if (_state == _BunkerState.open || _state == _BunkerState.opening || _state == _BunkerState.firing) {
        final glowAlpha = (0.2 + 0.3 * (DateTime.now().millisecondsSinceEpoch % 1000 / 1000)).clamp(0.0, 1.0);
        canvas.drawRect(
          interiorRect,
          Paint()
            ..color = Colors.red.withValues(alpha: glowAlpha * _openAmount)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      // The Launcher itself - slides up slightly
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y * (0.6 - 0.3 * _openAmount)),
          width: size.x * 0.3,
          height: size.y * 0.4,
        ),
        Paint()..color = const Color(0xFF333333),
      );
    }

    // 3. Armored doors with bevel effect
    final doorHeight = size.y * 0.6;
    // Doors slide left/right instead of just squashing
    final openOffset = (size.x * 0.45) * _openAmount;
    
    final doorPaint = Paint()..color = const Color(0xFF556655);
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Left door
    final leftDoor = Rect.fromLTWH(-openOffset, 0, size.x * 0.5, doorHeight);
    canvas.drawRect(leftDoor, doorPaint);
    canvas.drawRect(leftDoor, borderPaint);
    
    // Right door
    final rightDoor = Rect.fromLTWH(size.x * 0.5 + openOffset, 0, size.x * 0.5, doorHeight);
    canvas.drawRect(rightDoor, doorPaint);
    canvas.drawRect(rightDoor, borderPaint);

    // Door details / rivets (only visible if not fully open)
    if (_openAmount < 0.9) {
      final rivetPaint = Paint()..color = Colors.black.withValues(alpha: 0.3);
      // Left rivets
      canvas.drawCircle(Offset(size.x * 0.1 - openOffset, 10), 2, rivetPaint);
      canvas.drawCircle(Offset(size.x * 0.4 - openOffset, 10), 2, rivetPaint);
      canvas.drawCircle(Offset(size.x * 0.1 - openOffset, doorHeight - 10), 2, rivetPaint);
      canvas.drawCircle(Offset(size.x * 0.4 - openOffset, doorHeight - 10), 2, rivetPaint);
      
      // Right rivets
      canvas.drawCircle(Offset(size.x * 0.6 + openOffset, 10), 2, rivetPaint);
      canvas.drawCircle(Offset(size.x * 0.9 + openOffset, 10), 2, rivetPaint);
      canvas.drawCircle(Offset(size.x * 0.6 + openOffset, doorHeight - 10), 2, rivetPaint);
      canvas.drawCircle(Offset(size.x * 0.9 + openOffset, doorHeight - 10), 2, rivetPaint);
    }
  }
}
