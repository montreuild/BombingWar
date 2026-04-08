/// Central configuration file for all game constants.
/// Tune gameplay here without touching component logic.
class GameConfig {
  GameConfig._();

  // ---------------------------------------------------------------------------
  // Screen / World (Horizontal Side-View)
  // ---------------------------------------------------------------------------
  static const double worldWidth = 800.0;
  static const double worldHeight = 400.0;

  // Visual layout
  static const double groundLevel = 300.0; // Ground line (y-coordinate)
  static const double skyHeight = groundLevel;
  static const double subSurfaceDepth = 100.0; // Underground gallery height

  // Squadron Mechanics
  static const int maxAmmoPerAircraft = 6;
  static const int maxLossesPerMission = 4;

  // ---------------------------------------------------------------------------
  // Player Aircraft
  // ---------------------------------------------------------------------------
  static const double interceptorSpeed = 250.0;
  static const double interceptorHealth = 80.0;
  static const double heavyBomberSpeed = 150.0;
  static const double heavyBomberHealth = 200.0;
  static const double stealthSpeed = 200.0;
  static const double stealthHealth = 100.0;

  static const double aircraftSize = 40.0;

  // Special ability durations (seconds)
  static const double barrelRollDuration = 0.6;
  static const double armorDuration = 3.0;
  static const double cloakDuration = 5.0;
  static const double armorDamageReduction = 0.5;

  // Special ability cooldowns (seconds)
  static const double specialCooldown = 8.0;

  // ---------------------------------------------------------------------------
  // Weapons
  // ---------------------------------------------------------------------------
  static const double bulletSpeed = 500.0;
  static const double bulletDamage = 10.0;
  static const double bulletCooldown = 0.15;
  static const double bulletRange = 300.0;
  static const double bulletSize = 8.0;

  static const double missileSpeed = 350.0;
  static const double missileDamage = 40.0;
  static const double missileCooldown = 0.8;
  static const double missileRange = 400.0;
  static const double missileSize = 12.0;
  static const double missileHomingStrength = 180.0; // degrees per second

  static const double bombSpeed = 200.0;
  static const double bombDamage = 80.0;
  static const double bombExplosionRadius = 60.0;
  static const double bombCooldown = 1.5;
  static const double bombSize = 14.0;
  static const double gravityAcceleration = 60.0;

  static const double penetratorDamage = 250.0;
  static const double penetratorCooldown = 3.0;
  static const double penetratorSize = 16.0;
  static const double penetratorSpeed = 180.0;
  static const double penetratorExplosionRadius = 40.0;

  // ---------------------------------------------------------------------------
  // Enemies
  // ---------------------------------------------------------------------------
  static const double infantryHealth = 30.0;
  static const double infantrySpeed = 60.0;
  static const double infantryDamage = 8.0;
  static const int infantryScore = 10;
  static const double infantrySize = 20.0;
  static const double infantryFireCooldown = 1.5;

  static const double rpgHealth = 60.0;
  static const double rpgSpeed = 40.0;
  static const double rpgDamage = 30.0;
  static const int rpgScore = 25;
  static const double rpgSize = 24.0;
  static const double rpgFireCooldown = 3.0;

  static const double bunkerHealth = 150.0;
  static const int bunkerScore = 100;
  static const double bunkerSize = 36.0;
  static const double bunkerOpenDuration = 1.5;
  static const int bunkerSalvoCount = 3;
  static const double bunkerSalvoCooldown = 5.0;
  static const double bunkerMissileDamage = 45.0;

  static const double factoryHealth = 500.0;
  static const int factoryScore = 500;
  static const double factorySize = 60.0;
  static const double factoryRespawnInterval = 8.0;

  // ---------------------------------------------------------------------------
  // Level Generation
  // ---------------------------------------------------------------------------
  static const double baseDifficulty = 1.0;
  static const double difficultyPerLevel = 0.15;
  static const int baseEnemiesPerWave = 3;
  static const int infantryUnlockLevel = 1;
  static const int rpgUnlockLevel = 3;
  static const int bunkerUnlockLevel = 7;
  static const int factoryUnlockLevel = 12;
  static const int factorySpawnEveryNLevels = 5;
  static const int terrainSeedMultiplier = 31337;
  static const int heavyBomberUnlockLevel = 5;
  static const int stealthUnlockLevel = 15;

  // ---------------------------------------------------------------------------
  // Threat System
  // ---------------------------------------------------------------------------
  static const double threatFillRate = 8.0;       // percent per second
  static const double threatDecayRate = 2.0;       // percent per second when no radar
  static const double stealthThreatMultiplier = 0.2; // 80% reduction
  static const double threatBarrageThreshold = 100.0;
  static const int barrageMissileCount = 6;
  static const double radarTowerThreatReduction = 3.0; // per second per destroyed tower

  // ---------------------------------------------------------------------------
  // Score System
  // ---------------------------------------------------------------------------
  static const int comboKillsForX2 = 3;
  static const int comboKillsForX3 = 5;
  static const double comboWindowSeconds = 5.0;
  static const int pilotRescueBonus = 200;
  static const double coinsPerScore = 0.01; // score / 100

  // ---------------------------------------------------------------------------
  // HUD
  // ---------------------------------------------------------------------------
  static const double joystickRadius = 60.0;
  static const double joystickKnobRadius = 25.0;
  static const double weaponButtonSize = 56.0;
  static const double hudPadding = 16.0;

  // ---------------------------------------------------------------------------
  // Physics / Misc
  // ---------------------------------------------------------------------------
  static const double spawnMargin = 40.0; // pixels from edge for enemy spawn
  static const double despawnMargin = 80.0;
}
