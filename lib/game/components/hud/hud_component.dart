import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

/// Heads-up display: score, health bar, threat bar, weapon name, multiplier.
class HudComponent extends PositionComponent {
  HudComponent({required this.game})
      : super(priority: 10); // Render on top

  final BombingWarGame game;

  int _score = 0;
  double _threatPercent = 0.0;
  String _weaponName = '';

  void updateScore(int score) => _score = score;
  void updateThreat(double percent) => _threatPercent = percent;
  void updateWeapon(String name) => _weaponName = name;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawScore(canvas);
    _drawHealthBar(canvas);
    _drawThreatBar(canvas);
    _drawWeaponName(canvas);
    _drawMultiplier(canvas);
  }

  void _drawScore(Canvas canvas) {
    _drawText(
      canvas,
      'SCORE: $_score',
      const Offset(GameConfig.hudPadding, GameConfig.hudPadding),
      fontSize: 16,
      color: Colors.white,
    );
  }

  void _drawHealthBar(Canvas canvas) {
    const double barW = 120.0;
    const double barH = 12.0;
    const double left = GameConfig.hudPadding;
    const double top = GameConfig.hudPadding + 24.0;

    canvas.drawRect(
      const Rect.fromLTWH(left, top, barW, barH),
      Paint()..color = Colors.black54,
    );

    final player = game.playerAircraft;
    final pct = player != null
        ? (player.health / player.maxHealth).clamp(0.0, 1.0)
        : 0.0;
    final Color hpColor = pct > 0.5
        ? Colors.green
        : pct > 0.25
            ? Colors.orange
            : Colors.red;

    canvas.drawRect(
      Rect.fromLTWH(left, top, barW * pct, barH),
      Paint()..color = hpColor,
    );

    canvas.drawRect(
      const Rect.fromLTWH(left, top, barW, barH),
      Paint()
        ..color = Colors.white38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    _drawText(canvas, 'HP', const Offset(left + barW + 4, top - 1),
        fontSize: 10, color: Colors.white70);
  }

  void _drawThreatBar(Canvas canvas) {
    const double barW = 100.0;
    const double barH = 10.0;
    const double left = GameConfig.worldWidth - 100.0 - GameConfig.hudPadding;
    const double top = GameConfig.hudPadding;

    canvas.drawRect(
      const Rect.fromLTWH(left, top, barW, barH),
      Paint()..color = Colors.black54,
    );

    final double pct = (_threatPercent / 100.0).clamp(0.0, 1.0);
    final Color color = pct < 0.5
        ? Colors.yellow
        : pct < 0.8
            ? Colors.orange
            : Colors.red;

    canvas.drawRect(
      Rect.fromLTWH(left, top, barW * pct, barH),
      Paint()..color = color,
    );

    canvas.drawRect(
      const Rect.fromLTWH(left, top, barW, barH),
      Paint()
        ..color = Colors.white38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    _drawText(canvas, 'THREAT', const Offset(left, top + 14),
        fontSize: 9, color: Colors.white70);
  }

  void _drawWeaponName(Canvas canvas) {
    final name = game.playerAircraft?.currentWeapon.name ?? _weaponName;
    if (name.isEmpty) return;
    _drawText(
      canvas,
      name,
      const Offset(GameConfig.hudPadding, GameConfig.hudPadding + 46),
      fontSize: 11,
      color: const Color(0xFFAADDFF),
    );
  }

  void _drawMultiplier(Canvas canvas) {
    final mult = game.scoreSystem.multiplier;
    if (mult <= 1) return;
    _drawText(
      canvas,
      'x$mult COMBO!',
      const Offset(GameConfig.worldWidth / 2 - 30, GameConfig.hudPadding + 4),
      fontSize: 14,
      color: const Color(0xFFFFCC00),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 14,
    Color color = Colors.white,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }
}
