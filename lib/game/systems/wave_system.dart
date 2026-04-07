import 'dart:math';
import 'package:flame/components.dart';
import '../../config/game_config.dart';
import '../../models/level_data.dart';
import '../../models/enemy_data.dart';
import '../bombing_war_game.dart';
import '../components/enemies/infantry_component.dart';
import '../components/enemies/rpg_unit_component.dart';
import '../components/enemies/bunker_component.dart';
import '../components/enemies/factory_component.dart';

/// Handles procedural enemy wave spawning.
class WaveSystem {
  WaveSystem({required this.game});

  final BombingWarGame game;

  LevelData? _level;
  int _currentWave = 0;
  int _spawnIndex = 0;
  double _spawnTimer = 0.0;
  bool _levelComplete = false;
  int _activeEnemies = 0;
  bool _factorySpawned = false;
  final _rng = Random();

  bool get isLevelComplete => _levelComplete;

  void startLevel(LevelData level) {
    _level = level;
    _currentWave = 0;
    _spawnIndex = 0;
    _spawnTimer = 0.0;
    _levelComplete = false;
    _activeEnemies = 0;
    _factorySpawned = false;
  }

  void update(double dt) {
    if (_level == null || _levelComplete) return;

    _spawnTimer -= dt;
    if (_spawnTimer > 0) return;

    final waves = _level!.waves;

    if (_currentWave >= waves.length) {
      // All waves spawned; wait for remaining enemies to be cleared
      if (_activeEnemies <= 0) {
        _levelComplete = true;
      }
      return;
    }

    final wave = waves[_currentWave];
    if (_spawnIndex < wave.enemyTypes.length) {
      _spawnEnemy(wave.enemyTypes[_spawnIndex]);
      _spawnIndex++;
      _spawnTimer = wave.spawnInterval;
    } else {
      // Advance to next wave when current wave is fully spawned
      _currentWave++;
      _spawnIndex = 0;
    }

    // Spawn factory once when waves start if level has one
    if (_level!.hasFactory && !_factorySpawned && _currentWave == 1) {
      _spawnFactory();
      _factorySpawned = true;
    }
  }

  void _spawnEnemy(EnemyType type) {
    final pos = _randomSpawnPosition();
    switch (type) {
      case EnemyType.infantry:
        final e = InfantryComponent(game: game, position: pos);
        e.onDefeated = _onEnemyDefeated;
        game.add(e);
        _activeEnemies++;
      case EnemyType.rpgUnit:
        final e = RpgUnitComponent(game: game, position: pos);
        e.onDefeated = _onEnemyDefeated;
        game.add(e);
        _activeEnemies++;
      case EnemyType.bunker:
        final e = BunkerComponent(game: game, position: pos);
        e.onDefeated = _onEnemyDefeated;
        game.add(e);
        _activeEnemies++;
      case EnemyType.factory:
        _spawnFactory();
    }
  }

  void _spawnFactory() {
    final pos = Vector2(
      GameConfig.worldWidth / 2,
      GameConfig.worldHeight * 0.15,
    );
    final e = FactoryComponent(game: game, position: pos);
    e.onDefeated = _onEnemyDefeated;
    game.add(e);
    _activeEnemies++;
  }

  void _onEnemyDefeated() {
    _activeEnemies = (_activeEnemies - 1).clamp(0, 9999);
  }

  /// Spawns a missile barrage from multiple edges (triggered by ThreatSystem).
  void spawnBarrage() {
    for (int i = 0; i < GameConfig.barrageMissileCount; i++) {
      _spawnBarrageMissile();
    }
  }

  void _spawnBarrageMissile() {
    // Barrage missiles spawn from top edge
    final x = _rng.nextDouble() * GameConfig.worldWidth;
    final pos = Vector2(x, -10);
    final e = RpgUnitComponent(game: game, position: pos);
    // No callback needed for barrage units — they don't count toward wave completion
    game.add(e);
  }

  Vector2 _randomSpawnPosition() {
    // Enemies spawn in the upper portion of the screen
    final x = GameConfig.spawnMargin +
        _rng.nextDouble() * (GameConfig.worldWidth - GameConfig.spawnMargin * 2);
    final y = GameConfig.spawnMargin +
        _rng.nextDouble() * (GameConfig.worldHeight * 0.4);
    return Vector2(x, y);
  }
}
