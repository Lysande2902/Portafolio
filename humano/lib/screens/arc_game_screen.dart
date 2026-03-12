import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Arcos fusionados
import 'package:humano/game/hack_system/mind_hack_game.dart';
import 'package:humano/game/hack_system/puzzles/frequency_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/sequence_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/glitch_tapper_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/mirror_fragments_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/network_web_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/vanity_filter_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/unboxing_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/transaction_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/aperture_scan_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/audio_spectrum_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/dead_task_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/thermal_containment_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/expiation_syntax_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/binary_shift_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/circular_sync_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/symmetry_corrupt_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/comment_spam_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/notification_detox_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/conveyor_belt_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/ledger_balance_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/unboxing_infinite_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/overexposure_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/echo_isolation_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/ego_syntax_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/thermal_containment_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/missed_call_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/shadow_corridor_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/static_clear_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/guilt_sentence_puzzle.dart';
import 'package:humano/game/hack_system/puzzles/final_heartbeat_puzzle.dart';







// VirtualJoystick removed
import 'package:humano/game/ui/game_hud.dart';
import 'package:humano/game/ui/arc_victory_cinematic.dart';
import 'package:humano/game/ui/game_over_screen.dart';
import 'package:humano/game/ui/pause_menu.dart';
import 'package:humano/game/ui/dialogue_overlay.dart';
import 'package:humano/game/ui/evidence_collected_notification.dart';
import 'package:humano/providers/arc_progress_provider.dart';
import 'package:humano/providers/evidence_provider.dart';
import 'package:humano/providers/store_provider.dart';
import 'package:humano/providers/user_data_provider.dart';
import 'package:humano/providers/notifications_provider.dart';
import 'package:humano/providers/auth_provider.dart';
import 'package:humano/data/providers/puzzle_data_provider.dart';
import 'package:humano/data/providers/fragments_provider.dart';
import 'package:humano/game/core/utils/game_instance_factory.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/ui/shattered_screen_overlay.dart';
import 'package:humano/screens/arc_outro_screen.dart';
import 'package:vibration/vibration.dart';
import 'dart:async' as async;

class ArcGameScreen extends StatefulWidget {
  final String arcId;


  const ArcGameScreen({
    super.key,
    required this.arcId,
  });

  @override
  State<ArcGameScreen> createState() => _ArcGameScreenState();
}

class _ArcGameScreenState extends State<ArcGameScreen> {
  late dynamic game; // Can be GluttonyArcGame, GreedArcGame, etc.
  bool _isDisposing = false;
  bool _isInitialized = false;
  
  // Clave FIJA para el GameWidget - se crea una vez y nunca cambia.
  // Esto evita que Flutter destruya y recree el GameWidget en cada setState().
  late final GlobalKey _gameWidgetKey;
  
  Map<String, int> availableItems = {};
  bool showPauseMenu = false;
  bool _showEvidenceNotification = false;
  int _currentEvidenceCount = 0;
  int _totalFollowersEarned = 0; // Track followers for the final stats screen
  bool _outroShown = false; 
  bool _progressSaved = false; 


  @override
  void initState() {
    super.initState();
    
    debugPrint('═══════════════════════════════════');
    debugPrint('🎮 [INIT] Initializing ArcGameScreen for ${widget.arcId}');
    debugPrint('🎮 [INIT] Creating game instance');

    // Get protocols from inventory
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final hasVPN = userProvider.inventory.ownsItem('protocol_vpn');
    final hasFirewall = userProvider.inventory.ownsItem('protocol_firewall');
    
    game = _createGameInstance(hasVPN: hasVPN, hasFirewall: hasFirewall);
    _gameWidgetKey = GlobalKey(debugLabel: 'GameWidget_${widget.arcId}');
    
    // Connect multiplayer hooks and UI callbacks
    if (game is BaseArcGame) {
      final baseGame = game as BaseArcGame;
      
      // Evidence collection callback - triggers UI update
      baseGame.onEvidenceCollectedChanged = () {
        if (mounted && !_isDisposing) {
          final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
          // Calculate absolute fragment index based on initial phase + collected count
          final int fragmentIndex = (game.evidenceCollected as int);
          
          final isAlreadyUnlocked = fragmentsProvider.isFragmentUnlocked(widget.arcId, fragmentIndex);
          
          if (!isAlreadyUnlocked) {
            // ONLY show if it's a NEW discovery
            setState(() {
              _showEvidenceNotification = true;
              _currentEvidenceCount = fragmentIndex;
            });
            
            // Hide notification after 2.5 seconds
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (mounted) {
                setState(() {
                  _showEvidenceNotification = false;
                });
              }
            });
          } else {
            // If already unlocked, just update silent state or log
            debugPrint('🔍 [FRAGMENTS] Fragment $fragmentIndex already unlocked - skipping notification');
          }
        }
      };
      
