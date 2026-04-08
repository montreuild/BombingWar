import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/aircraft_data.dart';
import '../../../models/weapon_data.dart';
import '../../bombing_war_game.dart';
import '../projectiles/bomb_component.dart';
import '../projectiles/bullet_component.dart';
import '../projectiles/missile_component.dart';

/// Base class for all player-controlled aircraft.
abstract class AircraftComponent extends PositionComponent {
  AircraftComponent({
    required this.data,
    required this.game,
  }) : super(size: Vector2.all(GameConfig.aircraftSize), anchor: Anchor.center);

  final AircraftData data;
  final BombingWarGame game;

  late double _health;
  late double _maxHealth;
  int _currentWeaponIndex = 0;
  double _fireCooldown = 0.0;
  double _specialCooldown = 0.0;
  double _specialTimer = 0.0;
  bool _specialActive = false;
  bool _isInvincible = false;

  int _ammoRemaining = GameConfig.maxAmmoPerAircraft;

  double get health => _health;
  double get maxHealth => _maxHealth;
  int get ammoRemaining => _ammoRemaining;
  double get hitRadius => GameConfig.aircraftSize * 0.4;
  bool get isAlive => _health > 0;
  bool get isInvincible => _isInvincible;

  /// Overridden by StealthComponent to expose cloaked state to game systems.
  bool get isCloaked => false;

  WeaponData get currentWeapon => data.weapons[_currentWeaponIndex];
  bool get specialReady => _specialCooldown <= 0;

  // Template-method hooks for subclasses
  Color get bodyColor;
  Color get wingColor;
  double get specialDuration;
  void onSpecialStart();
  void onSpecialEnd() {}

