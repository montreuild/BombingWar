import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../bombing_war_game.dart';

/// Manages the GBU-57 cutscene sequence:
/// 1. Partial fade, camera pulls back
/// 2. B-2 Spirit traverses the frame (semi-transparent sprite)
/// 3. GBU-57 drop, animated fall
/// 4. Underground L2 impact: explosion in L2, no surface crater
/// 5. Surface enemies get STAGGER animation (no damage)
/// 6. Targeted L2 bunker destroyed
/// 7. Return to gameplay
class CutsceneManager extends Component {
  CutsceneManager({
    required this.game,
    required this.targetPosition,
    this.onComplete,
  });

  final BombingWarGame game;
  final Vector2 targetPosition;
  final VoidCallback? onComplete;

  double _elapsed = 0.0;
  bool _isActive = false;
  bool _bombDropped = false;
  bool _impactDone = false;

  // B-2 Spirit position
  double _b2X = -100.0;
  double _b2Y = 40.0;

  // GBU bomb position
  double _gbuX = 0.0;
  double _gbuY = 0.0;
  bool _gbuVisible = false;

  // Fade overlay
  double _fadeAlpha = 0.0;

  bool get isActive => _isActive;

  void startCutscene() {
    _isActive = true;
    _elapsed = 0.0;
    _bombDropped = false;
    _impactDone = false;
    _b2X = -100.0;
    _b2Y = 40.0;
    _fadeAlpha = 0.0;
    _gbuVisible = false;
  }

  @override
  void update(double dt) {
    if (!_isActive) return;
    _elapsed += dt;
    const totalDuration = GameConfig.cutsceneDuration;

    // Phase 1: Fade in (0 - 0.5s)
    if (_elapsed < 0.5) {
      _fadeAlpha = (_elapsed / 0.5) * 0.4; // Max 40% fade
    }
    // Phase 2: B-2 fly-by (0.5 - 2.5s)
    else if (_elapsed < 2.5) {
      _b2X += GameConfig.b2SpiritSpeed * dt;

      // Drop bomb at center of screen
      if (!_bombDropped && _b2X >= targetPosition.x) {
        _bombDropped = true;
        _gbuVisible = true;
        _gbuX = _b2X;
        _gbuY = _b2Y + 10;
      }
    }
    // Phase 3: Bomb fall + impact (2.5 - 3.5s)
    else if (_elapsed < 3.5) {
      if (_gbuVisible && !_impactDone) {
        _gbuY += GameConfig.gbuSpeed * dt;
        // Impact at underground L2
        if (_gbuY >= GameConfig.undergroundL2Top) {
          _impactDone = true;
          _gbuVisible = false;
          _performImpact();
        }
      }
    }
    // Phase 4: Fade out + return (3.5 - 4.0s)
    else if (_elapsed < totalDuration) {
      _fadeAlpha = math.max(0, _fadeAlpha - dt * 2);
    }
    // Done
    else {
      _isActive = false;
      _fadeAlpha = 0.0;
      onComplete?.call();
    }
  }

  void _performImpact() {
    // Explosion in L2
    game.spawnExplosion(
      Vector2(targetPosition.x, GameConfig.undergroundL2Top + 10),
      radius: GameConfig.gbuExplosionRadius,
    );

    // Destroy targeted L2 bunker
    game.destroyReinforcedBunkerAt(targetPosition);

    // Stagger surface enemies (no damage)
    game.staggerSurfaceEnemiesNear(targetPosition.x);
  }

  @override
  void render(Canvas canvas) {
    if (!_isActive) return;

    // Fade overlay
    if (_fadeAlpha > 0) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, GameConfig.worldWidth, GameConfig.worldHeight),
        Paint()..color = Colors.black.withValues(alpha: _fadeAlpha),
      );
    }

    // B-2 Spirit
    if (_elapsed >= 0.5 && _elapsed < 3.0) {
      _renderB2Spirit(canvas);
    }

    // GBU-57 bomb
    if (_gbuVisible) {
      _renderGBU(canvas);
    }

    // Impact flash
    if (_impactDone && _elapsed < 3.2) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, GameConfig.worldWidth, GameConfig.worldHeight),
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }
  }

  void _renderB2Spirit(Canvas canvas) {
    final screenX = _b2X - game.cameraX;
    const alpha = 0.6; // Semi-transparent

    // B-2 flying wing shape
    final path = Path()
      ..moveTo(screenX + 40, _b2Y) // Nose
      ..lineTo(screenX + 25, _b2Y - 12) // Left wing tip
      ..lineTo(screenX - 40, _b2Y - 8) // Far left wing
      ..lineTo(screenX - 30, _b2Y) // Left trailing edge
      ..lineTo(screenX - 30, _b2Y + 2) // Right trailing edge
      ..lineTo(screenX - 40, _b2Y + 8) // Far right wing
      ..lineTo(screenX + 25, _b2Y + 12) // Right wing tip
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF2A2A3A).withValues(alpha: alpha),
    );

    // Cockpit
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(screenX + 30, _b2Y),
        width: 8,
        height: 4,
      ),
      Paint()..color = Colors.lightBlueAccent.withValues(alpha: alpha * 0.7),
    );

    // Engine glow
    for (final dy in [-4.0, 4.0]) {
      canvas.drawCircle(
        Offset(screenX - 20, _b2Y + dy),
        3,
        Paint()
          ..color = Colors.blue.withValues(alpha: alpha * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  void _renderGBU(Canvas canvas) {
    final screenX = _gbuX - game.cameraX;

    // GBU-57 bomb body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(screenX, _gbuY),
          width: 6,
          height: 20,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF3A3A3A),
    );

    // Nose cone
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(screenX, _gbuY + 10),
        width: 4,
        height: 6,
      ),
      Paint()..color = const Color(0xFF2A2A2A),
    );

    // Fins
    for (final dx in [-4.0, 4.0]) {
      canvas.drawLine(
        Offset(screenX, _gbuY - 8),
        Offset(screenX + dx, _gbuY - 12),
        Paint()
          ..color = Colors.grey.shade600
          ..strokeWidth = 1.5,
      );
    }
  }
}
