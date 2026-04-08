import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/player_progress.dart';

/// Handles persistence of player progress via SharedPreferences.
class SaveManager {
  static const _progressKey = 'player_progress';

  PlayerProgress _progress = PlayerProgress();
  PlayerProgress get progress => _progress;

  /// Load saved progress from disk.  Returns default progress if none found.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw != null) {
      try {
        _progress = PlayerProgress.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _progress = PlayerProgress();
      }
    }
  }

  /// Persist current progress to disk.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(_progress.toJson()));
  }

  /// Wipe all saved data (for debug / new game).
  Future<void> reset() async {
    _progress = PlayerProgress();
    await save();
  }
}
