import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/core/systems/sanity_system.dart';
import 'package:humano/game/puzzle/effects/sound_manager.dart';
import 'mind_hack_puzzle.dart';
import 'mind_hack_tutorial_layer.dart';

/// MindHackGame - A non-sprite, non-map based game for Arcs
/// Focused on terminal-style hacking puzzles.
class MindHackGame extends BaseArcGame {
  final List<MindHackPuzzle Function(VoidCallback onComplete, VoidCallback onFail, int difficulty)> puzzleFactories;
  int _currentPuzzleIndex = 0;
  MindHackPuzzle? _currentPuzzle;

  
  // Systems
  final SanitySystem sanitySystem = SanitySystem();
  final ValueNotifier<int> phaseNotifier = ValueNotifier<int>(0);
  
  // Per-puzzle timer - initialized to safe value to prevent immediate failure loop
  double puzzleTimer = 99.0; 
  bool _isPausedForTutorial = false;
  double get maxPuzzleTime => (35.0 - (_currentPuzzleIndex * 3.0)).clamp(15.0, 40.0); // 35s, 32s, 29s... harder each time

  // Penalty drain
  double _penaltyDrainRemaining = 0.0;
  final double _penaltyDamageTotal = 12.0; // Total damage for one error
  
  // Glitch effect
  double _glitchEffectTimer = 0.0;
  
  // Protocols state
  bool hasVPN = false;
  bool hasFirewall = false;
  
  MindHackGame({
    required this.puzzleFactories, 
    this.hasVPN = false,
    this.hasFirewall = false,
  }) : _currentPuzzleIndex = 0;



  @override
  Future<void> onLoad() async {
    debugPrint('📦 [LOAD] VanityFilterPuzzle loading...');
    await super.onLoad();
    // For terminal puzzles, we want (0,0) to be top-left
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero(); // Reset any camera movements
  }

  @override
  Future<void> setupScene() async {
    // No physics scene needed
  }

  @override
  Future<void> setupPlayer() async {
    // No player sprite
  }

  @override
  Future<void> setupEnemy() async {
    // Enemy is the "Firewall" or "System Integrity"
  }

  @override
  Future<void> setupCollectibles() async {
    _loadNextPuzzle();
  }

