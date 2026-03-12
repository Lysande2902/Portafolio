import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key});

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  int _currentLineIndex = 0;
  bool _showButton = false;

  final List<String> _endingLines = [
    'Has visto la verdad.',
    '',
    'Siete pecados.',
    'Siete víctimas.',
    'Una cámara.',
    '',
    '¿Valió la pena?',
    '',
    'Los likes siguen subiendo.',
    'Las víctimas siguen sufriendo.',
    '',
    'Pero tú...',
    'Tú ya sabes.',
    '',
    'FIN',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _startEndingSequence();
  }

  void _startEndingSequence() async {
    // Esperar 2 segundos antes de empezar
    await Future.delayed(const Duration(seconds: 2));
    
    // Mostrar líneas una por una
    for (int i = 0; i < _endingLines.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _currentLineIndex = i;
      });
      
      _fadeController.forward(from: 0);
      
      // Esperar más tiempo en líneas importantes
      final isImportantLine = _endingLines[i].contains('FIN') || 
                              _endingLines[i].contains('¿Valió la pena?');
      await Future.delayed(Duration(
        milliseconds: isImportantLine ? 3000 : 2000,
      ));
    }
    
    // Mostrar botón después de todas las líneas
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _showButton = true;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Líneas de texto
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Text(
                _currentLineIndex < _endingLines.length 
                    ? _endingLines[_currentLineIndex]
                    : '',
                style: GoogleFonts.courierPrime(
                  color: Colors.white,
                  fontSize: _endingLines[_currentLineIndex] == 'FIN' ? 64 : 28,
                  fontWeight: _endingLines[_currentLineIndex] == 'FIN' 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Botón para volver al menú
          if (_showButton)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'VOLVER AL MENÚ',
                      style: GoogleFonts.courierPrime(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Indicador REC (siempre grabando)
          Positioned(
            top: 30,
            right: 30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'REC',
                  style: GoogleFonts.courierPrime(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
