import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';

/// Scrolling terrain for Bombing War.
///
/// Rendered in screen space; the game feeds it a `cameraX` value each frame
/// so it can draw the currently visible slice of an otherwise huge world.
///
/// Layers, drawn back to front:
///   • sky gradient
///   • far mountains  (parallax 0.2)
///   • mid dunes      (parallax 0.5)
///   • ground surface + sand body  (1:1 with camera)
///   • underground L1 / L2 layers
///   • craters
class TerrainComponent extends Component {
  TerrainComponent({required this.terrainSeed, this.missionDistance = 2000.0})
      : super(priority: -10);

  final int terrainSeed;
  final double missionDistance;

  // Palette
  static const _skyTop = Color(0xFF1A0A2E);
  static const _skyMid = Color(0xFF6B3A5A);
  static const _skyHorizon = Color(0xFFE09060);
  static const _sandSurface = Color(0xFFD9B070);
  static const _sandMid = Color(0xFF9C7845);
  static const _sandDeep = Color(0xFF6A4A25);
  static const _rockL1 = Color(0xFF4A3018);
  static const _rockL2 = Color(0xFF2A1810);
  static const _duneColor = Color(0xFF8F6530);
  static const _mountainColor = Color(0xFF4A3020);

  late final List<_ParallaxMountain> _farMountains;
  late final List<_ParallaxDune> _midDunes;

  /// Perlin-ish ground profile (additive offset relative to groundLevel).
  late final List<double> _groundProfile;
  final List<_Crater> _craters = [];

  /// Horizontal camera offset, updated by the game each frame.
  double cameraX = 0.0;

  static const int _groundStep = 4; // draw ground every 4 px for perf

  @override
  Future<void> onLoad() async {
    final rng = Random(terrainSeed);
    _generateGroundProfile(rng);
    _farMountains = _generateFarMountains(rng);
    _midDunes = _generateMidDunes(rng);
  }

  /// Y-coordinate of the ground surface at the given world X.
  double groundLevelAt(double worldX) {
    final index = worldX.round().clamp(0, _groundProfile.length - 1);
    return GameConfig.groundLevel + _groundProfile[index];
  }

  /// Register a new crater at worldX and slightly depress the ground
  /// profile so later rendering shows a dip.
  void addCrater(double worldX, double radius) {
    _craters.add(_Crater(cx: worldX, radius: radius));
    final startX =
        (worldX - radius).round().clamp(0, _groundProfile.length - 1);
    final endX =
        (worldX + radius).round().clamp(0, _groundProfile.length - 1);
    for (int x = startX; x <= endX; x++) {
      final dist = (x - worldX).abs();
      final deformation = (1 - (dist / radius)) * radius * 0.25;
      if (deformation > 0) {
        _groundProfile[x] += deformation;
      }
    }
  }

  // ── Generation ─────────────────────────────────────────────────────────

  void _generateGroundProfile(Random rng) {
    final profileLength = missionDistance.round() + 200;
    _groundProfile = List<double>.filled(profileLength, 0.0);

    // Sum of a few sinusoid "octaves" → smooth, rolling dunes.
    for (int octave = 0; octave < 4; octave++) {
      final frequency = 0.004 * (1 << octave);
      final amplitude = 18.0 / (1 << octave);
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
    double x = -GameConfig.worldWidth;
    final limit = missionDistance + GameConfig.worldWidth * 2;
    while (x < limit) {
      final w = 160 + rng.nextDouble() * 220;
      final h = 60 + rng.nextDouble() * 90;
      list.add(_ParallaxMountain(x: x, width: w, height: h));
      x += w * 0.55 + rng.nextDouble() * 80;
    }
    return list;
  }

  List<_ParallaxDune> _generateMidDunes(Random rng) {
    final list = <_ParallaxDune>[];
    double x = -GameConfig.worldWidth;
    final limit = missionDistance + GameConfig.worldWidth * 2;
    while (x < limit) {
      final w = 90 + rng.nextDouble() * 140;
      final h = 22 + rng.nextDouble() * 36;
      list.add(_ParallaxDune(x: x, width: w, height: h));
      x += w * 0.45 + rng.nextDouble() * 40;
    }
    return list;
  }

  // ── Render ─────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    _drawSky(canvas);
    _drawParallaxFar(canvas);
    _drawParallaxMid(canvas);
    _drawGround(canvas);
    _drawUndergroundL1(canvas);
    _drawUndergroundL2(canvas);
    _drawCraters(canvas);
  }

