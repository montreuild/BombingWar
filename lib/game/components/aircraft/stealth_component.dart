import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import 'aircraft_component.dart';

/// Stealth X-26 — reduced threat buildup.
/// Only aircraft whose penetrator bomb can destroy Underground Factories.
/// Special: Cloak — invisible to AA, slows threat bar fill rate.
class StealthComponent extends AircraftComponent {
  StealthComponent({required super.data, required super.game});

  bool _cloakActive = false;

  @override
  bool get isCloaked => _cloakActive;

  @override
  Color get bodyColor =>
      _cloakActive ? const Color(0xFF223322) : const Color(0xFF44AA44);
  @override
  Color get wingColor =>
      _cloakActive ? const Color(0xFF112211) : const Color(0xFF227722);
  @override
  double get specialDuration => GameConfig.cloakDuration;

  @override
  void onSpecialStart() => _cloakActive = true;

  @override
  void onSpecialEnd() => _cloakActive = false;
}
