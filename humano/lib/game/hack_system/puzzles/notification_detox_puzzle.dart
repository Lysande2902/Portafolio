import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class NotificationDetoxPuzzle extends MindHackPuzzle {
  int _round = 0;
  final int _targetRounds = 3;
  late TextComponent _statusText;
  late TextComponent _counterText;
  final List<NotificationComponent> _notifications = [];
  bool _isFinished = false;

  NotificationDetoxPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "DETOX DE NOTIFICACIONES";

  @override
  String get instruction => "SILENCIA LAS DISTRACCIONES TOCÁNDOLAS ANTES DE QUE SE AGOTE EL TIEMPO";

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final screenSize = gameRef.size;

    _statusText = TextComponent(
      text: '[2] DETOX DE AVISOS',
      position: Vector2(screenSize.x / 2, screenSize.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'DETOX: 0/$_targetRounds',
      position: Vector2(screenSize.x / 2, screenSize.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
      ),
    );
    add(_counterText);

    _startRound();
  }

  void _startRound() {
    if (_round >= _targetRounds) {
      _isFinished = true;
      Future.delayed(const Duration(milliseconds: 500), () => onComplete());
      return;
    }

    _notifications.clear();
    final count = 5 + (_round * 2); // Más notificaciones por ronda
    final random = Random();
    
    for (int i = 0; i < count; i++) {
      final notif = NotificationComponent(
        onClose: (n) => _handleNotifClose(n),
        onExpired: () => onFail(), // Fallar si expira una notificación
        position: Vector2(
          80 + random.nextDouble() * (gameRef.size.x - 160),
          180 + random.nextDouble() * (gameRef.size.y - 350),
        ),
      );
      _notifications.add(notif);
      add(notif);
    }
  }

  void _handleNotifClose(NotificationComponent notif) {
    if (_isFinished) return;
    
    notif.removeFromParent();
    _notifications.remove(notif);

    if (_notifications.isEmpty) {
      _round++;
      _counterText.text = 'DETOX: $_round/$_targetRounds';
      _startRound();
    }
  }

  @override
  void reset() {
    _round = 0;
    _isFinished = false;
    _notifications.forEach((n) => n.removeFromParent());
    _notifications.clear();
    _counterText.text = 'DETOX: 0/$_targetRounds';
    _startRound();
  }
}

class NotificationComponent extends PositionComponent with TapCallbacks {
  final Function(NotificationComponent) onClose;
  final VoidCallback onExpired;
  double _timer = 2.5; // Segundos para cerrar la notificación
  late RectangleComponent _timerBar;
  bool _isExpired = false;

  static final List<String> _titles = [
    'NUEVA SOLICITUD', 'MENSAJE URGENTE', 'TE MENCIONARON', 'ALERTA SEGURIDAD', 'SÍGUEME YA'
  ];

  NotificationComponent({required this.onClose, required this.onExpired, required Vector2 position}) 
    : super(position: position, size: Vector2(200, 55), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final title = _titles[Random().nextInt(_titles.length)];
    
    // Background con gradiente cian/oscuro
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF003840), Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    )..add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF00F0FF).withOpacity(0.4)
          ..style = PaintingStyle.stroke..strokeWidth = 1.2
    )));

    // Icono pequeño de advertencia
    add(CircleComponent(
      radius: 4,
      position: Vector2(12, size.y / 2),
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF00F0FF),
    ));

    // Text
    add(TextComponent(
      text: title,
      position: Vector2(25, size.y / 2),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    ));

    // Botón X estilizado
    add(RectangleComponent(
      size: Vector2(30, 30),
      position: Vector2(size.x - 20, size.y / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.red.withOpacity(0.1),
    )..add(TextComponent(
        text: 'X',
        position: Vector2(15, 15),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: GoogleFonts.shareTechMono(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )));

    // Barra de tiempo dinámica
    _timerBar = RectangleComponent(
      size: Vector2(size.x, 3),
      position: Vector2(0, size.y - 3),
      paint: Paint()..color = const Color(0xFF00F0FF),
    );
    add(_timerBar);

    // Animación de entrada
    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.25, curve: Curves.easeOutBack)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isExpired) return;

    _timer -= dt;
    // Actualizar ancho de la barra
    _timerBar.size.x = (max(0, _timer) / 2.5) * size.x;
    
    // Cambiar color de la barra cuando queda poco tiempo
    if (_timer < 1.0) {
      _timerBar.paint.color = Colors.redAccent;
    }

    if (_timer <= 0) {
      _isExpired = true;
      onExpired();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isExpired) return;
    onClose(this);
  }
}
