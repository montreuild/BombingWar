import '../config/game_config.dart';

/// All enemy types in Desert Strike Mobile.
enum EnemyType {
  // Surface enemies
  soldier,
  rocketLauncher,
  jeep,
  droneLauncher,
  // Surface bonus targets (don't count for 80% ratio)
  radar,
  fortification,
  oilWell,
  powerPlant,
  // Underground L1
  bunkerL1,
  missileFactory,
  // Underground L2
  reinforcedBunkerL2,
  // Drones (spawned by droneLauncher)
  drone,
}

/// Enemy AI states.
enum EnemyAIState { idle, alert, attack, huntPilot }

class EnemyData {
  const EnemyData({
    required this.type,
    required this.name,
    required this.health,
    required this.speed,
    required this.damage,
    required this.scoreValue,
    required this.size,
    this.isBonus = false,
    this.countsForVictory = true,
  });

  final EnemyType type;
  final String name;
  final double health;
  final double speed;
  final double damage;
  final int scoreValue;
  final double size;

  /// Bonus targets don't count towards the 80% victory ratio.
  final bool isBonus;

  /// Whether this enemy counts for the victory ratio.
  final bool countsForVictory;

  // ---------------------------------------------------------------------------
  // Surface enemies
  // ---------------------------------------------------------------------------

  static const EnemyData soldier = EnemyData(
    type: EnemyType.soldier,
    name: 'Soldat',
    health: GameConfig.soldierHealth,
    speed: GameConfig.soldierSpeed,
    damage: GameConfig.soldierDamage,
    scoreValue: GameConfig.scoreSoldierKill,
    size: GameConfig.soldierSize,
  );

  static const EnemyData rocketLauncher = EnemyData(
    type: EnemyType.rocketLauncher,
    name: 'Lanceur de roquettes',
    health: GameConfig.rocketLauncherHealth,
    speed: 0.0,
    damage: GameConfig.rocketLauncherDamage,
    scoreValue: GameConfig.scoreRocketeerKill,
    size: GameConfig.rocketLauncherSize,
  );

  static const EnemyData jeep = EnemyData(
    type: EnemyType.jeep,
    name: 'Jeep mitrailleuse',
    health: GameConfig.jeepHealth,
    speed: GameConfig.jeepSpeed,
    damage: GameConfig.jeepDamage,
    scoreValue: GameConfig.scoreJeepKill,
    size: GameConfig.jeepSize,
  );

  static const EnemyData droneLauncher = EnemyData(
    type: EnemyType.droneLauncher,
    name: 'Lanceur de drones',
    health: GameConfig.droneLauncherHealth,
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.scoreDroneLauncherKill,
    size: GameConfig.droneLauncherSize,
  );

  // ---------------------------------------------------------------------------
  // Bonus targets (don't count for victory ratio)
  // ---------------------------------------------------------------------------

  static const EnemyData radar = EnemyData(
    type: EnemyType.radar,
    name: 'Radar',
    health: GameConfig.radarHealth,
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.scoreRadar,
    size: GameConfig.radarSize,
    isBonus: true,
    countsForVictory: false,
  );

  static const EnemyData fortification = EnemyData(
    type: EnemyType.fortification,
    name: 'Fortification',
    health: GameConfig.fortificationHealth,
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.scoreFortification,
    size: GameConfig.fortificationSize,
    isBonus: true,
    countsForVictory: false,
  );

  static const EnemyData oilWell = EnemyData(
    type: EnemyType.oilWell,
    name: 'Puits de pétrole',
    health: GameConfig.oilWellHealth,
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.scoreOilWell,
    size: GameConfig.oilWellSize,
    isBonus: true,
    countsForVictory: false,
  );

  static const EnemyData powerPlant = EnemyData(
    type: EnemyType.powerPlant,
    name: 'Centrale électrique',
    health: GameConfig.powerPlantHealth,
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.scorePowerPlant,
    size: GameConfig.powerPlantSize,
    isBonus: true,
    countsForVictory: false,
  );

  // ---------------------------------------------------------------------------
  // Underground L1
  // ---------------------------------------------------------------------------

  static const EnemyData bunkerL1 = EnemyData(
    type: EnemyType.bunkerL1,
    name: 'Bunker Standard',
    health: GameConfig.bunkerL1Hits * 100.0, // 3 hits
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.scoreBunkerL1,
    size: GameConfig.bunkerL1Size,
  );

  static const EnemyData missileFactory = EnemyData(
    type: EnemyType.missileFactory,
    name: 'Usine de missiles',
    health: GameConfig.missileFactoryHits * 100.0, // 5 hits
    speed: 0.0,
    damage: GameConfig.missileDamage,
    scoreValue: GameConfig.scoreFactory,
    size: GameConfig.missileFactorySize,
  );

  // ---------------------------------------------------------------------------
  // Underground L2
  // ---------------------------------------------------------------------------

  static const EnemyData reinforcedBunkerL2 = EnemyData(
    type: EnemyType.reinforcedBunkerL2,
    name: 'Bunker Renforcé',
    health: 99999.0, // Only GBU-57 can destroy
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.scoreBunkerL2,
    size: GameConfig.reinforcedBunkerSize,
  );

  // ---------------------------------------------------------------------------
  // Drones
  // ---------------------------------------------------------------------------

  static const EnemyData drone = EnemyData(
    type: EnemyType.drone,
    name: 'Drone',
    health: GameConfig.droneHealth,
    speed: GameConfig.droneSpeed,
    damage: GameConfig.droneDamage,
    scoreValue: GameConfig.scoreDroneIntercepted,
    size: GameConfig.droneSize,
    countsForVictory: false,
  );

  static const Map<EnemyType, EnemyData> byType = {
    EnemyType.soldier: soldier,
    EnemyType.rocketLauncher: rocketLauncher,
    EnemyType.jeep: jeep,
    EnemyType.droneLauncher: droneLauncher,
    EnemyType.radar: radar,
    EnemyType.fortification: fortification,
    EnemyType.oilWell: oilWell,
    EnemyType.powerPlant: powerPlant,
    EnemyType.bunkerL1: bunkerL1,
    EnemyType.missileFactory: missileFactory,
    EnemyType.reinforcedBunkerL2: reinforcedBunkerL2,
    EnemyType.drone: drone,
  };
}
