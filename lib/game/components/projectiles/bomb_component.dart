import 'dart:math' as math;
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
    
    final mainColor = isPenetrator ? const Color(0xFF444444) : const Color(0xFF556644);
    final highlightColor = isPenetrator ? const Color(0xFFFF2200) : const Color(0xFF778866);

    final paint = Paint()..color = mainColor;
    
    // Rotation based on velocity
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final angle = math.atan2(_verticalSpeed, _horizontalSpeed);
    canvas.rotate(angle);

    // Bomb Body (Tapered Cylinder/Oval)
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y * 0.7),
      paint,
    );

    // Nose cone
    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.x * 0.2, 0), width: size.x * 0.6, height: size.y * 0.7),
      -1.57, 3.14, true, 
      Paint()..color = highlightColor
    );

    // Fins (at the back)
    final finPath = Path()
      ..moveTo(-size.x * 0.3, -size.y * 0.3)
      ..lineTo(-size.x * 0.5, -size.y * 0.5)
      ..lineTo(-size.x * 0.5, size.y * 0.5)
      ..lineTo(-size.x * 0.3, size.y * 0.3)
      ..close();
    canvas.drawPath(finPath, paint);

    canvas.restore();
  }
}
