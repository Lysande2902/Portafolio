import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:humano/screens/menu_screen.dart';

/// Final de la DEMO - Versión extremadamente incómoda
/// Simula doxxeo y acoso en tiempo real para hacer sentir al jugador
class DemoEndingScreen extends StatefulWidget {
  const DemoEndingScreen({super.key});

  @override
  State<DemoEndingScreen> createState() => _DemoEndingScreenState();
}

class _DemoEndingScreenState extends State<DemoEndingScreen>
    with TickerProviderStateMixin {
  String _currentText = '';
  int _phase = 0;
  double _glitchIntensity = 0.0;
  bool _showFakeNotifications = false;
  int _viewerCount = 0;
  final List<String> _fakeComments = [];
  String _deviceInfo = 'Cargando...';
  bool _showTypingIndicator = false;
  
  late AnimationController _fadeController;
  late AnimationController _glitchController;
  late Animation<double> _fadeAnimation;
  Timer? _viewerTimer;
  Timer? _commentTimer;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 60),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _getDeviceInfo();
    _startEnding();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glitchController.dispose();
    _viewerTimer?.cancel();
    _commentTimer?.cancel();
    super.dispose();
  }

  Future<void> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String info = '';
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info = '${iosInfo.name} - ${iosInfo.model}';
      } else {
        info = 'Dispositivo desconocido';
      }
    } catch (e) {
      info = 'Dispositivo móvil';
    }
    
    setState(() => _deviceInfo = info);
  }

  void _vibrate() {
    Vibration.vibrate(duration: 100);
  }

  Future<void> _startEnding() async {
    _fadeController.forward();
    
    // FASE 1: Recapitulación normal
    await _wait(2);
    await _type('Has completado 3 arcos');
    await _wait(3);
    
    _clear();
    await _type('Escapaste de las máscaras');
    await _wait(4);

    // FASE 2: Primera señal de que algo está mal
    _clear();
    setState(() => _phase = 1);
    await _wait(2);
    await _type('Procesando datos...');
    await _wait(3);
    
    _clear();
    await _type('Un momento.');
    await _wait(4);

    // FASE 3: INICIO DEL DOXXEO - Obtener "permiso" de cámara
    _clear();
    setState(() => _phase = 2);
    await _wait(1);
    await _type('Activando cámara frontal...', speed: 35);
    _vibrate();
    await _wait(3);
    
    _clear();
    await _type('Captura guardada.', speed: 35);
    _vibrate();
    await _wait(2);
    
    _clear();
    await _type('Analizando expresión facial...', speed: 35);
    await _wait(4);

    // FASE 4: Revelar información "personal"
    _clear();
    setState(() {
      _phase = 3;
      _glitchIntensity = 0.3;
    });
    await _wait(1);
    _vibrate();
    await _type('PERFIL GENERADO', speed: 30);
    await _wait(3);
    
    _clear();
    await _type('Usuario: P-L-A-Y-E-R', speed: 35);
    await _wait(2);
    
    _clear();
    await _type('Dispositivo: $_deviceInfo', speed: 35);
    _vibrate();
    await _wait(2);
    
    _clear();
    await _type('Ubicación aproximada: [TU CIUDAD]', speed: 35);
    _vibrate();
    await _wait(2);
    
    _clear();
    await _type('Hora local: ${DateTime.now().hour}:${DateTime.now().minute}', speed: 35);
    await _wait(2);
    
    _clear();
    await _type('Arcos completados: 3/7', speed: 35);
    await _wait(2);
    
    _clear();
    await _type('Tiempo jugado: ${_getRandomTime()}', speed: 35);
    await _wait(3);

    // FASE 5: Simular subida a redes
    _clear();
    setState(() {
      _phase = 4;
      _glitchIntensity = 0.6;
    });
    await _wait(1);
    await _type('Conectando a servidor...', speed: 25);
    _vibrate();
    await _wait(2);
    
    _clear();
    await _type('Subiendo captura de pantalla...', speed: 25);
    await _wait(2);
    
    _clear();
    await _type('Comprimiendo datos de sesión...', speed: 25);
    await _wait(2);
    
    _clear();
    await _type('Publicando en Reddit...', speed: 25);
    _vibrate();
    await _wait(2);
    
    setState(() => _showFakeNotifications = true);
    _clear();
    await _type('Publicando en Twitter...', speed: 25);
    _vibrate();
    await _wait(2);
    
    _clear();
    await _type('Compartiendo en Discord...', speed: 25);
    _vibrate();
    await _wait(3);

    // FASE 6: Contador de espectadores en vivo
    _clear();
    setState(() => _phase = 5);
    _startViewerCount();
    await _wait(2);
    await _type('Transmisión iniciada', speed: 30);
    await _wait(4);
    
    _clear();
    await _type('Personas viendo: CARGANDO...', speed: 30);
    await _wait(3);

    // FASE 7: COMENTARIOS CRUELES simulados
    _clear();
    setState(() {
      _phase = 6;
      _glitchIntensity = 1.0;
    });
    await _wait(2);
    _startFakeComments();
    await _type('Comentarios habilitados', speed: 25);
    await _wait(6);

    // FASE 8: Mensaje directo "personal"
    _stopViewerCount();
    _stopComments();
    setState(() => _showFakeNotifications = false);
    _clear();
    setState(() {
      _phase = 7;
      _glitchIntensity = 0.8;
    });
    await _wait(3);
    
    // Simular que "alguien" está escribiendo
    setState(() => _showTypingIndicator = true);
    await _wait(4);
    setState(() => _showTypingIndicator = false);
    
    await _type('«Ahora tú eres el monstruo»', speed: 25);
    await _wait(1);
    await _type('\n\n- Mateo', speed: 35);
    _vibrate();
    await _wait(4);
    
    _clear();
    setState(() => _showTypingIndicator = true);
    await _wait(3);
    setState(() => _showTypingIndicator = false);
    
    await _type('«¿Cómo se siente ser observado?»', speed: 25);
    await _wait(1);
    await _type('\n\n- Valeria', speed: 35);
    _vibrate();
    await _wait(4);
    
    _clear();
    setState(() => _showTypingIndicator = true);
    await _wait(3);
    setState(() => _showTypingIndicator = false);
    
    await _type('«Te vemos. Te juzgamos. Te compartimos.»', speed: 25);
    await _wait(1);
    await _type('\n\n- Lucía', speed: 35);
    _vibrate();
    await _wait(5);

    // FASE 9: Pausa LARGA e incómoda
    _clear();
    await _wait(5);
    await _type('.', speed: 800);
    await _type('.', speed: 800);
    await _type('.', speed: 800);
    await _wait(4);

    // FASE 10: REVELACIÓN - Era falso
    _clear();
    setState(() {
      _phase = 8;
      _glitchIntensity = 0.0;
    });
    await _wait(2);
    await _type('Relájate.', speed: 50);
    await _wait(3);
    
    _clear();
    await _type('Nada de esto fue real.', speed: 40);
    await _wait(4);
    
    _clear();
    await _type('Tu cámara no se activó.', speed: 40);
    await _wait(3);
    
    _clear();
    await _type('Nadie te está viendo.', speed: 40);
    await _wait(3);
    
    _clear();
    await _type('No fuiste compartido.', speed: 40);
    await _wait(4);
    
    _clear();
    await _type('Pero sentiste algo, ¿verdad?', speed: 40);
    await _wait(5);

    // FASE 11: Reflexión sobre el miedo
    _clear();
    setState(() => _phase = 9);
    await _wait(2);
    await _type('Miedo.', speed: 60);
    await _wait(3);
    
    _clear();
    await _type('Esa sensación en el estómago.', speed: 40);
    await _wait(3);
    
    _clear();
    await _type('Esa urgencia de cerrar la app.', speed: 40);
    await _wait(3);
    
    _clear();
    await _type('Esa paranoia de revisar tu teléfono.', speed: 40);
    await _wait(4);
    
    _clear();
    await _type('Eso sintieron ellos.', speed: 35);
    await _wait(4);
    
    _clear();
    await _type('Cada. Maldito. Día.', speed: 55);
    await _wait(5);
    
    _clear();
    await _type('Por meses.', speed: 50);
    await _wait(3);
    
    _clear();
    await _type('Por años.', speed: 50);
    await _wait(4);
    
    _clear();
    await _type('Porque TÚ diste click.', speed: 40);
    await _wait(6);

    // FASE 12: Cierre
    _clear();
    setState(() => _phase = 10);
    await _wait(3);
    await _type('DEMO COMPLETA', speed: 45);
    await _wait(4);
    
    _clear();
    await _type('Esto fue solo el inicio.', speed: 40);
    await _wait(3);
    
    _clear();
    await _type('4 máscaras más.', speed: 40);
    await _wait(3);
    
    _clear();
    await _type('4 lecciones más.', speed: 40);
    await _wait(4);
    
    _clear();
    await _type('¿Estás preparado?', speed: 40);
    await _wait(5);

    // Volver al menú
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
        (route) => false,
      );
    }
  }

  void _startViewerCount() {
    _viewerCount = 237;
    _viewerTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _viewerCount += Random().nextInt(50) + 20;
      });
      if (_viewerCount > 2500) {
        timer.cancel();
      }
    });
  }

  void _stopViewerCount() {
    _viewerTimer?.cancel();
  }

  void _startFakeComments() {
    final comments = [
      'JAJAJA quién es este payaso',
      'Qué patético, jugando jueguitos',
      'Captura guardada para siempre lol',
      'Compartido en mi grupo 😂',
      'Este wey de verdad pensó que escapaba',
      'Ya sé dónde vive este',
      'Qué perdedor',
    ];

    _commentTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || _fakeComments.length >= 5) {
        timer.cancel();
        return;
      }
      setState(() {
        _fakeComments.add(comments[Random().nextInt(comments.length)]);
      });
      _vibrate();
    });
  }

  void _stopComments() {
    _commentTimer?.cancel();
    setState(() => _fakeComments.clear());
  }

  Future<void> _type(String text, {int speed = 50}) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() => _currentText = text.substring(0, i));
      await Future.delayed(Duration(milliseconds: speed));
    }
  }

  void _clear() {
    if (mounted) setState(() => _currentText = '');
  }

  Future<void> _wait(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  String _getRandomTime() {
    final minutes = Random().nextInt(45) + 15;
    return '${minutes}m ${Random().nextInt(60)}s';
  }

  Color _getPhaseColor() {
    if (_phase >= 7) return Colors.red.shade700;
    if (_phase >= 5) return Colors.red.shade300;
    if (_phase >= 3) return Colors.orange.shade300;
    if (_phase >= 9) return Colors.white;
    if (_phase >= 10) return Colors.cyan.shade200;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glitch
          if (_glitchIntensity > 0)
            AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GlitchPainter(
                    intensity: _glitchIntensity,
                    seed: _glitchController.value.toInt(),
                  ),
                  size: Size.infinite,
                );
              },
            ),

          // Contador de espectadores (arriba izquierda)
          if (_viewerCount > 0)
            Positioned(
              top: 40,
              left: 20,
              child: _buildViewerCounter(),
            ),

          // Notificaciones falsas (arriba derecha)
          if (_showFakeNotifications)
            Positioned(
              top: 40,
              right: 20,
              child: _buildFakeNotifications(),
            ),

          // Comentarios crueles (abajo)
          if (_fakeComments.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildCommentsSection(),
            ),

          // Indicador de "alguien está escribiendo"
          if (_showTypingIndicator)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: _buildTypingIndicator(),
              ),
            ),

          // Texto principal
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Text(
                      _currentText,
                      style: GoogleFonts.vt323(
                        fontSize: _phase >= 7 ? 26 : 22,
                        color: _getPhaseColor(),
                        height: 1.7,
                        letterSpacing: _phase >= 7 ? 3 : 1.5,
                        shadows: _phase >= 7
                            ? [
                                Shadow(
                                  color: Colors.red.withOpacity(0.9),
                                  blurRadius: 20,
                                ),
                              ]
                            : [],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),

          // Viñeta
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerCounter() {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_viewerCount),
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'EN VIVO: ${_viewerCount.toString()}',
                  style: GoogleFonts.vt323(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFakeNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildNotification('Reddit', '${Random().nextInt(5000) + 1000} upvotes'),
        const SizedBox(height: 8),
        _buildNotification('Twitter', '${Random().nextInt(2000) + 500} RTs'),
        const SizedBox(height: 8),
        _buildNotification('Discord', '${Random().nextInt(3000) + 800} msgs'),
      ],
    );
  }

  Widget _buildNotification(String platform, String stat) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade700, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    platform,
                    style: GoogleFonts.vt323(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    stat,
                    style: GoogleFonts.vt323(fontSize: 12, color: Colors.red.shade200),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade900, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'COMENTARIOS EN VIVO:',
            style: GoogleFonts.vt323(fontSize: 14, color: Colors.red.shade300),
          ),
          const SizedBox(height: 8),
          ..._fakeComments.map((comment) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $comment',
                  style: GoogleFonts.vt323(fontSize: 13, color: Colors.white70),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Alguien está escribiendo',
            style: GoogleFonts.vt323(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(width: 8),
          _buildDot(0),
          _buildDot(200),
          _buildDot(400),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _GlitchPainter extends CustomPainter {
  final double intensity;
  final int seed;

  _GlitchPainter({required this.intensity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final random = Random(seed);
    final paint = Paint()..color = Colors.red.withOpacity(0.2 * intensity);

    for (int i = 0; i < 12; i++) {
      final y = random.nextDouble() * size.height;
      final height = random.nextDouble() * 8;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GlitchPainter oldDelegate) => true;
}
