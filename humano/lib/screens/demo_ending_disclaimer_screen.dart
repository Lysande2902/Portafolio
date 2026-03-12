import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/screens/demo_ending_screen.dart';
import 'package:humano/screens/archive_screen.dart';
import 'package:humano/core/preferences/disclaimer_preference_manager.dart';

/// Pantalla de advertencia mejorada antes del final de la demo
/// Proporciona advertencias específicas y opciones claras
/// Guarda la preferencia del jugador para futuras sesiones
class DemoEndingDisclaimerScreen extends StatefulWidget {
  const DemoEndingDisclaimerScreen({super.key});
  
  @override
  State<DemoEndingDisclaimerScreen> createState() => _DemoEndingDisclaimerScreenState();
}

class _DemoEndingDisclaimerScreenState extends State<DemoEndingDisclaimerScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final DisclaimerPreferenceManager _preferenceManager = DisclaimerPreferenceManager();

  @override
  void initState() {
    super.initState();
    
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
  
  Future<void> _onContinue() async {
    await _preferenceManager.setDemoEndingSkipped(false);
    await _fadeController.reverse();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DemoEndingScreen(),
        ),
      );
    }
  }
  
  Future<void> _onSkip() async {
    await _preferenceManager.setDemoEndingSkipped(true);
    await _fadeController.reverse();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ArchiveScreen(),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A), // Neutral dark gray
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono de advertencia
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade600,
                      size: 80,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Título
                    Text(
                      'ADVERTENCIA DE CONTENIDO',
                      style: GoogleFonts.vt323(
                        fontSize: 42,
                        color: Colors.amber.shade600,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Advertencias específicas
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade800, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'El siguiente contenido incluye:',
                            style: GoogleFonts.vt323(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildWarningItem('Temas de salud mental y crisis emocional'),
                          _buildWarningItem('Referencias a autolesión'),
                          _buildWarningItem('Contenido emocionalmente intenso'),
                          _buildWarningItem('Simulación de acoso digital y doxxeo'),
                          _buildWarningItem('Contenido perturbador'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Contexto del demo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade700, width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade300,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ESTE ES EL FINAL DE LA DEMO',
                            style: GoogleFonts.vt323(
                              fontSize: 22,
                              color: Colors.blue.shade300,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'El juego completo explorará estos temas con mayor profundidad y contexto. '
                            'Este final busca generar reflexión sobre el impacto real de nuestras acciones en redes sociales.',
                            style: GoogleFonts.vt323(
                              fontSize: 18,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Aclaración de seguridad
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade900.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.cyan.shade700, width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.privacy_tip_outlined,
                            color: Colors.cyan.shade300,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'TU PRIVACIDAD ESTÁ SEGURA:',
                            style: GoogleFonts.vt323(
                              fontSize: 20,
                              color: Colors.cyan.shade300,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Ningún dato real será compartido\n'
                            '• Tu cámara NO se activará\n'
                            '• Nadie te está viendo realmente\n'
                            '• Es solo una simulación artística',
                            style: GoogleFonts.vt323(
                              fontSize: 18,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Mensaje de apoyo
                    Text(
                      'Si necesitas apoyo, recuerda que hay recursos disponibles.\n'
                      'Tu bienestar es lo más importante.',
                      style: GoogleFonts.vt323(
                        fontSize: 18,
                        color: Colors.grey.shade400,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botón SALTAR
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _onSkip,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade600, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'SALTAR',
                                style: GoogleFonts.vt323(
                                  fontSize: 24,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // Botón CONTINUAR
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _onContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'CONTINUAR',
                                style: GoogleFonts.vt323(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Nota final
                    Text(
                      'Puedes salir en cualquier momento presionando atrás',
                      style: GoogleFonts.vt323(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.vt323(
              fontSize: 20,
              color: Colors.amber.shade400,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.vt323(
                fontSize: 20,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
