import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';

/// Terrain component — draws a night-time Middle-East desert backdrop:
/// starry sky, crescent moon, city silhouettes with minarets, sandy ground
/// and a rocky underground layer.
class TerrainComponent extends Component {
  static const _skyTop = Color(0xFF060C14);
  static const _skyHorizon = Color(0xFF111E30);
  static const _sandSurface = Color(0xFFC4A060);
  static const _sandMid = Color(0xFF9C7A45);
  static const _rockDeep = Color(0xFF3B2A14);
  static const _buildingColor = Color(0xFF1A1208);
  static const _duneColor = Color(0xFF5A4020);
  static const _windowColor = Color(0xFFFFBB44);

  late final List<_Building> _buildings;
  late final List<_Dune> _dunes;

  @override
  Future<void> onLoad() async {
    final rng = Random(GameConfig.terrainSeedMultiplier);
    _dunes = _buildDunes(rng);
    _buildings = _buildBuildings(rng);
  }

  // ── generators ──────────────────────────────────────────────────────────

  List<_Dune> _buildDunes(Random rng) {
    final list = <_Dune>[];
    double x = 0;
    while (x < GameConfig.worldWidth) {
      final w = 90.0 + rng.nextDouble() * 150;
      final h = 15.0 + rng.nextDouble() * 25;
      list.add(_Dune(cx: x + w / 2, w: w, h: h));
      x += w * 0.6 + rng.nextDouble() * 40;
    }
    return list;
  }

  List<_Building> _buildBuildings(Random rng) {
    final list = <_Building>[];
    double x = 30.0;
    while (x < GameConfig.worldWidth - 20) {
      final type = rng.nextInt(3); // 0=flat, 1=domed, 2=minaret
      final w = type == 2 ? 12.0 + rng.nextDouble() * 10 : 22.0 + rng.nextDouble() * 38;
      final h = type == 2 ? 55.0 + rng.nextDouble() * 50 : 20.0 + rng.nextDouble() * 45;
      list.add(_Building(x: x, w: w, h: h, type: type, hasWindow: rng.nextBool()));
      x += w + 2.0 + rng.nextDouble() * 60;
    }
    return list;
  }

  // ── render ───────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    _drawSky(canvas);
    _drawMoon(canvas);
    _drawDunes(canvas);
    _drawBuildings(canvas);
    _drawGround(canvas);
    _drawUnderground(canvas);
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

  void _drawMoon(Canvas canvas) {
    const cx = GameConfig.worldWidth * 0.82;
    const cy = 48.0;
    // Full moon disc
    canvas.drawCircle(
      const Offset(cx, cy),
      20,
      Paint()..color = const Color(0xFFEDE8C0),
    );
    // Shadow to create crescent
    canvas.drawCircle(
      const Offset(cx + 11, cy - 4),
      18,
      Paint()..color = _skyTop,
    );
    // Faint glow
    canvas.drawCircle(
      const Offset(cx, cy),
      28,
      Paint()
        ..color = const Color(0x11EDE8C0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawDunes(Canvas canvas) {
    final paint = Paint()..color = _duneColor;
    for (final d in _dunes) {
      final path = Path()
        ..moveTo(d.cx - d.w / 2, GameConfig.groundLevel)
        ..quadraticBezierTo(d.cx, GameConfig.groundLevel - d.h, d.cx + d.w / 2, GameConfig.groundLevel)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawBuildings(Canvas canvas) {
    final bp = Paint()..color = _buildingColor;
    final wp = Paint()..color = _windowColor.withValues(alpha: 0.75);

    for (final b in _buildings) {
      final baseY = GameConfig.groundLevel - b.h;
      // Main body
      canvas.drawRect(Rect.fromLTWH(b.x, baseY, b.w, b.h), bp);

      if (b.type == 1) {
        // Dome on top
        canvas.drawArc(
          Rect.fromLTWH(b.x, baseY - b.w * 0.5, b.w, b.w),
          pi, pi, false, bp,
        );
      } else if (b.type == 2) {
        // Minaret tower above body
        final tw = b.w * 0.55;
        final tx = b.x + (b.w - tw) / 2;
        canvas.drawRect(Rect.fromLTWH(tx, baseY - b.h * 0.7, tw, b.h * 0.7), bp);
        // Pointed top
        final tip = Path()
          ..moveTo(tx, baseY - b.h * 0.7)
          ..lineTo(tx + tw, baseY - b.h * 0.7)
          ..lineTo(tx + tw / 2, baseY - b.h * 0.95)
          ..close();
        canvas.drawPath(tip, bp);
        // Balcony ring
        canvas.drawRect(
          Rect.fromLTWH(tx - 2, baseY - b.h * 0.4, tw + 4, 3),
          Paint()..color = const Color(0xFF2A1E08),
        );
      }

      // Window light
      if (b.hasWindow && b.w > 16) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(b.x + b.w * 0.2, baseY + b.h * 0.25, 5, 7),
            const Radius.circular(1),
          ),
          wp,
        );
        if (b.w > 28) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(b.x + b.w * 0.65, baseY + b.h * 0.25, 5, 7),
              const Radius.circular(1),
            ),
            wp,
          );
        }
      }
    }
  }

  void _drawGround(Canvas canvas) {
    // Sand surface band
    canvas.drawRect(
      const Rect.fromLTWH(0, GameConfig.groundLevel, GameConfig.worldWidth, 6),
      Paint()..color = _sandSurface,
    );
    canvas.drawRect(
      const Rect.fromLTWH(0, GameConfig.groundLevel + 6, GameConfig.worldWidth, 14),
      Paint()..color = _sandMid,
    );
    // Subtle sand ripples
    final ripple = Paint()
      ..color = _sandSurface.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 18; i++) {
      final y = GameConfig.groundLevel + 10 + i * 6.0;
      if (y >= GameConfig.groundLevel + 20) break;
      canvas.drawLine(Offset(i * 48.0, y), Offset(i * 48.0 + 28, y), ripple);
    }
  }

  void _drawUnderground(Canvas canvas) {
    final r = Rect.fromLTWH(
      0,
      GameConfig.groundLevel + 20,
      GameConfig.worldWidth,
      GameConfig.worldHeight - GameConfig.groundLevel - 20,
    );
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_sandMid, _rockDeep],
        ).createShader(r),
    );
    // Geological strata lines
    final strata = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final dy in [38.0, 70.0]) {
      canvas.drawLine(
        Offset(0, GameConfig.groundLevel + dy),
        Offset(GameConfig.worldWidth, GameConfig.groundLevel + dy),
        strata,
      );
    }
  }
}

class _Dune {
  const _Dune({required this.cx, required this.w, required this.h});
  final double cx, w, h;
}

class _Building {
  const _Building({
    required this.x,
    required this.w,
    required this.h,
    required this.type,
    required this.hasWindow,
  });
  final double x, w, h;
  final int type;       // 0=flat roof, 1=domed, 2=minaret
  final bool hasWindow;
}
