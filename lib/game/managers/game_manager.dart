/// State machine for top-level game flow.
enum GameState { menu, playing, paused, levelComplete, gameOver }

class GameManager {
  GameState _state = GameState.menu;
  GameState get state => _state;

  void setState(GameState newState) {
    _state = newState;
  }

  bool get isPlaying => _state == GameState.playing;
  bool get isPaused => _state == GameState.paused;
  bool get isGameOver => _state == GameState.gameOver;
  bool get isLevelComplete => _state == GameState.levelComplete;
}
