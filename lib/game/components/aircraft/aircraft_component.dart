import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../../models/weapon_data.dart';
import '../../bombing_war_game.dart';
import '../projectiles/bomb_component.dart';
import '../projectiles/bullet_component.dart';
import '../projectiles/missile_component.dart';

/// Single aircraft type for Desert Strike Mobile.
/// 8-direction movement via joystick, velocity + drag, no gravity.
/// Ammo: 200 canon, 6 missiles, 6 bombs. GBU-57 managed by game.
class AircraftComponent extends PositionComponent {
  AircraftComponent({
    required this.game,
  }) : super(size: Vector2.all(GameConfig.aircraftSize), anchor: Anchor.center);

  final BombingWarGame game;

  double _health = GameConfig.aircraftHealth;
  final double _maxHealth = GameConfig.aircraftHealth;

  // Velocity-based movement
  Vector2 _velocity = Vector2.zero();

  // Per-plane ammo (reset on switch)
  int _canonAmmo = GameConfig.canonAmmoPerPlane;
  int _missileAmmo = GameConfig.missileAmmoPerPlane;
  int _bombAmmo = GameConfig.bombAmmoPerPlane;

  // Weapon cycling: 0=canon, 1=missile, 2=bomb
  int _currentWeaponIndex = 0;
  double _fireCooldown = 0.0;
  bool _isInvincible = false;

  // Accessors
  double get health => _health;
  double get maxHealth => _maxHealth;
  int get canonAmmo => _canonAmmo;
  int get missileAmmo => _missileAmmo;
  int get bombAmmo => _bombAmmo;
  int get totalRemainingAmmo => _canonAmmo + _missileAmmo + _bombAmmo;
  double get hitRadius => GameConfig.aircraftSize * 0.4;
  bool get isAlive => _health > 0;
  bool get isInvincible => _isInvincible;

  static const List<WeaponData> _weapons = [
    WeaponData.canon,
    WeaponData.guidedMissile,
    WeaponData.classicBomb,
  ];

  WeaponData get currentWeapon => _weapons[_currentWeaponIndex];

  String get currentWeaponName {
    switch (_currentWeaponIndex) {
      case 0:
        return 'Canon ($_canonAmmo)';
      case 1:
        return 'Missiles ($_missileAmmo)';
      case 2:
        return 'Bombes ($_bombAmmo)';
      default:
        return '';
    }
  }

  int get currentAmmo {
    switch (_currentWeaponIndex) {
      case 0:
        return _canonAmmo;
      case 1:
        return _missileAmmo;
      case 2:
        return _bombAmmo;
      default:
        return 0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply drag
    _velocity *= GameConfig.aircraftDrag;

    // Move
    position += _velocity * dt;

    // Cooldown
    if (_fireCooldown > 0) _fireCooldown -= dt;

    // Ground collision check
    if (position.y >= GameConfig.groundLevel) {
      // Crash into ground
      _health = 0;
      game.spawnExplosion(position, radius: 50.0);
      final wasEjected =
          math.Random().nextDouble() < GameConfig.pilotEjectProbability;
      game.onAircraftDestroyed(position.clone(), wasEjected);
      removeFromParent();
      return;
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
    // Body (Fuselage)
    final bodyPath = Path()
      ..moveTo(size.x * 0.1, size.y * 0.5) // Tail
      ..quadraticBezierTo(
          size.x * 0.5, size.y * 0.2, size.x * 0.9, size.y * 0.5)
      ..quadraticBezierTo(
          size.x * 0.5, size.y * 0.8, size.x * 0.1, size.y * 0.5)
      ..close();

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.shade600,
          Colors.grey.shade800,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(bodyPath, bodyPaint);

    // Tail fin
    final tailPath = Path()
      ..moveTo(size.x * 0.15, size.y * 0.4)
      ..lineTo(size.x * 0.05, size.y * 0.15)
      ..lineTo(size.x * 0.25, size.y * 0.4)
      ..close();
    canvas.drawPath(tailPath, bodyPaint);

    // Wings
    final wingPaint = Paint()..color = Colors.grey.shade500;
    final wingPath = Path()
      ..moveTo(size.x * 0.35, size.y * 0.5)
      ..lineTo(size.x * 0.55, size.y * 0.75)
      ..lineTo(size.x * 0.65, size.y * 0.5)
      ..close();
    canvas.drawPath(wingPath, wingPaint);

    // Cockpit Glass
    final cockpitPaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.6, size.y * 0.35, size.x * 0.2, size.y * 0.12),
      cockpitPaint,
    );

    // Engine Exhaust Glow
    final enginePaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(size.x * 0.1, size.y * 0.5), 3, enginePaint);
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
  // Movement (8 directions via joystick, velocity + drag)
  // ---------------------------------------------------------------------------

