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
    // 1. Shadow for depth
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.9),
      size.x * 0.4,
      Paint()..color = Colors.black.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 2. Mobile Launcher Chassis (Truck-like)
    final chassisPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8B0000), Color(0xFF4B0000)],
      ).createShader(Rect.fromLTWH(size.x * 0.1, size.y * 0.3, size.x * 0.8, size.y * 0.5));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.1, size.y * 0.3, size.x * 0.8, size.y * 0.5),
        const Radius.circular(4),
      ),
      chassisPaint,
    );

    // 3. Wheels / Tracks
    final wheelPaint = Paint()..color = const Color(0xFF222222);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.x * 0.05, size.y * 0.35, 6, 12), const Radius.circular(2)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.x * 0.85, size.y * 0.35, 6, 12), const Radius.circular(2)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.x * 0.05, size.y * 0.6, 6, 12), const Radius.circular(2)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.x * 0.85, size.y * 0.6, 6, 12), const Radius.circular(2)), wheelPaint);

    // 4. Missile Tube (Elevated)
    final tubePaint = Paint()..color = const Color(0xFF444444);
    canvas.save();
    canvas.translate(size.x * 0.5, size.y * 0.4);
    // Add a slight rotation if moving? (Maybe later)
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size.x * 0.4, height: size.y * 0.6),
      tubePaint,
    );
    // Tube detail
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, -10), width: size.x * 0.3, height: 4),
      Paint()..color = Colors.black45,
    );
    canvas.restore();

    // 5. Warning / Status light
    canvas.drawCircle(
      Offset(size.x * 0.2, size.y * 0.35),
      2,
      Paint()..color = Colors.yellowAccent.withValues(alpha: 0.8),
    );
  }
}
