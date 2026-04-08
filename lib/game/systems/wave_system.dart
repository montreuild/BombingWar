import 'dart:math';

import 'package:flame/components.dart';

import '../../config/game_config.dart';
import '../../models/enemy_data.dart';
import '../../models/level_data.dart';
import '../bombing_war_game.dart';
import '../components/enemies/bunker_l1_component.dart';
import '../components/enemies/missile_factory_component.dart';
import '../components/enemies/rocket_launcher_component.dart';
import '../components/enemies/soldier_component.dart';

/// Handles procedural enemy wave spawning.
class WaveSystem {
  WaveSystem({required this.game});

  final BombingWarGame game;

  LevelConfig? _level;
  int _spawnIndex = 0;
  double _spawnTimer = 0.0;
  bool _levelComplete = false;
  int _activeEnemies = 0;
  bool _factorySpawned = false;
  final _rng = Random();

  /// Combined flat list of all enemies to spawn, built in [startLevel].
  List<EnemySpawnData> _allSpawns = [];

  bool get isLevelComplete => _levelComplete;

  void startLevel(LevelConfig level) {
    _level = level;
    _spawnIndex = 0;
    _spawnTimer = 0.0;
    _levelComplete = false;
    _activeEnemies = 0;
    _factorySpawned = false;

    // Combine all spawn lists into a single ordered sequence.
    _allSpawns = [
      ...level.surfaceEnemies,
      ...level.undergroundL1Enemies,
      ...level.undergroundL2Enemies,
      ...level.bonusTargets,
    ];
  }

  void update(double dt) {
    if (_level == null || _levelComplete) return;

    _spawnTimer -= dt;
    if (_spawnTimer > 0) return;

    if (_spawnIndex >= _allSpawns.length) {
      if (_activeEnemies <= 0) {
        _levelComplete = true;
      }
      return;
    }

    _spawnEnemy(_allSpawns[_spawnIndex]);
    _spawnIndex++;
    _spawnTimer = GameConfig.defaultSpawnInterval;

    // Spawn factory once when the second enemy is queued
    final hasFactory = _level!.undergroundL1Enemies
        .any((s) => s.type == EnemyType.missileFactory);
    if (hasFactory && !_factorySpawned && _spawnIndex == 2) {
      _spawnFactory();
      _factorySpawned = true;
    }
  }

  Vector2 _randomSpawnPosition(EnemyType type) {
    final x = GameConfig.spawnMargin +
        _rng.nextDouble() * (GameConfig.worldWidth - GameConfig.spawnMargin * 2);

    if (type == EnemyType.missileFactory) {
      return Vector2(x, GameConfig.groundLevel + 50);
    }

    return Vector2(x, GameConfig.groundLevel - 10);
  }

  void _spawnEnemy(EnemySpawnData spawn) {
    final pos = spawn.yPosition != null
        ? Vector2(spawn.xPosition, spawn.yPosition!)
        : _randomSpawnPosition(spawn.type);

    switch (spawn.type) {
      case EnemyType.soldier:
        final e = SoldierComponent(game: game, position: pos);
        e.onDefeated = _onEnemyDefeated;
        game.addToWorld(e);
        _activeEnemies++;
      case EnemyType.rocketLauncher:
        final e = RocketLauncherComponent(game: game, position: pos);
        e.onDefeated = _onEnemyDefeated;
        game.addToWorld(e);
        _activeEnemies++;
      case EnemyType.bunkerL1:
        final e = BunkerL1Component(game: game, position: pos);
        e.onDefeated = _onEnemyDefeated;
        game.addToWorld(e);
        _activeEnemies++;
      case EnemyType.missileFactory:
        _spawnFactory(pos);
      default:
        // Other types not handled by wave system
        break;
    }
  }

  void _onEnemyDefeated() {
    _activeEnemies = (_activeEnemies - 1).clamp(0, 9999);
  }

  /// Spawns a missile barrage from the right (triggered by ThreatSystem).
  void spawnBarrage() {
    for (int i = 0; i < GameConfig.barrageMissileCount; i++) {
      _spawnBarrageMissile();
    }
  }

  void _spawnBarrageMissile() {
    final y = _rng.nextDouble() * GameConfig.skyHeight;
    final pos = Vector2(GameConfig.worldWidth + 50, y);
    // Barrage units are rocket launcher trucks that move in from the side
    final e = RocketLauncherComponent(game: game, position: pos);
    game.addToWorld(e);
  }

  void _spawnFactory([Vector2? pos]) {
    final spawnPos = pos ??
        Vector2(
          GameConfig.worldWidth * 0.8,
          GameConfig.groundLevel + 40,
        );
    final e = MissileFactoryComponent(game: game, position: spawnPos);
    e.onDefeated = _onEnemyDefeated;
    game.addToWorld(e);
    _activeEnemies++;
  }
}
