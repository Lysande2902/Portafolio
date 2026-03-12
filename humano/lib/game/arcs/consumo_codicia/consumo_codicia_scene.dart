import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/components/obstacle_component.dart';
import 'package:humano/game/core/components/textured_obstacle_component.dart';
import 'package:humano/game/core/rendering/textured_background_component.dart';

/// Scene for Consumo y Codicia arc (Fused Gluttony + Greed)
/// Map size: 4800x1600 (double length for 2 phases)
/// Phase 1 (0-2400): Warehouse/Restaurant theme
/// Phase 2 (2400-4800): Vault/Bank theme
class ConsumoCodiciaScene {
  final World world;
  
  // Map dimensions
  static const double mapWidth = 4800.0;
  static const double mapHeight = 1600.0;
  
  // Collision constants - STANDARDIZED sizes
  static const double wallThickness = 40.0;
  static const double obstacleSmall = 80.0;
  static const double obstacleMedium = 120.0;
  static const double obstacleLarge = 160.0;
  
  ConsumoCodiciaScene(this.world);
  
  Future<void> setup() async {
    debugPrint('🎨 [SCENE] Setting up Consumo y Codicia scene (${mapWidth}x${mapHeight})');
    
    // Add background
    _addBackground();
    
    // Add boundary walls
    _addBoundaryWalls();
    
    // Add Phase 1 obstacles (Warehouse/Restaurant - 0 to 2400)
    _addPhase1Obstacles();
    
    // Add Phase 2 obstacles (Vault/Bank - 2400 to 4800)
    _addPhase2Obstacles();
    
    // Add checkpoint marker at x=2400
    _addCheckpointMarker();
    
    debugPrint('✅ [SCENE] Consumo y Codicia scene setup complete');
  }
  
  void _addBackground() {
    // Phase 1 background (dark warehouse) - Textura de concreto
    final bg1 = TexturedBackgroundComponent(
      position: Vector2(0, 0),
      size: Vector2(2400, mapHeight),
      textureType: 'concrete',
      baseColor: const Color(0xFF1a0f0a), // Dark brown
      seed: 1,
    );
    world.add(bg1);
    
    // Phase 2 background (vault) - Textura metálica
    final bg2 = TexturedBackgroundComponent(
      position: Vector2(2400, 0),
      size: Vector2(2400, mapHeight),
      textureType: 'metal',
      baseColor: const Color(0xFF0a0a0f), // Dark blue-gray
      seed: 2,
    );
    world.add(bg2);
  }
  
  void _addBoundaryWalls() {
    // Top wall
    world.add(ObstacleComponent(
      position: Vector2(0, 0),
      size: Vector2(mapWidth, wallThickness),
      color: const Color(0xFF2a1f1a),
    ));
    
    // Bottom wall
    world.add(ObstacleComponent(
      position: Vector2(0, mapHeight - wallThickness),
      size: Vector2(mapWidth, wallThickness),
      color: const Color(0xFF2a1f1a),
    ));
    
    // Left wall
    world.add(ObstacleComponent(
      position: Vector2(0, 0),
      size: Vector2(wallThickness, mapHeight),
      color: const Color(0xFF2a1f1a),
    ));
    
    // Right wall
    world.add(ObstacleComponent(
      position: Vector2(mapWidth - wallThickness, 0),
      size: Vector2(wallThickness, mapHeight),
      color: const Color(0xFF2a1f1a),
    ));
  }
  
