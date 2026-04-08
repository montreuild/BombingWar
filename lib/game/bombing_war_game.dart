import 'package:flame/effects.dart';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_config.dart';
import '../models/aircraft_data.dart';
import 'components/aircraft/aircraft_component.dart';
import 'components/aircraft/heavy_bomber_component.dart';
import 'components/aircraft/interceptor_component.dart';
import 'components/aircraft/stealth_component.dart';
import 'components/effects/explosion_effect.dart';
import 'components/environment/starfield_component.dart';
import 'components/effects/crater_component.dart';
import 'components/effects/debris_component.dart';
import 'components/rescue/jeep_component.dart';
import 'components/rescue/pilot_component.dart';
import 'components/rescue/rescue_helicopter_component.dart';
import 'components/environment/terrain_component.dart';
import 'components/hud/hud_component.dart';
import 'components/hud/joystick_component.dart';
import 'components/hud/weapon_button_component.dart';
import 'managers/audio_manager.dart';
import 'managers/game_manager.dart';
import 'managers/level_manager.dart';
import 'managers/save_manager.dart';
import 'systems/collision_system.dart';
import 'systems/score_system.dart';
import 'systems/threat_system.dart';
import 'systems/wave_system.dart';

class BombingWarGame extends FlameGame with KeyboardEvents {
  BombingWarGame({
    required this.saveManager,
    required this.selectedAircraftData,
  });

  final SaveManager saveManager;
  final AircraftData selectedAircraftData;

  // Managers — initialized in onLoad
  late final GameManager gameManager;
  late final LevelManager levelManager;
  late final AudioManager audioManager;

  // Systems
  late final ScoreSystem scoreSystem;
  late final ThreatSystem threatSystem;
  late final WaveSystem waveSystem;
  late final CollisionSystem collisionSystem;

  // Core components
  AircraftComponent? playerAircraft;
  HudComponent? hud;
  JoystickComponent? joystick;
  WeaponButtonComponent? weaponButtons;

  // Squadron & Rescue Management
  int aircraftLosses = 0;
  final List<AircraftData> squadronQueue = [];
  bool isRescueMissionActive = false;

  // Flutter-layer callbacks
  VoidCallback? onGameOver;
  void Function(int score, int coins)? onLevelComplete;

  final Set<LogicalKeyboardKey> _pressedKeys = {};

