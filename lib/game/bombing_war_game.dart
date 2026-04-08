import 'dart:math' as math;
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_config.dart';
import '../models/enemy_data.dart';
import '../models/level_data.dart';
import 'components/aircraft/aircraft_component.dart';
import 'components/effects/explosion_effect.dart';
import 'components/environment/starfield_component.dart';
import 'components/effects/crater_component.dart';
import 'components/effects/debris_component.dart';
import 'components/enemies/enemy_component.dart';
import 'components/enemies/radar_component.dart';
import 'components/enemies/reinforced_bunker_l2_component.dart';
import 'components/enemies/soldier_component.dart';
import 'components/enemies/rocket_launcher_component.dart';
import 'components/enemies/armed_jeep_component.dart';
import 'components/enemies/drone_launcher_component.dart';
import 'components/enemies/fortification_component.dart';
import 'components/enemies/oil_well_component.dart';
import 'components/enemies/power_plant_component.dart';
import 'components/enemies/bunker_l1_component.dart';
import 'components/enemies/missile_factory_component.dart';
import 'components/rescue/jeep_component.dart';
import 'components/rescue/pilot_component.dart';
import 'components/environment/terrain_component.dart';
import 'components/hud/hud_component.dart';
import 'components/hud/joystick_component.dart';
import 'components/hud/weapon_button_component.dart';
import 'managers/audio_manager.dart';
import 'managers/cutscene_manager.dart';
import 'managers/game_manager.dart';
import 'managers/level_manager.dart';
import 'managers/save_manager.dart';
import 'systems/collision_system.dart';
import 'systems/score_system.dart';

class BombingWarGame extends FlameGame with KeyboardEvents {
  BombingWarGame({
    required this.saveManager,
  });

  final SaveManager saveManager;

  // Managers
  late final GameManager gameManager;
  late final LevelManager levelManager;
  late final AudioManager audioManager;
  CutsceneManager? _cutsceneManager;

  // Systems
  late final ScoreSystem scoreSystem;
  late final CollisionSystem collisionSystem;

  // Core components
  AircraftComponent? playerAircraft;
  HudComponent? hud;
  JoystickComponent? joystick;
  WeaponButtonComponent? weaponButtons;
  TerrainComponent? terrain;

  // Mission state
  int _missionLives = GameConfig.planesPerMission;
  bool _gbuAvailable = true;
  bool isRescueMissionActive = false;
  PilotComponent? activePilot;
  int _activeDroneCount = 0;
  int _totalEnemies = 0;
  bool _pilotCaptured = false;

  // Camera / scrolling
  double cameraX = 0.0;
  double _missionDistance = GameConfig.baseMissionDistance;

  // Active radar list
  final List<RadarComponent> _activeRadars = [];

  // Getters for HUD
  int get missionLives => _missionLives;
  bool get gbuAvailable => _gbuAvailable;
  int get totalEnemies => _totalEnemies;
  double get missionProgress =>
      playerAircraft != null ? playerAircraft!.position.x / _missionDistance : 0.0;

  // Flutter-layer callbacks
  VoidCallback? onGameOver;
  void Function(MissionReport report)? onLevelComplete;

