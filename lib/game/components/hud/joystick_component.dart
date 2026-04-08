import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

/// Floating virtual joystick.
///
/// A touch anywhere in the lower-left quadrant of the screen becomes the
/// joystick's origin, the knob then tracks the finger's offset from that
/// origin. Releasing the touch resets the joystick. This "floating"
/// pattern is more forgiving on phones than a fixed-position stick.
class JoystickComponent extends PositionComponent {
  JoystickComponent({required this.game}) : super(priority: 10);

  final BombingWarGame game;

  Vector2 _origin = Vector2.zero();
  Vector2 _knobOffset = Vector2.zero();
  bool _active = false;

  /// Normalized direction vector, magnitude 0–1.
  Vector2 get direction {
    if (!_active || _knobOffset.length < 4) return Vector2.zero();
    final len = _knobOffset.length.clamp(0.0, GameConfig.joystickRadius);
    return _knobOffset.normalized() * (len / GameConfig.joystickRadius);
  }

  // Default visual center (used when the stick is inactive).
  Vector2 get _defaultCenter => Vector2(
        GameConfig.joystickRadius + GameConfig.hudPadding,
        GameConfig.worldHeight -
            GameConfig.joystickRadius -
            GameConfig.hudPadding,
      );

  /// Any touch in the left half of the screen (excluding the very top HUD
  /// bar) activates the stick.
  bool _isInActivationZone(Vector2 p) {
    return p.x < GameConfig.worldWidth / 2 && p.y > 40;
  }

  void onPanStart(Vector2 screenPos) {
    if (!_isInActivationZone(screenPos)) return;
    _active = true;
    _origin = screenPos.clone();
    _knobOffset = Vector2.zero();
  }

  void onPanUpdate(Vector2 screenPos) {
    if (!_active) return;
    final delta = screenPos - _origin;
    final len = delta.length;
    if (len > GameConfig.joystickRadius) {
      _knobOffset = delta.normalized() * GameConfig.joystickRadius;
    } else {
      _knobOffset = delta;
    }
  }

  void onPanEnd() {
    _active = false;
    _knobOffset = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = _active ? _origin : _defaultCenter;
    final ringAlpha = _active ? 0.28 : 0.15;
    final fillAlpha = _active ? 0.08 : 0.04;

    // Base ring
    canvas.drawCircle(
      Offset(center.x, center.y),
      GameConfig.joystickRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: ringAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Filled base
    canvas.drawCircle(
      Offset(center.x, center.y),
      GameConfig.joystickRadius,
      Paint()..color = Colors.white.withValues(alpha: fillAlpha),
    );

    // Knob
    final knobPos = center + _knobOffset;
    canvas.drawCircle(
      Offset(knobPos.x, knobPos.y),
      GameConfig.joystickKnobRadius,
      Paint()..color = Colors.white.withValues(alpha: _active ? 0.55 : 0.18),
    );
  }
}
