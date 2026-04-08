/// Central configuration file for all Desert Strike Mobile constants.
/// Tune gameplay here without touching component logic.
class GameConfig {
  GameConfig._();

  // ---------------------------------------------------------------------------
  // Screen / World (Horizontal Side-View, Landscape)
  // ---------------------------------------------------------------------------
  static const double worldWidth = 800.0;
  static const double worldHeight = 400.0;

  // Terrain layers (y-coordinates)
  static const double skyTop = 0.0;
  static const double groundLevel = 280.0;
  static const double undergroundL1Top = 320.0;
  static const double undergroundL1Bottom = 370.0;
  static const double undergroundL2Top = 370.0;
  static const double undergroundL2Bottom = 400.0;

  // Parallax layer speeds (multiplier of camera speed)
  static const double parallaxFarSpeed = 0.2;
  static const double parallaxMidSpeed = 0.5;
  static const double parallaxNearSpeed = 0.8;

  // ---------------------------------------------------------------------------
  // Mission / Squadron
  // ---------------------------------------------------------------------------
  static const int planesPerMission = 4;
  static const double pilotEjectProbability = 0.4; // 40%

  // ---------------------------------------------------------------------------
  // Player Aircraft (single type)
  // ---------------------------------------------------------------------------
  static const double aircraftSpeed = 220.0;
  static const double aircraftHealth = 100.0;
  static const double aircraftSize = 40.0;
  static const double aircraftDrag = 0.95; // velocity drag per frame

  // Ammo per aircraft (reset on switch)
  static const int canonAmmoPerPlane = 200;
  static const int missileAmmoPerPlane = 6;
  static const int bombAmmoPerPlane = 6;
  static const int gbuPerMission = 1; // NOT reset on switch

  // ---------------------------------------------------------------------------
  // Weapons
  // ---------------------------------------------------------------------------
  // Canon (machine gun)
  static const double canonSpeed = 500.0;
  static const double canonDamage = 10.0;
  static const double canonCooldown = 0.1;
  static const double canonRange = 350.0;
  static const double canonSize = 6.0;

  // Guided Missiles
  static const double missileSpeed = 350.0;
  static const double missileDamage = 50.0;
  static const double missileCooldown = 0.6;
  static const double missileRange = 500.0;
  static const double missileSize = 12.0;
  static const double missileHomingStrength = 200.0;

  // Classic Bombs
  static const double bombSpeed = 180.0;
  static const double bombDamage = 100.0;
  static const double bombExplosionRadius = 60.0;
  static const double bombCooldown = 1.0;
  static const double bombSize = 14.0;
  static const double gravityAcceleration = 80.0;
  static const double craterRadius = 40.0;

  // GBU-57 (Bunker Buster)
  static const double gbuDamage = 9999.0;
  static const double gbuSpeed = 250.0;
  static const double gbuSize = 20.0;
  static const double gbuExplosionRadius = 80.0;

  // ---------------------------------------------------------------------------
  // Surface Enemies
  // ---------------------------------------------------------------------------
  // Soldier
  static const double soldierHealth = 20.0;
  static const double soldierSpeed = 40.0;
  static const double soldierDamage = 5.0;
  static const double soldierFireCooldown = 2.0;
  static const double soldierSize = 16.0;

  // Rocket Launcher
  static const double rocketLauncherHealth = 40.0;
  static const double rocketLauncherDamage = 25.0;
  static const double rocketLauncherFireCooldown = 4.0;
  static const double rocketLauncherSize = 20.0;

  // Jeep (with turret)
  static const double jeepHealth = 60.0;
  static const double jeepSpeed = 80.0;
  static const double jeepDamage = 15.0;
  static const double jeepFireCooldown = 1.0;
  static const double jeepSize = 30.0;
  static const double jeepTurretAngle = 45.0; // ±45° range

  // Drone Launcher
  static const double droneLauncherHealth = 50.0;
  static const double droneLauncherFireCooldown = 8.0;
  static const double droneLauncherSize = 24.0;

  // Radar
  static const double radarHealth = 30.0;
  static const double radarSize = 22.0;
  static const double radarAlertRange = 200.0;

  // Fortification
  static const double fortificationHealth = 120.0;
  static const double fortificationSize = 36.0;

  // Oil Well
  static const double oilWellHealth = 40.0;
  static const double oilWellSize = 24.0;

  // Power Plant
  static const double powerPlantHealth = 60.0;
  static const double powerPlantSize = 30.0;
  static const double powerPlantBlackoutRadius = 250.0;
  static const double powerPlantBlackoutDuration = 10.0;

