import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import 'projectile_component.dart';

/// Gravity-affected bomb that falls downward with acceleration.
/// isPenetrator = true for the Stealth X-26 penetrator bomb.
class BombComponent extends ProjectileComponent {
  BombComponent({
    required super.position,
    required super.damage,
    required super.explosionRadius,
    required super.isPlayerProjectile,
    required super.isPenetrator,
  })  : _horizontalSpeed = isPlayerProjectile ? 100.0 : 0.0,
        _verticalSpeed = 0.0,
        super(
          size: isPenetrator ? GameConfig.penetratorSize : GameConfig.bombSize,
        );

  final double _horizontalSpeed;
  double _verticalSpeed;

  BombComponent({
    required super.position,
    required super.damage,
    required super.explosionRadius,
    required super.isPlayerProjectile,
    required super.isPenetrator,
  })  : _horizontalSpeed = isPlayerProjectile ? 100.0 : 0.0,
        _verticalSpeed = 0.0,
        super(
          size: isPenetrator ? GameConfig.penetratorSize : GameConfig.bombSize,
        );

  @override
  void update(double dt) {
    // Parabolic trajectory
    _verticalSpeed += GameConfig.gravityAcceleration * 5 * dt; // Stronger gravity for side-view
    position.y += _verticalSpeed * dt;
    position.x += _horizontalSpeed * dt;

    // Penetrator logic: it doesn't explode on ground level, it goes deeper
    if (!isPenetrator && position.y >= GameConfig.groundLevel) {
      // Explode on surface
      removeFromParent();
    } else if (isPenetrator && position.y >= GameConfig.worldHeight) {
      // Penetrator explodes at the very bottom or when hitting a factory
      removeFromParent();
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final color = isPenetrator
        ? const Color(0xFFFF2200)
        : const Color(0xFFFF9900);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x * 0.7,
        height: size.y,
      ),
      Paint()..color = color,
    );

    if (isPenetrator) {
      canvas.drawPath(
        Path()
          ..moveTo(size.x / 2, 0)
          ..lineTo(size.x * 0.3, size.y * 0.3)
          ..lineTo(size.x * 0.7, size.y * 0.3)
          ..close(),
        Paint()..color = const Color(0xFFCC0000),
      );
    }
  }
}
