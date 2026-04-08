import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';

class StarfieldComponent extends Component {
  StarfieldComponent({this.starCount = 100});

  final int starCount;
  final List<_Star> _stars = [];
  final _rng = Random();

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < starCount; i++) {
      _stars.add(_Star(
        x: _rng.nextDouble() * GameConfig.worldWidth,
        y: _rng.nextDouble() * GameConfig.worldHeight,
        speed: 20.0 + _rng.nextDouble() * 100.0,
        size: 0.5 + _rng.nextDouble() * 1.5,
        opacity: 0.1 + _rng.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void update(double dt) {
    for (final star in _stars) {
      // Side-scrolling: move stars horizontally
      star.x -= (star.speed * 0.5) * dt; 
      if (star.x < 0) {
        star.x = GameConfig.worldWidth + 5;
        star.y = _rng.nextDouble() * GameConfig.skyHeight;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in _stars) {
      paint.color = Colors.white.withValues(alpha: star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
  double x, y;
  final double speed;
  final double size;
  final double opacity;
}
