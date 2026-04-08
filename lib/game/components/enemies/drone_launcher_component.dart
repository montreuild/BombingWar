import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';
import '../../bombing_war_game.dart';
import 'drone_component.dart';

/// Drone Launcher — launches waves of 1-3 drones.
/// States: IDLE → ARMED (if radar nearby or player detected) → LAUNCHING → COOLDOWN → ARMED
enum DroneLauncherState { idle, armed, launching, cooldown }

class DroneLauncherComponent extends EnemyComponent {
  DroneLauncherComponent({
    required super.game,
    required super.position,
    this.dronesPerWave = 1,
  }) : super(
          enemyData: EnemyData.droneLauncher,
        );

  final int dronesPerWave;
  DroneLauncherState _launcherState = DroneLauncherState.idle;
  double _cooldownTimer = 0.0;

  @override
  void onUpdate(double dt, bool canFire) {
    switch (_launcherState) {
      case DroneLauncherState.idle:
        if (aiState == EnemyAIState.alert || aiState == EnemyAIState.attack) {
          _launcherState = DroneLauncherState.armed;
        }
        break;
      case DroneLauncherState.armed:
        if (canFire) {
          _launchDrones();
          _launcherState = DroneLauncherState.launching;
        }
        break;
      case DroneLauncherState.launching:
        _launcherState = DroneLauncherState.cooldown;
        _cooldownTimer = GameConfig.droneLauncherFireCooldown;
        resetFireCooldown(GameConfig.droneLauncherFireCooldown);
        break;
      case DroneLauncherState.cooldown:
        _cooldownTimer -= dt;
        if (_cooldownTimer <= 0) {
          _launcherState = DroneLauncherState.armed;
        }
        break;
    }
  }

  void _launchDrones() {
    final count = dronesPerWave.clamp(1, GameConfig.maxDronesPerWave);
    for (int i = 0; i < count; i++) {
      game.addToWorld(DroneComponent(
        game: game,
        position: position.clone() + Vector2(i * 15.0, -10.0 - i * 5.0),
      ));
      game.onDroneLaunched();
    }
  }

  @override
  void onRender(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Launch platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 4), width: 20, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4A5A3A),
    );

    // Launch rails
    canvas.drawLine(
      Offset(cx - 6, cy),
      Offset(cx - 6, cy - 8),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(cx + 6, cy),
      Offset(cx + 6, cy - 8),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 2,
    );

    // State indicator
    Color indicatorColor;
    switch (_launcherState) {
      case DroneLauncherState.idle:
        indicatorColor = Colors.grey;
        break;
      case DroneLauncherState.armed:
        indicatorColor = Colors.red;
        break;
      case DroneLauncherState.launching:
        indicatorColor = Colors.orange;
        break;
      case DroneLauncherState.cooldown:
        indicatorColor = Colors.yellow;
        break;
    }
    canvas.drawCircle(
      Offset(cx, cy - 10),
      2,
      Paint()..color = indicatorColor,
    );
  }
}