  final Set<LogicalKeyboardKey> _pressedKeys = {};
  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    if (isKeyDown) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        playerAircraft?.fireWeapon();
      } else if (event.logicalKey == LogicalKeyboardKey.keyQ ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        playerAircraft?.cycleWeapon();
      } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
        playerAircraft?.selectWeapon(0); // Canon
        playerAircraft?.fireWeapon();
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        playerAircraft?.selectWeapon(1); // Missile
        playerAircraft?.fireWeapon();
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        playerAircraft?.selectWeapon(2); // Bomb
        playerAircraft?.fireWeapon();
      } else if (event.logicalKey == LogicalKeyboardKey.keyG) {
        triggerGBU57();
      }
    }

    _pressedKeys.clear();
    _pressedKeys.addAll(keysPressed);

    return KeyEventResult.handled;
  }

  Vector2 _getKeyboardDirection() {
    final direction = Vector2.zero();
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      direction.y -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      direction.y += 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      direction.x -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      direction.x += 1;
    }
    return direction.normalized();
  }

  @override
  Color backgroundColor() => const Color(0xFF0A0E14);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.visibleGameSize =
        Vector2(GameConfig.worldWidth, GameConfig.worldHeight);

    audioManager = AudioManager();
    levelManager = LevelManager();
    gameManager = GameManager();
    scoreSystem = ScoreSystem();
    collisionSystem = CollisionSystem(game: this);

    levelManager.setLevel(saveManager.progress.currentLevel);
    final level = levelManager.currentLevel;
    _missionDistance = level.missionDistance;
    _totalEnemies = level.totalEnemies;
    _missionLives = GameConfig.planesPerMission;
    _gbuAvailable = true;

    // Terrain with Perlin noise
    terrain = TerrainComponent(
      terrainSeed: level.terrainSeed,
      missionDistance: _missionDistance,
    );
    await add(terrain!);
    await add(StarfieldComponent());

    // Spawn all enemies
    _spawnEnemiesFromLevel(level);

    // Spawn player
    await _spawnPlayer();
    await _buildHud();

    gameManager.setState(GameState.playing);
    audioManager.playMusic('bgm.mp3').catchError((_) {});
  }

  void _spawnEnemiesFromLevel(LevelConfig level) {
    // Surface enemies
    for (final spawn in level.surfaceEnemies) {
      final enemy = _createEnemy(spawn.type, Vector2(spawn.xPosition, GameConfig.groundLevel - GameConfig.surfaceEnemyYOffset));
      if (enemy != null) {
        enemy.onDefeated = () => _onEnemyKilled(spawn.type);
        add(enemy);
      }
    }

    // Underground L1
    for (final spawn in level.undergroundL1Enemies) {
      final y = (GameConfig.undergroundL1Top + GameConfig.undergroundL1Bottom) / 2;
      final enemy = _createEnemy(spawn.type, Vector2(spawn.xPosition, y));
      if (enemy != null) {
        enemy.onDefeated = () => _onEnemyKilled(spawn.type);
        add(enemy);
      }
    }

    // Underground L2
    for (final spawn in level.undergroundL2Enemies) {
      final y = (GameConfig.undergroundL2Top + GameConfig.undergroundL2Bottom) / 2;
      final enemy = _createEnemy(spawn.type, Vector2(spawn.xPosition, y));
      if (enemy != null) {
        enemy.onDefeated = () => _onEnemyKilled(spawn.type);
        add(enemy);
      }
    }

    // Bonus targets
    for (final spawn in level.bonusTargets) {
      final enemy = _createEnemy(spawn.type, Vector2(spawn.xPosition, GameConfig.groundLevel - GameConfig.surfaceEnemyYOffset));
      if (enemy != null) {
        enemy.onDefeated = () => _onEnemyKilled(spawn.type);
        add(enemy);
        // Track active radars
        if (enemy is RadarComponent) {
          _activeRadars.add(enemy);
        }
      }
    }
  }

  EnemyComponent? _createEnemy(EnemyType type, Vector2 pos) {
    switch (type) {
      case EnemyType.soldier:
        return SoldierComponent(game: this, position: pos);
      case EnemyType.rocketLauncher:
        return RocketLauncherComponent(game: this, position: pos);
      case EnemyType.jeep:
        return ArmedJeepComponent(game: this, position: pos);
      case EnemyType.droneLauncher:
        return DroneLauncherComponent(game: this, position: pos);
      case EnemyType.radar:
        return RadarComponent(game: this, position: pos);
      case EnemyType.fortification:
        return FortificationComponent(game: this, position: pos);
      case EnemyType.oilWell:
        return OilWellComponent(game: this, position: pos);
      case EnemyType.powerPlant:
        return PowerPlantComponent(game: this, position: pos);
      case EnemyType.bunkerL1:
        return BunkerL1Component(game: this, position: pos);
      case EnemyType.missileFactory:
        return MissileFactoryComponent(game: this, position: pos);
      case EnemyType.reinforcedBunkerL2:
        return ReinforcedBunkerL2Component(game: this, position: pos);
      case EnemyType.drone:
        return null; // Drones are spawned by drone launchers
    }
  }

  void _onEnemyKilled(EnemyType type) {
    scoreSystem.addKill(type);

    // Check victory condition continuously
    if (_totalEnemies > 0 &&
        scoreSystem.enemiesKilled / _totalEnemies >= GameConfig.victoryThreshold) {
      _triggerLevelComplete();
    }
  }

  Future<void> _spawnPlayer() async {
    if (_missionLives <= 0) return;
    _missionLives--;
    final aircraft = AircraftComponent(game: this);
    aircraft.position = Vector2(
      GameConfig.worldWidth * 0.1,
      GameConfig.groundLevel * 0.5,
    );
    playerAircraft = aircraft;
    await add(aircraft);
  }

  Future<void> _buildHud() async {
    hud = HudComponent(game: this);
    joystick = JoystickComponent(game: this);
    weaponButtons = WeaponButtonComponent(game: this);

    await add(hud!);
    await add(joystick!);
    await add(weaponButtons!);
  }

  @override
  void update(double dt) {
    if (gameManager.state != GameState.playing) return;
    super.update(dt);

    _updateShake(dt);
    collisionSystem.update(dt);
    scoreSystem.update(dt);

    // Player movement
    if (playerAircraft != null && playerAircraft!.isAlive) {
      final kbDir = _getKeyboardDirection();
      if (!kbDir.isZero()) {
        playerAircraft!.applyMovement(kbDir, dt);
      } else if (joystick != null) {
        playerAircraft!.applyMovement(joystick!.direction, dt);
      }

      // Update camera (horizontal scroll following player)
      cameraX = playerAircraft!.position.x - GameConfig.worldWidth * 0.3;
      cameraX = cameraX.clamp(0, _missionDistance - GameConfig.worldWidth);
      terrain?.cameraX = cameraX;
    }

    // Update active drone count for HUD
    hud?.updateActiveDrones(_activeDroneCount);

    _checkConditions();
  }

  void _checkConditions() {
    if (isRescueMissionActive) return;
    if (_pilotCaptured) return;

    if (playerAircraft == null || playerAircraft!.isRemoved) {
      if (_missionLives > 0) {
        _spawnPlayer();
      } else {
        _triggerGameOver();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Aircraft destroyed / Pilot ejection
  // ---------------------------------------------------------------------------

  void onAircraftDestroyed(Vector2 pos, bool wasEjected) {
    scoreSystem.registerPlaneLost();
    playerAircraft = null;
    audioManager.playMayday().catchError((_) {});

    if (wasEjected) {
      isRescueMissionActive = true;
      scoreSystem.registerPilotEjected();
      audioManager.playPilotEjected().catchError((_) {});
      activePilot = PilotComponent(position: pos, game: this);
      add(activePilot!);

      // Spawn a jeep to hunt the pilot
      add(JeepComponent(
          position: Vector2(GameConfig.worldWidth + 50, GameConfig.groundLevel - GameConfig.surfaceEnemyYOffset),
          game: this));
    } else {
      // No ejection — try next plane
      if (_missionLives > 0) {
        _spawnPlayer();
      } else {
        _triggerGameOver();
      }
    }
  }

  void onPilotKilled() {
    isRescueMissionActive = false;
    activePilot = null;
    _pilotCaptured = true;
    _triggerGameOver();
  }

  void onPilotSurvived() {
    isRescueMissionActive = false;
    activePilot = null;
    scoreSystem.registerPilotSurvived();
    if (_missionLives > 0) {
      _spawnPlayer();
    } else {
      _triggerGameOver();
    }
  }

  // ---------------------------------------------------------------------------
  // GBU-57 Cutscene
  // ---------------------------------------------------------------------------

  void triggerGBU57() {
    if (!_gbuAvailable) return;
    if (playerAircraft == null) return;

    _gbuAvailable = false;

    // Find nearest reinforced bunker L2 as target
    final target = _findNearestReinforcedBunker();
    final targetPos = target?.position ?? playerAircraft!.position;

    _cutsceneManager = CutsceneManager(
      game: this,
      targetPosition: targetPos,
      onComplete: () {
        _cutsceneManager?.removeFromParent();
        _cutsceneManager = null;
      },
    );
    add(_cutsceneManager!);
    _cutsceneManager!.startCutscene();
  }

  ReinforcedBunkerL2Component? _findNearestReinforcedBunker() {
    ReinforcedBunkerL2Component? nearest;
    double bestDist = double.infinity;
    for (final child in children) {
      if (child is ReinforcedBunkerL2Component && child.isAlive) {
        final dist = child.position.distanceTo(playerAircraft!.position);
        if (dist < bestDist) {
          bestDist = dist;
          nearest = child;
        }
      }
    }
    return nearest;
  }

  void destroyReinforcedBunkerAt(Vector2 target) {
    for (final child in children.toList()) {
      if (child is ReinforcedBunkerL2Component &&
          child.isAlive &&
          child.position.distanceTo(target) < 50) {
        child.takeDamage(GameConfig.gbuDamage, isGBU: true);
        break;
      }
    }
  }

  void staggerSurfaceEnemiesNear(double worldX) {
    for (final child in children) {
      if (child is EnemyComponent &&
          child.position.y <= GameConfig.groundLevel &&
          (child.position.x - worldX).abs() < GameConfig.gbuExplosionRadius) {
        // Stagger animation only, no damage
        // Visual feedback: brief flash
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Radar & Power Plant mechanics
  // ---------------------------------------------------------------------------

  bool isEnemyRadarAlerted(EnemyComponent enemy) {
    for (final radar in _activeRadars) {
      if (radar.isAlive && radar.isInRange(enemy)) {
        return true;
      }
    }
    return false;
  }

  void onRadarDestroyed(RadarComponent radar) {
    _activeRadars.remove(radar);
  }

  void onPowerPlantDestroyed(Vector2 pos, double radius) {
    // Blind all enemies in radius
    for (final child in children) {
      if (child is EnemyComponent &&
          child.position.distanceTo(pos) <= radius) {
        child.isBlinded = true;
        // Reset after duration
        Future.delayed(
            Duration(
                seconds: GameConfig.powerPlantBlackoutDuration.round()), () {
          if (child.isMounted) {
            child.isBlinded = false;
          }
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Drone tracking
  // ---------------------------------------------------------------------------

  void onDroneLaunched() {
    _activeDroneCount++;
  }

  void onDroneIntercepted() {
    _activeDroneCount = math.max(0, _activeDroneCount - 1);
  }

  void onDroneEscaped() {
    _activeDroneCount = math.max(0, _activeDroneCount - 1);
    scoreSystem.registerDroneEscaped();
  }

  // ---------------------------------------------------------------------------
  // Enemy finder (for pilot auto-pistol)
  // ---------------------------------------------------------------------------

  EnemyComponent? findNearestEnemyInRange(Vector2 pos, double range) {
    EnemyComponent? nearest;
    double bestDist = range;
    for (final child in children) {
      if (child is EnemyComponent && child.isAlive) {
        final dist = child.position.distanceTo(pos);
        if (dist < bestDist) {
          bestDist = dist;
          nearest = child;
        }
      }
    }
    return nearest;
  }

  // ---------------------------------------------------------------------------
  // Score feedback
  // ---------------------------------------------------------------------------

  void showFeedback(String text, Vector2 pos) {
    // Add visual floating text (handled by HUD via score feedback queue)
    scoreSystem.feedbackQueue.add(
      ScoreFeedback(text: text, isPenalty: true),
    );
  }

  // ---------------------------------------------------------------------------
  // Persistent fire (oil well destruction)
  // ---------------------------------------------------------------------------

  void spawnPersistentFire(Vector2 pos) {
    // Spawn fire + smoke particles at position
    spawnExplosion(pos, radius: 30.0);
    // Additional fire effect could be added here
  }

  // ---------------------------------------------------------------------------
  // Conditions
  // ---------------------------------------------------------------------------

  void _triggerGameOver() {
    if (gameManager.state == GameState.gameOver) return;
    gameManager.setState(GameState.gameOver);
    audioManager.playGameOver().catchError((_) {});
    onGameOver?.call();
  }

  void _triggerLevelComplete() {
    if (gameManager.state == GameState.levelComplete) return;
    gameManager.setState(GameState.levelComplete);

    // Compute end-of-mission bonuses
    final remainingAmmo = playerAircraft?.totalRemainingAmmo ?? 0;
    scoreSystem.computeAmmoBonus(remainingAmmo);
    scoreSystem.computePerfectBonus(_totalEnemies);

    final report = scoreSystem.buildReport(_totalEnemies);

    // Save progress
    saveManager.progress.addScore(report.dollarNet);
    saveManager.progress.currentLevel++;
    saveManager.save();

    audioManager.playLevelComplete().catchError((_) {});
    onLevelComplete?.call(report);
  }

  // ---------------------------------------------------------------------------
  // Effects
  // ---------------------------------------------------------------------------

  void spawnExplosion(Vector2 pos, {double radius = 40.0}) {
    add(ExplosionEffect(position: pos.clone(), radius: radius));
    audioManager.playExplosion().catchError((_) {});
    shakeScreen(intensity: radius / 10.0);

    final rng = math.Random();
    for (int i = 0; i < 8; i++) {
      add(DebrisComponent(
        position: pos.clone(),
        color: i % 2 == 0 ? Colors.orange : Colors.grey,
        velocity: Vector2(
          (rng.nextDouble() - 0.5) * 200,
          -rng.nextDouble() * 200,
        ),
      ));
    }

    // Crater on ground
    if ((pos.y - GameConfig.groundLevel).abs() < 20) {
      add(CraterComponent(
          position: Vector2(pos.x, GameConfig.groundLevel),
          radius: radius * 0.5));
      terrain?.addCrater(pos.x, GameConfig.craterRadius);
    }
  }

  void shakeScreen({double duration = 0.3, double intensity = 5.0}) {
    _shakeTimer = duration;
    _shakeIntensity = intensity;
  }

  void _updateShake(double dt) {
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      final shakeX =
          (math.Random().nextDouble() - 0.5) * 2 * _shakeIntensity;
      final shakeY =
          (math.Random().nextDouble() - 0.5) * 2 * _shakeIntensity;
      camera.viewfinder.position = Vector2(shakeX, shakeY);
    } else {
      camera.viewfinder.position = Vector2.zero();
    }
  }

  void pauseGame() {
    if (gameManager.state != GameState.playing) return;
    gameManager.setState(GameState.paused);
    pauseEngine();
  }

  void resumeGame() {
    if (gameManager.state != GameState.paused) return;
    gameManager.setState(GameState.playing);
    resumeEngine();
  }

  @override
  void onRemove() {
    audioManager.dispose();
    super.onRemove();
  }
}
