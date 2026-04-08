import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';

class RadarTowerComponent extends EnemyComponent {
  RadarTowerComponent({required super.game, required super.position})
      : super(enemyData: EnemyData.bunker); // Reusing bunker data for stats or define new

  final double radarRadius = 150.0;
  double _pulseTimer = 0.0;
  bool _playerInZone = false;

  @override
  void onUpdate(double dt, bool canFire) {
    _pulseTimer += dt;
    
    final player = game.playerAircraft;
    if (player != null) {
      final dist = position.distanceTo(player.position);
      final wasInZone = _playerInZone;
      _playerInZone = dist < radarRadius && !player.isCloaked;
      
      if (_playerInZone && !wasInZone) {
        game.audioManager.playRadarBeep().catchError((_) {});
      }
    } else {
      _playerInZone = false;
    }
  }

  @override
  void onRender(Canvas canvas) {
    // 1. Tower Structure
    final towerPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRect(Rect.fromLTWH(size.x * 0.4, size.y * 0.2, size.x * 0.2, size.y * 0.8), towerPaint);
    
    // Rotating Dish
    final dishPaint = Paint()..color = const Color(0xFF555555)..style = PaintingStyle.stroke..strokeWidth = 3;
    final dishAngle = _pulseTimer * 3;
    canvas.save();
    canvas.translate(size.x * 0.5, size.y * 0.2);
    canvas.drawArc(Rect.fromCenter(center: Offset.zero, width: 30, height: 10), dishAngle, 2.0, false, dishPaint);
    canvas.restore();

    // 2. Radar Zone (The Circle)
    final pulse = (_pulseTimer % 2.0) / 2.0;
    final radarPaint = Paint()
      ..color = (_playerInZone ? Colors.red : Colors.green).withValues(alpha: 0.1 + (0.1 * (1.0 - pulse)))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.5), radarRadius * pulse, radarPaint);
    
    final borderPaint = Paint()
      ..color = (_playerInZone ? Colors.red : Colors.green).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.5), radarRadius, borderPaint);

    // Red light at top
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.1), 3, Paint()..color = Colors.red);
  }
}