  void _drawSky(Canvas canvas) {
    const rect =
        Rect.fromLTWH(0, 0, GameConfig.worldWidth, GameConfig.groundLevel);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(0, GameConfig.groundLevel),
          const [_skyTop, _skyMid, _skyHorizon],
          const [0.0, 0.6, 1.0],
        ),
    );
  }

  void _drawParallaxFar(Canvas canvas) {
    final offset = cameraX * GameConfig.parallaxFarSpeed;
    final paint = Paint()..color = _mountainColor.withValues(alpha: 0.5);
    for (final m in _farMountains) {
      final screenX = m.x - offset;
      if (screenX + m.width < 0 || screenX > GameConfig.worldWidth) continue;
      final path = Path()
        ..moveTo(screenX, GameConfig.groundLevel)
        ..lineTo(screenX + m.width * 0.3, GameConfig.groundLevel - m.height)
        ..lineTo(
            screenX + m.width * 0.5, GameConfig.groundLevel - m.height * 0.85)
        ..lineTo(
            screenX + m.width * 0.7, GameConfig.groundLevel - m.height * 0.95)
        ..lineTo(screenX + m.width, GameConfig.groundLevel)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawParallaxMid(Canvas canvas) {
    final offset = cameraX * GameConfig.parallaxMidSpeed;
    final paint = Paint()..color = _duneColor.withValues(alpha: 0.55);
    for (final d in _midDunes) {
      final screenX = d.x - offset;
      if (screenX + d.width < 0 || screenX > GameConfig.worldWidth) continue;
      final path = Path()
        ..moveTo(screenX, GameConfig.groundLevel)
        ..quadraticBezierTo(
          screenX + d.width / 2,
          GameConfig.groundLevel - d.height,
          screenX + d.width,
          GameConfig.groundLevel,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawGround(Canvas canvas) {
    // Build a single filled polygon for the visible ground slice.
    final camStart = cameraX.floor().clamp(0, _groundProfile.length - 1);
    final camEnd = (cameraX + GameConfig.worldWidth)
        .ceil()
        .clamp(0, _groundProfile.length - 1);

    if (camEnd <= camStart) return;

    final path = Path();
    bool first = true;
    for (int x = camStart; x <= camEnd; x += _groundStep) {
      final screenX = (x - cameraX).toDouble();
      final y = GameConfig.groundLevel + _groundProfile[x];
      if (first) {
        path.moveTo(screenX, y);
        first = false;
      } else {
        path.lineTo(screenX, y);
      }
    }
    // Close the path to the bottom of the L1 band.
    path.lineTo(
        (camEnd - cameraX).toDouble(), GameConfig.undergroundL1Top);
    path.lineTo((camStart - cameraX).toDouble(), GameConfig.undergroundL1Top);
    path.close();

    const r = Rect.fromLTWH(
        0, GameConfig.groundLevel - 40, GameConfig.worldWidth, 100);
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          r.topCenter,
          r.bottomCenter,
          const [_sandSurface, _sandMid, _sandDeep],
          const [0.0, 0.5, 1.0],
        ),
    );

    // Crisp surface outline on top of the sand body.
    final outline = Path();
    bool firstOutline = true;
    for (int x = camStart; x <= camEnd; x += _groundStep) {
      final screenX = (x - cameraX).toDouble();
      final y = GameConfig.groundLevel + _groundProfile[x];
      if (firstOutline) {
        outline.moveTo(screenX, y);
        firstOutline = false;
      } else {
        outline.lineTo(screenX, y);
      }
    }
    canvas.drawPath(
      outline,
      Paint()
        ..color = _sandSurface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawUndergroundL1(Canvas canvas) {
    const r = Rect.fromLTWH(
      0,
      GameConfig.undergroundL1Top,
      GameConfig.worldWidth,
      GameConfig.undergroundL1Bottom - GameConfig.undergroundL1Top,
    );
    canvas.drawRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          r.topCenter,
          r.bottomCenter,
          const [_sandDeep, _rockL1],
        ),
    );

    canvas.drawLine(
      const Offset(0, GameConfig.undergroundL1Bottom),
      const Offset(GameConfig.worldWidth, GameConfig.undergroundL1Bottom),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..strokeWidth = 2,
    );
  }

  void _drawUndergroundL2(Canvas canvas) {
    const r = Rect.fromLTWH(
      0,
      GameConfig.undergroundL2Top,
      GameConfig.worldWidth,
      GameConfig.undergroundL2Bottom - GameConfig.undergroundL2Top,
    );
    canvas.drawRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          r.topCenter,
          r.bottomCenter,
          const [_rockL1, _rockL2],
        ),
    );
  }

  void _drawCraters(Canvas canvas) {
    for (final c in _craters) {
      final screenX = c.cx - cameraX;
      if (screenX < -c.radius || screenX > GameConfig.worldWidth + c.radius) {
        continue;
      }

      final groundY = groundLevelAt(c.cx);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(screenX, groundY),
          width: c.radius * 2,
          height: c.radius * 0.6,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.5),
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(screenX, groundY),
          width: c.radius * 2.4,
          height: c.radius * 0.75,
        ),
        Paint()
          ..color = const Color(0xFF3A2A10).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }
}

class _ParallaxMountain {
  const _ParallaxMountain(
      {required this.x, required this.width, required this.height});
  final double x, width, height;
}

class _ParallaxDune {
  const _ParallaxDune(
      {required this.x, required this.width, required this.height});
  final double x, width, height;
}

class _Crater {
  const _Crater({required this.cx, required this.radius});
  final double cx, radius;
}
