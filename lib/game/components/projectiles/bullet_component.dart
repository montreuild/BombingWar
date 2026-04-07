import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import 'projectile_component.dart';

/// Fast, straight-flying bullet.
class BulletComponent extends ProjectileComponent {
  BulletComponent({
    required Vector2 position,
    required this.direction,
    required double damage,
    required bool isPlayerProjectile,
  }) : super(
          position: position,
          damage: damage,
          isPlayerProjectile: isPlayerProjectile,
          size: GameConfig.bulletSize,
        );

  final Vector2 direction;

  @override
  double get maxLifespan =>
      GameConfig.bulletRange / GameConfig.bulletSpeed;

  @override
  void update(double dt) {
    position += direction * GameConfig.bulletSpeed * dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = isPlayerProjectile
          ? const Color(0xFFFFFF44)
          : const Color(0xFFFF4444);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
  }
}