  // Shake effect properties
  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    if (isKeyDown) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        playerAircraft?.fireWeapon();
      } else if (event.logicalKey == LogicalKeyboardKey.keyE ||
          event.logicalKey == LogicalKeyboardKey.shiftLeft) {
        playerAircraft?.activateSpecial();
      } else if (event.logicalKey == LogicalKeyboardKey.keyQ ||
          event.logicalKey == LogicalKeyboardKey.tab) {
        playerAircraft?.cycleWeapon();
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

    // Initialize Squadron
    for (int i = 0; i < 4; i++) {
      squadronQueue.add(selectedAircraftData);
    }

    audioManager = AudioManager();
    levelManager = LevelManager();
    gameManager = GameManager();
    scoreSystem = ScoreSystem();
    threatSystem = ThreatSystem();
    collisionSystem = CollisionSystem(game: this);
    waveSystem = WaveSystem(game: this);

    levelManager.setLevel(saveManager.progress.currentLevel);

    await _spawnPlayer();
    await add(StarfieldComponent());
    await add(TerrainComponent()); // Ground and Underground layer
    await _buildHud();

    gameManager.setState(GameState.playing);
    waveSystem.startLevel(levelManager.currentLevel);

    // Fire and forget — gracefully silences audio errors if files are absent
    audioManager.playMusic('bgm.mp3').catchError((_) {});
  }

  Future<void> _spawnPlayer() async {
    if (squadronQueue.isEmpty) return;
    final data = squadronQueue.removeAt(0);
    playerAircraft = _createAircraft(data);
    playerAircraft!.position = Vector2(
      GameConfig.worldWidth * 0.1, // Start on the left
      GameConfig.groundLevel * 0.5, // Midway in the sky
    );
    await add(playerAircraft!);
  }

  AircraftComponent _createAircraft(AircraftData data) {
    switch (data.id) {
      case 'interceptor':
        return InterceptorComponent(data: data, game: this);
      case 'heavy_bomber':
        return HeavyBomberComponent(data: data, game: this);
      case 'stealth_x26':
        return StealthComponent(data: data, game: this);
      default:
        return InterceptorComponent(data: data, game: this);
    }
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
    threatSystem.update(dt, isStealthActive: playerAircraft?.isCloaked ?? false);
    waveSystem.update(dt);

    // Feed movement to player aircraft each frame
    if (playerAircraft != null) {
      final kbDir = _getKeyboardDirection();
      if (!kbDir.isZero()) {
        playerAircraft!.applyMovement(kbDir, dt);
      } else if (joystick != null) {
        playerAircraft!.applyMovement(joystick!.direction, dt);
      }
    }

    // Trigger barrage if threat bar is full
    threatSystem.checkBarrage(triggerMissileBarrage);

    // Update HUD threat bar
    hud?.updateThreat(threatSystem.threatPercent);

    _checkConditions();
  }

  void _checkConditions() {
    if (isRescueMissionActive) return; // Wait for rescue result

    if (playerAircraft == null || playerAircraft!.isRemoved) {
      if (squadronQueue.isNotEmpty && aircraftLosses < GameConfig.maxLossesPerMission) {
        _spawnPlayer();
      } else {
        _triggerGameOver();
      }
      return;
    }
    if (waveSystem.isLevelComplete) {
      _triggerLevelComplete();
    }
  }

  void onAircraftDestroyed(Vector2 pos, bool wasEjected) {
    aircraftLosses++;
    playerAircraft = null;
    audioManager.playMayday().catchError((_) {});

    if (wasEjected) {
      isRescueMissionActive = true;
      audioManager.playPilotEjected().catchError((_) {});
      final pilot = PilotComponent(position: pos, game: this);
      add(pilot);
      
      // Schedule helicopter arrival
      Future.delayed(const Duration(seconds: 10), () {
        if (isRescueMissionActive) {
          audioManager.playRescueArrived().catchError((_) {});
          add(RescueHelicopterComponent(game: this)..position = Vector2(-50, 50));
        }
      });
      
      // Spawn initial threat
      add(JeepComponent(position: Vector2(GameConfig.worldWidth + 50, GameConfig.groundLevel - 10), game: this));
    } else {
      // No ejection, just try to spawn next plane if available
      if (squadronQueue.isNotEmpty && aircraftLosses < GameConfig.maxLossesPerMission) {
        _spawnPlayer();
      } else if (aircraftLosses >= GameConfig.maxLossesPerMission) {
        _triggerGameOver();
      }
    }
  }

  void onPilotKilled() {
    isRescueMissionActive = false;
    _triggerGameOver();
  }

  void onPilotRescued() {
    isRescueMissionActive = false;
    scoreSystem.addBonus(GameConfig.pilotRescueBonus);
    if (squadronQueue.isNotEmpty && aircraftLosses < GameConfig.maxLossesPerMission) {
      _spawnPlayer();
    } else {
      _triggerGameOver();
    }
  }

  void onAircraftOutOfAmmo() {
    if (playerAircraft == null) return;
    
    // Make the current aircraft fly away to the right
    final oldAircraft = playerAircraft!;
    oldAircraft.add(MoveByEffect(
      Vector2(GameConfig.worldWidth, -50),
      EffectController(duration: 2.0, curve: Curves.easeIn),
      onComplete: () => oldAircraft.removeFromParent(),
    ));
    playerAircraft = null;

    if (squadronQueue.isNotEmpty) {
      _spawnPlayer();
    } else {
      // Out of planes and out of ammo? Level might be failed if objectives not met
      // but usually we'll have enough.
    }
  }

  void _triggerGameOver() {
    if (gameManager.state == GameState.gameOver) return;
    gameManager.setState(GameState.gameOver);
    audioManager.playGameOver().catchError((_) {});
    onGameOver?.call();
  }

  void _triggerLevelComplete() {
    if (gameManager.state == GameState.levelComplete) return;
    gameManager.setState(GameState.levelComplete);

    final missionScore = scoreSystem.sessionScore;
    final coins = saveManager.progress.missionCoins(missionScore);

    saveManager.progress.addScore(missionScore);
    saveManager.progress.coins += coins;
    saveManager.progress.currentLevel++;

    saveManager.save();
    audioManager.playLevelComplete().catchError((_) {});
    onLevelComplete?.call(missionScore, coins);
  }

  /// Called by threat system when barrage threshold is reached.
  void triggerMissileBarrage() {
    waveSystem.spawnBarrage();
    audioManager.playThreatBarrage().catchError((_) {});
  }

  /// Add an explosion visual effect at [pos].
  void spawnExplosion(Vector2 pos, {double radius = 40.0}) {
    add(ExplosionEffect(position: pos.clone(), radius: radius));
    audioManager.playExplosion().catchError((_) {});
    shakeScreen(intensity: radius / 10.0);

    // Spawn debris
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

    // Spawn crater if near ground
    if ((pos.y - GameConfig.groundLevel).abs() < 20) {
      add(CraterComponent(position: Vector2(pos.x, GameConfig.groundLevel), radius: radius * 0.5));
    }
  }

  void shakeScreen({double duration = 0.3, double intensity = 5.0}) {
    _shakeTimer = duration;
    _shakeIntensity = intensity;
  }

  void _updateShake(double dt) {
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      final shakeX = (math.Random().nextDouble() - 0.5) * 2 * _shakeIntensity;
      final shakeY = (math.Random().nextDouble() - 0.5) * 2 * _shakeIntensity;
      camera.viewfinder.position = Vector2(shakeX, shakeY);
    } else {
      camera.viewfinder.position = Vector2.zero();
    }
  }

  /// Notify score system of a kill and update HUD.
  void registerKill(int scoreValue) {
    scoreSystem.addKill(scoreValue);
    hud?.updateScore(scoreSystem.sessionScore);
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
