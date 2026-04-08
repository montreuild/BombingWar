import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Animated explosion: expanding shockwave + fading particles.
class ExplosionEffect extends PositionComponent {
  ExplosionEffect({
    required Vector2 position,
    this.radius = 40.0,
  }) : super(position: position, anchor: Anchor.center);

  final double radius;

  double _elapsed = 0.0;
  static const double _duration = 0.5;

  final _rng = Random();
  late final List<_Particle> _particles;

  @override
  Future<void> onLoad() async {
    // Spawn random particles once
    _particles = List.generate(12, (i) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = radius * 0.8 + _rng.nextDouble() * radius * 0.8;
      return _Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: [
          const Color(0xFFFF6600),
          const Color(0xFFFFCC00),
          const Color(0xFFFF2200),
          Colors.white,
        ][_rng.nextInt(4)],
        size: 3.0 + _rng.nextDouble() * 5.0,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
    }
    if (_elapsed >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / _duration).clamp(0.0, 1.0);
    final curve = Curves.easeOut.transform(progress);

    // Shockwave ring with bloom
    canvas.drawCircle(
      Offset.zero,
      radius * curve * 1.2,
      Paint()
        ..color = Color.fromRGBO(255, 200, 100, (1.0 - progress) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Inner flash
    if (progress < 0.4) {
      final flashOpacity = (1.0 - progress / 0.4);
      canvas.drawCircle(
        Offset.zero,
        radius * 0.6 * (1.0 - progress),
        Paint()
          ..color = Colors.white.withValues(alpha: flashOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Particles
    for (final p in _particles) {
      final pProgress = (_elapsed / _duration).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size * (1.0 - pProgress),
        Paint()
          ..color = p.color.withValues(alpha: 1.0 - pProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      
      // Small trails for particles
      canvas.drawLine(
        Offset(p.x, p.y),
        Offset(p.x - p.vx * 0.05, p.y - p.vy * 0.05),
        Paint()
          ..color = p.color.withValues(alpha: (1.0 - pProgress) * 0.3)
          ..strokeWidth = p.size * 0.5,
      );
    }
  }
}

class _Particle {
  _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
  double x = 0, y = 0;
  final double vx, vy;
  final Color color;
  final double size;
}
