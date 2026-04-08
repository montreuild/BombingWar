import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

/// Weapon buttons: Canon / Missile / Bombe / GBU-57 (bottom-right).
class WeaponButtonComponent extends PositionComponent {
  WeaponButtonComponent({required this.game}) : super(priority: 10);

  final BombingWarGame game;

  static const double _btnSize = GameConfig.weaponButtonSize;
  static const double _pad = 8.0;

  // Button positions
  Vector2 get _canonPos => Vector2(
        GameConfig.worldWidth - _btnSize * 4 - _pad * 5,
        GameConfig.worldHeight - _btnSize - _pad,
      );

  Vector2 get _missilePos => Vector2(
        GameConfig.worldWidth - _btnSize * 3 - _pad * 4,
        GameConfig.worldHeight - _btnSize - _pad,
      );

  Vector2 get _bombPos => Vector2(
        GameConfig.worldWidth - _btnSize * 2 - _pad * 3,
        GameConfig.worldHeight - _btnSize - _pad,
      );

  Vector2 get _gbuPos => Vector2(
        GameConfig.worldWidth - _btnSize - _pad * 2,
        GameConfig.worldHeight - _btnSize - _pad,
      );

  /// Called by game's tap handler.
  void onTap(Vector2 worldPos) {
    if (_hitTest(worldPos, _canonPos)) {
      game.playerAircraft?.selectWeapon(0);
      game.playerAircraft?.fireWeapon();
    } else if (_hitTest(worldPos, _missilePos)) {
      game.playerAircraft?.selectWeapon(1);
      game.playerAircraft?.fireWeapon();
    } else if (_hitTest(worldPos, _bombPos)) {
      game.playerAircraft?.selectWeapon(2);
      game.playerAircraft?.fireWeapon();
    } else if (_hitTest(worldPos, _gbuPos)) {
      game.triggerGBU57();
    }
  }

  bool _hitTest(Vector2 tap, Vector2 btnCenter) {
    return (tap - (btnCenter + Vector2(_btnSize / 2, _btnSize / 2))).length <
        _btnSize * 0.6;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final aircraft = game.playerAircraft;

    _drawButton(canvas, _canonPos, '🔫', 'Canon',
        Colors.yellow, '${aircraft?.canonAmmo ?? 0}');
    _drawButton(canvas, _missilePos, '🚀', 'Missile',
        Colors.cyan, '${aircraft?.missileAmmo ?? 0}');
    _drawButton(canvas, _bombPos, '💣', 'Bombe',
        Colors.orange, '${aircraft?.bombAmmo ?? 0}');

    final gbuColor = game.gbuAvailable ? Colors.greenAccent : Colors.grey;
    _drawButton(canvas, _gbuPos, 'GBU', '57',
        gbuColor, game.gbuAvailable ? '●' : '✗');
  }

  void _drawButton(Canvas canvas, Vector2 pos, String label,
      String subLabel, Color color, String ammoText) {
    final rect = Rect.fromLTWH(pos.x, pos.y, _btnSize, _btnSize);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = color.withValues(alpha: 0.3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Main label
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        pos.x + _btnSize / 2 - tp.width / 2,
        pos.y + _btnSize * 0.15,
      ),
    );

    // Ammo count
    final ammo = TextPainter(
      text: TextSpan(
        text: ammoText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color.withValues(alpha: 0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    ammo.paint(
      canvas,
      Offset(
        pos.x + _btnSize / 2 - ammo.width / 2,
        pos.y + _btnSize * 0.6,
      ),
    );

    // Sub-label
    final sub = TextPainter(
      text: TextSpan(
        text: subLabel,
        style: TextStyle(
          fontSize: 7,
          color: color.withValues(alpha: 0.7),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    sub.paint(
      canvas,
      Offset(
        pos.x + _btnSize / 2 - sub.width / 2,
        pos.y + _btnSize * 0.82,
      ),
    );
  }
}
