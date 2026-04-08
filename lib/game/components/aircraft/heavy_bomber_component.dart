import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import 'aircraft_component.dart';

/// Heavy Bomber — slow but armored.
/// Special: Armor — 50% damage reduction for [armorDuration] seconds.
class HeavyBomberComponent extends AircraftComponent {
  HeavyBomberComponent({required super.data, required super.game});

  bool _armorActive = false;

  @override
  Color get bodyColor =>
      _armorActive ? const Color(0xFFFFAA00) : const Color(0xFF888888);
  @override
  Color get wingColor =>
      _armorActive ? const Color(0xFFCC7700) : const Color(0xFF555555);
  @override
  double get specialDuration => GameConfig.armorDuration;

  @override
  void onSpecialStart() => _armorActive = true;

  @override
  void onSpecialEnd() => _armorActive = false;

  @override
  double applyDamageReduction(double amount) {
    if (_armorActive) return amount * (1.0 - GameConfig.armorDamageReduction);
    return amount;
  }
}
