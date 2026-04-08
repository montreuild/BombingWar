import '../config/game_config.dart';

enum WeaponType { canon, missile, bomb, gbu57 }

class WeaponData {
  const WeaponData({
    required this.name,
    required this.damage,
    required this.range,
    required this.cooldown,
    required this.type,
    this.explosionRadius = 0.0,
    this.maxAmmo = 0,
  });

  final String name;
  final double damage;
  final double range;
  final double cooldown;
  final WeaponType type;
  final double explosionRadius;
  final int maxAmmo;

  // ---------------------------------------------------------------------------
  // Preset weapon definitions
  // ---------------------------------------------------------------------------

  static const WeaponData canon = WeaponData(
    name: 'Canon 20mm',
    damage: GameConfig.canonDamage,
    range: GameConfig.canonRange,
    cooldown: GameConfig.canonCooldown,
    type: WeaponType.canon,
    maxAmmo: GameConfig.canonAmmoPerPlane,
  );

  static const WeaponData guidedMissile = WeaponData(
    name: 'Missile Guidé',
    damage: GameConfig.missileDamage,
    range: GameConfig.missileRange,
    cooldown: GameConfig.missileCooldown,
    type: WeaponType.missile,
    maxAmmo: GameConfig.missileAmmoPerPlane,
  );

  static const WeaponData classicBomb = WeaponData(
    name: 'Bombe Classique',
    damage: GameConfig.bombDamage,
    range: GameConfig.worldHeight,
    cooldown: GameConfig.bombCooldown,
    type: WeaponType.bomb,
    explosionRadius: GameConfig.bombExplosionRadius,
    maxAmmo: GameConfig.bombAmmoPerPlane,
  );

  static const WeaponData gbu57 = WeaponData(
    name: 'GBU-57',
    damage: GameConfig.gbuDamage,
    range: GameConfig.worldHeight,
    cooldown: 0.0, // single use
    type: WeaponType.gbu57,
    explosionRadius: GameConfig.gbuExplosionRadius,
    maxAmmo: GameConfig.gbuPerMission,
  );

  static const List<WeaponData> allWeapons = [canon, guidedMissile, classicBomb, gbu57];
}
