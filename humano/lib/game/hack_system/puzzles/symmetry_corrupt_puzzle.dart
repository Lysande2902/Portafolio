import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class SymmetryCorruptPuzzle extends MindHackPuzzle {
  final int _gridSize = 4;
  final List<int> _targetPattern = [];
  final List<int> _playerPattern = [];
  final List<int> _glitchIndices = [];
  
  late TextComponent _statusText;
  late TextComponent _counterText;
  int _round = 0;
  final int _targetRounds = 3;

  final List<SymmetryTile> _leftTiles = [];
  final List<SymmetryTile> _rightTiles = [];

  SymmetryCorruptPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "SIMETRÍA CORRUPTA";

  @override
  String get instruction => "REPLICA EL PATRÓN DE LA IZQUIERDA EN LA CUADRÍCULA DE LA DERECHA";

  @override
  Future<void> onLoad() async {
    debugPrint('📦 [LOAD] SymmetryCorruptPuzzle (Fase 3) - Iniciando onLoad');
    await super.onLoad();

    _statusText = TextComponent(
      text: '[3] SIMETRÍA',
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.1),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'FASE: 0/$_targetRounds',

      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.15),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
      ),
    );
    add(_counterText);

    _setupGrids();
    _startRound();
  }

  void _setupGrids() {
    final screenSize = gameRef.size;
    final padding = 20.0;
    final totalWidth = screenSize.x - (padding * 2);
    final gridWidth = (totalWidth / 2) - 10;
    final tileSize = gridWidth / _gridSize;

    // Left Grid (Target)
    for (int i = 0; i < _gridSize * _gridSize; i++) {
      final row = i ~/ _gridSize;
      final col = i % _gridSize;
      final tile = SymmetryTile(
        index: i,
        size: Vector2.all(tileSize - 4),
        position: Vector2(
          padding + col * tileSize,
          screenSize.y * 0.25 + row * tileSize,
        ),
        isInteractive: false,
        onTap: (_) {},
      );
      _leftTiles.add(tile);
      add(tile);
    }

    // Right Grid (Player)
    for (int i = 0; i < _gridSize * _gridSize; i++) {
      final row = i ~/ _gridSize;
      final col = i % _gridSize;
      final tile = SymmetryTile(
        index: i,
        size: Vector2.all(tileSize - 4),
        position: Vector2(
          screenSize.x / 2 + 5 + col * tileSize,
          screenSize.y * 0.25 + row * tileSize,
        ),
        isInteractive: true,
        onTap: _handleTileTap,
      );
      _rightTiles.add(tile);
      add(tile);
    }
  }

  void _startRound() {
    if (_round >= _targetRounds) {
      debugPrint('✨ [PUZZLE] SymmetryCorruptPuzzle target reached. Calling onComplete()');
      _isFinished = true;
      Future.delayed(const Duration(milliseconds: 600), () => onComplete());
      return;
    }


    final random = Random();
    _targetPattern.clear();
    _playerPattern.clear();
    _glitchIndices.clear();

    // Generate random pattern (3-5 tiles)
    final patternSize = 3 + _round;
    while (_targetPattern.length < patternSize) {
      int idx = random.nextInt(_gridSize * _gridSize);
      if (!_targetPattern.contains(idx)) {
        _targetPattern.add(idx);
      }
    }

    // Generate glitches (tiles that shouldn't be touched)
    final glitchCount = 2 + _round;
    while (_glitchIndices.length < glitchCount) {
      int idx = random.nextInt(_gridSize * _gridSize);
      if (!_targetPattern.contains(idx) && !_glitchIndices.contains(idx)) {
        _glitchIndices.add(idx);
      }
    }

    // Reset tiles
    for (int i = 0; i < _leftTiles.length; i++) {
      _leftTiles[i].isActive = _targetPattern.contains(i);
      _rightTiles[i].isActive = false;
      _rightTiles[i].isGlitch = _glitchIndices.contains(i);
    }

    _statusText.text = 'REPLIQUE LA IZQUIERDA';
  }

  bool _isFinished = false;

  void _handleTileTap(int index) {
    if (_isFinished) return;

    if (_glitchIndices.contains(index)) {
      _rightTiles[index].shake();
      onFail();
      return;
    }

    if (_targetPattern.contains(index)) {
      if (!_playerPattern.contains(index)) {
        _playerPattern.add(index);
        _rightTiles[index].isActive = true;
        
        if (_playerPattern.length == _targetPattern.length) {
          if (_round + 1 >= _targetRounds) {
            _isFinished = true;
          }
          _round++;
          _counterText.text = 'FASE: $_round/$_targetRounds';
          Future.delayed(const Duration(milliseconds: 500), () => _startRound());
        }
      }
    } else {
      onFail();
    }
  }

  @override
  void reset() {
    _round = 0;
    _counterText.text = 'FASE: 0/$_targetRounds';
    _startRound();
  }
}

class SymmetryTile extends PositionComponent with TapCallbacks {
  final int index;
  final bool isInteractive;
  final Function(int) onTap;
  
  bool _isActive = false;
  bool _isGlitch = false;
  
  late RectangleComponent _bg;
  late RectangleComponent _glitchEffect;

  bool get isActive => _isActive;
  set isActive(bool value) {
    _isActive = value;
    _bg.paint.color = _isActive 
        ? const Color(0xFF00F0FF).withOpacity(0.8) 
        : Colors.white.withOpacity(0.05);
  }

  bool get isGlitch => _isGlitch;
  set isGlitch(bool value) {
    _isGlitch = value;
    _glitchEffect.opacity = _isGlitch ? 0.2 : 0.0;
  }

  SymmetryTile({
    required this.index,
    required Vector2 size,
    required Vector2 position,
    required this.isInteractive,
    required this.onTap,
  }) : super(size: size, position: position);

  @override
  Future<void> onLoad() async {
    _bg = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white.withOpacity(0.05),
    );
    add(_bg);

    _glitchEffect = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red.withOpacity(0.5),
    );
    _glitchEffect.opacity = 0.0;
    add(_glitchEffect);

    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    ));
  }

  void shake() {
    add(MoveEffect.by(
      Vector2(4, 0),
      EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 3),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isInteractive) {
      onTap(index);
    }
  }
}
