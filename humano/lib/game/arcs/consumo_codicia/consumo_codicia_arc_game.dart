import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/arcs/gluttony/components/player_component.dart';
import 'package:humano/game/arcs/gluttony/components/enemy_component.dart' as gluttony;
import 'package:humano/game/arcs/greed/components/banker_enemy.dart';
import 'package:humano/game/arcs/consumo_codicia/components/evidence_component.dart';
import 'package:humano/game/core/input/input_controller.dart';
import 'package:humano/game/core/systems/sanity_system.dart';
import 'package:humano/game/arcs/consumo_codicia/components/exit_door_component.dart';
import 'package:humano/game/arcs/consumo_codicia/components/hiding_spot_component.dart';
import 'package:humano/game/arcs/consumo_codicia/consumo_codicia_scene.dart';

/// Arco 1: CONSUMO Y CODICIA (Gula + Avaricia fusionados)
/// Fase 1 (0-5 fragmentos): Mateo (Cerdo) - Mecánica de Gula
/// Fase 2 (5-10 fragmentos): Valeria (Rata) - Mecánica de Avaricia
/// Mapa expandido: 4800x1600 (doble de largo para 2 enemigos)
class ConsumoCodiciaArcGame extends BaseArcGame with KeyboardEvents {
  // Components
  PlayerComponent? _player;
  PositionComponent? _currentEnemy; // Can be Mateo or Valeria
  
  PlayerComponent? get player => _player;
  PositionComponent? get currentEnemy => _currentEnemy;
  
  // Systems
  final SanitySystem sanitySystem = SanitySystem();
  final InputController inputController = InputController();
  
  // Game state
  double gameTime = 0.0;
  int currentPhase = 1; // 1 = Mateo, 2 = Valeria
  bool checkpointReached = false;
  
  // Phase-specific stats
  int coinsThrown = 0;
  
  // Override scene dimensions for FUSED arc (double length)
  static const double fusedSceneWidth = 4800.0;
  static const double fusedSceneHeight = 1600.0;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugPrint('🎮 [CONSUMO_CODICIA] Arc loaded - Fused map: ${fusedSceneWidth}x${fusedSceneHeight}');
    