  void applyMovement(Vector2 direction, double dt) {
    if (direction.isZero()) return;
    _velocity += direction * GameConfig.aircraftSpeed * dt;
    // Clamp max velocity
    if (_velocity.length > GameConfig.aircraftSpeed) {
      _velocity = _velocity.normalized() * GameConfig.aircraftSpeed;
    }
  }

  void _clampToWorld() {
    const halfSize = GameConfig.aircraftSize / 2;
    position.x = position.x.clamp(halfSize, game.missionDistance - halfSize);
    // Allow the aircraft to reach groundLevel so the crash check fires.
    // Using worldHeight - halfSize keeps the centre within world bounds while
    // still letting position.y exceed groundLevel (280) on the way down.
    position.y = position.y.clamp(halfSize, GameConfig.worldHeight - halfSize);
  }

  // ---------------------------------------------------------------------------
  // Weapons
  // ---------------------------------------------------------------------------

  void cycleWeapon() {
    _currentWeaponIndex = (_currentWeaponIndex + 1) % _weapons.length;
    game.hud?.updateWeapon(currentWeaponName);
  }

  /// Select a specific weapon type. Used by HUD buttons.
  void selectWeapon(int index) {
    if (index >= 0 && index < _weapons.length) {
      _currentWeaponIndex = index;
      game.hud?.updateWeapon(currentWeaponName);
    }
  }

  void fireWeapon() {
    if (_fireCooldown > 0) return;
    if (currentAmmo <= 0) return;

    _fireCooldown = currentWeapon.cooldown;
    _decrementAmmo();
    _spawnProjectile(currentWeapon);
    game.audioManager.playShoot().catchError((_) {});
  }

  void _decrementAmmo() {
    switch (_currentWeaponIndex) {
      case 0:
        _canonAmmo--;
        break;
      case 1:
        _missileAmmo--;
        break;
      case 2:
        _bombAmmo--;
        break;
    }
  }

  void _spawnProjectile(WeaponData weapon) {
    final spawnPos = position + Vector2(size.x * 0.4, size.y * 0.2);
    switch (weapon.type) {
      case WeaponType.canon:
        game.add(BulletComponent(
          position: spawnPos,
          direction: Vector2(1, 0),
          damage: weapon.damage,
          isPlayerProjectile: true,
        ));
        break;
      case WeaponType.missile:
        game.add(MissileComponent(
          position: spawnPos,
          damage: weapon.damage,
          isPlayerProjectile: true,
          game: game,
        ));
        break;
      case WeaponType.bomb:
        game.add(BombComponent(
          position: spawnPos,
          damage: weapon.damage,
          explosionRadius: weapon.explosionRadius,
          isPlayerProjectile: true,
          isPenetrator: false,
        ));
        break;
      case WeaponType.gbu57:
        // GBU-57 is handled via cutscene, not direct fire
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Damage / Health
  // ---------------------------------------------------------------------------

  void takeDamage(double amount) {
    if (_isInvincible) return;
    _health -= amount;
    if (_health <= 0) {
      _health = 0;
      game.spawnExplosion(position, radius: 50.0);

      final wasEjected =
          math.Random().nextDouble() < GameConfig.pilotEjectProbability;
      game.onAircraftDestroyed(position.clone(), wasEjected);

      removeFromParent();
    }
  }

  /// Grant brief invincibility.
  void setInvincible(double duration) {
    _isInvincible = true;
    Future.delayed(
      Duration(milliseconds: (duration * 1000).round()),
      () => _isInvincible = false,
    );
  }
}
