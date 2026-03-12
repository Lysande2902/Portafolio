import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tutorial overlay que aparece la primera vez que juegas
/// Enseña controles básicos del juego
/// 
/// Features:
/// - 5 sequential steps covering all basic controls
/// - Fade in/out animations (300ms)
/// - Progress indicator
/// - Skip button
/// - High contrast text (22px+)
/// - Large touch targets (48x48 dp minimum)
class FirstTimeTutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const FirstTimeTutorialOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<FirstTimeTutorialOverlay> createState() => _FirstTimeTutorialOverlayState();
}

class _FirstTimeTutorialOverlayState extends State<FirstTimeTutorialOverlay> 
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'MOVIMIENTO',
      message: 'Arrastra el joystick (abajo izquierda)\npara moverte por el mapa',
      icon: Icons.gamepad,
      alignment: Alignment.bottomLeft,
      arrowDirection: ArrowDirection.down,
    ),
    TutorialStep(
      title: 'ESCONDERSE',
      message: 'Presiona el botón morado\npara esconderte del enemigo',
      icon: Icons.visibility_off,
      alignment: Alignment.bottomRight,
      arrowDirection: ArrowDirection.down,
    ),
    TutorialStep(
      title: 'FRAGMENTOS',
      message: 'Recolecta los 5 fragmentos brillantes\nacercándote a ellos',
      icon: Icons.auto_awesome,
      alignment: Alignment.center,
      arrowDirection: ArrowDirection.up,
    ),
    TutorialStep(
      title: 'ESTABILIDAD MENTAL',
      message: 'El temporizador de estabilidad (arriba izquierda) cuenta atrás.\nSi llega a 00:00:00, el sistema colapsa.',
      icon: Icons.timer,
      alignment: Alignment.topLeft,
      arrowDirection: ArrowDirection.up,
    ),
    TutorialStep(
      title: '¡LISTO!',
      message: 'Escapa del enemigo y encuentra la salida.\n¡Buena suerte!',
      icon: Icons.check_circle,
      alignment: Alignment.center,
      arrowDirection: ArrowDirection.none,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize fade animation controller
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

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
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

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _nextStep,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Stack(
            children: [
              // Contenido principal del tutorial
              Align(
                alignment: step.alignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 400,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade700,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            step.icon,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Título
                        Text(
                          step.title,
                          style: GoogleFonts.vt323(
                            fontSize: 32,
                            color: Colors.cyan.shade300,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Mensaje
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.cyan.shade700, width: 2),
                            ),
                            child: Text(
                              step.message,
                              style: GoogleFonts.vt323(
                                fontSize: 20,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Botón continuar (48x48 minimum touch target)
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan.shade700,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              _currentStep == _steps.length - 1 ? 'EMPEZAR' : 'SIGUIENTE',
                              style: GoogleFonts.vt323(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Header con indicador de progreso y botón saltar
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicador de progreso
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _steps.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentStep
                                  ? Colors.cyan.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      
                      // Botón saltar (48x48 minimum touch target)
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
              ),
              

            ],
          ),
        ),
      ),
    );
  }
}

enum ArrowDirection { up, down, left, right, none }

class TutorialStep {
  final String title;
  final String message;
  final IconData icon;
  final Alignment alignment;
  final ArrowDirection arrowDirection;

  TutorialStep({
    required this.title,
    required this.message,
    required this.icon,
    required this.alignment,
    required this.arrowDirection,
  });
}
