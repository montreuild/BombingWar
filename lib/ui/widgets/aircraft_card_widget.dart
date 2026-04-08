import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/aircraft_data.dart';

/// Reusable card for displaying aircraft info in the hangar.
class AircraftCardWidget extends StatelessWidget {
  const AircraftCardWidget({
    super.key,
    required this.aircraft,
    required this.isOwned,
    required this.isSelected,
    required this.canAfford,
    required this.onTap,
  });

  final AircraftData aircraft;
  final bool isOwned;
  final bool isSelected;
  final bool canAfford;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? const Color(0xFFFFB800)
        : isOwned
            ? Colors.white24
            : Colors.white12;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? const Color(0xFF1A2A1A)
              : const Color(0xFF111A11),
        ),
        child: Row(
          children: [
            _AircraftIcon(aircraft: aircraft, isOwned: isOwned),
            const SizedBox(width: 16),
            Expanded(child: _AircraftInfo(aircraft: aircraft)),
            _StatusBadge(
              isOwned: isOwned,
              isSelected: isSelected,
              canAfford: canAfford,
              cost: aircraft.unlockCost,
            ),
          ],
        ),
      ),
    );
  }
}

class _AircraftIcon extends StatelessWidget {
  const _AircraftIcon({required this.aircraft, required this.isOwned});

  final AircraftData aircraft;
  final bool isOwned;

  @override
  Widget build(BuildContext context) {
    final color = isOwned ? _aircraftColor(aircraft.id) : Colors.white24;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Icon(Icons.flight, color: color, size: 28),
    );
  }

  Color _aircraftColor(String id) {
    switch (id) {
      case 'interceptor':
        return const Color(0xFF4488FF);
      case 'heavy_bomber':
        return const Color(0xFFAA8855);
      case 'stealth_x26':
        return const Color(0xFF44AA44);
      default:
        return Colors.white;
    }
  }
}

class _AircraftInfo extends StatelessWidget {
  const _AircraftInfo({required this.aircraft});

  final AircraftData aircraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          aircraft.name.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          aircraft.description,
          style: const TextStyle(fontSize: 11, color: Colors.white54),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _statChip('SPD', '${aircraft.speed.toInt()}'),
            const SizedBox(width: 8),
            _statChip('HP', '${aircraft.health.toInt()}'),
            const SizedBox(width: 8),
            _statChip(
                'SPECIAL', _specialName(aircraft.specialAbility)),
          ],
        ),
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 9, color: Colors.white60),
      ),
    );
  }

  String _specialName(SpecialAbility ability) {
    switch (ability) {
      case SpecialAbility.barrelRoll:
        return 'ROLL';
      case SpecialAbility.armor:
        return 'ARMOR';
      case SpecialAbility.cloak:
        return 'CLOAK';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isOwned,
    required this.isSelected,
    required this.canAfford,
    required this.cost,
  });

  final bool isOwned;
  final bool isSelected;
  final bool canAfford;
  final int cost;

  @override
  Widget build(BuildContext context) {
    if (isOwned && isSelected) {
      return _badge('ACTIVE', const Color(0xFF44FF88));
    }
    if (isOwned) {
      return _badge('OWNED', Colors.white54);
    }
    if (cost == 0) {
      return _badge('FREE', const Color(0xFF44FF88));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.lock,
          color: canAfford ? const Color(0xFFFFB800) : Colors.white24,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          '$cost',
          style: GoogleFonts.orbitron(
            fontSize: 12,
            color: canAfford
                ? const Color(0xFFFFCC44)
                : Colors.white38,
          ),
        ),
        const Text(
          'coins',
          style: TextStyle(fontSize: 9, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(fontSize: 10, color: color),
      ),
    );
  }
}