  Future<void> _loadNextPuzzle() async {
    debugPrint('🧩 [PHASE] Iniciando carga de puzzle index: $_currentPuzzleIndex');
    
    if (_currentPuzzleIndex < puzzleFactories.length) {
      _isTransitioning = true;

      // Guardamos referencia al puzzle anterior para eliminarlo directamente
      final oldPuzzle = _currentPuzzle;
      _currentPuzzle = null;

      // Asegurar cámara en el origen
      camera.viewfinder.anchor = Anchor.topLeft;
      camera.viewfinder.position = Vector2.zero();

      // 1. Eliminar el puzzle anterior directamente por referencia (más confiable que removeAll)
      if (oldPuzzle != null && oldPuzzle.isMounted) {
        oldPuzzle.removeFromParent();
        debugPrint('🧩 [PHASE] Puzzle anterior eliminado por referencia: ${oldPuzzle.runtimeType}');
      }
      // Limpieza adicional de cualquier componente huérfano
      world.children.whereType<MindHackPuzzle>().toList().forEach((p) => p.removeFromParent());
      world.removeAll(world.children);

      // 2. ESPERAR a que Flame procese la cola de eliminaciones antes de añadir el nuevo
      // Sin este delay, ambos puzzles coexisten durante un tick y el viejo sigue visible.
      await Future.delayed(const Duration(milliseconds: 50));

      debugPrint('🧩 [PHASE] Mundo limpio. Añadiendo puzzle ${_currentPuzzleIndex + 1}...');
      
      // 3. Crear y añadir el nuevo puzzle
      final puzzle = puzzleFactories[_currentPuzzleIndex](
        _onPuzzleComplete,
        _onPuzzleFail,
        _currentPuzzleIndex,
      );
      
    _currentPuzzle = puzzle;
    world.add(puzzle);
    phaseNotifier.value = _currentPuzzleIndex;

    // --- AGREGAR TUTORIAL PARA ESTE PUZZLE ---
    // Pausar timer del puzzle mientras mostramos tutorial
    _isPausedForTutorial = true;
    final tutorial = MindHackTutorialLayer(
      title: puzzle.title,
      instruction: puzzle.instruction,
      showUIHints: _currentPuzzleIndex == 0, // Solo en el primer minijuego
      onDismiss: () {
        _isPausedForTutorial = false;
        debugPrint('🧩 [TUTORIAL] Dismissed. Start!');
      },
    );
    world.add(tutorial);
    // -----------------------------------------

    debugPrint('🧩 [PHASE] ${_currentPuzzleIndex + 1}/${puzzleFactories.length} [${puzzle.runtimeType}] INYECTADO');

      
      // Reiniciar estado
      puzzleTimer = maxPuzzleTime; 
      _penaltyDrainRemaining = 0.0; 
      
      onGameStateChanged?.call();
      
      Future.delayed(const Duration(milliseconds: 150), () {
        _isTransitioning = false;
        debugPrint('🧩 [PHASE] Lock liberado');
      });

    } else {
      debugPrint('🧩 [PHASE] Todas las fases completadas. Victoria!');
      onVictory();
      _isTransitioning = false;
    }
    
    // Iniciar sonido ambiental de servidores si es la primera fase
    if (_currentPuzzleIndex == 0) {
      SoundManager().playAmbientSound();
    }
  }





  bool _isTransitioning = false;

