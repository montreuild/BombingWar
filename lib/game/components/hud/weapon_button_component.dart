import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../config/game_config.dart';
import '../../bombing_war_game.dart';

/// Three buttons in the bottom-right: Fire (A), Special (B), Switch Weapon (C).
class WeaponButtonComponent extends PositionComponent {
  WeaponButtonComponent({required this.game}) : super(priority: 10);

  final BombingWarGame game;

  static const double _btnSize = GameConfig.weaponButtonSize;
  static const double _pad = GameConfig.hudPadding;

  // Button positions in world coords
  Vector2 get _firePos => Vector2(
        GameConfig.worldWidth - _btnSize - _pad,
        GameConfig.worldHeight - _btnSize - _pad,
      );

  Vector2 get _specialPos => Vector2(
        GameConfig.worldWidth - _btnSize * 2 - _pad * 2,
        GameConfig.worldHeight - _btnSize - _pad,
      );

  Vector2 get _switchPos => Vector2(
        GameConfig.worldWidth - _btnSize * 1.5 - _pad * 1.5,
        GameConfig.worldHeight - _btnSize * 2 - _pad * 2,
      );

  /// Called by game's tap handler.
  void onTap(Vector2 worldPos) {
    if (_hitTest(worldPos, _firePos)) {
      game.playerAircraft?.fireWeapon();
    } else if (_hitTest(worldPos, _specialPos)) {
      game.playerAircraft?.activateSpecial();
    } else if (_hitTest(worldPos, _switchPos)) {
      game.playerAircraft?.cycleWeapon();
    }
  }

  bool _hitTest(Vector2 tap, Vector2 btnCenter) {
    return (tap - (btnCenter + Vector2(_btnSize / 2, _btnSize / 2))).length <
        _btnSize * 0.6;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawButton(canvas, _firePos, 'FIRE', 'Tirer', Colors.red);
    _drawButton(canvas, _specialPos, 'SPEC', 'Spécial', Colors.blue);
    _drawButton(canvas, _switchPos, 'NEXT', 'Arme suiv.', Colors.green);
  }

  void _drawButton(Canvas canvas, Vector2 pos, String label, String subLabel, Color color) {
    final rect = Rect.fromLTWH(pos.x, pos.y, _btnSize, _btnSize);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = color.withValues(alpha: 0.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Main label
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14,
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
        pos.y + _btnSize / 2 - tp.height / 2 - 6,
      ),
    );

    // Sub-label (action description)
    final sub = TextPainter(
      text: TextSpan(
        text: subLabel,
        style: TextStyle(
          fontSize: 8,
          color: color.withValues(alpha: 0.85),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    sub.paint(
      canvas,
      Offset(
        pos.x + _btnSize / 2 - sub.width / 2,
        pos.y + _btnSize / 2 + 6,
      ),
    );
  }
}
