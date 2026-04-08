import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';

class TerrainComponent extends Component {
  @override
  void render(Canvas canvas) {
    final groundRect = Rect.fromLTWH(
      0, 
      GameConfig.groundLevel, 
      GameConfig.worldWidth, 
      GameConfig.worldHeight - GameConfig.groundLevel
    );

    // 1. Underground Layer (The "Guts")
    final undergroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A1510), Color(0xFF0D0B08)],
      ).createShader(groundRect);
    canvas.drawRect(groundRect, undergroundPaint);

    // 2. Ground Surface Line
    final surfacePaint = Paint()
      ..color = const Color(0xFF445533)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      const Offset(0, GameConfig.groundLevel),
      const Offset(GameConfig.worldWidth, GameConfig.groundLevel),
      surfacePaint,
    );

    // 3. Grid/Galleries hint (Visual only for now)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Horizontal gallery lines
    canvas.drawLine(const Offset(0, GameConfig.groundLevel + 40), const Offset(GameConfig.worldWidth, GameConfig.groundLevel + 40), gridPaint);
    canvas.drawLine(const Offset(0, GameConfig.groundLevel + 80), const Offset(GameConfig.worldWidth, GameConfig.groundLevel + 80), gridPaint);
  }
}