    // Trigger initial dialogue
    Future.delayed(const Duration(milliseconds: 1000), () {
      pauseGame();
      stateNotifier.updateDialogue(
        'Alex', 
        'Este es el primer caso... Mateo. Se consumió a sí mismo hasta no dejar nada. Debo encontrar qué fue lo que olvidé aquí.'
      );
    });
  }
  
  @override
  Future<void> setupPlayer() async {
    debugPrint('🎮 [CONSUMO_CODICIA] setupPlayer() - Phase $currentPhase');
    
    _player = PlayerComponent(skinId: equippedPlayerSkin)
      ..position = Vector2(200, fusedSceneHeight / 2)
      ..onNoiseMade = (pos) {
        onPlayerNoise?.call(pos);
      };
    
    world.add(_player!);
    camera.follow(_player!, maxSpeed: 500);
    
    debugPrint('✅ [CONSUMO_CODICIA] Player setup complete');
  }
  
  @override
  Future<void> setupEnemy() async {
    debugPrint('🎮 [CONSUMO_CODICIA] setupEnemy() - Starting with Phase 1 (Mateo)');
    await _spawnPhase1Enemy();
  }
  
  /// Spawn Phase 1 enemy: Mateo (Cerdo) - Gula mechanic
  Future<void> _spawnPhase1Enemy() async {
    // Waypoints for FIRST HALF of fused map (0-2400)
    final waypoints = [
      Vector2(400, 600),
      Vector2(800, 1000),
      Vector2(1200, 600),
      Vector2(1600, 1100),
      Vector2(2000, 700),
      Vector2(1600, 1300),
      Vector2(1000, 1200),
      Vector2(600, 900),
    ];
    
    _currentEnemy = gluttony.EnemyComponent(
      position: waypoints[0],
      waypoints: waypoints,
      skinId: equippedEnemySkin,
    );
    
    (_currentEnemy as gluttony.EnemyComponent).setTargetPlayer(_player!);
    world.add(_currentEnemy!);
    
    debugPrint('✅ [CONSUMO_CODICIA] Phase 1 enemy (Mateo) spawned');
  }
  
  /// Spawn Phase 2 enemy: Valeria (Rata) - Avaricia mechanic
  Future<void> _spawnPhase2Enemy() async {
    // Waypoints for SECOND HALF of fused map (2400-4800)
    final waypoints = [
      Vector2(2600, 700),
      Vector2(3000, 1100),
      Vector2(3400, 700),
      Vector2(3800, 1200),
      Vector2(4200, 800),
      Vector2(3800, 1400),
      Vector2(3200, 1300),
      Vector2(2800, 1000),
    ];
    
    _currentEnemy = BankerEnemy(
      position: waypoints[0],
      waypoints: waypoints,
      skinId: equippedEnemySkin,
    );
    
    (_currentEnemy as BankerEnemy).setTargetPlayer(_player!);
    world.add(_currentEnemy!);
    
    debugPrint('✅ [CONSUMO_CODICIA] Phase 2 enemy (Valeria) spawned');
  }
  
  @override
  Future<void> setupScene() async {
    debugPrint('🎮 [CONSUMO_CODICIA] setupScene()');
    
    final scene = ConsumoCodiciaScene(world);
    await scene.setup();
    
    debugPrint('✅ [CONSUMO_CODICIA] Scene setup complete');
  }
  
  @override
  Future<void> setupCollectibles() async {
    debugPrint('🎮 [CONSUMO_CODICIA] setupCollectibles() - 10 total fragments');
    
    // 10 evidence items distributed across FULL fused map
    // First 5 in Phase 1 area (0-2400), Last 5 in Phase 2 area (2400-4800)
    final evidencePositions = [
      // Phase 1 area (Mateo zone)
      Vector2(500, 700),
      Vector2(1000, 1100),
      Vector2(1500, 700),
      Vector2(1900, 1200),
      Vector2(1200, 1400),
      // Phase 2 area (Valeria zone)
      Vector2(2700, 800),
      Vector2(3200, 1200),
      Vector2(3700, 800),
      Vector2(4100, 1300),
      Vector2(3400, 1400),
    ];
    
    for (int i = 0; i < evidencePositions.length; i++) {
      final evidence = EvidenceComponent(
        position: evidencePositions[i],
        evidenceId: 'consumo_codicia_evidence_$i',
      );
      world.add(evidence);
    }
    
    // Exit door at the END of fused map
    final exitDoor = ExitDoorComponent(
      position: Vector2(4600, fusedSceneHeight / 2),
    );
    world.add(exitDoor);
    
    // Hiding spots distributed across BOTH phases (MÁS PEQUEÑOS Y MEJORADOS)
    final hidingSpots = [
      // Phase 1 hiding spots (reducidos de 160-180 a 100-120)
      HidingSpotComponent(position: Vector2(300, 400), size: Vector2(100, 100)),
      HidingSpotComponent(position: Vector2(1100, 600), size: Vector2(110, 110)),
      HidingSpotComponent(position: Vector2(800, 1100), size: Vector2(105, 105)),
      HidingSpotComponent(position: Vector2(1700, 1200), size: Vector2(100, 100)),
      // Phase 2 hiding spots (reducidos de 160-180 a 100-120)
      HidingSpotComponent(position: Vector2(2700, 600), size: Vector2(105, 105)),
      HidingSpotComponent(position: Vector2(3300, 1000), size: Vector2(110, 110)),
      HidingSpotComponent(position: Vector2(3900, 700), size: Vector2(100, 100)),
      HidingSpotComponent(position: Vector2(4300, 1300), size: Vector2(105, 105)),
    ];
    world.addAll(hidingSpots);
    
    debugPrint('✅ [CONSUMO_CODICIA] Collectibles setup: 10 evidences, 8 hiding spots (mejorados), 1 exit door');
  }
  
  @override
  void updateGame(double dt) {
    if (_player == null || _currentEnemy == null) return;
    
    gameTime += dt;
    
    // Update player movement
    _player!.move(inputController.movementDirection);
    
    // Update sanity
    sanitySystem.update(dt, false, _player!.isHidden);
    
    // Check for checkpoint (5 fragments = switch to Phase 2)
    if (evidenceCollected >= 5 && currentPhase == 1 && !checkpointReached) {
      _triggerCheckpoint();
    }
    
    // Check evidence collection
    _checkEvidenceCollection();
    
    // Check game over conditions
    _checkGameOverConditions();
    
    // Update item timers
    updateItemTimers(dt);
    
    // Check victory condition
    _checkVictoryCondition();
  }
  
  /// Trigger checkpoint: Remove Phase 1 enemy, spawn Phase 2 enemy
  void _triggerCheckpoint() async {
    checkpointReached = true;
    currentPhase = 2;
    
    debugPrint('🎯 [CHECKPOINT] Reached! Switching from Mateo to Valeria');
    debugPrint('   Fragments collected: $evidenceCollected/10');
    
    // Remove Phase 1 enemy (Mateo)
    if (_currentEnemy != null && _currentEnemy!.isMounted) {
      _currentEnemy!.removeFromParent();
      debugPrint('🗑️ [CHECKPOINT] Phase 1 enemy removed');
    }
    
    // Small delay for dramatic effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Spawn Phase 2 enemy (Valeria)
    await _spawnPhase2Enemy();
    
    debugPrint('✅ [CHECKPOINT] Phase 2 active - Valeria hunting!');
  }
  
  void _checkEvidenceCollection() {
    if (_player == null) return;
    
    for (final component in world.children) {
      if (component is EvidenceComponent && !component.isCollected) {
        final distance = (component.position - _player!.position).length;
        
        // Increased collection radius from 50 to 80 for easier pickup
        if (distance < 80) {
          component.collect();
          evidenceCollected++;
          
          // Update door state
          _updateDoorState();
          
          // Notify UI
          onEvidenceCollectedChanged?.call();
          
          debugPrint('📄 [CONSUMO_CODICIA] Evidence collected! Total: $evidenceCollected/10 (Phase $currentPhase)');
          debugPrint('   Evidence position: ${component.position}');
          debugPrint('   Player position: ${_player!.position}');
          debugPrint('   Distance: ${distance.toStringAsFixed(1)}');
        }
      }
    }
  }
  
  void _updateDoorState() {
    for (final component in world.children) {
      if (component is ExitDoorComponent) {
        component.updateFragments(evidenceCollected);
        break;
      }
    }
  }
  
  void _checkGameOverConditions() {
    if (_player == null || _currentEnemy == null) return;
    
    // Check if enemy caught player
    final distance = (_currentEnemy!.position - _player!.position).length;
    if (distance < 40 && !_player!.isHidden) {
      onGameOver();
      return;
    }
    
    // Check if sanity depleted
    if (sanitySystem.isDepleted()) {
      onGameOver();
      return;
    }
  }
  
  void _checkVictoryCondition() {
    if (_player == null) return;
    
    // Check if player is near the exit door
    for (final component in world.children) {
      if (component is ExitDoorComponent) {
        final distance = (component.position - _player!.position).length;
        
        // Player must be near door AND have all 10 fragments
        if (distance < 60 && evidenceCollected >= 10 && !component.isLocked) {
          onVictory();
        }
        break;
      }
    }
  }
  
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    inputController.updateFromKeyboard(keysPressed);
    return KeyEventResult.handled;
  }
  
  /// Update input from virtual joystick
  void updateJoystickInput(Vector2 direction) {
    inputController.updateFromJoystick(direction);
  }
  
  /// Toggle hide/unhide
  void toggleHide() {
    if (_player == null) return;
    
    if (_player!.isNearHidingSpot && !_player!.isHidden) {
      _player!.hide();
    } else if (_player!.isHidden) {
      _player!.unhide();
    }
  }
  
  /// Throw coin (Phase 2 mechanic)
  void throwCoin(Vector2 targetPosition) {
    if (currentPhase != 2 || _currentEnemy == null) return;
    
    coinsThrown++;
    debugPrint('💰 [CONSUMO_CODICIA] Coin thrown! Total: $coinsThrown');
    
    // Distract Valeria
    if (_currentEnemy is BankerEnemy) {
      (_currentEnemy as BankerEnemy).distractTo(targetPosition, duration: 5.0);
    }
  }
  
  /// Get game-specific stats for victory screen
  Map<String, dynamic> getGameStats() {
    return {
      'coinsThrown': coinsThrown,
      'checkpointReached': checkpointReached,
      'finalPhase': currentPhase,
    };
  }
  
  @override
  Future<void> resetGame() async {
    // Reset phase state
    currentPhase = 1;
    checkpointReached = false;
    coinsThrown = 0;
    
    // Reset systems
    sanitySystem.reset();
    
    // Call parent reset
    await super.resetGame();
  }
}
