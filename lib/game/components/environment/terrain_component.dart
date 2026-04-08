import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';

/// Terrain component for Desert Strike Mobile.
/// Procéduralement généré via Perlin noise selon le levelIndex.
/// 4 couches verticales : sky / ground / underground_L1 / underground_L2.
/// Parallax scrolling with 3 layers of different speeds.
/// Ground = irregular polygon (hills, dunes, craters).
class TerrainComponent extends Component {
  TerrainComponent({required this.terrainSeed, this.missionDistance = 2000.0});

  final int terrainSeed;
  final double missionDistance;

  // Colors
  static const _skyTop = Color(0xFF1A0A2E);
  static const _skyHorizon = Color(0xFFCC8844);
  static const _sandSurface = Color(0xFFC4A060);
  static const _sandMid = Color(0xFF9C7A45);
  static const _rockL1 = Color(0xFF5A3A1A);
  static const _rockL2 = Color(0xFF2E1A0A);
  static const _duneColor = Color(0xFF8A6530);
  static const _mountainColor = Color(0xFF4A3020);
  static const _rockerColor = Color(0xFF3B2A14);

  // Parallax backgrounds (generated procedurally)
  late final List<_ParallaxMountain> _farMountains;
  late final List<_ParallaxDune> _midDunes;
  late final List<_ParallaxRock> _nearRocks;

  // Ground profile (irregular polygon with Perlin noise)
  late final List<double> _groundProfile; // y-offset for each x pixel
  final List<_Crater> _craters = [];

  // Camera offset for scrolling
  double cameraX = 0.0;

  @override
  Future<void> onLoad() async {
    final rng = Random(terrainSeed);
    _generateGroundProfile(rng);
    _farMountains = _generateFarMountains(rng);
    _midDunes = _generateMidDunes(rng);
    _nearRocks = _generateNearRocks(rng);
  }

  /// Get the ground level (y coordinate) at a given world x position.
  double groundLevelAt(double worldX) {
    final index = worldX.round().clamp(0, _groundProfile.length - 1);
    return GameConfig.groundLevel + _groundProfile[index];
  }

  /// Add a crater deformation at worldX.
  void addCrater(double worldX, double radius) {
    _craters.add(_Crater(cx: worldX, radius: radius));
    // Deform the ground profile
    final startX = (worldX - radius).round().clamp(0, _groundProfile.length - 1);
    final endX = (worldX + radius).round().clamp(0, _groundProfile.length - 1);
    for (int x = startX; x <= endX; x++) {
      final dist = (x - worldX).abs();
      final deformation = (1 - (dist / radius)) * radius * 0.3;
      if (deformation > 0) {
        _groundProfile[x] += deformation; // push ground down
      }
    }
  }

  // ── Perlin noise approximation ──────────────────────────────────────────

  void _generateGroundProfile(Random rng) {
    final profileLength = missionDistance.round() + 100;
    _groundProfile = List<double>.filled(profileLength, 0.0);

    // Simple Perlin-like noise using multiple octaves
    for (int octave = 0; octave < 4; octave++) {
      final frequency = 0.003 * (1 << octave);
      final amplitude = 20.0 / (1 << octave);
      final phase = rng.nextDouble() * 2 * pi;
      for (int x = 0; x < profileLength; x++) {
        _groundProfile[x] +=
            sin(x * frequency + phase) * amplitude +
            cos(x * frequency * 1.7 + phase * 0.5) * amplitude * 0.5;
      }
    }
  }

  List<_ParallaxMountain> _generateFarMountains(Random rng) {
    final list = <_ParallaxMountain>[];
    double x = 0;
    while (x < missionDistance + GameConfig.worldWidth) {
      final w = 150 + rng.nextDouble() * 200;
      final h = 60 + rng.nextDouble() * 100;
      list.add(_ParallaxMountain(x: x, width: w, height: h));
      x += w * 0.7 + rng.nextDouble() * 100;
    }
    return list;
  }

  List<_ParallaxDune> _generateMidDunes(Random rng) {
    final list = <_ParallaxDune>[];
    double x = 0;
    while (x < missionDistance + GameConfig.worldWidth) {
      final w = 80 + rng.nextDouble() * 120;
      final h = 20 + rng.nextDouble() * 40;
      list.add(_ParallaxDune(x: x, width: w, height: h));
      x += w * 0.5 + rng.nextDouble() * 60;
    }
    return list;
  }

  List<_ParallaxRock> _generateNearRocks(Random rng) {
    final list = <_ParallaxRock>[];
    double x = 0;
    while (x < missionDistance + GameConfig.worldWidth) {
      final s = 8 + rng.nextDouble() * 16;
      list.add(_ParallaxRock(x: x, size: s));
      x += 100 + rng.nextDouble() * 200;
    }
    return list;
  }

