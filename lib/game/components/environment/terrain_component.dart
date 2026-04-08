import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../config/game_config.dart';

class TerrainComponent extends Component {
  @override
  void render(Canvas canvas) {
    // 1. Sky Gradient (Subtle)
    const skyRect = Rect.fromLTWH(0, 0, GameConfig.worldWidth, GameConfig.groundLevel);
    canvas.drawRect(
      skyRect,
      Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0E14), Color(0xFF1A2535)],
      ).createShader(skyRect),
    );

    // 2. Underground Layer
    const groundRect = Rect.fromLTWH(0, GameConfig.groundLevel, GameConfig.worldWidth, GameConfig.worldHeight - GameConfig.groundLevel);
    final undergroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3D2B1F), Color(0xFF1A1108)],
      ).createShader(groundRect);
    canvas.drawRect(groundRect, undergroundPaint);

    // 3. Ground Surface (Grass/Dirt line)
    final surfacePaint = Paint()..color = const Color(0xFF4E6B31);
    canvas.drawRect(const Rect.fromLTWH(0, GameConfig.groundLevel, GameConfig.worldWidth, 6), surfacePaint);
    
    // Dirt highlights
    final dirtPaint = Paint()..color = Colors.black.withValues(alpha: 0.1);
    for (int i = 0; i < 20; i++) {
       canvas.drawCircle(Offset(i * 45.0, GameConfig.groundLevel + 20), 2, dirtPaint);
       canvas.drawCircle(Offset(i * 38.0 + 10, GameConfig.groundLevel + 60), 3, dirtPaint);
    }

    // 4. Grid/Galleries
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawLine(const Offset(0, GameConfig.groundLevel + 40), const Offset(GameConfig.worldWidth, GameConfig.groundLevel + 40), gridPaint);
    canvas.drawLine(const Offset(0, GameConfig.groundLevel + 80), const Offset(GameConfig.worldWidth, GameConfig.groundLevel + 80), gridPaint);
  }
}
