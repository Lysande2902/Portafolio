import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/animation/animated_enemy_sprite.dart';
import 'package:humano/game/core/animation/enemy_animation_types.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/hiding_spot_component.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/exit_door_component.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/evidence_component.dart';

/// Spider Enemy component for Lust phase (Adriana)
/// Mechanics: Teleportation + Web traps
class SpiderEnemy extends PositionComponent with CollisionCallbacks {
  // Movement
  static const double baseSpeed = 90.0;
  double currentSpeed = baseSpeed;
  Vector2 velocity = Vector2.zero();
  Vector2 previousPosition = Vector2.zero();
  
  // Patrol
  final List<Vector2> waypoints;
  int currentWaypointIndex = 0;
  static const double waypointThreshold = 20.0;
  
  // Chase
  PositionComponent? targetPlayer;
  bool isChasing = false;
  static const double chaseDistance = 280.0;
  static const double chaseSpeed = 120.0;
  
  // Teleport mechanic
  double teleportTimer = 0.0;
  static const double teleportInterval = 10.0; // Teleport every 10 seconds
  final Random _random = Random();
  
  // Web mechanic (TODO: implement web traps)
  double webTimer = 0.0;
  static const double webInterval = 15.0;
  
  // Grace period
  double _graceTimer = 0.0;
  static const double gracePeriod = 1.0;
  bool _wasPlayerHidden = false;
  
  // Animation
  late AnimatedEnemySprite animatedSprite;
  EnemyAnimationState currentAnimationState = EnemyAnimationState.idle;
  EnemyDirection currentDirection = EnemyDirection.down;
  
  // Size
  static const double enemyWidth = 50.0;
  static const double enemyHeight = 70.0;

  // Skin
  final String? skinId;

  SpiderEnemy({
    required Vector2 position,
    required this.waypoints,
    this.skinId,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    debugPrint('🕷️ [SPIDER-ENEMY] onLoad() called');
    
    await super.onLoad();
    
    size = Vector2(enemyWidth, enemyHeight);
    
    // Add animated sprite
    animatedSprite = AnimatedEnemySprite(skinId: skinId);
    animatedSprite.scale = Vector2(0.78, 1.09);
    await add(animatedSprite);
    
    // Add collision
    add(RectangleHitbox());
    
    debugPrint('✅ [SPIDER-ENEMY] Enemy component loaded');
  }
  
  void setTargetPlayer(PositionComponent player) {
    targetPlayer = player;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Store previous position for collision rollback
    previousPosition = position.clone();
    
    if (targetPlayer == null) return;
    
    // Update teleport timer
    teleportTimer += dt;
    if (teleportTimer >= teleportInterval) {
      _teleportNearPlayer();
      teleportTimer = 0.0;
    }
    
    // Update web timer (TODO: implement web placement)
    webTimer += dt;
    if (webTimer >= webInterval) {
      // Place web trap
      webTimer = 0.0;
    }
    
    // Check if player is hidden
    final playerComponent = targetPlayer as dynamic;
    final isPlayerHidden = playerComponent.isHidden ?? false;
    
    // Update grace timer
    if (_graceTimer > 0) {
      _graceTimer -= dt;
    }
    
    // Start grace period when player exits hiding
    if (!isPlayerHidden && _wasPlayerHidden) {
      _graceTimer = gracePeriod;
      debugPrint('🛡️ [SPIDER-ENEMY] Grace period started (${gracePeriod}s)');
    }
    _wasPlayerHidden = isPlayerHidden;
    
    // Check if should chase
    double distanceToPlayer = (targetPlayer!.position - position).length;
    isChasing = distanceToPlayer < chaseDistance && !isPlayerHidden && _graceTimer <= 0;
    
    if (isChasing) {
      _chasePlayer();
    } else {
      _patrol();
    }
    
    // Update position
    position += velocity * dt;
    
    // Update animation
    _updateAnimation();
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Check if colliding with walls or obstacles
    if (other is RectangleComponent && 
        other is! HidingSpotComponent && 
        other is! ExitDoorComponent && 
        other is! EvidenceComponent) {
      // Rollback to previous position
      position = previousPosition.clone();
      velocity = Vector2.zero();
      
      // Try to navigate around obstacle
      if (!isChasing) {
        currentWaypointIndex = (currentWaypointIndex + 1) % waypoints.length;
      }
    }
  }
  
  void _teleportNearPlayer() {
    if (targetPlayer == null) return;

    // Teleport to a random position near the player (200-350 pixels away)
    final distance = 200 + _random.nextDouble() * 150;
    final angle = _random.nextDouble() * 2 * pi;

    final newX = targetPlayer!.position.x + cos(angle) * distance;
    final newY = targetPlayer!.position.y + sin(angle) * distance;

    // Clamp to map bounds (Phase 2 area: 2400-4800, height: 40-1560)
    final clampedX = newX.clamp(2440.0, 4760.0);
    final clampedY = newY.clamp(80.0, 1520.0);

    position = Vector2(clampedX, clampedY);
    debugPrint('🕷️ [SPIDER-ENEMY] Teleported near player!');
  }
  
  void _patrol() {
    if (waypoints.isEmpty) return;
    
    Vector2 targetWaypoint = waypoints[currentWaypointIndex];
    Vector2 direction = (targetWaypoint - position).normalized();
    
    // Check if reached waypoint
    if ((targetWaypoint - position).length < waypointThreshold) {
      currentWaypointIndex = (currentWaypointIndex + 1) % waypoints.length;
    }
    
    velocity = direction * baseSpeed;
    currentSpeed = baseSpeed;
    
    // Update direction
    _updateDirection(direction);
  }
  
  void _chasePlayer() {
    if (targetPlayer == null) return;
    
    Vector2 direction = (targetPlayer!.position - position).normalized();
    velocity = direction * chaseSpeed;
    currentSpeed = chaseSpeed;
    
    // Update direction
    _updateDirection(direction);
  }
  
  void _updateDirection(Vector2 direction) {
    if (direction.x.abs() > direction.y.abs()) {
      currentDirection = direction.x > 0 ? EnemyDirection.right : EnemyDirection.left;
    } else if (direction.y != 0) {
      currentDirection = direction.y > 0 ? EnemyDirection.down : EnemyDirection.up;
    }
  }
  
  void _updateAnimation() {
    bool isMoving = velocity.length > 0.1;
    
    if (isChasing) {
      currentAnimationState = EnemyAnimationState.run;
    } else if (isMoving) {
      currentAnimationState = EnemyAnimationState.walk;
    } else {
      currentAnimationState = EnemyAnimationState.idle;
    }
    
    animatedSprite.updateAnimationState(currentAnimationState, currentDirection);
  }
}
