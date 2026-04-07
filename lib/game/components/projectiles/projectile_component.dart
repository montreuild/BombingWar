import 'package:flame/components.dart';
import '../../../config/game_config.dart';

/// Base class for all projectiles.
abstract class ProjectileComponent extends PositionComponent {
  ProjectileComponent({
    required Vector2 position,
    required this.damage,
    required this.isPlayerProjectile,
    required double size,
    this.explosionRadius = 0.0,
    this.isPenetrator = false,
  }) : super(
          position: position,
          size: Vector2.all(size),
          anchor: Anchor.center,
        );

  final double damage;
  final bool isPlayerProjectile;
  final double explosionRadius;
  final bool isPenetrator;

  /// Collision circle radius (half size by default).
  double get radius => size.x * 0.5;

  double _lifespan = 0.0;
  double get maxLifespan => 5.0;

  @override
  void update(double dt) {
    super.update(dt);
    _lifespan += dt;
    if (_lifespan > maxLifespan) removeFromParent();
    // Also remove if out of world bounds
    if (position.x < -GameConfig.despawnMargin ||
        position.x > GameConfig.worldWidth + GameConfig.despawnMargin ||
        position.y < -GameConfig.despawnMargin ||
        position.y > GameConfig.worldHeight + GameConfig.despawnMargin) {
      removeFromParent();
    }
  }
}
