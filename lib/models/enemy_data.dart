import '../config/game_config.dart';

enum EnemyType { infantry, rpgUnit, bunker, factory }

class EnemyData {
  const EnemyData({
    required this.type,
    required this.name,
    required this.health,
    required this.speed,
    required this.damage,
    required this.scoreValue,
    required this.size,
  });

  final EnemyType type;
  final String name;
  final double health;
  final double speed;
  final double damage;
  final int scoreValue;
  final double size;

  // ---------------------------------------------------------------------------
  // Preset enemy definitions
  // ---------------------------------------------------------------------------

  static const EnemyData infantry = EnemyData(
    type: EnemyType.infantry,
    name: 'Garde du Croissant',
    health: GameConfig.infantryHealth,
    speed: GameConfig.infantrySpeed,
    damage: GameConfig.infantryDamage,
    scoreValue: GameConfig.infantryScore,
    size: GameConfig.infantrySize,
  );

  static const EnemyData rpgUnit = EnemyData(
    type: EnemyType.rpgUnit,
    name: 'Lanceur Shahine',
    health: GameConfig.rpgHealth,
    speed: GameConfig.rpgSpeed,
    damage: GameConfig.rpgDamage,
    scoreValue: GameConfig.rpgScore,
    size: GameConfig.rpgSize,
  );

  static const EnemyData bunker = EnemyData(
    type: EnemyType.bunker,
    name: 'Bunker Blindé',
    health: GameConfig.bunkerHealth,
    speed: 0.0,
    damage: GameConfig.bunkerMissileDamage,
    scoreValue: GameConfig.bunkerScore,
    size: GameConfig.bunkerSize,
  );

  static const EnemyData factory = EnemyData(
    type: EnemyType.factory,
    name: 'Site Fortifié',
    health: GameConfig.factoryHealth,
    speed: 0.0,
    damage: 0.0,
    scoreValue: GameConfig.factoryScore,
    size: GameConfig.factorySize,
  );

  static const Map<EnemyType, EnemyData> byType = {
    EnemyType.infantry: infantry,
    EnemyType.rpgUnit: rpgUnit,
    EnemyType.bunker: bunker,
    EnemyType.factory: factory,
  };
}