  /// Phase 1 obstacles: Warehouse/Restaurant theme (0-2400)
  void _addPhase1Obstacles() {
    // Storage crates and tables - ALIGNED to grid with WOOD texture
    final obstacles = [
      // Row 1 - Top area
      Vector2(400, 200),
      Vector2(600, 200),
      Vector2(1000, 200),
      Vector2(1400, 200),
      Vector2(1800, 200),
      
      // Row 2 - Upper middle
      Vector2(300, 500),
      Vector2(800, 500),
      Vector2(1300, 500),
      Vector2(1800, 500),
      Vector2(2100, 500),
      
      // Row 3 - Center
      Vector2(500, 800),
      Vector2(1000, 800),
      Vector2(1500, 800),
      Vector2(2000, 800),
      
      // Row 4 - Lower middle
      Vector2(400, 1100),
      Vector2(900, 1100),
      Vector2(1400, 1100),
      Vector2(1900, 1100),
      
      // Row 5 - Bottom area
      Vector2(600, 1400),
      Vector2(1100, 1400),
      Vector2(1600, 1400),
      Vector2(2100, 1400),
    ];
    
    int seedCounter = 100;
    for (final pos in obstacles) {
      world.add(TexturedObstacleComponent(
        position: pos,
        size: Vector2(obstacleMedium, obstacleMedium),
        textureType: 'crate', // Cajas de madera
        baseColor: const Color(0xFF3a2f2a), // Brown crates
        seed: seedCounter++,
      ));
    }
    
    // Large central obstacles - Bigger crates
    world.add(TexturedObstacleComponent(
      position: Vector2(1100, 600),
      size: Vector2(obstacleLarge, obstacleLarge),
      textureType: 'crate',
      baseColor: const Color(0xFF4a3f3a),
      seed: 200,
    ));
    
    world.add(TexturedObstacleComponent(
      position: Vector2(1100, 1000),
      size: Vector2(obstacleLarge, obstacleLarge),
      textureType: 'crate',
      baseColor: const Color(0xFF4a3f3a),
      seed: 201,
    ));
  }
  
  /// Phase 2 obstacles: Vault/Bank theme (2400-4800)
  void _addPhase2Obstacles() {
    // Vault boxes and safes - ALIGNED to grid with METAL texture
    final obstacles = [
      // Row 1 - Top area
      Vector2(2600, 200),
      Vector2(2900, 200),
      Vector2(3300, 200),
      Vector2(3700, 200),
      Vector2(4100, 200),
      
      // Row 2 - Upper middle
      Vector2(2700, 500),
      Vector2(3200, 500),
      Vector2(3700, 500),
      Vector2(4200, 500),
      
      // Row 3 - Center
      Vector2(2800, 800),
      Vector2(3300, 800),
      Vector2(3800, 800),
      Vector2(4300, 800),
      
      // Row 4 - Lower middle
      Vector2(2700, 1100),
      Vector2(3200, 1100),
      Vector2(3700, 1100),
      Vector2(4200, 1100),
      
      // Row 5 - Bottom area
      Vector2(2900, 1400),
      Vector2(3400, 1400),
      Vector2(3900, 1400),
      Vector2(4300, 1400),
    ];
    
    int seedCounter = 300;
    for (final pos in obstacles) {
      world.add(TexturedObstacleComponent(
        position: pos,
        size: Vector2(obstacleMedium, obstacleMedium),
        textureType: 'vault', // Cajas fuertes metálicas
        baseColor: const Color(0xFF2a2a3a), // Gray-blue vaults
        seed: seedCounter++,
      ));
    }
    
    // Large vault safes
    world.add(TexturedObstacleComponent(
      position: Vector2(3400, 600),
      size: Vector2(obstacleLarge, obstacleLarge),
      textureType: 'vault',
      baseColor: const Color(0xFF3a3a4a),
      seed: 400,
    ));
    
    world.add(TexturedObstacleComponent(
      position: Vector2(3400, 1000),
      size: Vector2(obstacleLarge, obstacleLarge),
      textureType: 'vault',
      baseColor: const Color(0xFF3a3a4a),
      seed: 401,
    ));
  }
  
  /// Add visual checkpoint marker at x=2400
  void _addCheckpointMarker() {
    // Vertical line to mark phase transition
    final marker = RectangleComponent(
      position: Vector2(2395, 0),
      size: Vector2(10, mapHeight),
      paint: Paint()
        ..color = const Color(0xFF8B0000).withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    world.add(marker);
    
    // Text label (optional, for debugging)
    debugPrint('🎯 [SCENE] Checkpoint marker added at x=2400');
  }
}
