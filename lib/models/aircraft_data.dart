import '../config/game_config.dart';
import 'weapon_data.dart';

/// In Desert Strike Mobile, there is a single aircraft type.
/// The player gets 4 planes per mission.
class AircraftData {
  const AircraftData({
    required this.id,
    required this.name,
    required this.speed,
    required this.health,
    required this.description,
  });

  final String id;
  final String name;
  final double speed;
  final double health;
  final String description;

  // The single aircraft type used in the game.
  static const AircraftData strikeAircraft = AircraftData(
    id: 'strike_aircraft',
    name: 'Desert Strike',
    speed: GameConfig.aircraftSpeed,
    health: GameConfig.aircraftHealth,
    description: 'Avion d\'attaque au sol multi-rôle.',
  );

  /// Weapons available per aircraft.
  static List<WeaponData> get weapons => [
        WeaponData.canon,
        WeaponData.guidedMissile,
        WeaponData.classicBomb,
      ];
}
