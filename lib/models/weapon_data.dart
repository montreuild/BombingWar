import '../config/game_config.dart';

enum WeaponType { bullet, missile, bomb, penetratorBomb }

class WeaponData {
  const WeaponData({
    required this.name,
    required this.damage,
    required this.range,
    required this.cooldown,
    required this.type,
    this.explosionRadius = 0.0,
  });

  final String name;
  final double damage;
  final double range;
  final double cooldown;
  final WeaponType type;
  final double explosionRadius;

  // ---------------------------------------------------------------------------
  // Preset weapon definitions
  // ---------------------------------------------------------------------------

  static const WeaponData machineGun = WeaponData(
    name: 'Canon 20mm',
    damage: GameConfig.bulletDamage,
    range: GameConfig.bulletRange,
    cooldown: GameConfig.bulletCooldown,
    type: WeaponType.bullet,
  );

  static const WeaponData heatMissile = WeaponData(
    name: 'Missile Python-5',
    damage: GameConfig.missileDamage,
    range: GameConfig.missileRange,
    cooldown: GameConfig.missileCooldown,
    type: WeaponType.missile,
  );

  static const WeaponData carpetBomb = WeaponData(
    name: 'Bombe Mk.82',
    damage: GameConfig.bombDamage,
    range: GameConfig.worldHeight,
    cooldown: GameConfig.bombCooldown,
    type: WeaponType.bomb,
    explosionRadius: GameConfig.bombExplosionRadius,
  );

  static const WeaponData penetratorBomb = WeaponData(
    name: 'Perforateur GBU-28',
    damage: GameConfig.penetratorDamage,
    range: GameConfig.worldHeight,
    cooldown: GameConfig.penetratorCooldown,
    type: WeaponType.penetratorBomb,
    explosionRadius: GameConfig.penetratorExplosionRadius,
  );
}
