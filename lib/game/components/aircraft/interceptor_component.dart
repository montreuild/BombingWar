import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../../models/aircraft_data.dart';
import '../../bombing_war_game.dart';
import 'aircraft_component.dart';

/// Fast interceptor aircraft.
/// Special: Barrel Roll — brief invincibility + rotation animation.
class InterceptorComponent extends AircraftComponent {
  InterceptorComponent({required super.data, required super.game});

  bool _rolling = false;
  double _rollAngle = 0.0;

  @override
  Color get bodyColor => const Color(0xFF4488FF);
  @override
  Color get wingColor => const Color(0xFF2255CC);
  @override
  double get specialDuration => GameConfig.barrelRollDuration;

  @override
  void onSpecialStart() {
    _rolling = true;
    setInvincible(GameConfig.barrelRollDuration);
  }

  @override
  void onSpecialEnd() {
    _rolling = false;
    _rollAngle = 0.0;
    angle = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_rolling) {
      _rollAngle += 360.0 * dt / GameConfig.barrelRollDuration;
      angle = _rollAngle * 3.14159 / 180.0;
    }
  }
}
