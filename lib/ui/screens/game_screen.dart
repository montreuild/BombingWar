import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../game/bombing_war_game.dart';
import '../../game/managers/save_manager.dart';
import '../../models/aircraft_data.dart';
import 'game_over_screen.dart';
import 'level_complete_screen.dart';

/// Flutter widget that hosts the Flame game and listens for game-over/level-complete events.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.saveManager,
    required this.selectedAircraft,
  });

  final SaveManager saveManager;
  final AircraftData selectedAircraft;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BombingWarGame _game;

  @override
  void initState() {
    super.initState();
    _game = BombingWarGame(
      saveManager: widget.saveManager,
      selectedAircraftData: widget.selectedAircraft,
    );

    _game.onGameOver = _handleGameOver;
    _game.onLevelComplete = _handleLevelComplete;
  }

  void _handleGameOver() {
    if (!mounted) return;
    // Use addPostFrameCallback so we don't navigate during the game loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameOverScreen(
            score: _game.scoreSystem.sessionScore,
            level: widget.saveManager.progress.currentLevel,
            saveManager: widget.saveManager,
          ),
        ),
      );
    });
  }

  void _handleLevelComplete(int score, int coins) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LevelCompleteScreen(
            score: score,
            coins: coins,
            level: widget.saveManager.progress.currentLevel - 1,
            saveManager: widget.saveManager,
            selectedAircraft: widget.selectedAircraft,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          _TouchOverlay(game: _game),
          _PauseButton(game: _game),
        ],
      ),
    );
  }
}

/// Transparent overlay that captures touch for joystick and weapon buttons.
class _TouchOverlay extends StatelessWidget {
  const _TouchOverlay({required this.game});
  final BombingWarGame game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (d) {
        final pos = _toWorld(d.localPosition, context);
        game.joystick?.onPanStart(pos);
      },
      onPanUpdate: (d) {
        final pos = _toWorld(d.localPosition, context);
        game.joystick?.onPanUpdate(pos);
      },
      onPanEnd: (_) => game.joystick?.onPanEnd(),
      onTapUp: (d) {
        final pos = _toWorld(d.localPosition, context);
        game.weaponButtons?.onTap(pos);
      },
    );
  }

  Vector2 _toWorld(Offset local, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleX = 400.0 / size.width;
    final scaleY = 800.0 / size.height;
    return Vector2(local.dx * scaleX, local.dy * scaleY);
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.game});
  final BombingWarGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: SafeArea(
        child: IconButton(
          icon: const Icon(Icons.pause_circle, color: Colors.white38),
          iconSize: 32,
          onPressed: () {
            game.pauseGame();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _PauseDialog(game: game),
            );
          },
        ),
      ),
    );
  }
}

class _PauseDialog extends StatelessWidget {
  const _PauseDialog({required this.game});
  final BombingWarGame game;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2A1A),
      title: const Text('PAUSED',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      actions: [
        TextButton(
          onPressed: () {
            game.resumeGame();
            Navigator.pop(context);
          },
          child: const Text('RESUME',
              style: TextStyle(color: Color(0xFF44FF88))),
        ),
        TextButton(
          onPressed: () {
            game.resumeGame();
            Navigator.of(context).popUntil((r) => r.isFirst);
          },
          child: const Text('QUIT',
              style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}
