import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import 'projectile_component.dart';

/// Gravity-affected bomb that falls downward with acceleration.
/// isPenetrator = true for the Stealth X-26 penetrator bomb.
class BombComponent extends ProjectileComponent {
  BombComponent({
    required Vector2 position,
    required double damage,
    required double explosionRadius,
    required bool isPlayerProjectile,
    required bool isPenetrator,
  })  : _verticalSpeed =
            isPlayerProjectile ? GameConfig.bombSpeed : GameConfig.bombSpeed * 0.5,
        super(
          position: position,
          damage: damage,
          isPlayerProjectile: isPlayerProjectile,
          size: isPenetrator ? GameConfig.penetratorSize : GameConfig.bombSize,
          explosionRadius: explosionRadius,
          isPenetrator: isPenetrator,
        );

  double _verticalSpeed;

  @override
  void update(double dt) {
    // Gravity accelerates the bomb downward each frame
    _verticalSpeed += GameConfig.gravityAcceleration * dt;
    position.y += _verticalSpeed * dt;
    // Slight forward drift for carpet bombs
    if (!isPenetrator) {
      position.x += (_verticalSpeed * 0.02) * dt;
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
