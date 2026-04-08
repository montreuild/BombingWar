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
    // Lifespan is the primary despawn trigger; keep a loose absolute clamp
    // to catch anything that escapes vertically out of the world.
    if (_lifespan > maxLifespan) {
      removeFromParent();
      return;
    }
    if (position.y < -GameConfig.despawnMargin ||
        position.y > GameConfig.worldHeight + GameConfig.despawnMargin) {
      removeFromParent();
    }
  }
}

