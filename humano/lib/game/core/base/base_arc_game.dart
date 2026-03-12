import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:humano/game/core/state/game_state_notifier.dart';
import 'package:humano/game/core/performance/performance_monitor.dart';
import 'package:humano/data/providers/fragments_provider.dart';

// DISABLE ALL DEBUG PRINTS
void _log(String message) {
  // Silently ignore all logs
}

/// Queue for deferring state updates until after build phase
class StateUpdateQueue {
  final List<VoidCallback> _updates = [];
  bool _isProcessing = false;
  
  /// Add an update to the queue
  void enqueue(VoidCallback update) {
    _updates.add(update);
  }
  
  /// Execute all queued updates
  void flush() {
    if (_isProcessing) return;
    _isProcessing = true;
    
    for (final update in _updates) {
      try {
        update();
      } catch (e) {
        _log('❌ [QUEUE] Error executing queued update: $e');
      }
    }
    
    _updates.clear();
    _isProcessing = false;
  }
  
  /// Clear all queued updates without executing
  void clear() {
    _updates.clear();
  }
  
  /// Check if queue has pending updates
  bool get hasPendingUpdates => _updates.isNotEmpty;
}

abstract class BaseArcGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  // Instance tracking fields
  int? _instanceId;
  bool _hasBeenAttached = false;
  bool _hasBeenDisposed = false;
  bool _isDisposing = false; // Flag to indicate disposal in progress
  
  @override
  void onTapDown(TapDownEvent event) {
    try {
      // Safely access localPosition to trigger conversion logic
      final pos = event.localPosition;
      _log('🎮 [GAME_TAP] Received tap at $pos');
    } catch (e) {
      debugPrint('⚠️ [GAME_TAP] Error converting tap position: $e');
      return; // Skip tap if coordinates are invalid
    }
    super.onTapDown(event);
  }
  // Getter for instance ID
  int? get instanceId => _instanceId;
  
  // Setter for instance ID (called by factory)
  set instanceId(int id) {
    if (_instanceId != null) {
      throw StateError('Instance ID already set to $_instanceId, cannot change to $id');
    }
    _instanceId = id;
  }
  
  // State notifier for reactive UI updates
  final GameStateNotifier stateNotifier = GameStateNotifier();
  
  // Performance monitor
  final PerformanceMonitor performanceMonitor = PerformanceMonitor();
  
  // State update queue for deferred updates
  final StateUpdateQueue _stateUpdateQueue = StateUpdateQueue();
  
  // Flag to track if initial build is complete
  bool _initialBuildComplete = false;
  
  // Direct reference to FragmentsProvider (no BuildContext needed)
  FragmentsProvider? _fragmentsProvider;
  // Game state
  bool isGameOver = false;
  bool isVictory = false;
  bool isPaused = false;
  int evidenceCollected = 0;
  double elapsedTime = 0.0;
  double playTime = 0.0; // Time in milliseconds for victory screen
  
  // Player customization
  String? equippedPlayerSkin;
  String? equippedEnemySkin;
  Map<String, int> availableConsumables = {};
  
  // Player inventory items
  bool hasAltAccount = false;
  bool modoIncognitoActive = false;
  bool firewallActive = false;
  bool vpnActive = false;
  bool altAccountActive = false;
  
  // Item timers
  double modoIncognitoTimer = 0.0;
  double firewallTimer = 0.0;
  double vpnTimer = 0.0;
  double altAccountTimer = 0.0;
  
  // Item durations (in seconds)
  static const double modoIncognitoDuration = 10.0;
  static const double firewallDuration = 15.0;
  static const double vpnDuration = 12.0;
  static const double altAccountDuration = 45.0; // 45 seconds - slows enemies

  // Scene dimensions - EXPANDED for full game (2400x1600 = 4x area)
  static const double sceneWidth = 2400.0;
  static const double sceneHeight = 1600.0;
  
  // Build context for providers (set from screen)
  @override
  BuildContext? buildContext;
  
  // Flag to prevent double initialization
  bool _isInitialized = false;
  
  // Frame time monitoring
  DateTime? _lastFrameTime;
  final List<double> _frameTimeHistory = [];
  static const int _maxFrameHistory = 60; // Track last 60 frames
  
  // Component queue for safe addition during gameplay
  final List<Component> _componentsToAdd = [];

  // Multiplayer hooks
  Function(Vector2 position)? onPlayerNoise;
  
  // UI update callbacks
  VoidCallback? onEvidenceCollectedChanged;
  VoidCallback? onGameStateChanged;
  void Function(int amount)? onRewardGained;

  @override
  Future<void> onLoad() async {
    debugPrint('🔄 [LIFECYCLE] onLoad() called');
    debugPrint('   Game hashCode: $hashCode');
    debugPrint('   Already initialized: $_isInitialized');
    debugPrint('   Has been attached: $_hasBeenAttached');
    
    try {
      await super.onLoad();
      
      // Setup camera
      camera.viewfinder.anchor = Anchor.center;
      
      // Only initialize if not already done manually
      if (!_isInitialized) {
        debugPrint('🎮 [LIFECYCLE] Initializing game for first time');
        await initializeGame();
        _isInitialized = true;
      } else {
        debugPrint('⚠️ [LIFECYCLE] Game already initialized, skipping');
      }
      
      // Schedule post-frame update to flush queued state updates
      schedulePostFrameUpdate();
      
      debugPrint('✅ [LIFECYCLE] onLoad() completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [LIFECYCLE] Error in onLoad: $e');
      debugPrint('📋 [LIFECYCLE] Stack trace: $stackTrace');
      _log('❌ [BASE] Error in onLoad: $e');
      _log('📋 [BASE] Stack trace: $stackTrace');
    }
  }
  
  /// Schedule state updates to be applied after the current frame
  void schedulePostFrameUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _log('✅ [POST-FRAME] Executing post-frame callback');
      
      // Flush queued state updates
      if (_stateUpdateQueue.hasPendingUpdates) {
        _log('📤 [QUEUE] Flushing ${_stateUpdateQueue._updates.length} queued updates');
        _stateUpdateQueue.flush();
      }
      
      // Flush deferred notifier updates
      stateNotifier.flushDeferredUpdates();
      
      // Mark build as complete
      _initialBuildComplete = true;
      _log('✅ [BUILD] Initial build complete - updates can now be applied immediately');
    });
  }

  @override
  void attach(PipelineOwner owner, GameRenderBox gameRenderBox) {
    // SOLUCIÓN CLAVE: Si ya estamos adjuntos, salir inmediatamente.
    // Antes llamábamos super.attach() y capturábamos la excepción con try/catch,
    // pero Flame corrompe su estado interno ANTES de lanzar la excepción,
    // dejando el motor en un estado donde la lógica corre pero el render se congela.
    if (isAttached) {
      debugPrint('⚠️ [ATTACH] Game hashCode $hashCode already attached - skipping duplicate.');
      return;
    }

    super.attach(owner, gameRenderBox);
    _hasBeenAttached = true;
  }


  @override
  Vector2 convertGlobalToLocalCoordinate(Vector2 point) {
    // Robust coordinate conversion to avoid "Null check operator used on a null value"
    // which happens inside Flame if a tap occurs before the first render/update.
    try {
      return super.convertGlobalToLocalCoordinate(point);
    } catch (_) {
      // Fallback: if we're not fully initialized, return the point as-is
      // to avoid breaking the event chain with a null error.
      return point;
    }
  }

  @override
  void detach() {
    debugPrint('💔 [DETACH] Game instance $_instanceId detached');
    _hasBeenAttached = false;
    super.detach();
  }
  
  @override
  void onMount() {
    super.onMount();
    debugPrint('✅ [LIFECYCLE] Game instance $_instanceId mounted');
    debugPrint('   Game hashCode: $hashCode');
  }
  
  @override
  void onRemove() {
    if (_hasBeenDisposed) {
      debugPrint('⚠️ [DISPOSE] Game instance $_instanceId already disposed, skipping');
      return;
    }
    
    _hasBeenDisposed = true;
    _isDisposing = false;
    _hasBeenAttached = false;
    
    debugPrint('═══════════════════════════════════');
    debugPrint('🗑️ [DISPOSE] Disposing game instance $_instanceId');
    debugPrint('   Game type: $runtimeType');
    debugPrint('   Game hashCode: $hashCode');
    debugPrint('   Was attached: $_hasBeenAttached');
    debugPrint('   Is mounted: $isMounted');
    debugPrint('═══════════════════════════════════');
    
    // Reset state notifier instead of disposing (to avoid "used after disposed" errors)
    try {
      stateNotifier.reset();
    } catch (e) {
      debugPrint('⚠️ [DISPOSE] Error resetting state notifier: $e');
    }
    
    super.onRemove();
    
    debugPrint('✅ [DISPOSE] Game instance $_instanceId disposed successfully');
  }
  
  /// Manual initialization (called before GameWidget creation)
  Future<void> preInitialize() async {
    if (_isInitialized) return;

    _log('🎮 [PRE-INIT] Starting manual game initialization...');
    await initializeGame();
    _isInitialized = true;
    _log('✅ [PRE-INIT] Game initialized successfully');
  }

  @override
  void update(double dt) {
    // Track frame time
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!).inMilliseconds.toDouble();
      _trackFrameTime(frameTime);
    }
    _lastFrameTime = now;
    
    if (!_isInitialized) return;
    
    try {
      super.update(dt);
      
      if (!isPaused && !isGameOver && !isVictory) {
        elapsedTime += dt;
        playTime += dt * 1000; // Convert seconds to milliseconds
        updateItemTimers(dt);
        updateGame(dt);
        
        // Update state notifier (only notifies if values changed)
        _updateStateNotifier();
      }
      
      // Add queued components safely after update
      if (_componentsToAdd.isNotEmpty) {
        final componentsToAdd = List<Component>.from(_componentsToAdd);
        _componentsToAdd.clear();
        world.addAll(componentsToAdd);
      }
    } catch (e, stackTrace) {
      // Log error for debugging
      _log('❌ [ERROR] $e');
      _log('📋 [STACK] $stackTrace');
      
      // Try to remove failed components
      _removeFailedComponents();
    }
  }
  
  /// Track frame time and detect freezes
  void _trackFrameTime(double frameTime) {
    // Add to history
    _frameTimeHistory.add(frameTime);
    
    // Keep only last N frames
    if (_frameTimeHistory.length > _maxFrameHistory) {
      _frameTimeHistory.removeAt(0);
    }
    
    // Track in performance monitor
    performanceMonitor.trackFrame(frameTime);
    
    // Detect freeze (frame time > 100ms)
    if (frameTime > 100) {
      _log('⚠️ [PERFORMANCE] Frame freeze detected: ${frameTime.toStringAsFixed(1)}ms');
      _logGameState();
    }
  }
  
  /// Log current game state for debugging
  void _logGameState() {
    _log('📊 [STATE] Evidence: $evidenceCollected, Sanity: ${(stateNotifier.sanity.value * 100).toStringAsFixed(0)}%');
    _log('📊 [STATE] GameOver: $isGameOver, Victory: $isVictory, Paused: $isPaused');
    _log('📊 [STATE] Components: ${world.children.length}');
  }
  
  /// Update state notifier with current game state
  /// Subclasses should override updateStateNotifierExtended() to add their specific state updates
  void _updateStateNotifier() {
    // If initial build not complete, queue updates instead of applying immediately
    if (!_initialBuildComplete) {
      _stateUpdateQueue.enqueue(() {
        _applyStateUpdates();
      });
      return;
    }
    
    // Apply updates immediately if build is complete
    _applyStateUpdates();
  }
  
  /// Apply state updates to notifier
  void _applyStateUpdates() {
    stateNotifier.updateEvidence(evidenceCollected);
    stateNotifier.updateGameOver(isGameOver);
    stateNotifier.updateVictory(isVictory);
    stateNotifier.updatePaused(isPaused);
    
    // Add sanity update if it exists in subclass
    try {
      final dynamicGame = this as dynamic;
      if (dynamicGame.sanitySystem != null) {
        stateNotifier.updateSanity(dynamicGame.sanitySystem.currentSanity);
      }
    } catch (e) {
      // Not all games have sanity
    }

    stateNotifier.updateModoIncognito(modoIncognitoActive);
    stateNotifier.updateFirewall(firewallActive);
    stateNotifier.updateVPN(vpnActive);
    stateNotifier.updateAltAccount(altAccountActive);
    
    // Call subclass-specific updates (for arc-specific state like food inventory, etc.)
    updateStateNotifierExtended();
  }
  
  /// Override this in subclasses to add game-specific state updates
  /// Example: stateNotifier.updateFoodInventory(foodInventory.length);
  void updateStateNotifierExtended() {
    // Override in subclasses
  }
  
  /// Remove components that are in error state
  void _removeFailedComponents() {
    try {
      final componentsToRemove = <Component>[];
      
      // Test each component's validity
      for (final component in world.children) {
        try {
          // Try to access component's mounted state
          // If this throws or returns false, the component is in error state
          if (!component.isMounted) {
            componentsToRemove.add(component);
          }
        } catch (e) {
          _log('🗑️ [CLEANUP] Marking failed component for removal: ${component.runtimeType}');
          componentsToRemove.add(component);
        }
      }
      
      // Remove failed components
      for (final component in componentsToRemove) {
        try {
          component.removeFromParent();
          _log('✅ [CLEANUP] Removed failed component: ${component.runtimeType}');
        } catch (e) {
          _log('⚠️ [CLEANUP] Could not remove component: ${component.runtimeType}');
        }
      }
    } catch (e) {
      _log('❌ [CLEANUP] Error during component cleanup: $e');
    }
  }

  /// Initialize the game - called once on load
  Future<void> initializeGame() async {
    _log('🎮 [INIT] Starting game initialization...');
    _log('🎮 [INIT] Build complete: $_initialBuildComplete');
    
    try {
      // Enable deferred updates during initialization
      stateNotifier.enableDeferredUpdates();
      
      await setupScene();
      await setupPlayer();
      await setupEnemy();
      await setupCollectibles();
      
      _log('✅ [INIT] Game initialization complete');
    } catch (e, stackTrace) {
      _log('❌ [INIT] Error during game initialization: $e');
      _log('📋 [INIT] Stack trace: $stackTrace');
    }
  }

  /// Setup the scene/environment - to be implemented by each arc
  Future<void> setupScene();

  /// Setup the player character - to be implemented by each arc
  Future<void> setupPlayer();

  /// Setup the enemy/enemies - to be implemented by each arc
  Future<void> setupEnemy();

  /// Setup collectibles (evidence, items) - to be implemented by each arc
  Future<void> setupCollectibles();

  /// Update game logic - to be implemented by each arc
  void updateGame(double dt);

  /// Called when game over condition is met
  void onGameOver() {
    if (isGameOver) return;
    isGameOver = true;
    pauseEngine();
    
    // Notify UI to show game over screen
    onGameStateChanged?.call();
  }

  /// Called when victory condition is met
  void onVictory() {
    if (isVictory) return;
    isVictory = true;
    pauseEngine();
    
    // Notify UI to show victory screen
    onGameStateChanged?.call();
  }

  /// Pause the game
  void pauseGame() {
    isPaused = true;
    pauseEngine();
  }

  /// Resume the game
  void resumeGame() {
    isPaused = false;
    resumeEngine();
  }
  
  /// Reset the game to initial state
  Future<void> resetGame() async {
    _log('📍 [BASE] Resetting game flags...');
    isGameOver = false;
    isVictory = false;
    isPaused = false;
    evidenceCollected = 0;
    elapsedTime = 0.0;
    _log('✅ [BASE] Flags reset');
    
    _log('📍 [BASE] Removing all world components...');
    world.removeAll(world.children);
    _log('✅ [BASE] World cleared');
    
    _log('📍 [BASE] Reinitializing game...');
    await initializeGame();
    _log('✅ [BASE] Game reinitialized');
    
    _log('📍 [BASE] Resuming engine...');
    resumeEngine();
    _log('✅ [BASE] Engine resumed');
  }
  
  /// Reset game-specific state - to be overridden by subclasses
  void resetGameState() {
    // Override in subclasses to reset specific game state
  }
  
  /// Activate Modo Incognito item
  void activateModoIncognito() {
    if (modoIncognitoActive) return;
    
    modoIncognitoActive = true;
    modoIncognitoTimer = modoIncognitoDuration;
    _log('Modo Incognito activated for ${modoIncognitoDuration}s');
    onGameStateChanged?.call();
  }
  
  /// Activate Firewall item
  void activateFirewall() {
    if (firewallActive) return;
    
    firewallActive = true;
    firewallTimer = firewallDuration;
    _log('Firewall activated for ${firewallDuration}s');
    onGameStateChanged?.call();
  }
  
  /// Activate VPN item
  void activateVPN() {
    if (vpnActive) return;
    
    vpnActive = true;
    vpnTimer = vpnDuration;
    _log('VPN activated for ${vpnDuration}s');
    onGameStateChanged?.call();
  }
  
  /// Activate Alt Account item (slows enemies)
  void activateAltAccount() {
    if (altAccountActive) return;
    
    altAccountActive = true;
    altAccountTimer = altAccountDuration;
    _log('Alt Account activated for ${altAccountDuration}s - Enemies slowed!');
    onGameStateChanged?.call();
  }
  
  /// Marks the game as disposing. Prevents attach checks from throwing during disposal.
  void markAsDisposing() {
    _isDisposing = true;
    debugPrint('⚙️ [DISPOSING] Game instance $_instanceId marked as disposing');
  }
  
  /// Update item timers
  void updateItemTimers(double dt) {
    // Update Modo Incognito
    if (modoIncognitoActive) {
      modoIncognitoTimer -= dt;
        if (modoIncognitoTimer <= 0) {
          modoIncognitoActive = false;
          modoIncognitoTimer = 0;
          _log('Modo Incognito expired');
          onGameStateChanged?.call();
        }
    }
    
    // Update Firewall
    if (firewallActive) {
      firewallTimer -= dt;
        if (firewallTimer <= 0) {
          firewallActive = false;
          firewallTimer = 0;
          _log('Firewall expired');
          onGameStateChanged?.call();
        }
    }
    
    // Update VPN
    if (vpnActive) {
      vpnTimer -= dt;
        if (vpnTimer <= 0) {
          vpnActive = false;
          vpnTimer = 0;
          _log('VPN expired');
          onGameStateChanged?.call();
        }
    }
    
    // Update Alt Account
    if (altAccountActive) {
      altAccountTimer -= dt;
        if (altAccountTimer <= 0) {
          altAccountActive = false;
          altAccountTimer = 0;
          _log('Alt Account expired');
          onGameStateChanged?.call();
        }
    }
  }
  
  /// Set player skin from inventory
  void setPlayerSkin(String? skinId) {
    equippedPlayerSkin = skinId;
    _log('🎨 Game: Player skin set to ${skinId ?? "default"}');
  }
  
  /// Set enemy skin from inventory
  void setEnemySkin(String? skinId) {
    equippedEnemySkin = skinId;
    _log('🎨 Game: Enemy skin set to ${skinId ?? "default"}');
  }
  
  /// Set available consumables from inventory
  void setAvailableConsumables(Map<String, int> consumables) {
    availableConsumables = Map.from(consumables);
    _log('🎒 Game: Available consumables loaded: $availableConsumables');
  }
  
  /// Set the fragments provider (called from screen)
  void setFragmentsProvider(FragmentsProvider provider) {
    _fragmentsProvider = provider;
    _log('✅ [FRAGMENT] FragmentsProvider set for game');
  }
  
  /// Save fragment directly using provider reference
  Future<void> saveFragment(String arcId, int fragmentNumber) async {
    if (_fragmentsProvider == null) {
      _log('❌ [FRAGMENT] FragmentsProvider not set - cannot save fragment');
      return;
    }
    
    try {
      // Normalize arc ID to standard format
      final normalizedArcId = _normalizeArcId(arcId);
      
      _log('💾 [FRAGMENT] Saving: $normalizedArcId - Fragment $fragmentNumber');
      await _fragmentsProvider!.unlockFragment(normalizedArcId, fragmentNumber);
      _log('✅ [FRAGMENT] Fragment saved successfully');
    } catch (e, stackTrace) {
      _log('❌ [FRAGMENT] Error saving fragment: $e');
      _log('📋 [FRAGMENT] Stack trace: $stackTrace');
    }
  }
  
  /// Normalize arc ID to standard format
  String _normalizeArcId(String arcId) {
    switch (arcId.toLowerCase()) {
      case 'gluttony':
      case 'gula':
        return 'arc_1_gula';
      case 'greed':
      case 'avaricia':
        return 'arc_2_greed';
      case 'envy':
      case 'envidia':
        return 'arc_3_envy';
      case 'lust':
      case 'lujuria':
        return 'arc_4_lust';
      case 'pride':
      case 'orgullo':
        return 'arc_5_pride';
      case 'sloth':
      case 'pereza':
        return 'arc_6_sloth';
      case 'wrath':
      case 'ira':
        return 'arc_7_wrath';
      default:
        // Already in standard format or unknown
        return arcId;
    }
  }
  
  /// Safely add a component to the world
  /// This queues the component to be added after the current update cycle
  void safeAdd(Component component) {
    _componentsToAdd.add(component);
  }

  /// Safely add multiple components to the world
  void safeAddAll(List<Component> components) {
    _componentsToAdd.addAll(components);
  }
}