  // ── render ───────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    _drawSky(canvas);
    _drawParallaxFar(canvas);
    _drawParallaxMid(canvas);
    _drawParallaxNear(canvas);
    _drawGround(canvas);
    _drawUndergroundL1(canvas);
    _drawUndergroundL2(canvas);
    _drawCraters(canvas);
  }

  void _drawSky(Canvas canvas) {
    final r = const Rect.fromLTWH(0, 0, GameConfig.worldWidth, GameConfig.groundLevel);
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyHorizon],
        ).createShader(r),
    );
  }

  void _drawParallaxFar(Canvas canvas) {
    final paint = Paint()..color = _mountainColor.withValues(alpha: 0.4);
    for (final m in _farMountains) {
      final screenX = m.x - cameraX * GameConfig.parallaxFarSpeed;
      // Wrap around for infinite scrolling
      final wrappedX = screenX % (missionDistance + GameConfig.worldWidth) - GameConfig.worldWidth;
      if (wrappedX > -m.width && wrappedX < GameConfig.worldWidth + m.width) {
        final path = Path()
          ..moveTo(wrappedX, GameConfig.groundLevel)
          ..lineTo(wrappedX + m.width * 0.3, GameConfig.groundLevel - m.height)
          ..lineTo(wrappedX + m.width * 0.5, GameConfig.groundLevel - m.height * 0.85)
          ..lineTo(wrappedX + m.width * 0.7, GameConfig.groundLevel - m.height * 0.95)
          ..lineTo(wrappedX + m.width, GameConfig.groundLevel)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawParallaxMid(Canvas canvas) {
    final paint = Paint()..color = _duneColor.withValues(alpha: 0.5);
    for (final d in _midDunes) {
      final screenX = d.x - cameraX * GameConfig.parallaxMidSpeed;
      final wrappedX = screenX % (missionDistance + GameConfig.worldWidth) - GameConfig.worldWidth;
      if (wrappedX > -d.width && wrappedX < GameConfig.worldWidth + d.width) {
        final path = Path()
          ..moveTo(wrappedX, GameConfig.groundLevel)
          ..quadraticBezierTo(
            wrappedX + d.width / 2,
            GameConfig.groundLevel - d.height,
            wrappedX + d.width,
            GameConfig.groundLevel,
          )
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawParallaxNear(Canvas canvas) {
    final paint = Paint()..color = _rockerColor.withValues(alpha: 0.7);
    for (final r in _nearRocks) {
      final screenX = r.x - cameraX * GameConfig.parallaxNearSpeed;
      final wrappedX = screenX % (missionDistance + GameConfig.worldWidth) - GameConfig.worldWidth;
      if (wrappedX > -r.size * 2 && wrappedX < GameConfig.worldWidth + r.size * 2) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(wrappedX, GameConfig.groundLevel - r.size * 0.3),
            width: r.size * 1.5,
            height: r.size,
          ),
          paint,
        );
      }
    }
  }

  void _drawGround(Canvas canvas) {
    // Draw irregular ground polygon
    final startX = cameraX.floor().clamp(0, _groundProfile.length - 1);
    final endX = (cameraX + GameConfig.worldWidth).ceil().clamp(0, _groundProfile.length - 1);

    final path = Path();
    path.moveTo(0, GameConfig.groundLevel + 20); // below visible ground

    for (int x = startX; x <= endX; x++) {
      final screenX = (x - cameraX).toDouble();
      final groundY = GameConfig.groundLevel + _groundProfile[x];
      if (x == startX) {
        path.moveTo(screenX, groundY);
      } else {
        path.lineTo(screenX, groundY);
      }
    }

    // Close the path at the bottom
    path.lineTo(endX - cameraX, GameConfig.undergroundL1Top);
    path.lineTo(0, GameConfig.undergroundL1Top);
    path.close();

    // Draw with sand gradient
    final r = const Rect.fromLTWH(0, GameConfig.groundLevel - 30, GameConfig.worldWidth, 80);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_sandSurface, _sandMid],
        ).createShader(r),
    );

    // Surface line
    final surfacePaint = Paint()
      ..color = _sandSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final surfacePath = Path();
    for (int x = startX; x <= endX; x++) {
      final screenX = (x - cameraX).toDouble();
      final groundY = GameConfig.groundLevel + _groundProfile[x];
      if (x == startX) {
        surfacePath.moveTo(screenX, groundY);
      } else {
        surfacePath.lineTo(screenX, groundY);
      }
    }
    canvas.drawPath(surfacePath, surfacePaint);
  }

  void _drawUndergroundL1(Canvas canvas) {
    final r = const Rect.fromLTWH(
      0,
      GameConfig.undergroundL1Top,
      GameConfig.worldWidth,
      GameConfig.undergroundL1Bottom - GameConfig.undergroundL1Top,
    );
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_sandMid, _rockL1],
        ).createShader(r),
    );

    // Strata line separating L1 from L2
    canvas.drawLine(
      const Offset(0, GameConfig.undergroundL1Bottom),
      const Offset(GameConfig.worldWidth, GameConfig.undergroundL1Bottom),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 2,
    );
  }

  void _drawUndergroundL2(Canvas canvas) {
    final r = const Rect.fromLTWH(
      0,
      GameConfig.undergroundL2Top,
      GameConfig.worldWidth,
      GameConfig.undergroundL2Bottom - GameConfig.undergroundL2Top,
    );
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_rockL1, _rockL2],
        ).createShader(r),
    );
  }

  void _drawCraters(Canvas canvas) {
    for (final c in _craters) {
      final screenX = c.cx - cameraX;
      if (screenX < -c.radius || screenX > GameConfig.worldWidth + c.radius) continue;

      final groundY = groundLevelAt(c.cx);

      // Crater shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(screenX, groundY),
          width: c.radius * 2,
          height: c.radius * 0.6,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.5),
      );

      // Scorch marks
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(screenX, groundY),
          width: c.radius * 2.5,
          height: c.radius * 0.8,
        ),
        Paint()
          ..color = const Color(0xFF3A2A10).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }
}

class _ParallaxMountain {
  const _ParallaxMountain({required this.x, required this.width, required this.height});
  final double x, width, height;
}

class _ParallaxDune {
  const _ParallaxDune({required this.x, required this.width, required this.height});
  final double x, width, height;
}

class _ParallaxRock {
  const _ParallaxRock({required this.x, required this.size});
  final double x, size;
}

class _Crater {
  const _Crater({required this.cx, required this.radius});
  final double cx, radius;
}
