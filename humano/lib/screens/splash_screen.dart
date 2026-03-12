import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth_screen.dart';
import 'menu_screen.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Forzar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Configurar animación de fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    // Iniciar fade in
    _fadeController.forward();
    
    _checkAuthAndNavigate();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Mostrar el logo por 6 segundos
    await Future.delayed(const Duration(milliseconds: 6000));
    
    if (!mounted) return;
    
    // Fade out lento (1.5 segundos)
    await _fadeController.reverse();
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Si aún no sabemos si está autenticado, esperar un poco más
    int attempts = 0;
    while (authProvider.isLoading && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    if (!mounted) return;

    // Navegar según el estado de autenticación
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.red[900],
                  size: 100,
                ),
                const SizedBox(height: 40),
                
                // Nombre de la empresa
                Text(
                  'E I D O L O N',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 28,
                    letterSpacing: 5,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'C O N C E P T S',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 20,
                    letterSpacing: 6,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Subtítulo
                Text(
                  'Grupo de Investigación de\nConsecuencias Digitales',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    letterSpacing: 2,
                    color: Colors.grey[600],
                    height: 1.8,
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
