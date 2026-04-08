import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A container component that holds all "world-space" game entities
/// (aircraft, enemies, projectiles, effects). Applies a horizontal camera
/// translation when rendering so that its children can use world
/// coordinates directly while the visible viewport follows the player.
///
/// HUD, terrain (which does its own parallax math) and cutscenes stay
/// outside of this container so that they keep rendering in screen space.
class WorldContainer extends PositionComponent {
  WorldContainer() : super(priority: 0);

  /// Horizontal camera offset in world units.
  double cameraX = 0.0;

  /// Vertical camera shake offset (small jitter applied on explosions).
  double shakeX = 0.0;
  double shakeY = 0.0;

  @override
  void renderTree(Canvas canvas) {
    canvas.save();
    canvas.translate(-cameraX + shakeX, shakeY);
    super.renderTree(canvas);
    canvas.restore();
  }
}
