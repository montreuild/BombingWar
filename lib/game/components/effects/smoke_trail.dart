import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Fading smoke puff left by aircraft or missiles.
class SmokeTrail extends PositionComponent {
  SmokeTrail({required Vector2 position, this.color = const Color(0x88888888)})
      : super(position: position, anchor: Anchor.center);

  final Color color;
  double _elapsed = 0.0;
  static const double _duration = 0.8;
  static const double _maxRadius = 12.0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / _duration).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset.zero,
      _maxRadius * progress,
      Paint()
        ..color = color.withValues(alpha: (1.0 - progress) * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}
