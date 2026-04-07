import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

/// Virtual joystick rendered in the bottom-left quadrant.
/// Tracks touch/pan input and exposes a normalized direction vector.
class JoystickComponent extends PositionComponent {
  JoystickComponent({required this.game}) : super(priority: 10);

  final BombingWarGame game;

  Vector2 _knobOffset = Vector2.zero();
  bool _active = false;
  int? _pointerId;

  /// Normalized direction vector, magnitude 0–1.
  Vector2 get direction {
    if (!_active || _knobOffset.isZero()) return Vector2.zero();
    final len = _knobOffset.length.clamp(0.0, GameConfig.joystickRadius);
    return _knobOffset.normalized() * (len / GameConfig.joystickRadius);
  }

  // Center of the joystick in world coords
  Vector2 get _center => Vector2(
        GameConfig.joystickRadius + GameConfig.hudPadding * 2,
        GameConfig.worldHeight -
            GameConfig.joystickRadius -
            GameConfig.hudPadding * 2,
      );

  /// Called by BombingWarGame pan callbacks.
  void onPanStart(Vector2 worldPos) {
    if (_isNearCenter(worldPos)) {
      _active = true;
      _updateKnob(worldPos);
    }
  }

  void onPanUpdate(Vector2 worldPos) {
    if (_active) _updateKnob(worldPos);
  }

  void onPanEnd() {
    _active = false;
    _knobOffset = Vector2.zero();
  }

  void _updateKnob(Vector2 worldPos) {
    final delta = worldPos - _center;
    final len = delta.length;
    if (len > GameConfig.joystickRadius) {
      _knobOffset = delta.normalized() * GameConfig.joystickRadius;
    } else {
      _knobOffset = delta.clone();
    }
  }

  bool _isNearCenter(Vector2 pos) {
    return (pos - _center).length < GameConfig.joystickRadius * 1.5;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final c = _center;
    // Base ring
    canvas.drawCircle(
      Offset(c.x, c.y),
      GameConfig.joystickRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Filled base
    canvas.drawCircle(
      Offset(c.x, c.y),
      GameConfig.joystickRadius,
      Paint()..color = Colors.white.withOpacity(0.05),
    );

    // Knob
    final knobPos = c + _knobOffset;
    canvas.drawCircle(
      Offset(knobPos.x, knobPos.y),
      GameConfig.joystickKnobRadius,
      Paint()..color = Colors.white.withOpacity(_active ? 0.5 : 0.2),
    );
  }
}
