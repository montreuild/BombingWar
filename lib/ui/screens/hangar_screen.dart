import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/managers/save_manager.dart';
import '../../models/aircraft_data.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/aircraft_card_widget.dart';

class HangarScreen extends StatefulWidget {
  const HangarScreen({super.key, required this.saveManager});

  final SaveManager saveManager;

  @override
  State<HangarScreen> createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.saveManager.progress.unlockedAircraftIds.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'HANGAR',
          style: GoogleFonts.orbitron(
            color: const Color(0xFFFFB800),
            letterSpacing: 4,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Column(
        children: [
          _buildCoinRow(),
          const SizedBox(height: 8),
          const AdBannerWidget(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: AircraftData.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final aircraft = AircraftData.all[i];
                final owned = widget.saveManager.progress
                    .ownsAircraft(aircraft.id);
                final canAfford =
                    widget.saveManager.progress.coins >= aircraft.unlockCost;
                final levelMet = widget.saveManager.progress.currentLevel >=
                    aircraft.unlockLevel;
                return AircraftCardWidget(
                  aircraft: aircraft,
                  isOwned: owned,
                  isSelected: _selectedId == aircraft.id,
                  canAfford: canAfford && levelMet,
                  onTap: () => _onCardTap(aircraft, owned),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFCC44)),
          const SizedBox(width: 8),
          Text(
            '${widget.saveManager.progress.coins} COINS',
            style: GoogleFonts.orbitron(
                color: const Color(0xFFFFCC44), fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _onCardTap(AircraftData aircraft, bool owned) {
    if (owned) {
      setState(() => _selectedId = aircraft.id);
      // Remember selection in progress (last unlocked = selected)
      final ids = widget.saveManager.progress.unlockedAircraftIds;
      if (!ids.contains(aircraft.id)) return;
      // Move selected to end so MainMenuScreen picks it up
      widget.saveManager.progress.unlockedAircraftIds = [
        ...ids.where((id) => id != aircraft.id),
        aircraft.id,
      ];
      widget.saveManager.save();
      return;
    }

    // Not owned — try to purchase
    final progress = widget.saveManager.progress;
    if (progress.currentLevel < aircraft.unlockLevel) {
      _showMessage('Reach level ${aircraft.unlockLevel} to unlock!');
      return;
    }
    if (progress.coins < aircraft.unlockCost) {
      _showMessage('Not enough coins! Need ${aircraft.unlockCost}.');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A1A),
        title: Text('Unlock ${aircraft.name}?',
            style: GoogleFonts.orbitron(color: const Color(0xFFFFB800))),
        content: Text(
          'Cost: ${aircraft.unlockCost} coins',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB800)),
            onPressed: () {
              progress.coins -= aircraft.unlockCost;
              progress.unlockAircraft(aircraft.id);
              widget.saveManager.save();
              Navigator.pop(context);
              setState(() => _selectedId = aircraft.id);
            },
            child: const Text('UNLOCK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.orbitron(fontSize: 12)),
        backgroundColor: const Color(0xFF1A2A1A),
      ),
    );
  }
}
