import 'package:audioplayers/audioplayers.dart';

/// Manages sound effects and background music.
/// All audio paths are relative to assets/audio/.
class AudioManager {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _muted = false;

  bool get muted => _muted;

  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      _musicPlayer.setVolume(0);
    } else {
      _musicPlayer.setVolume(0.5);
    }
  }

  Future<void> playMusic(String filename) async {
    if (_muted) return;
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.5);
    await _musicPlayer.play(AssetSource('audio/$filename'));
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> playSfx(String filename) async {
    if (_muted) return;
    await _sfxPlayer.play(AssetSource('audio/$filename'));
  }

  // Convenience SFX helpers
  Future<void> playExplosion() => playSfx('explosion.mp3');
  Future<void> playShoot() => playSfx('shoot.mp3');
  Future<void> playMissile() => playSfx('missile.mp3');
  Future<void> playSpecial() => playSfx('special.mp3');
  Future<void> playLevelComplete() => playSfx('level_complete.mp3');
  Future<void> playGameOver() => playSfx('game_over.mp3');
  Future<void> playThreatBarrage() => playSfx('barrage.mp3');

  // New Radio & Rescue SFX
  Future<void> playMayday() => playSfx('mayday.mp3');
  Future<void> playPilotEjected() => playSfx('pilot_ejected.mp3');
  Future<void> playRescueArrived() => playSfx('rescue_arrived.mp3');
  Future<void> playPilotRescued() => playSfx('pilot_rescued.mp3');
  Future<void> playRadarBeep() => playSfx('radar_beep.mp3');

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