  // ---------------------------------------------------------------------------
  // Underground Enemies
  // ---------------------------------------------------------------------------
  // Bunker L1 (standard)
  static const int bunkerL1Hits = 3;
  static const double bunkerL1Size = 36.0;

  // Missile Factory L1
  static const int missileFactoryHits = 5;
  static const double missileFactorySize = 48.0;
  static const double missileFactorySalvoCooldown = 6.0;

  // Reinforced Bunker L2 (GBU-57 only)
  static const double reinforcedBunkerSize = 40.0;

  // ---------------------------------------------------------------------------
  // Drones
  // ---------------------------------------------------------------------------
  static const double droneSpeed = 280.0;
  static const double droneHealth = 10.0;
  static const double droneDamage = 20.0;
  static const double droneSize = 12.0;
  static const int maxDronesPerWave = 3;

  // ---------------------------------------------------------------------------
  // Enemy AI States
  // ---------------------------------------------------------------------------
  static const double enemyDetectionRange = 300.0;
  static const double enemyAttackRange = 200.0;
  static const double huntPilotSpeedMultiplier = 1.5;

  // ---------------------------------------------------------------------------
  // Pilot Ejection
  // ---------------------------------------------------------------------------
  static const double pilotGravity = 120.0;
  static const double pilotDrift = 20.0;
  static const double pilotPistolRange = 80.0;
  static const double pilotPistolCooldown = 1.5;
  static const double pilotPistolDamage = 8.0;

  // ---------------------------------------------------------------------------
  // Score System (Dollars)
  // ---------------------------------------------------------------------------
  static const int scoreSoldierKill = 50;
  static const int scoreRocketeerKill = 100;
  static const int scoreJeepKill = 150;
  static const int scoreDroneLauncherKill = 200;
  static const int scoreDroneIntercepted = 75;
  static const int scoreBunkerL1 = 400;
  static const int scoreBunkerL2 = 1500;
  static const int scoreFactory = 600;
  static const int scoreRadar = 300;
  static const int scoreFortification = 150;
  static const int scoreOilWell = 500;
  static const int scorePowerPlant = 500;

  // Penalties
  static const int penaltyDroneHitsPlane = -250;
  static const int penaltyDroneEscapes = -100;
  static const int penaltyPlaneLost = -300;
  static const int penaltyPilotCaptured = -500;

  // Bonus
  static const int ammoBonusMultiplier = 2;
  static const int perfectBonus = 2000;
  static const double victoryThreshold = 0.80;

  // Combo
  static const int comboKillsForX2 = 3;
  static const int comboKillsForX3 = 5;
  static const double comboWindowSeconds = 5.0;

  // Coins conversion
  static const double coinsPerScore = 0.01;

  // ---------------------------------------------------------------------------
  // GBU-57 Cutscene
  // ---------------------------------------------------------------------------
  static const double cutsceneDuration = 4.0;
  static const double b2SpiritSpeed = 400.0;

  // ---------------------------------------------------------------------------
  // Level Generation
  // ---------------------------------------------------------------------------
  static const double baseDifficulty = 1.0;
  static const double difficultyPerLevel = 0.12;
  static const double baseMissionDistance = 2000.0;
  static const double distancePerLevel = 500.0;
  static const int terrainSeedMultiplier = 31337;

  // Enemy unlock levels
  static const int soldierUnlockLevel = 1;
  static const int rocketLauncherUnlockLevel = 2;
  static const int jeepUnlockLevel = 3;
  static const int radarUnlockLevel = 4;
  static const int fortificationUnlockLevel = 5;
  static const int droneLauncherUnlockLevel = 6;
  static const int oilWellUnlockLevel = 3;
  static const int powerPlantUnlockLevel = 5;
  static const int bunkerL1UnlockLevel = 4;
  static const int missileFactoryUnlockLevel = 7;
  static const int reinforcedBunkerUnlockLevel = 10;

  // ---------------------------------------------------------------------------
  // HUD
  // ---------------------------------------------------------------------------
  static const double joystickRadius = 60.0;
  static const double joystickKnobRadius = 25.0;
  static const double weaponButtonSize = 50.0;
  static const double hudPadding = 12.0;
  static const double progressBarHeight = 6.0;

  // ---------------------------------------------------------------------------
  // Physics / Misc
  // ---------------------------------------------------------------------------
  static const double spawnMargin = 40.0;
  static const double despawnMargin = 100.0;
}
