import '../../config/game_config.dart';

/// Tracks the threat / detection level (0-100%).
/// When full, triggers a missile barrage.
class ThreatSystem {
  double _threatLevel = 0.0;
  bool _barrageTriggered = false;
  int _destroyedRadarTowers = 0;

  double get threatLevel => _threatLevel;
  double get threatPercent => _threatLevel.clamp(0.0, 100.0);

  void update(double dt, {bool isStealthActive = false}) {
    if (_barrageTriggered) {
      // Brief pause after barrage before threat resets
      _threatLevel = 0.0;
      _barrageTriggered = false;
      return;
    }

    final fillMultiplier = isStealthActive ? GameConfig.stealthThreatMultiplier : 1.0;
    final radarReduction = _destroyedRadarTowers * GameConfig.radarTowerThreatReduction;
    final netRate = (GameConfig.threatFillRate * fillMultiplier) - radarReduction;

    _threatLevel += netRate * dt;

    // Passive decay when radar network is disrupted
    if (_destroyedRadarTowers > 0) {
      _threatLevel -= GameConfig.threatDecayRate * dt;
    }

    _threatLevel = _threatLevel.clamp(0.0, 100.0);
  }

  /// Returns true when barrage should be triggered (call once per threshold crossing).
  bool checkBarrage(void Function() onBarrage) {
    if (_threatLevel >= GameConfig.threatBarrageThreshold && !_barrageTriggered) {
      _barrageTriggered = true;
      onBarrage();
      return true;
    }
    return false;
  }

  void registerRadarTowerDestroyed() {
    _destroyedRadarTowers++;
  }

  void reset() {
    _threatLevel = 0.0;
    _barrageTriggered = false;
    _destroyedRadarTowers = 0;
  }
}
