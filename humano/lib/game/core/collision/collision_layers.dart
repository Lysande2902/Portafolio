/// Collision layers for organizing collision detection
/// Each layer represents a type of collidable object
enum CollisionLayer {
  player,
  enemy,
  obstacle,
  evidence,
  hidingSpot,
  exitDoor,
}

/// Helper class to manage collision layer interactions
class CollisionLayerManager {
  /// Check if two layers should collide
  static bool shouldCollide(CollisionLayer layer1, CollisionLayer layer2) {
    // Define collision rules
    switch (layer1) {
      case CollisionLayer.player:
        return layer2 == CollisionLayer.obstacle ||
            layer2 == CollisionLayer.enemy ||
            layer2 == CollisionLayer.evidence ||
            layer2 == CollisionLayer.hidingSpot ||
            layer2 == CollisionLayer.exitDoor;

      case CollisionLayer.enemy:
        return layer2 == CollisionLayer.obstacle ||
            layer2 == CollisionLayer.player;

      case CollisionLayer.obstacle:
        return layer2 == CollisionLayer.player ||
            layer2 == CollisionLayer.enemy;

      case CollisionLayer.evidence:
        return layer2 == CollisionLayer.player;

      case CollisionLayer.hidingSpot:
        return layer2 == CollisionLayer.player;

      case CollisionLayer.exitDoor:
        return layer2 == CollisionLayer.player;
    }
  }
}
