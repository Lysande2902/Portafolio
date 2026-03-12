import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class LedgerBalancePuzzle extends MindHackPuzzle {
  double _currentBalance = -50.00;
  final double _targetBalance = 0.00;
  late TextComponent _statusText;
  late TextComponent _balanceDisplay;
  late TextComponent _instructions;
  double _spawnTimer = 0;
  final double _spawnInterval = 0.8;
  bool _isFinished = false;

  LedgerBalancePuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "BALANCE DE CUENTAS";

  @override
  String get instruction => "TOCA LOS VALORES POSITIVOS O NEGATIVOS PARA EQUILIBRAR LA CUENTA A 0.00";

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Generar deuda inicial aleatoria
    _currentBalance = -(20 + Random().nextInt(40)).toDouble();

    _statusText = TextComponent(
      text: '[2] LEDGER DECIMAL',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _instructions = TextComponent(
      text: 'EQUILIBRA LA CUENTA A 0.00',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white.withOpacity(0.6), fontSize: 12),
      ),
    );
    add(_instructions);

    _balanceDisplay = TextComponent(
      text: _currentBalance.toStringAsFixed(2),
      position: Vector2(size.x / 2, size.y * 0.45),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(
          color: Colors.redAccent, 
          fontSize: 48, 
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(color: Colors.red, blurRadius: 15)]
        ),
      ),
    );
    add(_balanceDisplay);

    _startSpawning();
  }

  void _startSpawning() {
    // Primera tanda de números
    for (int i = 0; i < 3; i++) {
      _spawnNumber();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnNumber();
    }

    // Feedback visual del balance
    if (_currentBalance == 0) {
      _balanceDisplay.textRenderer = TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 52, fontWeight: FontWeight.bold),
      );
    } else if (_currentBalance > 0) {
      _balanceDisplay.textRenderer = TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.greenAccent, fontSize: 48, fontWeight: FontWeight.bold),
      );
    } else {
      _balanceDisplay.textRenderer = TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.redAccent, fontSize: 48, fontWeight: FontWeight.bold),
      );
    }
    
    _balanceDisplay.text = _currentBalance.toStringAsFixed(2);
  }

  void _spawnNumber() {
    final random = Random();
    // Generar valores que ayuden a llegar a cero
    double val;
    if (_currentBalance < 0) {
      val = (random.nextInt(15) + 1).toDouble(); // Valores positivos para compensar deuda
    } else {
      val = -(random.nextInt(15) + 1).toDouble(); // Valores negativos si se pasó
    }

    final numComp = LedgerNumberComponent(
      value: val,
      onTap: (v) => _handleValueTap(v),
      position: Vector2(
        50 + random.nextDouble() * (size.x - 100),
        size.y * 0.6 + random.nextDouble() * (size.y * 0.3),
      ),
    );
    add(numComp);
  }

  void _handleValueTap(double val) {
    if (_isFinished) return;
    
    _currentBalance += val;
    
    // Efecto de impacto en el texto central
    _balanceDisplay.add(ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.1, reverseDuration: 0.1)));

    if (_currentBalance.abs() < 0.01) {
      _currentBalance = 0;
      _isFinished = true;
      _instructions.text = 'CUENTA SALDADA';
      Future.delayed(const Duration(milliseconds: 800), () => onComplete());
    }
  }

  @override
  void reset() {
    _currentBalance = -(20 + Random().nextInt(40)).toDouble();
    _isFinished = false;
    children.whereType<LedgerNumberComponent>().forEach((c) => c.removeFromParent());
  }
}

class LedgerNumberComponent extends PositionComponent with TapCallbacks {
  final double value;
  final Function(double) onTap;
  late Vector2 _velocity;

  LedgerNumberComponent({
    required this.value,
    required this.onTap,
    required Vector2 position,
  }) : super(position: position, size: Vector2(80, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final isPositive = value > 0;
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;
    final random = Random();
    
    _velocity = Vector2(random.nextDouble() * 40 - 20, random.nextDouble() * 30 - 15);

    add(RectangleComponent(
      size: size,
      paint: Paint()..color = color.withOpacity(0.1)..style = PaintingStyle.fill,
    )..add(RectangleComponent(
        size: size,
        paint: Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1
    )));

    add(TextComponent(
      text: (value > 0 ? '+' : '') + value.toInt().toString(),
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: color, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ));

    // Animación de entrada
    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.easeOutBack)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
    
    // Desaparecer después de un tiempo (para no saturar la pantalla)
    if (Random().nextDouble() < 0.005) {
      add(ScaleEffect.to(
        Vector2.zero(), 
        EffectController(duration: 0.5),
      )..onComplete = () => removeFromParent());
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(value);
    removeFromParent();
  }
}
