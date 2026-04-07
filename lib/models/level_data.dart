import 'enemy_data.dart';

class WaveData {
  const WaveData({
    required this.enemyTypes,
    required this.spawnInterval,
  });

  /// Ordered list of enemy types to spawn in this wave.
  final List<EnemyType> enemyTypes;

  /// Seconds between individual enemy spawns.
  final double spawnInterval;
}

class LevelData {
  const LevelData({
    required this.levelNumber,
    required this.difficulty,
    required this.waves,
    required this.terrainSeed,
    required this.hasFactory,
  });

  final int levelNumber;
  final double difficulty;
  final List<WaveData> waves;

  /// Deterministic seed for terrain generation.
  final int terrainSeed;

  /// Whether this level contains the Underground Factory boss target.
  final bool hasFactory;
}
