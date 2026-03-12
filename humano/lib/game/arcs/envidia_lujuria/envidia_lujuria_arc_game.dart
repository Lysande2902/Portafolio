import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/arcs/envy/components/player_component.dart';
import 'package:humano/game/arcs/envidia_lujuria/envidia_lujuria_scene.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/locker_component.dart';
import 'package:humano/game/arcs/envidia_lujuria/components/exit_door_component.dart';
import 'package:humano/game/core/input/input_controller.dart';
import 'package:humano/game/core/systems/sanity_system.dart';

/// Arco 1: ENVIDIA Y LUJURIA - Club Reflections
/// Rebuilt from scratch based on user instructions.
class EnvidiaLujuriaArcGame extends BaseArcGame with KeyboardEvents {
  PlayerComponent? _player;
  PlayerComponent? get player => _player;
  
  final SanitySystem sanitySystem = SanitySystem();
  final InputController inputController = InputController();
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugPrint('🎮 [ENVIDIA_LUJURIA] Protocol 1 Loaded - Starting from scratch');
  }
  
  @override
  Future<void> setupPlayer() async {
    _player = PlayerComponent(skinId: equippedPlayerSkin)
      ..position = Vector2(100, 120) // Inside bathroom
      ..onNoiseMade = (pos) {
        onPlayerNoise?.call(pos);
      };
    
    world.add(_player!);
    camera.follow(_player!, maxSpeed: 400);
  }
  
  @override
  Future<void> setupEnemy() async {
    // Enemy will be added later when we define its patrol
    debugPrint('🎮 [ENVIDIA_LUJURIA] setupEnemy() - Empty for now');
  }
  
  @override
  Future<void> setupScene() async {
    final scene = EnvidiaLujuriaScene(world);
    await scene.setup();
  }
  
  @override
  Future<void> setupCollectibles() async {
    // Collectibles are handled by lockers in the scene
    debugPrint('🎮 [ENVIDIA_LUJURIA] Collectibles are inside lockers');
  }
  
  @override
  void updateGame(double dt) {
    if (_player == null) return;
    
    // Update movement
    _player!.move(inputController.movementDirection);
    
    // Update sanity
    sanitySystem.update(dt, false, _player!.isHidden);
    
    // Check victory
    _checkVictoryCondition();
    
    updateItemTimers(dt);
  }

  void _checkVictoryCondition() {
    if (_player == null) return;
    
    // Check if player is near the exit door (which is at x=4600)
    // We can iterate world children to find ExitDoorComponent
    for (final component in world.children) {
      if (component is ExitDoorComponent) {
        final door = component;
        final distance = (door.position - _player!.position).length;
        if (distance < 80 && evidenceCollected >= 6) {
          onVictory();
        }
        break;
      }
    }
  }
  
  @override
  void toggleHide() {
    if (_player == null || !_player!.isNearHidingSpot) return;
    
    final locker = _player!.currentLocker;
    if (locker != null) {
      // 1. Check for fragments first
      if (locker.hasUncollectedFragment) {
        locker.collectFragment();
        evidenceCollected++;
        onEvidenceCollectedChanged?.call();
        debugPrint('📄 [ENVIDIA_LUJURIA] Fragment found in locker! ($evidenceCollected/10)');
        // Note: We don't hide yet, just collect. Tapping again will hide.
        return;
      }
      
      // 2. Hide/Unhide logic
      if (_player!.isHidden) {
        _player!.unhide();
        locker.isPlayerInside = false;
      } else if (!locker.isOccupied) {
        _player!.hide();
        locker.isPlayerInside = true;
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
  
  void updateJoystickInput(Vector2 direction) {
    inputController.updateFromJoystick(direction);
  }

  @override
  Future<void> resetGame() async {
    sanitySystem.reset();
    await super.resetGame();
  }
}
