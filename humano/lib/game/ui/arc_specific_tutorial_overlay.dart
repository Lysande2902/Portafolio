import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arc-specific tutorial overlay that explains unique mechanics for each arc
/// 
/// Features:
/// - Confirmation dialog before showing tutorial
/// - Arc-specific content for Gluttony, Greed, and Envy
/// - Manual trigger mode (doesn't affect completion state)
/// - Fade in/out animations (300ms)
/// - Skip button
/// - High contrast text and accessibility
class ArcSpecificTutorialOverlay extends StatefulWidget {
  final String arcId;
  final VoidCallback onComplete;
  final bool isManualTrigger;

  const ArcSpecificTutorialOverlay({
    super.key,
    required this.arcId,
    required this.onComplete,
    this.isManualTrigger = false,
  });

  @override
  State<ArcSpecificTutorialOverlay> createState() => _ArcSpecificTutorialOverlayState();
}

class _ArcSpecificTutorialOverlayState extends State<ArcSpecificTutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentSlide = 0;
  bool _showConfirmation = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final List<ArcTutorialSlide> _slides;

  @override
  void initState() {
    super.initState();
    
    // Skip confirmation if manually triggered
    if (widget.isManualTrigger) {
      _showConfirmation = false;
    }
    
    _slides = _getSlidesForArc(widget.arcId);
    
    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    // Start fade in
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      setState(() {
        _currentSlide++;
      });
    } else {
      _complete();
    }
  }

  void _skip() {
    _complete();
  }

  void _complete() async {
    // Fade out before completing
    await _fadeController.reverse();
    if (mounted) {
      widget.onComplete();
    }
  }

  void _startTutorial() {
    setState(() {
      _showConfirmation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showConfirmation) {
      return _buildConfirmationDialog();
    }

    return _buildTutorialSlides();
  }

  Widget _buildConfirmationDialog() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85),
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyan.shade700, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 48,
                  color: Colors.cyan.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  '¿VER TUTORIAL?',
                  style: GoogleFonts.vt323(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan.shade300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Deseas ver la guía de supervivencia\npara este arco?',
                  style: GoogleFonts.vt323(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'NO',
                          style: GoogleFonts.vt323(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _startTutorial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade700,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'SÍ',
                          style: GoogleFonts.vt323(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialSlides() {
    final slide = _slides[_currentSlide];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _nextSlide,
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.85),
          body: SafeArea(
            child: Stack(
              children: [
                // Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: slide.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: slide.color.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide.icon,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          slide.title,
                          style: GoogleFonts.vt323(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: slide.color,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: 350,
                              maxHeight: MediaQuery.of(context).size.height * 0.45,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: slide.color, width: 2),
                            ),
                            child: Text(
                              slide.description,
                              style: GoogleFonts.vt323(
                                fontSize: 17,
                                color: Colors.white,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header con indicador de progreso y botón saltar
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _slides.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentSlide
                                  ? _slides[_currentSlide].color
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      
                      // Skip button
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: _skip,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text(
                            'SALTAR',
                            style: GoogleFonts.vt323(
                              fontSize: 20,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ArcTutorialSlide> _getSlidesForArc(String arcId) {
    switch (arcId) {
      case 'arc_1_gula':
        return [
          ArcTutorialSlide(
            title: 'OBJETIVO',
            description: 'Recolecta 5 fragmentos y escapa del restaurante',
            icon: Icons.restaurant,
            color: const Color(0xFFFF4500), // Orange-red
          ),
          ArcTutorialSlide(
            title: 'MECÁNICA: DEVORADOR',
            description: 'Mateo devora todo a su paso.\n\nCuando te atrapa, consume tus evidencias una por una.\n\nDebes esconderte para evitar ser devorado.',
            icon: Icons.warning_amber,
            color: const Color(0xFFFF4500),
          ),
          ArcTutorialSlide(
            title: 'CONTROLES',
            description: 'Joystick: Moverte por el mapa\n\nBotón morado: Esconderte del enemigo',
            icon: Icons.gamepad,
            color: const Color(0xFFFF4500),
          ),
          ArcTutorialSlide(
            title: 'ESTRATEGIA',
            description: 'Usa los escondites estratégicamente.\n\nMateo no puede verte cuando estás oculto, pero no puedes moverte.\n\n¡Planifica tu ruta!',
            icon: Icons.lightbulb_outline,
            color: const Color(0xFFFF4500),
          ),
        ];

      case 'arc_2_greed':
        return [
          ArcTutorialSlide(
            title: 'OBJETIVO',
            description: 'Recolecta 5 fragmentos y escapa del banco',
            icon: Icons.account_balance,
            color: const Color(0xFFFFD700), // Gold
          ),
          ArcTutorialSlide(
            title: 'MECÁNICA: ROBO DE RECURSOS',
            description: 'La Rata roba tus evidencias cuando te atrapa.\n\nTambién reduce tu estabilidad de sistema por cada robo.\n\nCada robo tiene un cooldown de 5 segundos.',
            icon: Icons.warning_amber,
            color: const Color(0xFFFFD700),
          ),
          ArcTutorialSlide(
            title: 'CONTROLES',
            description: 'Joystick: Moverte por el mapa\n\nBotón morado: Esconderte del enemigo',
            icon: Icons.gamepad,
            color: const Color(0xFFFFD700),
          ),
          ArcTutorialSlide(
            title: 'ESTRATEGIA',
            description: 'Usa las cajas registradoras (brillo dorado) para recuperar parte de la estabilidad perdida.\n\n¡Planifica tu ruta estratégicamente!',
            icon: Icons.lightbulb_outline,
            color: const Color(0xFFFFD700),
          ),
        ];

      case 'arc_3_envy':
        return [
          ArcTutorialSlide(
            title: 'OBJETIVO',
            description: 'Recolecta 5 fragmentos y escapa del gimnasio',
            icon: Icons.fitness_center,
            color: const Color(0xFF00FF00), // Green
          ),
          ArcTutorialSlide(
            title: 'MECÁNICA: ESPEJO ADAPTATIVO',
            description: 'El enemigo imita tus movimientos.\n\nSe vuelve más rápido y agresivo con cada evidencia.\n\n⚠️ NO HAY ESCONDITES ⚠️',
            icon: Icons.warning_amber,
            color: const Color(0xFF00FF00),
          ),
          ArcTutorialSlide(
            title: 'CONTROLES',
            description: 'Solo Joystick para mover\n\n⚠️ NO HAY BOTÓN DE ESCONDERSE ⚠️\n\n¡PURO MOVIMIENTO!',
            icon: Icons.gamepad,
            color: const Color(0xFF00FF00),
          ),
          ArcTutorialSlide(
            title: 'ESTRATEGIA',
            description: 'Cada evidencia aumenta la dificultad.\n\nUsa obstáculos para romper línea de visión.\n\n¡Mantente en movimiento constante!',
            icon: Icons.lightbulb_outline,
            color: const Color(0xFF00FF00),
          ),
        ];

      default:
        return [
          ArcTutorialSlide(
            title: 'SOBREVIVE',
            description: 'Escapa antes de que sea tarde.',
            icon: Icons.warning,
            color: Colors.red,
          ),
        ];
    }
  }
}

class ArcTutorialSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  ArcTutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