  void _onPuzzleComplete() {
    debugPrint('🚩 [EVENT] Puzzle complete signal received for phase $_currentPuzzleIndex');
    if (_isTransitioning || isGameOver || isVictory) {
      debugPrint('🚫 [EVENT] Signal ignored (Transitioning: $_isTransitioning, GameOver: $isGameOver, Victory: $isVictory)');
      return;
    }
    _isTransitioning = true;

    evidenceCollected++;
    SoundManager().playCompletionSound();
    SoundManager().successHaptic();
    
    // STOP THE CLOCK during transition
    puzzleTimer = 999.0;
    
    // Clear failure glitches
    _glitchEffectTimer = 0;
    _penaltyDrainRemaining = 0;
    
    // 1. Recompensa de Integridad (Diferenciada)
    double healAmount = 15.0; // Base reward
    if (_currentPuzzleIndex == 0) healAmount = 10.0;
    if (_currentPuzzleIndex == 1) healAmount = 15.0;
    if (_currentPuzzleIndex == 2) healAmount = 20.0;
    if (_currentPuzzleIndex == 3) healAmount = 25.0;
    if (_currentPuzzleIndex == 4) healAmount = 40.0; 
    sanitySystem.heal(healAmount); 

    // 2. Recompensa de SEGUIDORES (Monedas)
    int followerReward = 50; // Base
    if (_currentPuzzleIndex == 0) followerReward = 50;
    if (_currentPuzzleIndex == 1) followerReward = 100;
    if (_currentPuzzleIndex == 2) followerReward = 150;
    if (_currentPuzzleIndex == 3) followerReward = 200;
    if (_currentPuzzleIndex == 4) followerReward = 500; // Gran premio final de Arco 0
    onRewardGained?.call(followerReward);
    
    // Advance index
    _currentPuzzleIndex++;

    // Verificamos si realmente hay más puzzles
    if (_currentPuzzleIndex < puzzleFactories.length) {
      debugPrint('🧩 [PHASE] Advancing to puzzle index $_currentPuzzleIndex');
      _loadNextPuzzle();
    } else {
      debugPrint('🏆 [PHASE] Final phase reached. Victory!');
      onVictory();
      _isTransitioning = false;
      return;
    }
    
    // Notify about evidence after loading starts
    onEvidenceCollectedChanged?.call();
    
    // Reset transition lock after a shorter delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _isTransitioning = false;
      debugPrint('🧩 [PHASE] Lock de transición liberado');
    });
  }


  void _onPuzzleFail() {
    if (_isTransitioning || isGameOver || isVictory) return;
    
    debugPrint('❌ [EVENT] Puzzle fail signal received for phase $_currentPuzzleIndex');
    // Play error sound and trigger heavy haptic
    SoundManager().playErrorSound();
    SoundManager().errorHaptic();
    
    // Trigger visual glitch for half a second
    _glitchEffectTimer = 0.5;
    
    // Iniciamos un drenaje lento por error (vaciado progresivo)
    _penaltyDrainRemaining = 2.0; 
    
    _currentPuzzle?.reset();
    // Penalizar el tiempo también
    puzzleTimer = (puzzleTimer - 5.0).clamp(0.0, maxPuzzleTime);
  }

  @override
  void update(double dt) {
    super.update(dt); // Crucial: Allow Flame to process add/remove components
    // REMOVED: updateGame(dt) call here because super.update(dt) in BaseArcGame already calls it.
  }

  @override
  void updateGame(double dt) {
    if (isGameOver || isVictory || isPaused) {
      _glitchEffectTimer = 0;
      _penaltyDrainRemaining = 0;
      return;
    }

    if (_glitchEffectTimer > 0) {
      _glitchEffectTimer -= dt;
    }

    if (_isTransitioning || _isPausedForTutorial) return; 

    // Drenaje del tiempo del puzzle
    // protocol_vpn: Reduce la velocidad de detección en un 15% (el tiempo drena más lento)
    final timeMultiplier = hasVPN ? 0.85 : 1.0;
    final oldTimer = puzzleTimer;
    puzzleTimer -= dt * timeMultiplier;
    
    // Trigger ticking sound if entering low time
    if (puzzleTimer < 5.0 && oldTimer >= 5.0) {
      SoundManager().playProximitySound(); // Using proximity sound as ticking fallback or we can add specific method
    }

    if (puzzleTimer <= 0) {
      // Castigo severo por tiempo (35% de daño inmediato)
      final timeoutDamage = hasFirewall ? 35.0 * 0.9 : 35.0; // Cortafuegos mitiga un 10%
      sanitySystem.takeDamage(timeoutDamage);
      _onPuzzleFail(); // Esto reinicia el puzzle y el timer
      
      if (sanitySystem.isDepleted()) {
        onGameOver();
        return;
      }
    }

    // Drenaje por error (lentamente durante 2 segundos)
    if (_penaltyDrainRemaining > 0) {
      // protocol_firewall: Reduce el daño en un 10%
      final damageMultiplier = hasFirewall ? 0.9 : 1.0;
      final drainStep = (_penaltyDamageTotal / 2.0) * dt * damageMultiplier;
      sanitySystem.takeDamage(drainStep);
      _penaltyDrainRemaining -= dt;
    }

    if (sanitySystem.isDepleted()) {
      onGameOver();
    }
  }
  
  @override
  void render(Canvas canvas) {
    // 0. PROTOCOL VISUAL EFFECTS (Back Layer)
    if (hasVPN) {
      // Subtle pulse for VPN (Slow time)
      final vpnPulse = (math.sin(elapsedTime * 2) * 0.5 + 0.5) * 0.08;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFF00F0FF).withOpacity(vpnPulse)
      );
    }

    // 1. PURE MINIMALIST BACKGROUND
    canvas.drawColor(const Color(0xFF000000), BlendMode.src);
    
    // Minimal border (link to primary color if possible, or cyan fallback)
    final borderColor = hasFirewall 
        ? const Color(0xFFFFD700).withOpacity(0.3 + (math.sin(elapsedTime * 5) * 0.1)) 
        : const Color(0xFF00F0FF).withOpacity(0.15);

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = hasFirewall ? 2.0 : 1.0;
    canvas.drawRect(Rect.fromLTWH(10, 10, size.x - 20, size.y - 20), paint);

    if (hasFirewall) {
      // Shield glow effect for firewall
      final shieldPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.05)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(10, 10, size.x - 20, size.y - 20), shieldPaint);
    }

    // 2. CLIP AND RENDER PUZZLE
    canvas.save();
    // Clip to the blue border area to prevent puzzles from overpassing it
    canvas.clipRect(Rect.fromLTWH(10, 10, size.x - 20, size.y - 20));
    super.render(canvas);
    canvas.restore();

    // 3. RENDER BARS AT BOTTOM (Last to ensure visibility)
    _drawStatusBarsWithBackground(canvas);
    
    // 3. GLITCH OVERLAY
    if (_glitchEffectTimer > 0) {
      final rand = math.Random();
      
      // Screen tearing
      for(int i = 0; i < 8; i++) {
        final gPaint = Paint()..color = (rand.nextBool() ? Colors.red : const Color(0xFF39FF14)).withOpacity(0.4);
        canvas.drawRect(Rect.fromLTWH(
          rand.nextDouble() * size.x, 
          rand.nextDouble() * size.y, 
          rand.nextDouble() * size.x, 
          rand.nextDouble() * 30), gPaint);
      }
      
      // Disturbing text
      if (rand.nextDouble() > 0.3) {
        final msgs = ["¿QUÉ HACES?", "TE MIENTO", "DESPIERTA", "CULPABLE", "MÍRAME", "FATAL ERROR", "CORRUPTO"];
        final msg = msgs[rand.nextInt(msgs.length)];
        final fontSize = 20 + rand.nextDouble() * 50;
        final tp = TextPainter(
          text: TextSpan(
            text: msg,
            style: TextStyle(color: Colors.white, fontSize: fontSize, fontFamily: 'Courier', fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        
        // Clamp to avoid drawing completely out of view
        final maxX = math.max(0.0, size.x - tp.width);
        final maxY = math.max(0.0, size.y - tp.height);
        
        final dx = rand.nextDouble() * maxX;
        final dy = rand.nextDouble() * maxY;
        tp.paint(canvas, Offset(dx, dy));
      }
    }
  }

  void _drawStatusBarsWithBackground(Canvas canvas) {
    _drawStatusBars(canvas);
  }

  void _drawStatusBars(Canvas canvas) {
    final x = 20.0;
    final bottomY = size.y - 40;

    // --- INTEGRIDAD DEL SISTEMA (Sanity) ---
    final double s = sanitySystem.currentSanity;
    final String sPercent = (s * 100).toInt().toString();
    
    final stabilityLabelTp = TextPainter(
      text: TextSpan(
        text: "ESTABILIDAD_SISTEMA: ",
        style: TextStyle(
          color: s < 0.2 ? Colors.red.withOpacity(0.5) : Colors.white24, 
          fontSize: 10, 
          fontFamily: 'Courier', 
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    stabilityLabelTp.layout();
    stabilityLabelTp.paint(canvas, Offset(x, bottomY - 20));

    final stabilityValueTp = TextPainter(
      text: TextSpan(
        text: "$sPercent%",
        style: TextStyle(
          color: s < 0.2 ? Colors.red : Colors.white, 
          fontSize: 14, 
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    stabilityValueTp.layout();
    stabilityValueTp.paint(canvas, Offset(x + stabilityLabelTp.width, bottomY - 23));

    // --- TIEMPO DEL PUZZLE (Sincronización) ---
    final timeStr = puzzleTimer.toStringAsFixed(1);
    final isLow = puzzleTimer < 5.0;
    
    final labelTp = TextPainter(
      text: TextSpan(
        text: "SINCRONIZACIÓN_NODO: ",
        style: TextStyle(
          color: Colors.white24, 
          fontSize: 10, 
          fontFamily: 'Courier', 
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelTp.layout();
    labelTp.paint(canvas, Offset(x, bottomY));

    final timeTp = TextPainter(
      text: TextSpan(
        text: "${timeStr}s",
        style: TextStyle(
          color: isLow ? Colors.red : const Color(0xFF00F0FF), 
          fontSize: 14, 
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
          shadows: [
            if (isLow) Shadow(color: Colors.red, blurRadius: 10),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    timeTp.layout();
    timeTp.paint(canvas, Offset(x + labelTp.width, bottomY - 3));
    
    // Indicador de procesamiento
    final dots = "." * ((DateTime.now().millisecondsSinceEpoch % 1000) ~/ 250);
    final procTp = TextPainter(
      text: TextSpan(
        text: dots,
        style: TextStyle(color: const Color(0xFF00F0FF), fontSize: 14, fontFamily: 'Courier'),
      ),
      textDirection: TextDirection.ltr,
    );
    procTp.layout();
    procTp.paint(canvas, Offset(x + labelTp.width + timeTp.width + 5, bottomY - 3));

    // --- PROTOCOLOS ACTIVOS (Derecha) ---
    final rightX = size.x - 20;

    if (hasVPN) {
      final String statusText = puzzleTimer < 5.0 ? "[VPN: OVERCLOCK]" : "[VPN: ACTIVO]";
      final Color vpnColor = puzzleTimer < 5.0 ? Colors.red : const Color(0xFF00F0FF);
      
      final vpnTp = TextPainter(
        text: TextSpan(
          text: statusText,
          style: TextStyle(
            color: vpnColor, 
            fontSize: 10, 
            fontFamily: 'Courier', 
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      vpnTp.layout();
      vpnTp.paint(canvas, Offset(rightX - vpnTp.width, bottomY - 20));
    }

    if (hasFirewall) {
      // Glow text if damage is currently blocked by firewall
      final fwColor = (_penaltyDrainRemaining > 0) ? const Color(0xFF39FF14) : const Color(0xFFFFD700);
      final fwText = (_penaltyDrainRemaining > 0) ? "[FW: BLOQUEANDO DAÑO]" : "[CORTAFUEGOS: ON]";

      final fwTp = TextPainter(
        text: TextSpan(
          text: fwText,
          style: TextStyle(
            color: fwColor, 
            fontSize: 10, 
            fontFamily: 'Courier', 
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      fwTp.layout();
      fwTp.paint(canvas, Offset(rightX - fwTp.width, bottomY));
    }
  }

  void _drawBar(Canvas canvas, String label, double progress, Offset pos, double width, double height, {required Color color}) {
    // Label
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.white30, fontSize: 9, fontFamily: 'Courier', fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx, pos.dy - 14));

    // Progress text
    final percentTp = TextPainter(
      text: TextSpan(
        text: "${(progress * 100).toInt()}%",
        style: TextStyle(color: color.withOpacity(0.6), fontSize: 8, fontFamily: 'Courier'),
      ),
      textDirection: TextDirection.ltr,
    );
    percentTp.layout();
    percentTp.paint(canvas, Offset(pos.dx + width - percentTp.width, pos.dy - 12));

    // Background with border for better visibility
    final bgRect = Rect.fromLTWH(pos.dx, pos.dy, width, height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
      Paint()..color = Colors.white.withOpacity(0.12)
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(2)),
      Paint()..color = Colors.white.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 0.5
    );
    
    // Fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, width * progress, height), const Radius.circular(2)),
      Paint()..color = color.withOpacity(0.9)
    );
  }

  void _drawHexGrid(Canvas canvas, Paint paint) {}
  void _drawOverlayEffects(Canvas canvas) {}
}
