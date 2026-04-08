import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import 'projectile_component.dart';

/// Fast, straight-flying bullet.
class BulletComponent extends ProjectileComponent {
  BulletComponent({
    required super.position,
    required this.direction,
    required super.damage,
    required super.isPlayerProjectile,
  }) : super(
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
    
    // 1. Trail / Motion Blur effect
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          (isPlayerProjectile ? const Color(0xFFFFFF44) : const Color(0xFFFF4444)).withValues(alpha: 0.0),
          (isPlayerProjectile ? const Color(0xFFFFFF44) : const Color(0xFFFF4444)).withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(-10, 0, 10, size.y));
    
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(direction.angleTo(Vector2(1, 0)) * -1); // Face movement
    
    // Trail
    canvas.drawRect(const Rect.fromLTWH(-15, -1.5, 15, 3), trailPaint);

    // 2. Core projectile (Glowing bullet)
    final bulletPaint = Paint()
      ..color = isPlayerProjectile ? const Color(0xFFFFFFEE) : const Color(0xFFFFEEEE);
    
    final glowPaint = Paint()
      ..color = isPlayerProjectile ? const Color(0xFFFFFF44) : const Color(0xFFFF4444)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Glow
    canvas.drawCircle(const Offset(0, 0), size.x * 0.8, glowPaint);
    // Bullet
    canvas.drawCircle(const Offset(0, 0), size.x * 0.4, bulletPaint);
    
    canvas.restore();
  }
}
