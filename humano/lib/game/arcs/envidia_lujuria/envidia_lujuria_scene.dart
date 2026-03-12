import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/rendering/tiled_image_background_component.dart';
import 'package:humano/game/core/components/image_obstacle_component.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/broken_mirror_component.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/locker_component.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/exit_door_component.dart';

/// Club Reflections - Professional architectural layout
/// Total size: 2400x1600
class EnvidiaLujuriaScene {
  final World world;
  
  // Map dimensions
  static const double mapWidth = 2400.0;
  static const double mapHeight = 1600.0;
  static const double wallThickness = 50.0;
  
  EnvidiaLujuriaScene(this.world);
  
  Future<void> setup() async {
    debugPrint('🎨 [SCENE] Building Club Reflections (Professional Layout)');
    
    _addBackground();
    _addBoundaryWalls();
    _buildEntrance();
    _buildBathroomArea();
    _buildLockerRoom();
    _buildMainGym();
    _addExitDoor();
    
    debugPrint('✅ [SCENE] Club Reflections complete');
  }
  
  void _addBackground() {
    world.add(TiledImageBackgroundComponent(
      position: Vector2(0, 0),
      size: Vector2(mapWidth, mapHeight),
      imagePath: 'Floor_gym.jpg',
      tileWidth: 512,
      tileHeight: 512,
      blendColor: const Color(0xFF556655), // Subtle green-gray tint
    ));
  }
  
  void _addBoundaryWalls() {
    const wallImg = 'Wall.jpg';
    final paint = Colors.black.withOpacity(0.4);
    
    // Top
    world.add(ImageObstacleComponent(
      position: Vector2(0, 0),
      size: Vector2(mapWidth, wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Bottom
    world.add(ImageObstacleComponent(
      position: Vector2(0, mapHeight - wallThickness),
      size: Vector2(mapWidth, wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Left
    world.add(ImageObstacleComponent(
      position: Vector2(0, 0),
      size: Vector2(wallThickness, mapHeight),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Right
    world.add(ImageObstacleComponent(
      position: Vector2(mapWidth - wallThickness, 0),
      size: Vector2(wallThickness, mapHeight),
      imagePath: wallImg,
      blendColor: paint,
    ));
  }
  
  /// Entrance/Reception area (top-left corner)
  void _buildEntrance() {
    const wallImg = 'Wall.jpg';
    final paint = Colors.black.withOpacity(0.4);
    
    // Reception room: 400x300
    // Right wall of reception
    world.add(ImageObstacleComponent(
      position: Vector2(400, wallThickness),
      size: Vector2(wallThickness, 250),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Bottom wall of reception (with opening for hallway)
    world.add(ImageObstacleComponent(
      position: Vector2(wallThickness, 300),
      size: Vector2(150, wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Continue bottom wall after opening
    world.add(ImageObstacleComponent(
      position: Vector2(300, 300),
      size: Vector2(150, wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
  }
  
  /// Bathroom (small room in entrance)
  void _buildBathroomArea() {
    const wallImg = 'Wall.jpg';
    final paint = Colors.black.withOpacity(0.4);
    
    // Bathroom: 150x200 in top-left corner
    // Right wall
    world.add(ImageObstacleComponent(
      position: Vector2(150, wallThickness),
      size: Vector2(wallThickness, 150),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Bottom wall (with door opening)
    world.add(ImageObstacleComponent(
      position: Vector2(wallThickness, 200),
      size: Vector2(50, wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    world.add(ImageObstacleComponent(
      position: Vector2(150, 200),
      size: Vector2(50, wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Add broken mirrors in bathroom
    world.addAll([
      BrokenMirrorComponent(position: Vector2(70, 80), size: Vector2(50, 50)),
      BrokenMirrorComponent(position: Vector2(90, 140), size: Vector2(40, 40)),
      BrokenMirrorComponent(position: Vector2(120, 110), size: Vector2(35, 35)),
    ]);
  }
  
  /// Locker room area (below entrance)
  void _buildLockerRoom() {
    const wallImg = 'Wall.jpg';
    final paint = Colors.black.withOpacity(0.4);
    
    // Locker room: 400x400 (from y=350 to y=750)
    // Right wall
    world.add(ImageObstacleComponent(
      position: Vector2(400, 350),
      size: Vector2(wallThickness, 400),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Bottom wall (with opening to gym)
    world.add(ImageObstacleComponent(
      position: Vector2(wallThickness, 750),
      size: Vector2(200, wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Add lockers in locker room (2 rows)
    final lockerRoomLockers = [
      // Left row
      Vector2(80, 400),
      Vector2(80, 520),
      Vector2(80, 640),
      // Right row
      Vector2(320, 400),
      Vector2(320, 520),
      Vector2(320, 640),
    ];
    
    for (int i = 0; i < lockerRoomLockers.length; i++) {
      world.add(LockerComponent(
        position: lockerRoomLockers[i],
        size: Vector2(70, 100),
        isOccupied: i == 1 || i == 4, // Some are occupied
        hasFragment: i == 0 || i == 5, // 2 fragments here
      ));
    }
  }
  
  /// Main gymnasium area (large open space)
  void _buildMainGym() {
    const wallImg = 'Wall.jpg';
    final paint = Colors.black.withOpacity(0.4);
    
    // Main gym starts at x=450
    // Vertical divider wall (with opening)
    world.add(ImageObstacleComponent(
      position: Vector2(450, wallThickness),
      size: Vector2(wallThickness, 600),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    world.add(ImageObstacleComponent(
      position: Vector2(450, 800),
      size: Vector2(wallThickness, mapHeight - 800 - wallThickness),
      imagePath: wallImg,
      blendColor: paint,
    ));
    
    // Scatter lockers throughout gym
    final gymLockers = [
      Vector2(600, 200),
      Vector2(800, 200),
      Vector2(1000, 200),
      Vector2(1200, 200),
      Vector2(600, 600),
      Vector2(900, 600),
      Vector2(1200, 600),
      Vector2(600, 1000),
      Vector2(900, 1000),
      Vector2(1200, 1000),
      Vector2(1500, 400),
      Vector2(1500, 800),
      Vector2(1500, 1200),
      Vector2(1800, 300),
      Vector2(1800, 700),
      Vector2(1800, 1100),
      Vector2(2100, 400),
      Vector2(2100, 900),
    ];
    
    for (int i = 0; i < gymLockers.length; i++) {
      world.add(LockerComponent(
        position: gymLockers[i],
        size: Vector2(70, 100),
        isOccupied: i % 5 == 0, // Every 5th is occupied
        hasFragment: i == 3 || i == 7 || i == 12 || i == 16, // 4 more fragments
      ));
    }
    
    // Add some broken mirrors scattered in gym
    world.addAll([
      BrokenMirrorComponent(position: Vector2(700, 400), size: Vector2(60, 60)),
      BrokenMirrorComponent(position: Vector2(1100, 800), size: Vector2(50, 50)),
      BrokenMirrorComponent(position: Vector2(1600, 500), size: Vector2(55, 55)),
      BrokenMirrorComponent(position: Vector2(2000, 1200), size: Vector2(45, 45)),
    ]);
  }
  
  void _addExitDoor() {
    world.add(ExitDoorComponent(
      position: Vector2(mapWidth - 150, mapHeight / 2),
    ));
  }
}
