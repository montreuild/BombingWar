import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/enemy_data.dart';
import '../projectiles/missile_component.dart';
import 'enemy_component.dart';

/// RPG unit — fires slow homing rockets at the player.
class RpgUnitComponent extends EnemyComponent {
  RpgUnitComponent({required super.game, required super.position})
      : super(enemyData: EnemyData.rpgUnit);

  @override
  void onUpdate(double dt, bool canFire) {
    // Slow drift toward player for pressure
    final player = game.playerAircraft;
    if (player != null) {
      final dir = (player.position - position).normalized();
      position += dir * enemyData.speed * dt;
    }

    if (canFire && player != null) {
      _fireRocket();
      resetFireCooldown(GameConfig.rpgFireCooldown);
    }
  }

  void _fireRocket() {
    game.add(MissileComponent(
      position: position.clone(),
      damage: enemyData.damage,
      isPlayerProjectile: false,
      game: game,
    ));
    game.audioManager.playMissile().catchError((_) {});
  }

  @override
  void onRender(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF556644);
    final skinPaint = Paint()..color = const Color(0xFFFFDBAC);
    final tubePaint = Paint()..color = const Color(0xFF222222);

    // 1. Soldier (Kneeling/Shouldering RPG)
    // Head
    canvas.drawCircle(Offset(size.x * 0.4, size.y * 0.4), 5, skinPaint);
    // Helmet
    canvas.drawArc(Rect.fromCircle(center: Offset(size.x * 0.4, size.y * 0.4), radius: 6), -3.14, 3.14, true, bodyPaint);
    
    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.x * 0.3, size.y * 0.55, 10, 10), const Radius.circular(2)), bodyPaint);
    
    // 2. RPG Launcher (The "Tube")
    canvas.save();
    canvas.translate(size.x * 0.5, size.y * 0.45);
    // Angle slightly up towards sky
    canvas.rotate(-0.5); 
    
    // Main tube
    canvas.drawRect(const Rect.fromLTWH(-8, -2, 22, 4), tubePaint);
    // Back cone (exhaust)
    final backPath = Path()
      ..moveTo(-8, -2)
      ..lineTo(-12, -4)
      ..lineTo(-12, 4)
      ..lineTo(-8, 2)
      ..close();
    canvas.drawPath(backPath, tubePaint);
    
    // Front rocket tip (if loaded)
    if (fireCooldown <= 0.5) {
      canvas.drawCircle(const Offset(14, 0), 3, Paint()..color = Colors.grey);
    }
    
    canvas.restore();
  }
}
