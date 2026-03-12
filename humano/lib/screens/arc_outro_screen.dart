import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

/// Pantalla de epílogo que se muestra DESPUÉS de completar un arco
/// Revela la culpabilidad del jugador y pregunta "¿Valió la pena?"
class ArcOutroScreen extends StatefulWidget {
  final String arcId;
  final VoidCallback onComplete;

  const ArcOutroScreen({
    super.key,
    required this.arcId,
    required this.onComplete,
  });

  @override
  State<ArcOutroScreen> createState() => _ArcOutroScreenState();
}

class _ArcOutroScreenState extends State<ArcOutroScreen> {
  String _displayedText = '';
  int _currentCharIndex = 0;
  Timer? _typewriterTimer;
  bool _isComplete = false;
  double _glitchIntensity = 0.0;
  bool _isFinalBlackout = false;
  double _heartbeatScale = 1.0;
  Timer? _heartbeatTimer;
  int _heartbeatInterval = 1000;

  @override
  void initState() {
    super.initState();
    _startGlitchEffect();
    Future.delayed(const Duration(milliseconds: 800), () {
      _startTypewriter();
    });
    
    // FORCE PORTRAIT for outro
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  String _getOutroText() {
    switch (widget.arcId) {
      // Arco 0: Inicio - System heavily suppressing the message
      case 'arc_0_inicio':
        return '''NØ €R€S €L _#_ %ERR_404%
[CØN€XIÓN_P€RDIDÅ]

€LLØS TÅ_#_MPØCØ SÅLI€RØN
[ØV€RRID€_SYS_HŁ]

TU NØM_#_BR€ YÅ €STÅBÅ ÅQUÍ
[R€DÅCTÅDØ]

ÅNT€S D€ QU€ ŁŁ€GÅR_#_ÅS...''';
      // Arcos fusionados (nuevos)
      case 'arc_1_consumo_codicia':
        return '''SU MÅDR€ MUR_#_IÓ €SP€RÁNDØŁØ
[SYST€M_FÅIŁUR€]

SUS NIÑØS SIGU€N €SP€RÁNDØ_#_ŁÅ €N CÅSÅ''';
      case 'arc_2_envidia_lujuria':
        return '''ELLA ESCRIBIÓ TU NOMBRE CON SU SANGRE

SU OBSESIÓN FUE TU ALIMENTO''';
      case 'arc_3_soberbia_pereza':
        return '''ÉL CREÍA QUE ERA INVENCIBLE

LA INACCIÓN ES EL CRIMEN MÁS SILENCIOSO''';
      case 'arc_4_ira':
        return '''ÉL QUEMÓ TODO LO QUE AMABA PORQUE TÚ NO MIRASTE

LA VERDAD ES UN PARÁSITO

¿VAS A DEJAR QUE TE CONSUMA?''';
      // Arcos individuales (compatibilidad)
      case 'arc_1_gula':
        return 'SU MADRE MURIÓ ESPERÁNDOLO';
      case 'arc_2_greed':
        return 'SUS NIÑOS SIGUEN ESPERÁNDOLA EN CASA';
      case 'arc_3_envy':
        return 'ELLA ESCRIBIÓ TU NOMBRE CON SU SANGRE';
      default:
        return 'TE VIERON NA_#_CER\n\nTE VERÁN MO_#_RIR';
    }
  }

  void _startGlitchEffect() {
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        // More erratic glitching
        final rand = math.Random();
        _glitchIntensity = rand.nextDouble() < 0.2 ? 0.08 : 0.0;
      });
    });
  }

  void _startTypewriter() {
    final fullText = _getOutroText();
    
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (_currentCharIndex < fullText.length) {
        setState(() {
          _currentCharIndex++;
          
          // Progressive reveal with corruption
          String base = fullText.substring(0, _currentCharIndex);
          
          // Scramble logic: 15% of the last 10 chars are randomly symbols
          if (math.Random().nextDouble() < 0.4) {
             List<String> chars = base.split('');
             for (int i = math.max(0, _currentCharIndex - 10); i < _currentCharIndex; i++) {
               if (math.Random().nextDouble() < 0.25 && chars[i] != '\n' && chars[i] != ' ' ) {
                 chars[i] = ['#', '×', '§', '¶', '¿', 'Ø', 'Ł', '€'][math.Random().nextInt(8)];
               }
             }
             _displayedText = chars.join('');
          } else {
             _displayedText = base;
          }
        });
        
        // --- ERRATIC SYSTEM INTERFERENCE ---
        
        // Pause on special symbols (the "blocks" in system)
        final lastChar = fullText[_currentCharIndex - 1];
        if (lastChar == '_' || lastChar == ']' || lastChar == 'Å' || lastChar == 'Ø') {
          timer.cancel();
          Future.delayed(Duration(milliseconds: 400 + math.Random().nextInt(400)), () {
            if (mounted) _startTypewriter();
          });
          return;
        }

        // Random "STATIC_BURST" interference
        if (math.Random().nextDouble() < 0.1) {
          timer.cancel();
          final currentText = _displayedText;
          final noise = " [DÅTÅ_PURG€_ERROR_${math.Random().nextInt(999)}] ";
          
          setState(() {
            _displayedText += noise;
            _glitchIntensity = 0.12; 
          });

          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) {
              setState(() {
                _displayedText = currentText;
                _glitchIntensity = 0.0;
              });
              _startTypewriter();
            }
          });
          return;
        }
      } else {
        timer.cancel();
        setState(() {
          _isComplete = true;
          _glitchIntensity = 0.00;
        });
        
        // Final pause then start blackout sequence (Idea 10)
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
             setState(() => _isFinalBlackout = true);
             _startHeartbeatSequence();
          }
        });
      }
    });
  }

  void _startHeartbeatSequence() {
    if (!mounted) return;

    // Visual beat effect
    setState(() {
      _heartbeatScale = 1.5;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() {
          _heartbeatScale = 1.0;
        });
      }
    });

    // Intense feedback
    HapticFeedback.heavyImpact();

    // Accelerating the heart
    _heartbeatInterval = math.max(130, _heartbeatInterval - 80);

    if (_heartbeatInterval <= 130) {
      // SUDDEN STOP / FLATLINE
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _heartbeatScale = 0.0; // The point disappears (death/shutdown)
          });
          HapticFeedback.vibrate(); // One last long vibration?
          Future.delayed(const Duration(seconds: 3), widget.onComplete);
        }
      });
    } else {
      _heartbeatTimer = Timer(Duration(milliseconds: _heartbeatInterval), _startHeartbeatSequence);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (!_isFinalBlackout) ...[
            // Efecto de glitch en el fondo
            if (_glitchIntensity > 0)
              Positioned.fill(
                child: Container(
                  color: Colors.red.withOpacity(_glitchIntensity),
                ),
              ),

            // Texto principal
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Frase específica del arco con efecto
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            _displayedText,
                            style: GoogleFonts.vt323(
                              fontSize: 26,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.red.withOpacity(0.8),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Indicador de continuar
            if (_isComplete)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: widget.onComplete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CONTINUAR',
                        style: GoogleFonts.vt323(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ] else
            // THE FINAL BLACKOUT (Idea 10)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 12 * _heartbeatScale,
                height: 12 * _heartbeatScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5 * _heartbeatScale),
                      blurRadius: 30 * _heartbeatScale,
                      spreadRadius: 10 * _heartbeatScale,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
