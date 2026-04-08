import '../../config/game_config.dart';
import '../../models/enemy_data.dart';
import '../../models/level_data.dart';

/// Tracks session score in dollars ($), combos, penalties, and mission report.
class ScoreSystem {
  int _dollarGross = 0;
  int _dollarPenalties = 0;
  int _comboKills = 0;
  double _comboTimer = 0.0;
  int _multiplier = 1;

  // Mission report tracking
  int enemiesKilled = 0;
  int bunkersDestroyed = 0;
  int reinforcedBunkersDestroyed = 0;
  int factoriesDestroyed = 0;
  int bonusTargetsDestroyed = 0;
  int dronesIntercepted = 0;
  int dronesEscaped = 0;
  int droneLaunchersDestroyed = 0;
  int pilotsEjected = 0;
  int pilotsSurvived = 0;
  int planesLost = 0;

  /// Floating score feedback events (for HUD display).
  final List<ScoreFeedback> feedbackQueue = [];

  int get dollarGross => _dollarGross;
  int get dollarPenalties => _dollarPenalties;
  int get dollarNet => _dollarGross + _dollarPenalties; // penalties are negative
  int get multiplier => _multiplier;

  void update(double dt) {
    if (_comboTimer > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        _comboKills = 0;
        _multiplier = 1;
      }
    }
    // Remove expired feedback
    feedbackQueue.removeWhere((f) {
      f.age += dt;
      return f.age > 2.0;
    });
  }

  /// Register a kill by enemy type. Returns actual dollars awarded.
  int addKill(EnemyType type) {
    final data = EnemyData.byType[type];
    if (data == null) return 0;

    _comboKills++;
    _comboTimer = GameConfig.comboWindowSeconds;

    if (_comboKills >= GameConfig.comboKillsForX3) {
      _multiplier = 3;
    } else if (_comboKills >= GameConfig.comboKillsForX2) {
      _multiplier = 2;
    }

    final awarded = data.scoreValue * _multiplier;
    _dollarGross += awarded;

    // Track for mission report
    if (data.isBonus) {
      bonusTargetsDestroyed++;
    } else if (data.countsForVictory) {
      enemiesKilled++;
    }

    // Track specific types
    switch (type) {
      case EnemyType.bunkerL1:
        bunkersDestroyed++;
        break;
      case EnemyType.reinforcedBunkerL2:
        reinforcedBunkersDestroyed++;
        break;
      case EnemyType.missileFactory:
        factoriesDestroyed++;
        break;
      case EnemyType.droneLauncher:
        droneLaunchersDestroyed++;
        break;
      case EnemyType.drone:
        dronesIntercepted++;
        break;
      default:
        break;
    }

    _addFeedback('+\$$awarded', false);
    return awarded;
  }

  /// Apply a penalty (negative value).
  void addPenalty(int amount, String reason) {
    _dollarPenalties += amount; // amount is already negative
    _addFeedback('\$$amount', true);
  }

  /// Add a flat bonus (e.g., ammo bonus, perfect bonus).
  void addBonus(int bonus) {
    _dollarGross += bonus;
    if (bonus > 0) {
      _addFeedback('+\$$bonus', false);
    }
  }

  /// Register plane lost.
  void registerPlaneLost() {
    planesLost++;
    addPenalty(GameConfig.penaltyPlaneLost, 'Avion perdu');
  }

  /// Register pilot ejection.
  void registerPilotEjected() {
    pilotsEjected++;
  }

  /// Register pilot survived.
  void registerPilotSurvived() {
    pilotsSurvived++;
  }

  /// Register drone escape.
  void registerDroneEscaped() {
    dronesEscaped++;
    addPenalty(GameConfig.penaltyDroneEscapes, 'Drone non neutralisé');
  }

  /// Register drone hit on plane.
  void registerDroneHitPlane() {
    addPenalty(GameConfig.penaltyDroneHitsPlane, 'Drone touche avion');
  }

  /// Register pilot captured (game over).
  void registerPilotCaptured() {
    addPenalty(GameConfig.penaltyPilotCaptured, 'Pilote capturé');
  }

  /// Compute end-of-mission ammo bonus.
  int computeAmmoBonus(int remainingAmmo) {
    final bonus = remainingAmmo * GameConfig.ammoBonusMultiplier;
    if (bonus > 0) {
      addBonus(bonus);
    }
    return bonus;
  }

  /// Compute perfect bonus if all enemies destroyed.
  int computePerfectBonus(int totalEnemies) {
    if (totalEnemies > 0 && enemiesKilled >= totalEnemies) {
      addBonus(GameConfig.perfectBonus);
      return GameConfig.perfectBonus;
    }
    return 0;
  }

  /// Build the mission report.
  MissionReport buildReport(int totalEnemies) {
    final report = MissionReport(
      score: dollarNet,
      enemiesKilled: enemiesKilled,
      totalEnemies: totalEnemies,
      bunkersDestroyed: bunkersDestroyed,
      reinforcedBunkersDestroyed: reinforcedBunkersDestroyed,
      factoriesDestroyed: factoriesDestroyed,
      bonusTargetsDestroyed: bonusTargetsDestroyed,
      dronesIntercepted: dronesIntercepted,
      dronesEscaped: dronesEscaped,
      droneLaunchersDestroyed: droneLaunchersDestroyed,
      pilotsEjected: pilotsEjected,
      pilotsSurvived: pilotsSurvived,
      planesLost: planesLost,
      dollarGross: _dollarGross,
      dollarPenalties: _dollarPenalties,
      dollarNet: dollarNet,
    );
    report.computeRating();
    return report;
  }

  void _addFeedback(String text, bool isPenalty) {
    feedbackQueue.add(ScoreFeedback(text: text, isPenalty: isPenalty));
  }

  void reset() {
    _dollarGross = 0;
    _dollarPenalties = 0;
    _comboKills = 0;
    _comboTimer = 0.0;
    _multiplier = 1;
    enemiesKilled = 0;
    bunkersDestroyed = 0;
    reinforcedBunkersDestroyed = 0;
    factoriesDestroyed = 0;
    bonusTargetsDestroyed = 0;
    dronesIntercepted = 0;
    dronesEscaped = 0;
    droneLaunchersDestroyed = 0;
    pilotsEjected = 0;
    pilotsSurvived = 0;
    planesLost = 0;
    feedbackQueue.clear();
  }
}

/// Score feedback floating text event.
class ScoreFeedback {
  ScoreFeedback({required this.text, required this.isPenalty});
  final String text;
  final bool isPenalty;
  double age = 0.0;
}
