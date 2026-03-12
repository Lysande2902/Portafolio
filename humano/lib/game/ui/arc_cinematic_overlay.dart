import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class ArcCinematicOverlay extends StatefulWidget {
  final String arcId;
  final VoidCallback onFinished;

  const ArcCinematicOverlay({
    super.key,
    required this.arcId,
    required this.onFinished,
  });

  @override
  State<ArcCinematicOverlay> createState() => _ArcCinematicOverlayState();
}

class _ArcCinematicOverlayState extends State<ArcCinematicOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  
  String _mockeryText = '';
  Color _glitchColor = Colors.red;
  
  // Glitch effect state
  double _offsetX = 0;
  double _offsetY = 0;
  Timer? _glitchTimer;
  String _displayText = '';
  
  @override
  void initState() {
    super.initState();
    _setupContent();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    
    // Start sequence
    _controller.forward();
    
    // Start glitch effect
    _startGlitchEffect();
    
    // Typewriter effect
    _startTypewriter();
    
    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _handleSkip();
      }
    });
  }
  
  void _setupContent() {
    switch (widget.arcId) {
      case 'arc_0_inicio':
        _mockeryText = 'SINCRONIZANDO NÚCLEO DE CULPA\n\nEL JUICIO HA COMENZADO';
        _glitchColor = const Color(0xFF8B0000);
        break;
      case 'arc_1_envidia_lujuria':
        _mockeryText = 'DOS ROSTROS EN EL ESPEJO\n\n¿CUÁL ES EL TUYO?';
        _glitchColor = const Color(0xFFFF4500);
        break;
      case 'arc_2_consumo_codicia':
        _mockeryText = 'CAJAS VACÍAS, PROMESAS ROTAS\n\nEL VACÍO NO SE LLENA';
        _glitchColor = const Color(0xFFFFD700);
        break;
      case 'arc_3_soberbia_pereza':
        _mockeryText = 'LUCES APAGADAS, APLAUSOS MUERTOS\n\nEL SHOW HA TERMINADO';
        _glitchColor = const Color(0xFF00FF00);
        break;
      case 'arc_4_ira':
        _mockeryText = 'ALGUIEN LLAMA DESDE EL FUEGO\n\nYA NO PUEDE ESPERAR';
        _glitchColor = const Color(0xFFFF0000);
        break;
      default:
        _mockeryText = 'ERROR';
        _glitchColor = Colors.red;
    }
  }
  
  void _startGlitchEffect() {
    _glitchTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        if (Random().nextDouble() > 0.8) {
          _offsetX = (Random().nextDouble() - 0.5) * 4;
          _offsetY = (Random().nextDouble() - 0.5) * 4;
        } else {
          _offsetX = 0;
          _offsetY = 0;
        }
      });
    });
  }
  
  void _startTypewriter() {
    int index = 0;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (index < _mockeryText.length) {
        setState(() {
          _displayText = _mockeryText.substring(0, index + 1);
        });
        
        // Play system sound (haptic feedback) every 2 characters
        if (index % 2 == 0 && _displayText.isNotEmpty && !_displayText.endsWith(' ')) {
          try {
            HapticFeedback.selectionClick();
          } catch (e) {
            // Silently fail if haptic feedback is not available
          }
        }
        
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _glitchTimer?.cancel();
    super.dispose();
  }
  
  void _handleSkip() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85), // Semi-transparente para ver el mapa
      child: Stack(
        children: [
          // Texto central con glitch
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.translate(
                    offset: Offset(_offsetX, _offsetY),
                    child: Text(
                      _displayText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(
                        fontSize: 24,
                        color: _glitchColor,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            color: _glitchColor.withOpacity(0.8),
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Skip button (top right - más grande)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: _handleSkip,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: _glitchColor.withOpacity(0.6), width: 2),
                    color: Colors.black.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: _glitchColor.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    'SALTAR →',
                    style: GoogleFonts.vt323(
                      fontSize: 16,
                      color: _glitchColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
