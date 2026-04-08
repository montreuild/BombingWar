import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';
import '../projectiles/missile_component.dart';

/// Missile Factory (Underground L1) — launches automatic salvos towards surface.
/// 5 hits to destroy. Partial destruction reduces fire rate.
class MissileFactoryComponent extends EnemyComponent {
  MissileFactoryComponent({
    required BombingWarGame game,
    required Vector2 position,
  }) : super(
          game: game,
          position: position,
          enemyData: EnemyData.missileFactory,
        );

  double _salvoTimer = 0.0;
  int _hitsTaken = 0;
  double _chimneyGlow = 0.0;

  @override
  void onUpdate(double dt, bool canFire) {
    _chimneyGlow += dt * 3;

    // Fire salvos at adjusted rate based on damage
    final cooldownMultiplier = 1.0 + (_hitsTaken * 0.4); // Slower when damaged
    _salvoTimer += dt;
    if (_salvoTimer >= GameConfig.missileFactorySalvoCooldown * cooldownMultiplier) {
      _salvoTimer = 0;
      _fireSalvo();
    }
  }

  @override
  bool takeDamage(double amount, {bool isGBU = false}) {
    _hitsTaken++;
    return super.takeDamage(amount, isGBU: isGBU);
  }

  void _fireSalvo() {
    // Fire missiles upward towards surface
    final missileCount = math.max(1, 3 - _hitsTaken); // Fewer missiles when damaged
    for (int i = 0; i < missileCount; i++) {
      final offset = Vector2((i - missileCount / 2) * 15, -10);
      game.add(MissileComponent(
        position: position.clone() + offset,
        damage: GameConfig.missileDamage,
        isPlayerProjectile: false,
        game: game,
      ));
    }
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Underground foundation
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 4), width: 40, height: 20),
        const Radius.circular(3),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade700, Colors.grey.shade900],
        ).createShader(Rect.fromCenter(center: Offset(cx, cy + 4), width: 40, height: 20)),
    );

    // Industrial building
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 34, height: 14),
      Paint()..color = const Color(0xFF4A4A4A),
    );

    // Windows/vents
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(cx - 12 + i * 10.0, cy - 6, 6, 4),
        Paint()..color = const Color(0xFF2A2A1A),
      );
    }

    // Chimneys
    for (final dx in [-10.0, 10.0]) {
      canvas.drawRect(
        Rect.fromLTWH(cx + dx - 3, cy - 14, 6, 12),
        Paint()..color = const Color(0xFF3A3A3A),
      );

      // Glowing chimney top
      final glowAlpha = (0.5 + 0.3 * math.sin(_chimneyGlow + dx)).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(cx + dx, cy - 14),
        3,
        Paint()
          ..color = Colors.orange.withValues(alpha: glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Warning lights
    final warningAlpha = (0.4 + 0.4 * math.sin(_chimneyGlow * 2)).clamp(0.0, 1.0);
    for (final dx in [-14.0, -6.0, 6.0, 14.0]) {
      canvas.drawCircle(
        Offset(cx + dx, cy + 8),
        2,
        Paint()..color = Colors.red.withValues(alpha: warningAlpha),
      );
    }

    // Damage indicator
    if (_hitsTaken > 0) {
      // Smoke/damage cracks
      for (int i = 0; i < _hitsTaken; i++) {
        canvas.drawLine(
          Offset(cx + (i * 8.0 - 8), cy - 4),
          Offset(cx + (i * 8.0 - 4), cy + 4),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.5)
            ..strokeWidth = 1.5,
        );
      }
    }
  }
}
