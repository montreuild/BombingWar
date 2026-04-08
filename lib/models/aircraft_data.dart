import '../config/game_config.dart';
import 'weapon_data.dart';

/// Special abilities available to aircraft.
enum SpecialAbility { barrelRoll, armor, cloak }

/// In Desert Strike Mobile, there are multiple aircraft types.
/// Each aircraft has a unique special ability and must be unlocked.
class AircraftData {
  const AircraftData({
    required this.id,
    required this.name,
    required this.speed,
    required this.health,
    required this.description,
    required this.unlockLevel,
    required this.unlockCost,
    required this.specialAbility,
  });

  final String id;
  final String name;
  final double speed;
  final double health;
  final String description;

  /// Player level required to unlock this aircraft.
  final int unlockLevel;

  /// Coin cost to unlock (0 = free / default aircraft).
  final int unlockCost;

  /// The special ability granted by this aircraft.
  final SpecialAbility specialAbility;

  // ---------------------------------------------------------------------------
  // Aircraft variants
  // ---------------------------------------------------------------------------

  /// Default interceptor — free, available from level 1.
  static const AircraftData interceptor = AircraftData(
    id: 'interceptor',
    name: 'Interceptor',
    speed: GameConfig.aircraftSpeed,
    health: GameConfig.aircraftHealth,
    description: 'Avion d\'attaque polyvalent. Disponible dès le début.',
    unlockLevel: 1,
    unlockCost: 0,
    specialAbility: SpecialAbility.barrelRoll,
  );

  /// Heavy bomber — slow but durable, unlocked at level 5.
  static const AircraftData heavyBomber = AircraftData(
    id: 'heavy_bomber',
    name: 'Heavy Bomber',
    speed: GameConfig.aircraftSpeed * 0.75,
    health: GameConfig.aircraftHealth * 2.0,
    description: 'Bombardier lourd avec armure renforcée.',
    unlockLevel: 5,
    unlockCost: 1000,
    specialAbility: SpecialAbility.armor,
  );

  /// Stealth X-26 — fast and stealthy, unlocked at level 10.
  static const AircraftData stealthX26 = AircraftData(
    id: 'stealth_x26',
    name: 'Stealth X-26',
    speed: GameConfig.aircraftSpeed * 1.25,
    health: GameConfig.aircraftHealth * 0.75,
    description: 'Avion furtif à grande vitesse. Réduit la menace radar.',
    unlockLevel: 10,
    unlockCost: 3000,
    specialAbility: SpecialAbility.cloak,
  );

  /// All aircraft available in the hangar, in unlock order.
  static const List<AircraftData> all = [interceptor, heavyBomber, stealthX26];

  /// Legacy alias — the original single aircraft type.
  static const AircraftData strikeAircraft = interceptor;

  /// Weapons available per aircraft.
  static List<WeaponData> get weapons => [
        WeaponData.canon,
        WeaponData.guidedMissile,
        WeaponData.classicBomb,
      ];
}
