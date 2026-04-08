import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/bombing_war_game.dart';
import '../../game/managers/save_manager.dart';
import '../../models/level_data.dart';
import 'game_over_screen.dart';
import 'level_complete_screen.dart';

/// Flutter widget that hosts the Flame game and listens for game-over /
/// level-complete events. Renders the 800x400 logical game inside a uniform
/// [AspectRatio] so touches and clicks map directly to game coordinates on
/// any device size (mobile, tablet, desktop, web).
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.saveManager,
  });

  final SaveManager saveManager;

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
    );

    _game.onGameOver = _handleGameOver;
    _game.onLevelComplete = _handleLevelComplete;
  }

  void _handleGameOver() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameOverScreen(
            score: _game.scoreSystem.dollarNet,
            level: widget.saveManager.progress.currentLevel,
            saveManager: widget.saveManager,
          ),
        ),
      );
    });
  }

  void _handleLevelComplete(MissionReport report) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LevelCompleteScreen(
            report: report,
            level: widget.saveManager.progress.currentLevel - 1,
            saveManager: widget.saveManager,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: GameConfig.worldWidth / GameConfig.worldHeight,
              child: ClipRect(
                child: Stack(
                  children: [
                    GameWidget(game: _game, autofocus: true),
                    _TouchOverlay(game: _game),
                  ],
                ),
              ),
            ),
          ),
          _PauseButton(game: _game),
        ],
      ),
    );
  }
}

/// Transparent overlay that captures pointer events for joystick and weapon
/// buttons. Lives *inside* the fitted game frame so `localPosition` can be
/// converted to game (800x400) coordinates with a single uniform scale.
class _TouchOverlay extends StatelessWidget {
  const _TouchOverlay({required this.game});
  final BombingWarGame game;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = GameConfig.worldWidth / constraints.maxWidth;
        final scaleY = GameConfig.worldHeight / constraints.maxHeight;

        Vector2 toGame(Offset local) =>
            Vector2(local.dx * scaleX, local.dy * scaleY);

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) {
            final pos = toGame(e.localPosition);
            // Weapon-button tap first; joystick drag otherwise.
            final hitButton = game.weaponButtons?.onTap(pos) ?? false;
            if (!hitButton) {
              game.joystick?.onPanStart(pos);
            }
          },
          onPointerMove: (e) {
            game.joystick?.onPanUpdate(toGame(e.localPosition));
          },
          onPointerUp: (_) => game.joystick?.onPanEnd(),
          onPointerCancel: (_) => game.joystick?.onPanEnd(),
        );
      },
    );
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
      title: const Text(
        'PAUSED',
        style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
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
