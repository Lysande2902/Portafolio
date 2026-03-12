import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/audio_provider.dart';
import 'arc_selection_screen.dart';

/// Prólogo/Tutorial narrativo que establece el tono del juego
/// y recopila las primeras decisiones del jugador para el sistema de finales
class PrologueTutorialScreen extends StatefulWidget {
  const PrologueTutorialScreen({super.key});

  @override
  State<PrologueTutorialScreen> createState() => _PrologueTutorialScreenState();
}

class _PrologueTutorialScreenState extends State<PrologueTutorialScreen>
    with TickerProviderStateMixin {
  int _currentMessage = 0;
  
  // Sistema de puntuación (que no importa)
  int _empathyScore = 0;
  int _indifferenceScore = 0;
  
  // Audio
  final AudioPlayer _glitchPlayer = AudioPlayer();
  
  // Animaciones
  late AnimationController _glitchController;

  // Sistema de burla para el botón skip
  int _skipAttempts = 0;
  String _skipMessage = '';
  Timer? _skipMessageTimer;

  // Mensajes narranterrogatorio - VERSIÓN SUTIL
  final List<Map<String, dynamic>> _messages = [
    {
      'text': '¿Recuerdas la última vez que miraste a alguien sin grabar?',
      'options': [
        {'text': 'No entiendo la pregunta', 'empathy': 0, 'indifference': 1},
        {'text': 'Siempre estoy presente', 'empathy': 1, 'indifference': 0},
      ],
    },
    {
      'text': '¿Alguna vez dejaste de grabar para ayudar?',
      'options': [
        {'text': 'Siempre ayudo', 'empathy': 1, 'indifference': 0},
        {'text': 'No recuerdo', 'empathy': 0, 'indifference': 1},
      ],
    },
    {
      'text': 'Las llamadas perdidas... ¿las viste después?',
      'options': [
        {'text': 'Estaba en vivo', 'empathy': 0, 'indifference': 2},
        {'text': '¿De quién?', 'empathy': 1, 'indifference': 0},
      ],
    },
    {
      'text': '¿Cuántas notificaciones valen una vida?',
      'options': [
        {'text': 'Eso no tiene sentido', 'empathy': 1, 'indifference': 0},
        {'text': 'Las vidas no se miden así', 'empathy': 1, 'indifference': 0},
      ],
    },
    {
      'text': 'Cuando alguien lloraba... ¿pensaste en el encuadre?',
      'options': [
        {'text': 'Nunca haría eso', 'empathy': 1, 'indifference': 0},
        {'text': 'No recuerdo', 'empathy': 0, 'indifference': 1},
      ],
    },
    {
      'text': 'El video tuvo millones de vistas. ¿Valió la pena?',
      'options': [
        {'text': '¿Qué video?', 'empathy': 0, 'indifference': 1},
        {'text': 'Yo no hice nada malo', 'empathy': 0, 'indifference': 1},
      ],
    },
    {
      'text': 'Pronto lo recordarás todo',
      'options': [], // Sin opciones, se auto-borra
    },
  ];

  @override
  void initState() {
    super.initState();

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    )..repeat();

    _checkPrologueStatus();
    
    // Asegurar que la música siga sonando al entrar al juicio (prólogo)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AudioProvider>(context, listen: false).playArcMusic('current');
      }
    });
  }

  void _checkPrologueStatus() async {
    // Verificar si ya completó el prólogo antes
    final prefs = await SharedPreferences.getInstance();
    final prologueCompleted = prefs.getBool('prologue_completed') ?? false;
    
    if (prologueCompleted) {
      // Si ya completó el prólogo, saltar directamente a la selección de arcos
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ArcSelectionScreen()),
        );
      }
    }
  }

  void _onOptionSelected(int optionIndex) async {
    // Sumar puntos según la opción elegida
    final option = _messages[_currentMessage]['options'][optionIndex];
    setState(() {
      _empathyScore += (option['empathy'] as int? ?? 0);
      _indifferenceScore += (option['indifference'] as int? ?? 0);
    });
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentMessage < _messages.length - 1) {
      if (mounted) {
        setState(() {
          _currentMessage++;
        });
        
        // Si es el último mensaje (sin opciones), iniciar timer automático
        if (_currentMessage == _messages.length - 1) {
          print('📝 Último mensaje mostrado - iniciando timer de 3 segundos');
          Future.delayed(const Duration(milliseconds: 3000), () {
            if (mounted && _currentMessage == _messages.length - 1) {
              print('📝 Timer completado - completando prólogo');
              _completePrologue();
            }
          });
        }
      }
    }
  }

  void _completePrologue() async {
    await _savePlayerDecisions();
    
    // Navegar a selección de arcos
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ArcSelectionScreen()),
    );
  }

  Future<void> _savePlayerDecisions() async {
    try {
      // Marcar prólogo como completado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prologue_completed', true);
      
      print('✅ Prólogo completado');
      print('📊 Empatía: $_empathyScore | Indiferencia: $_indifferenceScore');
      
      // Determinar el "perfil" (que no importa)
      String profile;
      String mockingMessage;
      
      if (_empathyScore > _indifferenceScore) {
        profile = 'EMPÁTICO';
        mockingMessage = 'Elegiste las respuestas "correctas".\n\nPero eso no cambia lo que hiciste.\n\nLa empatía fingida no resucita a nadie.';
      } else if (_indifferenceScore > _empathyScore) {
        profile = 'INDIFERENTE';
        mockingMessage = 'Al menos fuiste honesto.\n\nPero la honestidad no borra la culpa.\n\nSigues siendo cómplice.';
      } else {
        profile = 'INDECISO';
        mockingMessage = 'No pudiste elegir un lado.\n\nIgual que cuando importaba.\n\nLa indecisión también mata.';
      }
      
      // PRIMER DIÁLOGO: Análisis del perfil (estilo terminal)
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.red[900]!.withOpacity(0.3), width: 1),
            ),
            title: Column(
              children: [
                // Header estilo terminal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.red[900]!.withOpacity(0.3), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ANÁLISIS_PSICOLÓGICO',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.red[900]!.withOpacity(0.6),
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '0x02',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.white24,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Perfil
                Text(
                  'PERFIL: $profile',
                  style: GoogleFonts.shareTechMono(
                    color: Colors.red[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra de puntuación visual (estilo terminal)
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                  ),
                  child: Row(
                    children: [
                      if (_empathyScore > 0)
                        Expanded(
                          flex: _empathyScore,
                          child: Container(
                            color: Colors.blue[700],
                          ),
                        ),
                      if (_indifferenceScore > 0)
                        Expanded(
                          flex: _indifferenceScore,
                          child: Container(
                            color: Colors.red[700],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Mensaje del análisis
                Text(
                  mockingMessage,
                  style: GoogleFonts.shareTechMono(
                    color: Colors.grey[400],
                    fontSize: 11,
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.red[900]!.withOpacity(0.3), width: 1),
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CONTINUAR >>',
                    style: GoogleFonts.shareTechMono(
                      color: Colors.red[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      
      // SEGUNDO DIÁLOGO: Mensaje burlón final (estilo terminal)
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.red[900]!.withOpacity(0.5), width: 1.5),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.red[900]!.withOpacity(0.3), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WITNESS_OS',
                    style: GoogleFonts.shareTechMono(
                      color: Colors.red[900]!.withOpacity(0.6),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.red, size: 6),
                      const SizedBox(width: 4),
                      Text(
                        'ACTIVO',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.red[700],
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border.all(color: Colors.red[900]!.withOpacity(0.2), width: 0.5),
              ),
              child: Text(
                '¿Creías que importaba?\n\nTus respuestas no cambian nada.\n\nEres cómplice de todo lo que verás.\n\nSiempre lo fuiste.',
                style: GoogleFonts.shareTechMono(
                  color: Colors.red[400],
                  fontSize: 11,
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.red[900]!.withOpacity(0.3), width: 1),
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'INICIAR PROTOCOLO >>',
                    style: GoogleFonts.shareTechMono(
                      color: Colors.red[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error en prólogo: $e');
    }
  }

  Future<void> _typeText(String text) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() {
        // Text typing removed - no longer needed
      });
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  void _playGlitchSound() async {
    try {
      await _glitchPlayer.setAsset('assets/sounds/glitch_09-226602.mp3');
      await _glitchPlayer.setLoopMode(LoopMode.one);
      await _glitchPlayer.setVolume(0.5);
      await _glitchPlayer.play();
    } catch (e) {
      print('Error playing glitch sound: $e');
    }
  }

  void _stopGlitchSound() {
    _glitchPlayer.stop();
  }

  void _skipPrologue() {
    // Durante la fase de mensajes, el botón no funciona y se burla
    _skipAttempts++;
    
    final messages = [
      '¿Intentas huir?',
      'No puedes escapar de esto',
      'Responde las preguntas',
      'Tus decisiones importan',
      'No seas cobarde',
      'Enfrenta las consecuencias',
      'Sigue intentando... no funcionará',
    ];
    
    setState(() {
      _skipMessage = messages[min(_skipAttempts - 1, messages.length - 1)];
    });
    
    // Limpiar el mensaje después de 2 segundos
    _skipMessageTimer?.cancel();
    _skipMessageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _skipMessage = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _glitchPlayer.dispose();
    _skipMessageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMessagesPhase(),
          
          // Botón Skip - SIEMPRE visible pero no funciona (se burla)
          Positioned(
            top: 30,
            right: 30,
            child: GestureDetector(
              onTap: _skipPrologue,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  border: Border.all(
                    color: Colors.red[900]!.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.skip_next, 
                      color: Colors.red[700], 
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SKIP',
                      style: GoogleFonts.courierPrime(
                        fontSize: 12,
                        color: Colors.red[700],
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Mensaje de burla cuando intentan skip
          if (_skipMessage.isNotEmpty)
            Positioned(
              top: 80,
              right: 30,
              child: AnimatedBuilder(
                animation: _glitchController,
                builder: (context, child) {
                  final glitch = _glitchController.value > 0.9;
                  return Transform.translate(
                    offset: Offset(
                      glitch ? (Random().nextDouble() - 0.5) * 3 : 0,
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        border: Border.all(color: Colors.red[900]!, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red[900]!.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        _skipMessage,
                        style: GoogleFonts.courierPrime(
                          fontSize: 11,
                          color: Colors.red[700],
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesPhase() {
    final message = _messages[_currentMessage];
    final options = message['options'] as List;
    final hasOptions = options.isNotEmpty;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF020000),
      ),
      child: Stack(
        children: [
          // Corazón/Pulso de Conciencia en el fondo
          Center(
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                final scale = 1.0 + (_glitchController.value * 0.05);
                final opacity = 0.05 + (_glitchController.value * 0.05);
                return Container(
                  width: 300 * scale,
                  height: 300 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(opacity),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Scanlines
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: ScanlinePainter(),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Status Bar superior (más sutil)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'WITNESS_INT_SCN // 0x00FF${_currentMessage + 1}',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.white12,
                          fontSize: 10,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // EL DIÁLOGO (Central y Grande)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentMessage),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // El Juez Pregunta
                          Text(
                            message['text'].toString().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.shareTechMono(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(2, 0),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Decoración de glitch sutil debajo del texto
                          Container(
                            width: 100,
                            height: 1,
                            color: Colors.red[900]?.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // LAS OPCIONES (Estilo de comando)
                  if (hasOptions)
                    Column(
                      children: List.generate(options.length, (index) {
                        final option = options[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () => _onOptionSelected(index),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(
                                  color: Colors.red[900]!.withOpacity(0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.01),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '> ',
                                    style: GoogleFonts.shareTechMono(
                                      color: Colors.red[900],
                                      fontSize: 18,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      option['text'].toString().toUpperCase(),
                                      style: GoogleFonts.shareTechMono(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter para efecto de glitch
class IntenseGlitchPainter extends CustomPainter {
  final double animationValue;

  IntenseGlitchPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((animationValue * 1000).toInt());
    
    for (int i = 0; i < 50; i++) {
      final y = random.nextDouble() * size.height;
      final height = random.nextDouble() * 10;
      
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, height),
        Paint()..color = Colors.red.withOpacity(0.5),
      );
      canvas.drawRect(
        Rect.fromLTWH(5, y + 2, size.width, height),
        Paint()..color = Colors.green.withOpacity(0.4),
      );
      canvas.drawRect(
        Rect.fromLTWH(-5, y - 2, size.width, height),
        Paint()..color = Colors.blue.withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(IntenseGlitchPainter oldDelegate) => true;
}

// Painter para ruido sutil
class SubtleNoisePainter extends CustomPainter {
  final double animationValue;

  SubtleNoisePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((animationValue * 1000).toInt());

    // Ruido muy sutil
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        0.5,
        Paint()..color = Colors.white.withOpacity(random.nextDouble() * 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(SubtleNoisePainter oldDelegate) => true;
}
