import 'dart:math';

import '../../config/game_config.dart';
import '../../models/enemy_data.dart';
import '../../models/level_data.dart';

/// Generates infinite levels procedurally from a level index.
/// Seed = f(level) → reproducible but infinite.
/// Difficulty, enemy count/type, bonus targets, underground structures
/// all scale with levelIndex.
class LevelManager {
  int _currentLevelIndex = 1;
  LevelConfig? _currentLevel;

  int get currentLevelIndex => _currentLevelIndex;
  LevelConfig get currentLevel => _currentLevel!;

  void setLevel(int levelIndex) {
    _currentLevelIndex = levelIndex;
    _currentLevel = generateLevel(levelIndex);
  }

  void advanceLevel() {
    _currentLevelIndex++;
    _currentLevel = generateLevel(_currentLevelIndex);
  }

  /// Generate a LevelConfig from a levelIndex.
  /// Deterministic via seed.
  LevelConfig generateLevel(int index) {
    final seed = index * GameConfig.terrainSeedMultiplier;
    final rng = Random(seed);
    final difficulty = GameConfig.baseDifficulty +
        (index * GameConfig.difficultyPerLevel);
    final missionDistance = GameConfig.baseMissionDistance +
        (index * GameConfig.distancePerLevel);

    // --- Surface combat enemies ---
    final surfaceEnemies = <EnemySpawnData>[];
    final availableSurface = _availableSurfaceTypes(index);
    final surfaceCount = (4 + index * 1.5 * difficulty).round().clamp(4, 50);
    for (int i = 0; i < surfaceCount; i++) {
      final type = availableSurface[rng.nextInt(availableSurface.length)];
      final xPos = 200 + rng.nextDouble() * (missionDistance - 300);
      surfaceEnemies.add(EnemySpawnData(type: type, xPosition: xPos));
    }

    // --- Underground L1 enemies ---
    final ugL1Enemies = <EnemySpawnData>[];
    if (index >= GameConfig.bunkerL1UnlockLevel) {
      final bunkerCount = (1 + index * 0.3).round().clamp(1, 8);
      for (int i = 0; i < bunkerCount; i++) {
        final xPos = 300 + rng.nextDouble() * (missionDistance - 400);
        ugL1Enemies.add(EnemySpawnData(
            type: EnemyType.bunkerL1, xPosition: xPos));
      }
    }
    if (index >= GameConfig.missileFactoryUnlockLevel) {
      final factoryCount = (index ~/ 5).clamp(0, 3);
      for (int i = 0; i < factoryCount; i++) {
        final xPos = 500 + rng.nextDouble() * (missionDistance - 600);
        ugL1Enemies.add(EnemySpawnData(
            type: EnemyType.missileFactory, xPosition: xPos));
      }
    }

    // --- Underground L2 enemies ---
    final ugL2Enemies = <EnemySpawnData>[];
    if (index >= GameConfig.reinforcedBunkerUnlockLevel) {
      final reinforcedCount = (index ~/ 10).clamp(0, 2);
      for (int i = 0; i < reinforcedCount; i++) {
        final xPos = 400 + rng.nextDouble() * (missionDistance - 500);
        ugL2Enemies.add(EnemySpawnData(
            type: EnemyType.reinforcedBunkerL2, xPosition: xPos));
      }
    }

    // --- Bonus targets ---
    final bonusTargets = <EnemySpawnData>[];
    if (index >= GameConfig.radarUnlockLevel) {
      final radarCount = (1 + index * 0.2).round().clamp(1, 5);
      for (int i = 0; i < radarCount; i++) {
        final xPos = 200 + rng.nextDouble() * (missionDistance - 300);
        bonusTargets.add(EnemySpawnData(
            type: EnemyType.radar, xPosition: xPos));
      }
    }
    if (index >= GameConfig.fortificationUnlockLevel) {
      final fortCount = (index * 0.15).round().clamp(0, 4);
      for (int i = 0; i < fortCount; i++) {
        final xPos = 200 + rng.nextDouble() * (missionDistance - 300);
        bonusTargets.add(EnemySpawnData(
            type: EnemyType.fortification, xPosition: xPos));
      }
    }
    if (index >= GameConfig.oilWellUnlockLevel) {
      final oilCount = (1 + index * 0.1).round().clamp(0, 3);
      for (int i = 0; i < oilCount; i++) {
        final xPos = 300 + rng.nextDouble() * (missionDistance - 400);
        bonusTargets.add(EnemySpawnData(
            type: EnemyType.oilWell, xPosition: xPos));
      }
    }
    if (index >= GameConfig.powerPlantUnlockLevel) {
      final ppCount = (index * 0.1).round().clamp(0, 2);
      for (int i = 0; i < ppCount; i++) {
        final xPos = 400 + rng.nextDouble() * (missionDistance - 500);
        bonusTargets.add(EnemySpawnData(
            type: EnemyType.powerPlant, xPosition: xPos));
      }
    }

    // Count enemies that count for victory ratio
    final totalEnemies = surfaceEnemies.length +
        ugL1Enemies.length +
        ugL2Enemies.length;
    final totalBonus = bonusTargets.length;

    return LevelConfig(
      levelIndex: index,
      terrainSeed: seed,
      difficulty: difficulty,
      missionDistance: missionDistance,
      surfaceEnemies: surfaceEnemies,
      undergroundL1Enemies: ugL1Enemies,
      undergroundL2Enemies: ugL2Enemies,
      bonusTargets: bonusTargets,
      totalEnemies: totalEnemies,
      totalBonusTargets: totalBonus,
    );
  }

  List<EnemyType> _availableSurfaceTypes(int index) {
    final types = <EnemyType>[];
    if (index >= GameConfig.soldierUnlockLevel) {
      types.add(EnemyType.soldier);
    }
    if (index >= GameConfig.rocketLauncherUnlockLevel) {
      types.add(EnemyType.rocketLauncher);
    }
    if (index >= GameConfig.jeepUnlockLevel) {
      types.add(EnemyType.jeep);
    }
    if (index >= GameConfig.droneLauncherUnlockLevel) {
      types.add(EnemyType.droneLauncher);
    }
    if (types.isEmpty) types.add(EnemyType.soldier);
    return types;
  }
}
