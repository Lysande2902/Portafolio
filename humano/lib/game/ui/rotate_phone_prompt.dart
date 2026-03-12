import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Pantalla que pide al usuario girar el teléfono antes de mostrar cinemáticas
class RotatePhonePrompt extends StatefulWidget {
  final VoidCallback onContinue;
  
  const RotatePhonePrompt({
    super.key,
    required this.onContinue,
  });

  @override
  State<RotatePhonePrompt> createState() => _RotatePhonePromptState();
}

class _RotatePhonePromptState extends State<RotatePhonePrompt> 
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    
    // Mantener vertical mientras se muestra el aviso
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de teléfono rotando
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: math.sin(_rotationController.value * math.pi * 2) * 0.3,
                      child: Icon(
                        Icons.screen_rotation,
                        color: Colors.red[300],
                        size: 80,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Texto principal
                Text(
                  'GIRA TU DISPOSITIVO',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 24,
                    letterSpacing: 3,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Subtexto
                Text(
                  'Para una mejor experiencia,\ncoloca tu teléfono en horizontal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: Colors.grey[500],
                    height: 1.8,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Botón para continuar
                ElevatedButton(
                  onPressed: () {
                    // Cambiar a horizontal y continuar
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]).then((_) {
                      widget.onContinue();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.red.withOpacity(0.7), width: 2),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '[ CONTINUAR ]',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 16,
                      color: Colors.red[300],
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
