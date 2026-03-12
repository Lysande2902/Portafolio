import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class NetworkWebPuzzle extends MindHackPuzzle {
  final List<LikeNode> _nodes = [];
  final List<int> _sequence = [];
  final List<int> _playerInput = [];
  int _round = 0;
  final int _targetRounds = 4;
  bool _showingSequence = false;
  late TextComponent _statusText;
  late TextComponent _counterText;

  NetworkWebPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "RED DE CONTACTOS";

  @override
  String get instruction => "MEMORIZA LA SECUENCIA DE LIKES Y REPÍTELO TOCANDO LOS ICONOS";

  @override
  Future<void> onLoad() async {
    debugPrint('📦 [LOAD] NetworkWebPuzzle (Fase 2) - Carga de componentes...');
    await super.onLoad();

    final screenSize = gameRef.size;
    debugPrint('📦 [LOAD] Screen Size Detectada: $screenSize');
    
    _statusText = TextComponent(
      text: '[2] VALIDACIÓN',
      position: Vector2(screenSize.x / 2, screenSize.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'FASE: 0/$_targetRounds',

      position: Vector2(screenSize.x / 2, screenSize.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
      ),
    );
    add(_counterText);

    _setupNodes();
    debugPrint('📦 [LOAD] Nodes creados: ${_nodes.length}');
    _startRound();
  }


  void _setupNodes() {
    final screenSize = gameRef.size;
    final centerX = screenSize.x / 2;
    final centerY = screenSize.y / 2;
    final radius = min(screenSize.x, screenSize.y) * 0.32;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * pi / 6) - (pi / 2);
      final node = LikeNode(
        index: i,
        position: Vector2(
          centerX + cos(angle) * radius,
          centerY + sin(angle) * radius,
        ),
        onTap: _handleNodeTap,
      );
      _nodes.add(node);
      add(node);
    }
  }

  void _startRound() {
    debugPrint('🎮 [PUZZLE] NetworkWebPuzzle - Iniciando Ronda $_round');
    if (_round >= _targetRounds) {
      debugPrint('✨ [PUZZLE] NetworkWebPuzzle target reached. Calling onComplete()');
      _isFinished = true;
      Future.delayed(const Duration(milliseconds: 600), () => onComplete());
      return;
    }

    _playerInput.clear();
    final nextNode = Random().nextInt(6);
    _sequence.add(nextNode);
    debugPrint('🎮 [PUZZLE] Secuencia actual: $_sequence');
    _showSequence();
  }


  Future<void> _showSequence() async {
    _showingSequence = true;
    _statusText.text = '>>> MEMORIZA <<<';
    
    // Tiempo de pausa antes de mostrar la secuencia para asegurarse que el usuario ya ve los nodos
    await Future.delayed(const Duration(milliseconds: 800));
    if (!isMounted) return;

    final delay = max(300, 700 - (_round * 80));
    
    for (final index in _sequence) {
      await Future.delayed(Duration(milliseconds: delay));
      if (!isMounted) return;
      _nodes[index].highlight();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!isMounted) return;
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (!isMounted) return;
    _showingSequence = false;
    _statusText.text = '>>> REPITE LA RUTA <<<';
  }

  bool _isFinished = false;

  void _handleNodeTap(int index) {
    if (_isFinished || _showingSequence) return;

    _nodes[index].highlight(color: const Color(0xFFFF00FF));
    _playerInput.add(index);

    if (_playerInput[_playerInput.length - 1] != _sequence[_playerInput.length - 1]) {
      onFail();
      return;
    }

    if (_playerInput.length == _sequence.length) {
      if (_round + 1 >= _targetRounds) {
        _isFinished = true;
      }
      _round++;
      _counterText.text = 'FASE: $_round/$_targetRounds';
      Future.delayed(const Duration(milliseconds: 500), () => _startRound());
    }
  }

  @override
  void reset() {
    _round = 0;
    _sequence.clear();
    _playerInput.clear();
    _counterText.text = 'FASE: 0/$_targetRounds';
    _startRound();
  }
}

class LikeNode extends PositionComponent with TapCallbacks {
  final int index;
  final Function(int) onTap;
  late CircleComponent _glow;

  LikeNode({
    required this.index,
    required Vector2 position,
    required this.onTap,
  }) : super(position: position, size: Vector2.all(80), anchor: Anchor.center);


  @override
  Future<void> onLoad() async {
    _glow = CircleComponent(
      radius: 38,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );
    add(_glow);

    // Borde visible para que el usuario sepa donde tocar
    add(CircleComponent(
      radius: 38,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()
        ..color = const Color(0xFF00F0FF).withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    ));

    add(TextComponent(
      text: String.fromCharCode(Icons.favorite.codePoint),
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 28,
          fontFamily: 'MaterialIcons',
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    ));
  }

  void highlight({Color color = const Color(0xFF00F0FF)}) {
    _glow.paint.color = color.withOpacity(0.7);
    
    add(ScaleEffect.by(
      Vector2.all(1.3),
      EffectController(duration: 0.12, reverseDuration: 0.12),
    ));

    async.Timer(const Duration(milliseconds: 400), () {
      if (isMounted) _glow.paint.color = Colors.white.withOpacity(0.08);
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(index);
  }
}
