import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CraterComponent extends PositionComponent {
  CraterComponent({required Vector2 position, this.radius = 20.0})
      : super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center, priority: -1);

  final double radius;
  final double _lifeTime = 10.0;
  double _elapsed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _lifeTime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - _elapsed / _lifeTime).clamp(0.0, 1.0);
    
    // Hole
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: radius * 2, height: radius * 0.8),
      Paint()..color = Colors.black.withValues(alpha: 0.6 * opacity),
    );
    
    // Scorch marks
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: radius * 2.5, height: radius * 1.0),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }
}