      // General game state callback
      baseGame.onGameStateChanged = () {
        if (mounted && !_isDisposing) {
          // Mantener orientación vertical siempre (las estadísticas también son verticales)
          setState(() {
            // Force UI rebuild for game state changes
          });
        }
      };

      // Connect reward system to user data provider
      baseGame.onRewardGained = (amount) {
        if (mounted && !_isDisposing) {
          final userProvider = Provider.of<UserDataProvider>(context, listen: false);
          userProvider.addCoins(amount);
          
          setState(() {
            _totalFollowersEarned += amount;
            // No usamos _activeFeedbackItem para evitar el mensaje de "ITEM USADO"
            // Se mostrará una notificación flotante más limpia
          });
          
          // Show a cleaner floating notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+$amount SEGUIDORES GANADOS', 
                style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontWeight: FontWeight.bold)),
              backgroundColor: Colors.black.withOpacity(0.8),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              width: 250,
            ),
          );
        }
      };
    }
    
    debugPrint('═══════════════════════════════════');
    debugPrint('✅ [INIT] Game created: ${game.hashCode}, instance: ${game.instanceId}');
    debugPrint('═══════════════════════════════════');
    
    // FORCE PORTRAIT para todo el juego (puzzles, estadísticas, etc)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    _isInitialized = true;
    
    // Start heartbeat effect - Removido por peticiòn del usuario
    // _startHeartbeatEffect();
  }
  
  async.Timer? _heartbeatTimer;

  void _startHeartbeatEffect() {
    _heartbeatTimer = async.Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      if (!mounted || !_isInitialized || showPauseMenu) return;
      
      try {
        final dynamicGame = game as dynamic;
        if (dynamicGame.sanitySystem != null) {
          final sanity = dynamicGame.sanitySystem.currentSanity as double;
          
          if (sanity < 0.4) {
            // Low sanity - heartbeat vibration
            bool hasVibrator = await Vibration.hasVibrator() ?? false;
            if (hasVibrator) {
              // Faster beat as sanity drops
              if (sanity < 0.2) {
                // Double beat
                Vibration.vibrate(pattern: [0, 50, 100, 50]);
              } else {
                Vibration.vibrate(duration: 50);
              }
            }
          }
        }
      } catch (e) {
        // Ignore
      }
    });
  }

  /// Create a fresh game instance using the factory
  /// This ensures each navigation creates a unique instance
  dynamic _createGameInstance({bool hasVPN = false, bool hasFirewall = false}) {
    debugPrint('🛠️ [GAME_FACTORY] Creating MindHackGame (VPN: $hasVPN, Firewall: $hasFirewall)');
    
    switch (widget.arcId) {
      // Arco 0
      case 'arc_0_inicio':
        return GameInstanceFactory.createGame(() => MindHackGame(
          hasVPN: hasVPN,
          hasFirewall: hasFirewall,
          puzzleFactories: [
            (onComplete, onFail, diff) => SequencePuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => FrequencyPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => BinaryShiftPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => CircularSyncPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => ExpiationSyntaxPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
          ],
        ));
      // Arcos fusionados (nuevos)
      case 'arc_1_envidia_lujuria':
        return GameInstanceFactory.createGame(() => MindHackGame(
          hasVPN: hasVPN,
          hasFirewall: hasFirewall,
          puzzleFactories: [
            (onComplete, onFail, diff) => CommentSpamPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => NotificationDetoxPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => VanityFilterPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
          ],
        ));

      case 'arc_2_consumo_codicia':
        return GameInstanceFactory.createGame(() => MindHackGame(
          hasVPN: hasVPN,
          hasFirewall: hasFirewall,
          puzzleFactories: [
            (onComplete, onFail, diff) => ConveyorBeltPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => LedgerBalancePuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => UnboxingInfinitePuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
          ],
        ));


      case 'arc_3_soberbia_pereza':
        return GameInstanceFactory.createGame(() => MindHackGame(
          hasVPN: hasVPN,
          hasFirewall: hasFirewall,
          puzzleFactories: [
            (onComplete, onFail, diff) => OverexposurePuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => EchoIsolationPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => EgoSyntaxPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
          ],
        ));

      case 'arc_4_ira':
        return GameInstanceFactory.createGame(() => MindHackGame(
          hasVPN: hasVPN,
          hasFirewall: hasFirewall,
          puzzleFactories: [
            (onComplete, onFail, diff) => ThermalContainmentPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => MissedCallPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => StaticClearPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => GuiltSentencePuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
            (onComplete, onFail, diff) => FinalHeartbeatPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
          ],
        ));




      
      default:
        debugPrint('⚠️ Unknown arc ID: ${widget.arcId}, defaulting to Arc 1');
        return GameInstanceFactory.createGame(() => MindHackGame(
          hasVPN: hasVPN,
          hasFirewall: hasFirewall,
          puzzleFactories: [
             (onComplete, onFail, diff) => FrequencyPuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
             (onComplete, onFail, diff) => SequencePuzzle(onComplete: onComplete, onFail: onFail, difficulty: diff),
          ],
        ));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    debugPrint('🔄 [DID_CHANGE_DEPS] Called - setting up providers');
    
    // Only setup providers once
    if (_isInitialized && !_isDisposing) {
      // Setup providers (this is safe to call multiple times)
      game.buildContext = context;
      final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
      game.setFragmentsProvider(fragmentsProvider);
      _loadInventory();
      
      debugPrint('✅ [DID_CHANGE_DEPS] Providers setup complete');
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    debugPrint('═══════════════════════════════════');
    debugPrint('🗑️ [SCREEN] Starting disposal for ${widget.arcId}');
    debugPrint('   Game hashCode: ${game?.hashCode}');
    debugPrint('   Game instance: ${game?.instanceId}');
    debugPrint('═══════════════════════════════════');

    _isDisposing = true;

    // Mantener orientación vertical al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Mark the game as disposing to allow safe re-attachment later
    try {
      if (game != null) {
        game.markAsDisposing();
      }
    } catch (e) {
      debugPrint('⚠️ [SCREEN] Error marking game as disposing: $e');
    }

    try {
      if (game != null) {
        debugPrint('⏸️ [SCREEN] Pausing game engine');
        game.pauseEngine();

        // Explicitly call onRemove() to trigger Flame's cleanup
        debugPrint('🧹 [SCREEN] Calling game.onRemove()');
        game.onRemove();

        // Clear reference to allow garbage collection
        debugPrint('🗑️ [SCREEN] Clearing game reference');
        game = null;
      }
    } catch (e) {
      debugPrint('⚠️ [SCREEN] Error disposing game: $e');
    }

    _isInitialized = false;

    // Mantener orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    super.dispose();
    debugPrint('✅ [SCREEN] Disposal complete');
  }

  void _loadInventory() {
    // El juego usa puzzles MindHack procedurales (terminal ASCII)
    // No hay sprites de jugador ni enemigos que requieran skins
    // No hay sistema de items/consumibles
    availableItems = {};
    debugPrint('🎮 Arc Game initialized without items (MindHack puzzles only)');
  }

  // Item system removed - no consumables in MindHack gameplay

  // Throw/Physical interaction methods removed (not used in MindHackGame)
  
  Future<void> _saveProgress() async {
    try {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final arcProgressProvider = Provider.of<ArcProgressProvider>(context, listen: false);
      final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);

      String arcPrefix;
      switch (widget.arcId) {
        case 'arc_0_inicio':
          arcPrefix = 'inicio';
          break;
        case 'arc_1_envidia_lujuria':
          arcPrefix = 'envidia_lujuria';
          break;
        case 'arc_2_consumo_codicia':
          arcPrefix = 'consumo_codicia';
          break;
        case 'arc_3_soberbia_pereza':
          arcPrefix = 'soberbia_pereza';
          break;
        case 'arc_4_ira':
          arcPrefix = 'ira';
          break;
        default:
          arcPrefix = 'unknown';
      }

      // Desbloquear TODAS las evidencias recolectadas
      final evidenceProvider = Provider.of<EvidenceProvider>(context, listen: false);
      for (int i = 1; i <= game.evidenceCollected; i++) {
        final evidenceId = '${arcPrefix}_evidence_$i';
        await evidenceProvider.unlockEvidence(evidenceId, widget.arcId);
        debugPrint('🔓 [SAVE PROGRESS] Evidencia desbloqueada: $evidenceId');
      }
      
      final List<String> collectedEvidenceIds = List.generate(
        game.evidenceCollected,
        (i) => '${arcPrefix}_evidence_${i + 1}'
      );
      
      debugPrint('📊 [SAVE PROGRESS] Total evidencias desbloqueadas: ${collectedEvidenceIds.length}');

      final puzzleDataProvider = Provider.of<PuzzleDataProvider>(context, listen: false);
      String puzzleEvidenceId;
      switch (widget.arcId) {
        case 'arc_1_gula':
          puzzleEvidenceId = 'gluttony_evidence';
          break;
        case 'arc_2_greed':
          puzzleEvidenceId = 'greed_evidence';
          break;
        case 'arc_0_inicio':
          puzzleEvidenceId = 'inicio_evidence';
          break;
        case 'arc_3_envy':
          puzzleEvidenceId = 'envy_evidence';
          break;
        default:
          puzzleEvidenceId = 'gluttony_evidence';
      }
      
      for (int i = 1; i <= game.evidenceCollected; i++) {
        try {
          await puzzleDataProvider.collectFragment(puzzleEvidenceId, i);
          debugPrint('✅ [SAVE PROGRESS] Fragmento $i de $puzzleEvidenceId recolectado');
        } catch (e) {
          debugPrint('⚠️ [SAVE PROGRESS] Error recolectando fragmento $i: $e');
        }
      }
      
      // CRÍTICO: Desbloquear fragmentos en FragmentsProvider
      debugPrint('═══════════════════════════════════');
      debugPrint('🔓 [SAVE PROGRESS] Guardando fragmentos');
      debugPrint('   Arc ID: ${widget.arcId}');
      debugPrint('   Evidencias recolectadas: ${game.evidenceCollected}');
      debugPrint('   Evidencias desbloqueadas: ${collectedEvidenceIds.length}');
      debugPrint('   FragmentsProvider hashCode: ${fragmentsProvider.hashCode}');
      
      try {
        await fragmentsProvider.unlockFragmentsForArcProgress(widget.arcId, game.evidenceCollected);
        
        debugPrint('✅ [SAVE PROGRESS] Fragmentos guardados');
        debugPrint('   Fragmentos actuales para ${widget.arcId}: ${fragmentsProvider.getFragmentsForArc(widget.arcId)}');
        debugPrint('   Total fragmentos: ${fragmentsProvider.totalUnlockedFragments}');
      } catch (e) {
        debugPrint('⚠️ [SAVE PROGRESS] Error guardando fragmentos: $e');
      }
      debugPrint('═══════════════════════════════════');

      // Achievements system removed - arc completion tracked via arcProgressProvider
      debugPrint('✅ [SAVE PROGRESS] Arc progress saved');

      final bool isArc0 = widget.arcId == 'arc_0_inicio';
      int baseReward = isArc0 ? 1000 : 250;
      int fragmentBonus = game.evidenceCollected * (isArc0 ? 200 : 50);
      int totalCoins = baseReward + fragmentBonus;
      
      if (userDataProvider.hasActiveBattlePass) {
        debugPrint('🎖️ [SAVE PROGRESS] Aplicando boost de Battle Pass');
        totalCoins = (totalCoins * 1.15).round();
        // NOTE: Battle Pass level progression is now independent of arc completion
        // Levels are incremented through other game activities, not here
      }
      
      await arcProgressProvider.completeArc(widget.arcId, collectedEvidenceIds);
      await storeProvider.addCoins(totalCoins);
      
      // Desbloquear notificaciones según el arco completado
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        int arcNumber = _getArcNumber(widget.arcId);
        debugPrint('🔔 [SAVE PROGRESS] Desbloqueando notificaciones para arco $arcNumber');
        await notificationsProvider.unlockNotificationsForArc(arcNumber, authProvider.currentUser!.uid);
        debugPrint('✅ [SAVE PROGRESS] Notificaciones desbloqueadas');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [SAVE PROGRESS] ERROR: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo guardar el progreso: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 [BUILD] build() called - game: ${game?.hashCode}, _isDisposing: $_isDisposing');
    
    // If disposing or game not ready, show loading
    if (_isDisposing || !_isInitialized) {
      debugPrint('⏳ [BUILD] Showing loading screen');
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    debugPrint('✅ [BUILD] Rendering game screen with game: ${game.hashCode}');
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game layer - stable key to prevent destroying the game on rebuilds
          _GameLayer(
            key: ValueKey(game.hashCode),
            game: game,
            gameKey: _gameWidgetKey,
          ),

          
          // Show HUD for all arcs
          _buildGameHUD(),

          // Virtual Joystick removed - replaced by direct touch interaction in puzzles

          // Evidence Collection Notification
          if (_showEvidenceNotification)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: EvidenceCollectedNotification(
                currentCount: _currentEvidenceCount,
                totalCount: _getTotalEvidenceForArc(),
                onComplete: () {
                  if (mounted) {
                    setState(() {
                      _showEvidenceNotification = false;
                    });
                  }
                },
              ),
            ),

          if (game.isVictory)
            Positioned.fill(child: _buildVictoryScreen()),
          if (game.isGameOver)
            Positioned.fill(child: _buildGameOverScreen()),
          
          // Shattered Screen Overlay - Disabled for MindHack arcs for cleaner terminal UI
          // Shattered Screen Overlay - Disabled for all MindHack arcs for cleaner terminal UI
          if (_isInitialized && !widget.arcId.contains('arc'))
            ShatteredScreenOverlay(
              evidenceCollected: game.evidenceCollected,
              totalEvidence: _getTotalEvidenceForArc(),
            ),
          
          if (showPauseMenu)
            PauseMenu(
              onResume: () {
                setState(() {
                  showPauseMenu = false;
                  game.resumeGame();
                });
              },
              onExit: () {
                Navigator.pop(context);
              },
            ),

          // Dialogue Overlay
          if (_isInitialized && game is BaseArcGame)
            ValueListenableBuilder<String?>(
              valueListenable: (game as BaseArcGame).stateNotifier.dialogueText,
              builder: (context, text, child) {
                if (text == null) return const SizedBox.shrink();
                
                return ValueListenableBuilder<String?>(
                  valueListenable: (game as BaseArcGame).stateNotifier.dialogueSpeaker,
                  builder: (context, speaker, child) {
                    return DialogueOverlay(
                      speakerName: speaker ?? '???',
                      text: text,
                      onDismiss: () {
                        (game as BaseArcGame).stateNotifier.updateDialogue(null, null);
                        game.resumeGame();
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
  
  // Hiding and physical interaction methods removed

  Widget _buildGameHUD() {
    if (_isDisposing || !_isInitialized) return const SizedBox.shrink();
    
    try {
      final dynamicGame = game as dynamic;
      
      final bool supportsHiding = false; // Terminal hacking doesn't use physical hiding
      // Variable kept for potential future use

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: ValueListenableBuilder<double>(
          valueListenable: dynamicGame.sanitySystem.sanityNotifier,
          builder: (context, currentSanity, _) {
            final userProvider = Provider.of<UserDataProvider>(context, listen: false);
            final hasVPN = userProvider.inventory.ownsItem('protocol_vpn');
            final hasFirewall = userProvider.inventory.ownsItem('protocol_firewall');

            return GameHUD(
              sanity: currentSanity,
              evidenceCollected: game.evidenceCollected ?? 0,
              totalEvidence: _getTotalEvidenceForArc(),
              onPause: null, // Pausa desactivada
              showHideButton: false,
              onHide: null,
              showSanityBar: game is! MindHackGame,
              vpnActive: hasVPN,
              firewallActive: hasFirewall,
            );
          }
        ),
      );
    } catch (e) {
      debugPrint('⚠️ [HUD] Error building HUD: $e');
      return const Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: SizedBox.shrink(),
      );
    }
  }

  // Throw/Physical buttons removed
  
  String _getArcTitle(String arcId) {
    switch (arcId) {
      case 'arc_0_inicio':
        return 'EL INICIO';
      case 'arc_1_envidia_lujuria':
        return 'ENVIDIA Y LUJURIA';
      case 'arc_2_consumo_codicia':
        return 'CONSUMO Y CODICIA';
      case 'arc_3_soberbia_pereza':
        return 'SOBERBIA Y PEREZA';
      case 'arc_4_ira':
        return 'IRA';
      default:
        return 'PROT. ??';

    }
  }
  
  int _getArcNumber(String arcId) {
    if (arcId.contains('arc_0')) return 0;
    if (arcId.contains('arc_1')) return 1;
    if (arcId.contains('arc_2')) return 2;
    if (arcId.contains('arc_3')) return 3;
    if (arcId.contains('arc_4')) return 4;
    return 0;
  }
  
  int _getTotalEvidenceForArc() {
    try {
      final provider = Provider.of<FragmentsProvider>(context, listen: false);
      final fragments = provider.getFragmentsWithStatus(widget.arcId);
      return fragments.length;
    } catch (e) {
      debugPrint('⚠️ [STATS] Error getting fragments count: $e');
      return 5; // Default fallback
    }
  }
  
  Widget _buildVictoryScreen() {
    if (!game.isVictory) return const SizedBox.shrink();
    
    // Si aún no hemos mostrado la cinemática de cierre (Outro), la mostramos primero
    if (!_outroShown) {
      return ArcOutroScreen(
        arcId: widget.arcId,
        onComplete: () {
          if (mounted) {
            setState(() {
              _outroShown = true;
            });
          }
        },
      );
    }

    // Una vez completado el Outro, procedemos a la Victoria (Cinemática + Estadísticas)
    final Map<String, dynamic> gameStats = {
      'evidenceCollected': game.evidenceCollected,
      'totalEvidence': _getTotalEvidenceForArc(),
      'playTime': game.playTime,
      'followersEarned': _totalFollowersEarned,
      'sanity': game.sanitySystem.currentSanity,
    };
    
    // Guardar progreso automáticamente en cuanto se detecta la victoria (Safeguard)
    if (!_progressSaved) {
      _progressSaved = true;
      _saveProgress();
    }

    return ArcVictoryCinematic(
      arcId: widget.arcId,
      arcTitle: _getArcTitle(widget.arcId),
      gameStats: gameStats,
      onComplete: () async {
        // El saveProgress aquí ya es redundante pero se deja como backup ligero o por si falló el anterior
        await _saveProgress();
        if (mounted) {
          // Regresar al menú principal una vez finalizado todo el flujo
          Navigator.pop(context);
        }
      },
    );
  }

  


  
  Widget _buildGameOverScreen() {
    if (!game.isGameOver) return const SizedBox.shrink();
    
    return GameOverScreen(
      arcId: widget.arcId,
      onRetry: () async {
        if (mounted) {
          final userProvider = Provider.of<UserDataProvider>(context, listen: false);
          final hasVPN = userProvider.inventory.ownsItem('protocol_vpn');
          final hasFirewall = userProvider.inventory.ownsItem('protocol_firewall');

          setState(() {
            game = _createGameInstance(hasVPN: hasVPN, hasFirewall: hasFirewall);
            game.buildContext = context;
            final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
            game.setFragmentsProvider(fragmentsProvider);
            _loadInventory();
            
            if (game is BaseArcGame) {
              final baseGame = game as BaseArcGame;
              baseGame.onEvidenceCollectedChanged = () {
                if (mounted && !_isDisposing) {
                  // Verify if this specific fragment was ALREADY unlocked previously
                  final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
                  // Calculate absolute fragment index based on collected count
                  final int fragmentIndex = (baseGame.evidenceCollected as int);
                  
                  final isAlreadyUnlocked = fragmentsProvider.isFragmentUnlocked(widget.arcId, fragmentIndex);
                  
                  if (!isAlreadyUnlocked) {
                    setState(() {
                      _showEvidenceNotification = true;
                      _currentEvidenceCount = fragmentIndex;
                    });
                    
                    Future.delayed(const Duration(milliseconds: 2500), () {
                      if (mounted) {
                        setState(() {
                          _showEvidenceNotification = false;
                        });
                      }
                    });
                  } else {
                    debugPrint('🔍 [FRAGMENTS] Fragment $fragmentIndex already unlocked - skipping notification');
                    setState(() {});
                  }
                }
              };
              baseGame.onGameStateChanged = () {
                if (mounted && !_isDisposing) {
                  setState(() {});
                }
              };
            }
          });
        }
      },
      onExit: () {
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  // Algorithm effects and vibration removed - not used in MindHack gameplay
}

class _GameLayer extends StatefulWidget {
  final dynamic game;
  final GlobalKey gameKey;
  
  const _GameLayer({
    super.key,
    required this.game,
    required this.gameKey,
  });

  @override
  State<_GameLayer> createState() => _GameLayerState();
}

class _GameLayerState extends State<_GameLayer> {
  @override
  Widget build(BuildContext context) {
    if (widget.game == null) return const SizedBox.shrink();
    
    // Usamos la clave estable que viene del padre (creada una sola vez en initState)
    return GameWidget(
      key: widget.gameKey,
      game: widget.game!,
    );
  }
}
