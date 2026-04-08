import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

/// Desert Strike Mobile HUD.
/// Displays: planes remaining, ammo (canon/missiles/bombs/GBU),
/// dollar score, progress bar, enemy ratio, active drones alert,
/// floating score feedback.
class HudComponent extends PositionComponent {
  HudComponent({required this.game}) : super(priority: 10);

  final BombingWarGame game;

  String _weaponName = '';
  int _activeDrones = 0;

  void updateWeapon(String name) => _weaponName = name;
  void updateActiveDrones(int count) => _activeDrones = count;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawTopBar(canvas);
    _drawProgressBar(canvas);
    _drawBottomBar(canvas);
    _drawScoreFeedback(canvas);
    _drawMultiplier(canvas);
    _drawDroneAlert(canvas);
  }

  /// Top bar: [✈✈✈✈] [🔫 200] [🚀 6] [💣 6] [GBU ●]  [$48 200]
  void _drawTopBar(Canvas canvas) {
    const y = 6.0;
    const pad = GameConfig.hudPadding;
    double x = pad;

    // Planes remaining
    final planesLeft = game.missionLives;
    String planesText = '';
    for (int i = 0; i < planesLeft; i++) {
      planesText += '✈';
    }
    for (int i = planesLeft; i < GameConfig.planesPerMission; i++) {
      planesText += '✗';
    }
    _drawText(canvas, planesText, Offset(x, y),
        fontSize: 14, color: Colors.white);
    x += 80;

    // Ammo counters
    final aircraft = game.playerAircraft;
    final canonAmmo = aircraft?.canonAmmo ?? 0;
    final missileAmmo = aircraft?.missileAmmo ?? 0;
    final bombAmmo = aircraft?.bombAmmo ?? 0;
    final gbuAvail = game.gbuAvailable;

    _drawAmmoBox(canvas, '🔫', canonAmmo.toString(), x, y, Colors.yellow);
    x += 62;
    _drawAmmoBox(canvas, '🚀', missileAmmo.toString(), x, y, Colors.cyan);
    x += 54;
    _drawAmmoBox(canvas, '💣', bombAmmo.toString(), x, y, Colors.orange);
    x += 54;

    // GBU indicator
    final gbuColor = gbuAvail ? Colors.greenAccent : Colors.grey;
    _drawText(canvas, 'GBU', Offset(x, y), fontSize: 10, color: gbuColor);
    canvas.drawCircle(
      Offset(x + 28, y + 6),
      4,
      Paint()..color = gbuAvail ? Colors.greenAccent : Colors.grey.shade700,
    );
    x += 50;

    // Dollar score (right-aligned)
    final scoreText = '\$${game.scoreSystem.dollarNet}';
    _drawText(
      canvas,
      scoreText,
      Offset(GameConfig.worldWidth - pad - 100, y),
      fontSize: 16,
      color: const Color(0xFF44FF44),
    );

    // Health bar below top bar
    _drawHealthBar(canvas);
  }

  void _drawAmmoBox(
      Canvas canvas, String icon, String count, double x, double y, Color c) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 2, y - 2, 50, 18),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );
    _drawText(canvas, '$icon $count', Offset(x, y), fontSize: 11, color: c);
  }

  void _drawHealthBar(Canvas canvas) {
    const double barW = 80.0;
    const double barH = 5.0;
    const double left = GameConfig.hudPadding;
    const double top = 26.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(left, top, barW, barH), const Radius.circular(3)),
      Paint()..color = Colors.black45,
    );

    final player = game.playerAircraft;
    final pct = player != null
        ? (player.health / player.maxHealth).clamp(0.0, 1.0)
        : 0.0;

    final Color hpColor = pct > 0.5
        ? const Color(0xFF4CAF50)
        : pct > 0.25
            ? const Color(0xFFFFC107)
            : const Color(0xFFF44336);

    if (pct > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, barW * pct, barH),
            const Radius.circular(3)),
        Paint()..color = hpColor,
      );
    }
  }

  /// Progress bar: [DÉPART]═══●═══[OBJECTIF]
  void _drawProgressBar(Canvas canvas) {
    const barY = GameConfig.worldHeight - 36.0;
    const pad = GameConfig.hudPadding;
    const barWidth = GameConfig.worldWidth - pad * 2 - 120;
    const barLeft = pad + 60;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(barLeft, barY, barWidth, GameConfig.progressBarHeight),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    // Progress fill
    final progress = game.missionProgress.clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(barLeft, barY, barWidth * progress, GameConfig.progressBarHeight),
      Paint()..color = Colors.greenAccent.withValues(alpha: 0.6),
    );

    // Aircraft indicator on bar
    final indicatorX = barLeft + barWidth * progress;
    canvas.drawCircle(
      Offset(indicatorX, barY + GameConfig.progressBarHeight / 2),
      4,
      Paint()..color = Colors.white,
    );

    // Labels
    _drawText(canvas, 'DÉPART', Offset(pad, barY - 4),
        fontSize: 8, color: Colors.white54);
    _drawText(
        canvas, 'OBJECTIF', Offset(barLeft + barWidth + 4, barY - 4),
        fontSize: 8, color: Colors.white54);
  }

  /// Bottom bar: [Ennemis: 14/32] [⚠ 2 drones actifs]
  void _drawBottomBar(Canvas canvas) {
    const y = GameConfig.worldHeight - 20.0;
    const pad = GameConfig.hudPadding;

    // Enemies destroyed / total
    final killed = game.scoreSystem.enemiesKilled;
    final total = game.totalEnemies;
    _drawText(canvas, 'Ennemis: $killed/$total', Offset(pad, y),
        fontSize: 11, color: Colors.white70);

    // Weapon name
    final weaponName = game.playerAircraft?.currentWeaponName ?? _weaponName;
    if (weaponName.isNotEmpty) {
      _drawText(
        canvas,
        weaponName,
        Offset(GameConfig.worldWidth / 2 - 40, y),
        fontSize: 11,
        color: const Color(0xFFAADDFF),
      );
    }
  }

  /// Drone alert indicator (blinking if active drones > 0)
  void _drawDroneAlert(Canvas canvas) {
    if (_activeDrones <= 0) return;

    final blink = (DateTime.now().millisecondsSinceEpoch ~/ 500) % 2 == 0;
    if (!blink) return;

    _drawText(
      canvas,
      '⚠ $_activeDrones drones actifs',
      Offset(GameConfig.worldWidth - GameConfig.hudPadding - 140,
          GameConfig.worldHeight - 20),
      fontSize: 11,
      color: Colors.red,
    );
  }

  /// Floating score feedback (+$75, -$250, etc.)
  void _drawScoreFeedback(Canvas canvas) {
    final feedbacks = game.scoreSystem.feedbackQueue;
    for (int i = 0; i < feedbacks.length; i++) {
      final f = feedbacks[i];
      final alpha = (1.0 - f.age / 2.0).clamp(0.0, 1.0);
      final yOffset = -f.age * 30; // float upward

      _drawText(
        canvas,
        f.text,
        Offset(
          GameConfig.worldWidth / 2 + i * 10,
          GameConfig.worldHeight / 2 + yOffset,
        ),
        fontSize: 14,
        color: f.isPenalty
            ? Colors.red.withValues(alpha: alpha)
            : Colors.greenAccent.withValues(alpha: alpha),
      );
    }
  }

  void _drawMultiplier(Canvas canvas) {
    final mult = game.scoreSystem.multiplier;
    if (mult <= 1) return;
    _drawText(
      canvas,
      'x$mult COMBO!',
      Offset(GameConfig.worldWidth / 2 - 30, 8),
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
