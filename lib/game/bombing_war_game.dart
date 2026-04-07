import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../models/aircraft_data.dart';
import 'managers/save_manager.dart';
import 'managers/audio_manager.dart';
import 'managers/level_manager.dart';
import 'managers/game_manager.dart';
import 'systems/collision_system.dart';
import 'systems/score_system.dart';
import 'systems/threat_system.dart';
import 'systems/wave_system.dart';
import 'components/aircraft/aircraft_component.dart';
import 'components/aircraft/interceptor_component.dart';
import 'components/aircraft/heavy_bomber_component.dart';
import 'components/aircraft/stealth_component.dart';
import 'components/hud/hud_component.dart';
import 'components/hud/joystick_component.dart';
import 'components/hud/weapon_button_component.dart';
import 'components/effects/explosion_effect.dart';

class BombingWarGame extends FlameGame {
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

  // Flutter-layer callbacks
  VoidCallback? onGameOver;
  void Function(int score, int coins)? onLevelComplete;

  @override
  Color backgroundColor() => const Color(0xFF1A2A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fix world size so all devices render the same 400x800 world.
    // Flame 1.18 uses the CameraComponent; visibleGameSize scales content
    // to fill the screen while preserving the game coordinate space.
    camera.viewfinder.visibleGameSize =
        Vector2(GameConfig.worldWidth, GameConfig.worldHeight);

    audioManager = AudioManager();
    levelManager = LevelManager();
    gameManager = GameManager();
    scoreSystem = ScoreSystem();
    threatSystem = ThreatSystem();
    collisionSystem = CollisionSystem(game: this);
    waveSystem = WaveSystem(game: this);

    levelManager.setLevel(saveManager.progress.currentLevel);

    await _spawnPlayer();
    await _buildHud();

    gameManager.setState(GameState.playing);
    waveSystem.startLevel(levelManager.currentLevel);

    // Fire and forget — gracefully silences audio errors if files are absent
    audioManager.playMusic('bgm.mp3').catchError((_) {});
  }

  Future<void> _spawnPlayer() async {
    playerAircraft = _createAircraft(selectedAircraftData);
    playerAircraft!.position = Vector2(
      GameConfig.worldWidth / 2,
      GameConfig.worldHeight * 0.75,
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

    collisionSystem.update(dt);
    scoreSystem.update(dt);
    threatSystem.update(dt, isStealthActive: playerAircraft?.isCloaked ?? false);
    waveSystem.update(dt);

    // Feed joystick direction to player aircraft each frame
    if (playerAircraft != null && joystick != null) {
      playerAircraft!.applyMovement(joystick!.direction, dt);
    }

    // Trigger barrage if threat bar is full
    threatSystem.checkBarrage(triggerMissileBarrage);

    // Update HUD threat bar
    hud?.updateThreat(threatSystem.threatPercent);

    _checkConditions();
  }

  void _checkConditions() {
    if (playerAircraft == null || playerAircraft!.isRemoved) {
      _triggerGameOver();
      return;
    }
    if (waveSystem.isLevelComplete) {
      _triggerLevelComplete();
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
