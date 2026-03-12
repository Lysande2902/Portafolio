import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialOverlay extends StatefulWidget {
  final String arcId;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const TutorialOverlay({
    super.key,
    required this.arcId,
    required this.onStart,
    required this.onSkip,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentSlide = 0;
  bool _showConfirmation = true; // Show "Watch Tutorial?" first
  late final List<Map<String, dynamic>> _slides;

  @override
  void initState() {
    super.initState();
    _slides = _getSlidesForArc(widget.arcId);
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      setState(() {
        _currentSlide++;
      });
    } else {
      widget.onStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showConfirmation) {
      return _buildConfirmationDialog();
    }

    return GestureDetector(
      onTap: _nextSlide,
      child: Scaffold(
        backgroundColor: Colors.black, // Opaque black background
        body: SafeArea(
          child: Stack(
            children: [
              // Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 70, 30, 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 350,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Icon(
                          _slides[_currentSlide]['icon'] as IconData,
                          size: 48,
                          color: Colors.red[700],
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          _slides[_currentSlide]['title'] as String,
                          style: GoogleFonts.cinzel(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Flexible(
                          child: Text(
                            _slides[_currentSlide]['description'] as String,
                            style: GoogleFonts.lora(
                              fontSize: 15,
                              color: Colors.grey[400],
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationDialog() {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿VER TUTORIAL?',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Deseas ver la guía de supervivencia?',
                style: GoogleFonts.lora(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'NO',
                      style: GoogleFonts.courierPrime(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmation = false;
                      });
                    },
                    child: Text(
                      'SÍ',
                      style: GoogleFonts.courierPrime(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSlidesForArc(String arcId) {
    // Common slides
    final controlsSlide = {
      'title': 'CONTROLES',
      'description': 'Joystick izquierdo para moverte. Botón derecho para interactuar.',
      'icon': Icons.gamepad,
    };

    final hidingSlide = {
      'title': 'ESCONDITES',
      'description': 'Usa armarios y zonas oscuras para ocultarte del enemigo.',
      'icon': Icons.meeting_room,
    };

    // Arc specific slides
    switch (arcId) {
      case 'arc_1_gula':
        return [
          {
            'title': 'OBJETIVO',
            'description': 'Recolecta 5 fragmentos de evidencia en el comedor.',
            'icon': Icons.restaurant,
          },
          controlsSlide,
          {
            'title': 'DISTRACCIÓN',
            'description': 'Lanza comida para distraer a Mateo.',
            'icon': Icons.fastfood,
          },
          hidingSlide,
        ];
      case 'arc_2_greed':
        return [
          {
            'title': 'OBJETIVO',
            'description': 'Recupera tus pertenencias en el almacén.',
            'icon': Icons.inventory_2,
          },
          controlsSlide,
          {
            'title': 'DISTRACCIÓN',
            'description': 'Lanza monedas para distraer a la Rata.',
            'icon': Icons.monetization_on,
          },
          hidingSlide,
        ];
      case 'arc_3_envy':
        return [
          {
            'title': 'OBJETIVO',
            'description': 'Fotografía las pruebas en la galería.',
            'icon': Icons.camera_alt,
          },
          controlsSlide,
          {
            'title': 'DEFENSA',
            'description': 'Usa el flash para cegar a Sofía.',
            'icon': Icons.flash_on,
          },
          hidingSlide,
        ];
      default:
        return [
          {
            'title': 'SOBREVIVE',
            'description': 'Escapa antes de que sea tarde.',
            'icon': Icons.warning,
          },
          controlsSlide,
        ];
    }
  }
}
