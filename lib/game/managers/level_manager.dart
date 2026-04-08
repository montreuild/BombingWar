import 'dart:math';

import '../../config/game_config.dart';
import '../../models/enemy_data.dart';
import '../../models/level_data.dart';

/// Generates infinite levels procedurally from a level number.
class LevelManager {
  int _currentLevelNumber = 1;
  LevelData? _currentLevel;

  int get currentLevelNumber => _currentLevelNumber;
  LevelData get currentLevel => _currentLevel!;

  void setLevel(int levelNumber) {
    _currentLevelNumber = levelNumber;
    _currentLevel = _generate(levelNumber);
  }

  void advanceLevel() {
    _currentLevelNumber++;
    _currentLevel = _generate(_currentLevelNumber);
  }

  LevelData _generate(int levelNumber) {
    final difficulty = GameConfig.baseDifficulty +
        (levelNumber * GameConfig.difficultyPerLevel);
    final enemiesPerWave = GameConfig.baseEnemiesPerWave +
        (levelNumber / 2).floor();
    final terrainSeed = levelNumber * GameConfig.terrainSeedMultiplier;
    final hasFactory = levelNumber % GameConfig.factorySpawnEveryNLevels == 0;

    // Determine which enemy types are available at this level
    final availableTypes = _availableEnemyTypes(levelNumber);

    // Generate 3 waves, each progressively harder
    final rng = Random(terrainSeed);
    final waves = List.generate(3, (waveIndex) {
      final count = enemiesPerWave + waveIndex;
      final spawnInterval = (1.5 / difficulty).clamp(0.3, 1.5);
      final types = List.generate(
        count,
        (_) => availableTypes[rng.nextInt(availableTypes.length)],
      );
      return WaveData(enemyTypes: types, spawnInterval: spawnInterval);
    });

    return LevelData(
      levelNumber: levelNumber,
      difficulty: difficulty,
      waves: waves,
      terrainSeed: terrainSeed,
      hasFactory: hasFactory,
    );
  }

  List<EnemyType> _availableEnemyTypes(int levelNumber) {
    final types = <EnemyType>[];
    if (levelNumber >= GameConfig.infantryUnlockLevel) {
      types.add(EnemyType.infantry);
    }
    if (levelNumber >= GameConfig.rpgUnlockLevel) {
      types.add(EnemyType.rpgUnit);
    }
    if (levelNumber >= GameConfig.bunkerUnlockLevel) {
      types.add(EnemyType.bunker);
    }
    // Factory is a boss target added separately, not in wave list
    if (types.isEmpty) types.add(EnemyType.infantry);
    return types;
  }
}
