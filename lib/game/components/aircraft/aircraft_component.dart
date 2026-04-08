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

  double get health => _health;
  double get maxHealth => _maxHealth;
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

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + 4, size.y / 2 + 6),
          width: size.x * 0.4,
          height: size.y * 0.8),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.3 * alpha),
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          bodyColor.withValues(alpha: alpha),
          bodyColor.withValues(alpha: 0.7 * alpha),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    final wingPaint = Paint()
      ..color = wingColor.withValues(alpha: alpha);

    // Wings with depth
    final wingPath = Path()
      ..moveTo(size.x * 0.5, size.y * 0.4)
      ..lineTo(0, size.y * 0.7)
      ..lineTo(size.x * 0.35, size.y * 0.55)
      ..close()
      ..moveTo(size.x * 0.5, size.y * 0.4)
      ..lineTo(size.x, size.y * 0.7)
      ..lineTo(size.x * 0.65, size.y * 0.55)
      ..close();
    
    canvas.drawPath(wingPath, wingPaint);
    canvas.drawPath(wingPath, Paint()..color = Colors.black12..style = PaintingStyle.stroke..strokeWidth = 1);

    // Fuselage
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.x / 2, size.y / 2),
            width: size.x * 0.4,
            height: size.y * 0.8),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Cockpit highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.35),
        width: size.x * 0.15,
        height: size.y * 0.2,
      ),
      Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.6 * alpha),
    );

    // Engine glow - Animated
    final pulse = 0.8 + (0.2 * (DateTime.now().millisecondsSinceEpoch % 1000 / 1000));
    canvas.drawCircle(
      Offset(size.x / 2, size.y * 0.88),
      5 * pulse,
      Paint()
        ..color = const Color(0xFFFF6600).withValues(alpha: 0.9 * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * pulse),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y * 0.88),
      2,
      Paint()..color = Colors.white.withValues(alpha: 0.8 * alpha),
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
    if (_fireCooldown > 0) return;
    _fireCooldown = currentWeapon.cooldown;
    _spawnProjectile(currentWeapon);
    game.audioManager.playShoot().catchError((_) {});
  }

  void _spawnProjectile(WeaponData weapon) {
    final spawnPos = position - Vector2(0, GameConfig.aircraftSize / 2);
    switch (weapon.type) {
      case WeaponType.bullet:
        game.add(BulletComponent(
          position: spawnPos,
          direction: Vector2(0, -1),
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
