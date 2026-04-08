import 'enemy_data.dart';

/// Configuration for a single level, generated from levelIndex.
class LevelConfig {
  const LevelConfig({
    required this.levelIndex,
    required this.terrainSeed,
    required this.difficulty,
    required this.missionDistance,
    required this.surfaceEnemies,
    required this.undergroundL1Enemies,
    required this.undergroundL2Enemies,
    required this.bonusTargets,
    required this.totalEnemies,
    required this.totalBonusTargets,
  });

  final int levelIndex;
  final int terrainSeed;
  final double difficulty;
  final double missionDistance;

  /// Surface combat enemies (soldiers, jeeps, rocket launchers, drone launchers).
  final List<EnemySpawnData> surfaceEnemies;

  /// Underground level 1 enemies (bunkers, missile factories).
  final List<EnemySpawnData> undergroundL1Enemies;

  /// Underground level 2 enemies (reinforced bunkers).
  final List<EnemySpawnData> undergroundL2Enemies;

  /// Bonus targets (radar, fortification, oil well, power plant).
  final List<EnemySpawnData> bonusTargets;

  /// Total enemies that count for the 80% victory ratio.
  final int totalEnemies;

  /// Total bonus targets (don't count for victory ratio).
  final int totalBonusTargets;
}

/// Spawn position and type data for a single enemy.
class EnemySpawnData {
  const EnemySpawnData({
    required this.type,
    required this.xPosition,
    this.yPosition,
  });

  final EnemyType type;

  /// X position along the mission distance.
  final double xPosition;

  /// Y position (if null, placed at default layer position).
  final double? yPosition;
}

/// Mission report data shown at end of mission.
class MissionReport {
  MissionReport({
    this.score = 0,
    this.enemiesKilled = 0,
    this.totalEnemies = 0,
    this.bunkersDestroyed = 0,
    this.reinforcedBunkersDestroyed = 0,
    this.factoriesDestroyed = 0,
    this.bonusTargetsDestroyed = 0,
    this.dronesIntercepted = 0,
    this.dronesEscaped = 0,
    this.droneLaunchersDestroyed = 0,
    this.pilotsEjected = 0,
    this.pilotsSurvived = 0,
    this.planesLost = 0,
    this.missionSuccess = false,
    this.dollarGross = 0,
    this.dollarPenalties = 0,
    this.dollarNet = 0,
    this.rating = 'FAILED',
  });

  int score;
  int enemiesKilled;
  int totalEnemies;
  int bunkersDestroyed;
  int reinforcedBunkersDestroyed;
  int factoriesDestroyed;
  int bonusTargetsDestroyed;
  int dronesIntercepted;
  int dronesEscaped;
  int droneLaunchersDestroyed;
  int pilotsEjected;
  int pilotsSurvived;
  int planesLost;
  bool missionSuccess;
  int dollarGross;
  int dollarPenalties;
  int dollarNet;
  String rating; // "EXCELLENT" / "GOOD" / "FAILED"

  /// Compute the rating based on destruction ratio.
  void computeRating() {
    if (totalEnemies == 0) {
      rating = 'FAILED';
      return;
    }
    final ratio = enemiesKilled / totalEnemies;
    if (ratio >= 1.0) {
      rating = 'EXCELLENT';
    } else if (ratio >= 0.80) {
      rating = 'GOOD';
    } else {
      rating = 'FAILED';
    }
    missionSuccess = ratio >= 0.80;
  }
}
