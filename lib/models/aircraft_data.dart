import '../config/game_config.dart';
import 'weapon_data.dart';

enum SpecialAbility { barrelRoll, armor, cloak }

class AircraftData {
  const AircraftData({
    required this.id,
    required this.name,
    required this.speed,
    required this.health,
    required this.weapons,
    required this.specialAbility,
    required this.unlockLevel,
    required this.unlockCost,
    required this.description,
  });

  final String id;
  final String name;
  final double speed;
  final double health;
  final List<WeaponData> weapons;
  final SpecialAbility specialAbility;
  final int unlockLevel;
  final int unlockCost;
  final String description;

  // ---------------------------------------------------------------------------
  // Preset aircraft definitions
  // ---------------------------------------------------------------------------

  static const AircraftData interceptor = AircraftData(
    id: 'interceptor',
    name: 'Faucon F-17',
    speed: GameConfig.interceptorSpeed,
    health: GameConfig.interceptorHealth,
    weapons: [WeaponData.heatMissile, WeaponData.machineGun],
    specialAbility: SpecialAbility.barrelRoll,
    unlockLevel: 0,
    unlockCost: 0,
    description: 'Chasseur rapide de l\'Alliance. Vrille d\'esquive des missiles ennemis.',
  );

  static const AircraftData heavyBomber = AircraftData(
    id: 'heavy_bomber',
    name: 'Tonnerre A-6',
    speed: GameConfig.heavyBomberSpeed,
    health: GameConfig.heavyBomberHealth,
    weapons: [WeaponData.carpetBomb],
    specialAbility: SpecialAbility.armor,
    unlockLevel: GameConfig.heavyBomberUnlockLevel,
    unlockCost: 500,
    description: 'Bombardier blindé. Les frappes en tapis rasent les positions au sol.',
  );

  static const AircraftData stealthX26 = AircraftData(
    id: 'stealth_x26',
    name: 'Fantôme SR-X',
    speed: GameConfig.stealthSpeed,
    health: GameConfig.stealthHealth,
    weapons: [WeaponData.penetratorBomb, WeaponData.machineGun],
    specialAbility: SpecialAbility.cloak,
    unlockLevel: GameConfig.stealthUnlockLevel,
    unlockCost: 1500,
    description: 'Seul appareil capable de détruire les Sites Fortifiés. Furtivité radar active.',
  );

  static const List<AircraftData> all = [interceptor, heavyBomber, stealthX26];
}
