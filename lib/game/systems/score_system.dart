import '../../config/game_config.dart';

/// Tracks session score, combos, and multipliers.
class ScoreSystem {
  int _sessionScore = 0;
  int _comboKills = 0;
  double _comboTimer = 0.0;
  int _multiplier = 1;

  int get sessionScore => _sessionScore;
  int get multiplier => _multiplier;

  void update(double dt) {
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        // Combo window expired — reset
        _comboKills = 0;
        _multiplier = 1;
      }
    }
  }

  /// Register a kill worth [basePoints]. Returns actual points awarded.
  int addKill(int basePoints) {
    _comboKills++;
    _comboTimer = GameConfig.comboWindowSeconds;

    if (_comboKills >= GameConfig.comboKillsForX3) {
      _multiplier = 3;
    } else if (_comboKills >= GameConfig.comboKillsForX2) {
      _multiplier = 2;
    }

    final awarded = basePoints * _multiplier;
    _sessionScore += awarded;
    return awarded;
  }

  void addBonus(int bonus) {
    _sessionScore += bonus;
  }

  void reset() {
    _sessionScore = 0;
    _comboKills = 0;
    _comboTimer = 0.0;
    _multiplier = 1;
  }
}
