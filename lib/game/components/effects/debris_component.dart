import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';

class DebrisComponent extends PositionComponent {
  DebrisComponent({
    required Vector2 position,
    required this.color,
    required Vector2 velocity,
    this.sizeValue = 4.0,
  }) : super(position: position, size: Vector2.all(sizeValue), anchor: Anchor.center) {
    _velocity = velocity;
  }

  final Color color;
  final double sizeValue;
  late Vector2 _velocity;
  double _rotationSpeed = (Random().nextDouble() - 0.5) * 10;
  final double _lifeTime = 1.5 + Random().nextDouble() * 1.5;
  double _elapsed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    
    // Gravity and air resistance
    _velocity.y += GameConfig.gravityAcceleration * 2 * dt;
    _velocity.x *= 0.98;
    
    position += _velocity * dt;
    angle += _rotationSpeed * dt;

    // Bounce or stop at ground
    if (position.y >= GameConfig.groundLevel - 2) {
      position.y = GameConfig.groundLevel - 2;
      _velocity.y = -_velocity.y * 0.4; // Bounce
      _velocity.x *= 0.8; // Friction
      _rotationSpeed *= 0.5;
    }

    if (_elapsed >= _lifeTime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - _elapsed / _lifeTime).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color.withValues(alpha: opacity),
    );
  }
}
