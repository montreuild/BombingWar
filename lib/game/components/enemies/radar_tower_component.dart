import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/enemy_data.dart';
import 'enemy_component.dart';

class RadarTowerComponent extends EnemyComponent {
  RadarTowerComponent({required super.game, required super.position})
      : super(enemyData: EnemyData.bunker); // Reusing bunker data for stats

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
      // Check distance from center of tower
      _playerInZone = dist < radarRadius;
      
      if (_playerInZone && !wasInZone) {
        game.audioManager.playRadarBeep().catchError((_) {});
      }
    } else {
      _playerInZone = false;
    }
  }

  @override
  void onRender(Canvas canvas) {
    // 1. Tower Structure (Lattice style)
    final towerPaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path = Path()
      ..moveTo(size.x * 0.3, size.y)
      ..lineTo(size.x * 0.5, size.y * 0.2)
      ..lineTo(size.x * 0.7, size.y)
      ..moveTo(size.x * 0.4, size.y * 0.6)
      ..lineTo(size.x * 0.6, size.y * 0.6)
      ..moveTo(size.x * 0.45, size.y * 0.4)
      ..lineTo(size.x * 0.55, size.y * 0.4);
    canvas.drawPath(path, towerPaint);
    
    // Rotating Dish
    final dishPaint = Paint()..color = const Color(0xFF666666)..style = PaintingStyle.stroke..strokeWidth = 3;
    final dishAngle = _pulseTimer * 3;
    canvas.save();
    canvas.translate(size.x * 0.5, size.y * 0.2);
    canvas.rotate(dishAngle);
    canvas.drawArc(Rect.fromCenter(center: Offset.zero, width: 30, height: 10), 0, 3.14, false, dishPaint);
    canvas.restore();

    // 2. Radar Zone (Visual scanning effect)
    final pulse = (_pulseTimer % 2.0) / 2.0;
    final color = _playerInZone ? Colors.red : Colors.green;
    
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.5), 
      radarRadius * pulse, 
      Paint()..color = color.withValues(alpha: 0.1 * (1.0 - pulse))
    );
    
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.5), 
      radarRadius, 
      Paint()..color = color.withValues(alpha: 0.2)..style = PaintingStyle.stroke
    );

    // Red light at top (pulsing)
    final pulseVal = (0.5 + 0.5 * math.sin(_pulseTimer * 5)).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.2), 
      3, 
      Paint()..color = Colors.red.withValues(alpha: pulseVal)
    );
  }
}