  /// Override in HeavyBomber to apply armor reduction.
  double applyDamageReduction(double amount) => amount;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _health = data.health;
    _maxHealth = data.health;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_fireCooldown > 0) _fireCooldown -= dt;
    if (_specialCooldown > 0) _specialCooldown -= dt;
    if (_specialActive) {
      _specialTimer -= dt;
      if (_specialTimer <= 0) _endSpecial();
    }
    _clampToWorld();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderBody(canvas);
    _renderHealthBar(canvas);
  }

  void _renderBody(Canvas canvas) {
    final alpha = isCloaked ? 0.35 : 1.0;

    // Rotation based on movement (slight tilt)
    // In side-view, we face right (angle 0) or left.
    
    // Fuselage (Horizontal)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          bodyColor.withValues(alpha: alpha),
          bodyColor.withValues(alpha: 0.7 * alpha),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    // Tail fin
    final tailPath = Path()
      ..moveTo(size.x * 0.1, size.y * 0.5)
      ..lineTo(0, size.y * 0.2)
      ..lineTo(size.x * 0.2, size.y * 0.5)
      ..close();
    canvas.drawPath(tailPath, bodyPaint);

    // Main Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.1, size.y * 0.35, size.x * 0.8, size.y * 0.3),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Wings (Side profile)
    final wingPaint = Paint()..color = wingColor.withValues(alpha: alpha);
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.4, size.y * 0.45, size.x * 0.3, size.y * 0.1),
      wingPaint,
    );

    // Cockpit
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.6, size.y * 0.35, size.x * 0.2, size.y * 0.15),
      Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.6 * alpha),
    );

    // Engine Glow (Back)
    final pulse = 0.8 + (0.2 * (DateTime.now().millisecondsSinceEpoch % 500 / 500));
    canvas.drawCircle(
      Offset(size.x * 0.1, size.y * 0.5),
      4 * pulse,
      Paint()
        ..color = const Color(0xFFFF6600).withValues(alpha: 0.9 * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * pulse),
    );
  }

  void _renderHealthBar(Canvas canvas) {
    const barWidth = GameConfig.aircraftSize;
    const barHeight = 4.0;
    const barY = -10.0;

    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2 + size.x / 2, barY, barWidth, barHeight),
      Paint()..color = Colors.black54,
    );

    final pct = (_health / _maxHealth).clamp(0.0, 1.0);
    final color = pct > 0.5
        ? Colors.green
        : pct > 0.25
            ? Colors.orange
            : Colors.red;

    canvas.drawRect(
      Rect.fromLTWH(
          -barWidth / 2 + size.x / 2, barY, barWidth * pct, barHeight),
      Paint()..color = color,
    );
  }

  // ---------------------------------------------------------------------------
  // Movement
  // ---------------------------------------------------------------------------

  void applyMovement(Vector2 direction, double dt) {
    if (direction.isZero()) return;
    position += direction * data.speed * dt;
  }

  void _clampToWorld() {
    position.x = position.x.clamp(
        GameConfig.aircraftSize / 2,
        GameConfig.worldWidth - GameConfig.aircraftSize / 2);
    position.y = position.y.clamp(
        GameConfig.aircraftSize / 2,
        GameConfig.worldHeight - GameConfig.aircraftSize / 2);
  }

  // ---------------------------------------------------------------------------
  // Weapons
  // ---------------------------------------------------------------------------

  void cycleWeapon() {
    if (data.weapons.length <= 1) return;
    _currentWeaponIndex = (_currentWeaponIndex + 1) % data.weapons.length;
    game.hud?.updateWeapon(currentWeapon.name);
  }

  void fireWeapon() {
    if (_fireCooldown > 0 || _ammoRemaining <= 0) return;
    
    _fireCooldown = currentWeapon.cooldown;
    _ammoRemaining--;
    _spawnProjectile(currentWeapon);
    game.audioManager.playShoot().catchError((_) {});

    if (_ammoRemaining <= 0) {
      game.onAircraftOutOfAmmo();
    }
  }

  void _spawnProjectile(WeaponData weapon) {
    // Projectiles spawn from the front/bottom of the plane
    final spawnPos = position + Vector2(size.x * 0.4, size.y * 0.2);
    switch (weapon.type) {
      case WeaponType.bullet:
        game.add(BulletComponent(
          position: spawnPos,
          direction: Vector2(1, 0), // Side-view: fire right
          damage: weapon.damage,
          isPlayerProjectile: true,
        ));
      case WeaponType.missile:
        game.add(MissileComponent(
          position: spawnPos,
          damage: weapon.damage,
          isPlayerProjectile: true,
          game: game,
        ));
      case WeaponType.bomb:
        game.add(BombComponent(
          position: spawnPos,
          damage: weapon.damage,
          explosionRadius: weapon.explosionRadius,
          isPlayerProjectile: true,
          isPenetrator: false,
        ));
      case WeaponType.penetratorBomb:
        game.add(BombComponent(
          position: spawnPos,
          damage: weapon.damage,
          explosionRadius: weapon.explosionRadius,
          isPlayerProjectile: true,
          isPenetrator: true,
        ));
    }
  }

  // ---------------------------------------------------------------------------
  // Damage / Health
  // ---------------------------------------------------------------------------

  void takeDamage(double amount) {
    if (_isInvincible) return;
    final reduced = applyDamageReduction(amount);
    _health -= reduced;
    if (_health <= 0) {
      _health = 0;
      game.spawnExplosion(position, radius: 50.0);
      
      // 50% chance of ejection
      final wasEjected = math.Random().nextBool();
      game.onAircraftDestroyed(position.clone(), wasEjected);

      removeFromParent();
    }
  }

  // ---------------------------------------------------------------------------
  // Special ability
  // ---------------------------------------------------------------------------

  void activateSpecial() {
    if (_specialCooldown > 0) return;
    _specialCooldown = GameConfig.specialCooldown;
    _specialTimer = specialDuration;
    _specialActive = true;
    onSpecialStart();
    game.audioManager.playSpecial().catchError((_) {});
  }

  void _endSpecial() {
    _specialActive = false;
    onSpecialEnd();
  }

  /// Grant brief invincibility (used by barrel roll).
  void setInvincible(double duration) {
    _isInvincible = true;
    Future.delayed(
      Duration(milliseconds: (duration * 1000).round()),
      () => _isInvincible = false,
    );
  }
}
