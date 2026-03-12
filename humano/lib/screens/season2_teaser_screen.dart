import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';
import 'menu_screen.dart';

/// Teaser de Temporada 2 - FUSIÓN: Impacto Emocional + Efectos Visuales Sutiles
/// Silencio absoluto. Inquietante. Perturbador.
/// Combina el guión original con efectos visuales minimalistas
class Season2TeaserScreen extends StatefulWidget {
  const Season2TeaserScreen({super.key});

  @override
  State<Season2TeaserScreen> createState() => _Season2TeaserScreenState();
}

class _Season2TeaserScreenState extends State<Season2TeaserScreen>
    with TickerProviderStateMixin {
  int _currentPhase = 0;
  String _currentText = '';
  bool _showContinueButton = false;
  
  // Video controllers
  VideoPlayerController? _loboVideoController;
  VideoPlayerController? _logoVideoController;
  
  // Animaciones sutiles
  late AnimationController _fadeController;
  late AnimationController _breatheController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();

    // Fade suave para transiciones
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Respiración sutil para crear tensión
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _startTeaser();
  }

  void _startTeaser() async {
    // FASE 0: Silencio absoluto. Pantalla negra. Ni un susurro.
    await Future.delayed(const Duration(seconds: 4));
    
    // FASE 1: Texto aparece muy lento, como si el sistema dudara
    if (!mounted) return;
    await _showPhase1();
    
    // FASE 2: Texto tenue, casi borrado - suspenso
    if (!mounted) return;
    await _showPhase2();
    
    // FASE 3: El Lobo - centrado, quietísimo, pidiendo silencio
    if (!mounted) return;
    await _showPhase3();
    
    // FASE 4: Títulos y revelación
    if (!mounted) return;
    await _showPhase4();
    
    // FASE 5: Logo formándose
    if (!mounted) return;
    await _showPhase5();
    
    // FASE 6: Susurro final - escalofriante
    if (!mounted) return;
    await _showPhase6();
    
    // Mostrar botón de continuar
    if (!mounted) return;
    setState(() => _showContinueButton = true);
  }

  // FASE 1: "Pensaste que tres eran suficientes."
  Future<void> _showPhase1() async {
    setState(() {
      _currentPhase = 1;
      _currentText = '';
    });
    
    _fadeController.forward(from: 0);
    
    // Texto muy lento, como si dudara
    await _typeTextSlow('Pensaste que tres eran suficientes.');
    await Future.delayed(const Duration(seconds: 5));
    
    setState(() => _currentText = '');
    await Future.delayed(const Duration(seconds: 2));
    
    await _typeTextSlow('Pero los registros nunca dejaron de contar.');
    await Future.delayed(const Duration(seconds: 4));
    
    setState(() => _currentText = '');
  }

  // FASE 2: Suspenso - "Algo más viene..."
  Future<void> _showPhase2() async {
    setState(() {
      _currentPhase = 2;
      _currentText = '';
    });
    
    // Texto más tenue, casi borrado - dejando el misterio
    await _typeTextFaint('Pero hay algo más...');
    await Future.delayed(const Duration(seconds: 5));
    
    setState(() => _currentText = '');
    await Future.delayed(const Duration(seconds: 2));
    
    await _typeTextFaint('Algo que nunca debió olvidarse.');
    await Future.delayed(const Duration(seconds: 4));
    
    setState(() => _currentText = '');
    
    // Pantalla negra total
    await Future.delayed(const Duration(seconds: 3));
  }

  // FASE 3: El Lobo - quietísimo, pidiendo silencio
  Future<void> _showPhase3() async {
    setState(() => _currentPhase = 3);
    
    // Vibración sutil cuando aparece el Lobo
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
    
    try {
      // Video del Lobo
      _loboVideoController = VideoPlayerController.asset('assets/videos/lobo_despe.mp4');
      await _loboVideoController!.initialize();
      _loboVideoController!.setLooping(false);
      _loboVideoController!.setVolume(0.0); // Sin sonido
      
      setState(() {});
      _loboVideoController!.play();
      
      // El Lobo levanta una mano, se despide, luego pide silencio
      await Future.delayed(const Duration(seconds: 6));
      
    } catch (e) {
      print('Error loading lobo video: $e');
      // Fallback: mostrar imagen estática
      await Future.delayed(const Duration(seconds: 6));
    }
    
    // La pantalla no se corta. Solo el Lobo pidiendo que calles...
    await Future.delayed(const Duration(seconds: 3));
  }

  // FASE 4: Títulos y revelación
  Future<void> _showPhase4() async {
    setState(() {
      _currentPhase = 4;
      _currentText = '';
    });
    
    await _typeTextBold('TEMPORADA 2');
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _currentText = '');
    await Future.delayed(const Duration(seconds: 1));
    
    await _typeTextBold('FRAGMENTOS DEL ERROR');
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() => _currentText = '');
    await Future.delayed(const Duration(seconds: 1));
    
    // Muy tenue debajo
    await _typeTextFaint('Quizá… no fue él.');
    await Future.delayed(const Duration(seconds: 4));
    
    setState(() => _currentText = '');
    
    // Silencio. Corte a negro.
    await Future.delayed(const Duration(seconds: 2));
  }

  // FASE 5: Logo formándose
  Future<void> _showPhase5() async {
    setState(() => _currentPhase = 5);
    
    try {
      _logoVideoController = VideoPlayerController.asset('assets/videos/logo_creacion.mp4');
      await _logoVideoController!.initialize();
      _logoVideoController!.setLooping(false);
      _logoVideoController!.setVolume(0.0); // Sin sonido
      
      setState(() {});
      _logoVideoController!.play();
      
      await Future.delayed(const Duration(seconds: 4));
      
    } catch (e) {
      print('Error loading logo video: $e');
      // Fallback: logo estático
      await Future.delayed(const Duration(seconds: 3));
    }
    
    await Future.delayed(const Duration(seconds: 2));
  }

  // FASE 6: Susurro final - escalofriante
  Future<void> _showPhase6() async {
    setState(() {
      _currentPhase = 6;
      _currentText = '';
    });
    
    // Susurro casi imperceptible
    await _typeTextWhisper('…hermano.');
    
    // Vibración muy sutil en "hermano"
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
    
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() => _currentText = '');
    await Future.delayed(const Duration(seconds: 2));
    
    // Texto final distorsionado
    await _typeTextDistorted('¿Cuántos más olvidaste?');
    
    // Vibración más intensa en la pregunta final
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 300);
    }
    
    await Future.delayed(const Duration(seconds: 4));
    
    setState(() => _currentText = '');
  }

  // Métodos de escritura con diferentes velocidades y estilos
  
  Future<void> _typeTextSlow(String text) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() => _currentText = text.substring(0, i));
      await Future.delayed(const Duration(milliseconds: 150)); // Muy lento
    }
  }

  Future<void> _typeTextFaint(String text) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() => _currentText = text.substring(0, i));
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  Future<void> _typeTextBold(String text) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() => _currentText = text.substring(0, i));
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _typeTextWhisper(String text) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() => _currentText = text.substring(0, i));
      await Future.delayed(const Duration(milliseconds: 200)); // Muy lento y susurrado
    }
  }

  Future<void> _typeTextDistorted(String text) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() => _currentText = text.substring(0, i));
      await Future.delayed(const Duration(milliseconds: 130));
    }
  }

  void _skipTeaser() {
    _loboVideoController?.dispose();
    _logoVideoController?.dispose();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breatheController.dispose();
    _loboVideoController?.dispose();
    _logoVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pantalla negra absoluta
      body: Stack(
        children: [
          // Contenido principal
          Center(child: _buildPhaseContent()),
          
          // Botón de continuar (solo al final)
          if (_showContinueButton)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: _skipTeaser,
                  child: Text(
                    'CONTINUAR',
                    style: GoogleFonts.courierPrime(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case 0:
        return const SizedBox.shrink(); // Silencio absoluto
      case 1:
        return _buildTextPhase(opacity: 0.9); // Texto inicial
      case 2:
        return _buildTextPhase(opacity: 0.4); // Texto tenue - suspenso
      case 3:
        return _buildLoboVideo(); // Video del Lobo
      case 4:
        return _buildTitlesPhase(); // Títulos
      case 5:
        return _buildLogoVideo(); // Logo formándose
      case 6:
        return _buildFinalWhisper(); // Susurro final
      default:
        return const SizedBox.shrink();
    }
  }

  // Fase de texto con opacidad variable
  Widget _buildTextPhase({required double opacity}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _breatheController,
        builder: (context, child) {
          return Transform.scale(
            scale: _breatheAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _currentText,
                style: GoogleFonts.courierPrime(
                  fontSize: 18,
                  color: Colors.white.withOpacity(opacity),
                  letterSpacing: 2,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  // Video del Lobo - pantalla completa
  Widget _buildLoboVideo() {
    if (_loboVideoController != null && _loboVideoController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _loboVideoController!.value.size.width,
            height: _loboVideoController!.value.size.height,
            child: VideoPlayer(_loboVideoController!),
          ),
        ),
      );
    } else {
      // Fallback: imagen estática del lobo
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/lobo_mask.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  // Fase de títulos
  Widget _buildTitlesPhase() {
    final isBold = _currentText.contains('TEMPORADA') || _currentText.contains('FRAGMENTOS');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _currentText,
        style: GoogleFonts.courierPrime(
          fontSize: isBold ? 28 : 14,
          color: isBold 
              ? const Color(0xFF8B0000) 
              : Colors.white.withOpacity(0.3),
          letterSpacing: isBold ? 4 : 1,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Logo formándose con fondo negro
  Widget _buildLogoVideo() {
    if (_logoVideoController != null && _logoVideoController!.value.isInitialized) {
      return Container(
        width: 250,
        height: 250,
        color: Colors.black, // Fondo negro para el logo
        child: AspectRatio(
          aspectRatio: _logoVideoController!.value.aspectRatio,
          child: VideoPlayer(_logoVideoController!),
        ),
      );
    } else {
      // Fallback: logo estático con fondo negro
      return Container(
        width: 200,
        height: 200,
        color: Colors.black, // Fondo negro
        child: Center(
          child: Image.asset(
            'assets/icon/logo_cond.png',
            fit: BoxFit.contain,
          ),
        ),
      );
    }
  }

  // Susurro final - escalofriante
  Widget _buildFinalWhisper() {
    final isWhisper = _currentText.contains('hermano');
    
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        return Transform.scale(
          scale: isWhisper ? _breatheAnimation.value : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _currentText,
              style: GoogleFonts.courierPrime(
                fontSize: isWhisper ? 12 : 16,
                color: isWhisper
                    ? Colors.white.withOpacity(0.2) // Casi imperceptible
                    : Colors.red.withOpacity(0.8), // Distorsionado
                letterSpacing: isWhisper ? 0.5 : 2,
                fontStyle: isWhisper ? FontStyle.italic : FontStyle.normal,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

}
