import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../providers/arc_progress_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/audio_provider.dart';
import '../data/providers/arc_data_provider.dart';
import 'package:humano/screens/arc_intro_screen.dart';
import '../widgets/monitor_effect.dart';
import 'package:humano/screens/arc_game_screen.dart';
import 'package:humano/screens/intro_screen.dart';
import '../providers/theme_provider.dart';
import '../core/theme/app_theme.dart';
import '../data/models/arc_progress.dart';

class ArcSelectionScreen extends StatefulWidget {
  const ArcSelectionScreen({super.key});

  @override
  State<ArcSelectionScreen> createState() => _ArcSelectionScreenState();
}

class _ArcSelectionScreenState extends State<ArcSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final ArcDataProvider _arcDataProvider = ArcDataProvider();
  
  // Season 2 reveal animation
  final List<bool> _season2ArcsRevealed = [false, false, false, false];
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _initVideo();
    _initAudio();
    _loadProgress();
    _startSeason2Reveal();

    // Asegurar que la música equipada siga sonando
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = Provider.of<AudioProvider>(context, listen: false);
      audio.playArcMusic('current');
    });
  }
  
  void _startSeason2Reveal() {
    // Reveal Season 2 arcs one by one with delay
    int index = 0;
    _revealTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (index < _season2ArcsRevealed.length) {
        if (mounted) {
          setState(() {
            _season2ArcsRevealed[index] = true;
          });
        }
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  void _initVideo() {
    print('Iniciando video de selección de arcos...');
    _videoController = VideoPlayerController.asset('assets/videos/lobby.mp4')
      ..initialize().then((_) {
        print('Video inicializado correctamente');
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController.setLooping(true);
          _videoController.setVolume(0.0);
          _videoController.play();
        }
      }).catchError((error) {
        print('Error initializing video: $error');
      });
  }

  void _initAudio() async {
    // Usar la música global del AudioProvider
    Provider.of<AudioProvider>(context, listen: false).playArcMusic('current');
  }

  void _loadProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final arcProgressProvider = Provider.of<ArcProgressProvider>(context, listen: false);
    
    final user = authProvider.currentUser;
    if (user != null) {
      await arcProgressProvider.loadProgress(user.uid);
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        title: Text(
          'MECÁNICAS POR ARCO',
          style: GoogleFonts.shareTechMono(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildArcTutorial(
                'PROTOCOLOS DE HACKEO',
                'Intervención directa en el núcleo de conciencia de Alex.\n'
                'Fase 1: Estabilización de parámetros (Frecuencia/Captura).\n'
                'Fase 2: Reestructuración de datos (Sintaxis/Depuración).',
              ),
              const SizedBox(height: 16),
              _buildArcTutorial(
                'ESTABILIDAD DEL NODO',
                'Cada error de hackeo drena la integridad psíquica.\n'
                'Si el núcleo se corrompe (0%), la conexión se pierde.\n'
                'Ciertos procesos requieren precisión temporal absoluta.',
              ),
              const SizedBox(height: 16),
              _buildArcTutorial(
                'SEGURIDAD DE DATOS',
                'Los sectores críticos se restauran tras la Fase 1.\n'
                'No hay respaldo de datos en caso de fallo crítico.\n'
                'El acceso es bajo tu propia responsabilidad cognitiva.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ENTENDIDO',
              style: GoogleFonts.shareTechMono(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArcTutorial(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.shareTechMono(
            color: Colors.red[300],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.shareTechMono(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _glitchController.dispose();
    _ambientPlayer.dispose();
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: MonitorEffect(
        noiseIntensity: 0.02,
        child: Stack(
          fit: StackFit.expand,
          children: [
          // 1. FONDO TÉCNICO
          Container(color: appTheme.backgroundColor),
          Positioned.fill(
            child: CustomPaint(
              painter: TechnicalSelectionPainter(
                animationValue: _glitchController.value,
                theme: appTheme,
              ),
            ),
          ),

          // Latido de Conciencia (Pulse of Conscience) - Coherencia con Prólogo
          Center(
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                final scale = 1.0 + (_glitchController.value * 0.15);
                final opacity = 0.03 + (_glitchController.value * 0.05);
                return Container(
                  width: 400 * scale,
                  height: 400 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.primaryColor.withOpacity(opacity),
                        blurRadius: 150,
                        spreadRadius: 80,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Scanlines
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(
                  painter: ScanlinePainter(),
                ),
              ),
            ),
          ),

          // RECORDATORIO DE VÍCTOR (Punto 3 de la lista)
          Positioned(
            top: 2,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_missed, color: appTheme.primaryColor, size: 10),
                      const SizedBox(width: 6),
                      Text(
                        '15 LLAMADAS PERDIDAS - VÍCTOR',
                        style: GoogleFonts.shareTechMono(
                          color: appTheme.primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Efecto VHS sutil
          AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              return CustomPaint(
                painter: VHSEffectPainter(
                  animationValue: _glitchController.value,
                ),
              );
            },
          ),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header con botón de regreso
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Botón de regreso
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        color: Colors.red[900],
                      ),
                      const SizedBox(width: 10),
                      // Título
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EL JUICIO · EN CURSO',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 14,
                                color: Colors.grey[400],
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Elige el recuerdo que quieres enfrentar',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 10,
                                color: Colors.grey[700],
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Carrusel de arcos (horizontal)
                Expanded(
                  child: Consumer<ArcProgressProvider>(
                    builder: (context, progressProvider, child) {
                      if (progressProvider.isLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.red[900],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Cargando protocolos...',
                                style: GoogleFonts.shareTechMono(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (progressProvider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[400],
                                size: 48,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                progressProvider.error!,
                                style: GoogleFonts.shareTechMono(
                                  fontSize: 14,
                                  color: Colors.red[400],
                                  letterSpacing: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadProgress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[900],
                                ),
                                child: Text(
                                  'REINTENTAR',
                                  style: GoogleFonts.shareTechMono(
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final allArcs = _arcDataProvider.getAllArcs();
                      final List<dynamic> displayArcs = List.from(allArcs);

                      return PageView.builder(
                        itemCount: displayArcs.length,
                        controller: PageController(viewportFraction: 0.8), // Un poco más ancho
                        itemBuilder: (context, index) {
                          final arc = displayArcs[index];
                          final progress = progressProvider.getProgress(arc.id);
                          final isLocked = !progressProvider.isArcUnlocked(arc);
                          
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
                              child: _buildArcPostCard(arc, progress, isLocked),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

              ],
            ),
          ),

          // Indicador REC
          Positioned(
            bottom: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                return Opacity(
                  opacity: _glitchController.value > 0.5 ? 1.0 : 0.3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'REC',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSeason2ArcCard(dynamic arc, int arcNumber) {
    // Creepy phrases for each Season 2 sin
    final Map<int, String> creepyPhrases = {
      4: 'El deseo que nunca se sacia...',
      5: 'La máscara que nunca cae...',
      6: 'El silencio que todo consume...',
      7: 'La furia que arde eternamente...',
    };
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => _showSeason2ComingSoon(arc, creepyPhrases[arcNumber]!),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 300,
              maxHeight: constraints.maxHeight * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: Colors.red[900]!.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Fondo técnico bloqueado
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: _buildProtocolBackground(arc.id),
                  ),
                ),
                
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono con pulso sutil
                        AnimatedBuilder(
                          animation: _glitchController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 0.3 + (_glitchController.value * 0.4),
                              child: const Icon(
                                Icons.lock_outline,
                                color: Colors.red,
                                size: 28,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'PROTOCOLO_${arc.id.split('_')[1].toUpperCase()}',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.red[900]!.withOpacity(0.5),
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          arc.title.toUpperCase(),
                          style: GoogleFonts.shareTechMono(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          creepyPhrases[arcNumber]!.toUpperCase(),
                          style: GoogleFonts.shareTechMono(
                            color: Colors.red[900]!.withOpacity(0.4),
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Text(
                            'TEMPORADA_2 // BLOQUEADO',
                            style: GoogleFonts.shareTechMono(
                              color: Colors.grey[800],
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const IntroScreen()),
             );
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 300,
              maxHeight: constraints.maxHeight * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              border: Border.all(
                color: Colors.red[900]!.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red[900]!.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: _buildProtocolBackground('history'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ARCHIVO_MAESTRO // DESBLOQUEADO',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.red[900],
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HISTORIA OFICIAL',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'LA VERDAD SOBRE VÍCTOR // FINAL',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.red[400],
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'REPRODUCIR_VERDAD',
                            style: GoogleFonts.shareTechMono(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeaserCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => _showSeasonTwoTeaser(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 300,
              maxHeight: constraints.maxHeight * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: Colors.blue[900]!.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[900]!.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: _buildProtocolBackground('teaser'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _glitchController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _glitchController.value * 0.1,
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.blue[400],
                                size: 32,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ARCHIVO_CLASIFICADO',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.blue[900],
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TEMPORADA 2',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'TEASER_EXCLUSIVO // REVELACIÓN',
                          style: GoogleFonts.shareTechMono(
                            color: Colors.blue[300]!.withOpacity(0.6),
                            fontSize: 8,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue[900]!.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.blue[900]!.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            'REPRODUCIR_ARCHIVO',
                            style: GoogleFonts.shareTechMono(
                              color: Colors.blue[100],
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Color de acento por arco
  Color _getArcAccentColor(String arcId, bool isLocked) {
    if (isLocked) return Colors.white12;
    switch (arcId) {
      case 'arc_0_inicio': return Colors.white54;
      case 'arc_1_envidia_lujuria': return const Color(0xFFB44FFF); // Morado
      case 'arc_2_consumo_codicia': return const Color(0xFFFFB300); // Ámbar
      case 'arc_3_soberbia_pereza': return const Color(0xFF00B8FF); // Azul eléctrico
      case 'arc_4_ira': return Colors.red[700]!;                   // Rojo
      default: return Colors.white24;
    }
  }

  Widget _buildArcPostCard(dynamic arc, dynamic progress, bool isLocked) {
    final accentColor = _getArcAccentColor(arc.id, isLocked);
    final bool isActive = !isLocked && (progress == null || progress.completionPercentage < 100);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => _handleArcSelection(arc, isLocked),
          child: AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              final pulseOpacity = isActive
                  ? 0.3 + (_glitchController.value * 0.5)
                  : 0.0;
              return Container(
                constraints: BoxConstraints(
                  maxWidth: 300,
                  maxHeight: constraints.maxHeight * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                    color: isActive
                        ? accentColor.withOpacity(pulseOpacity)
                        : isLocked
                            ? Colors.white10
                            : accentColor.withOpacity(0.25),
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: accentColor.withOpacity(pulseOpacity * 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: child,
              );
            },
            child: Stack(
              children: [
                // Miniatura o fondo técnico del protocolo
                Positioned.fill(
                  child: Opacity(
                    opacity: isLocked ? 0.1 : 0.2,
                    child: _buildProtocolBackground(arc.id),
                  ),
                ),
                
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLocked ? Icons.lock_outline : Icons.memory,
                          color: isLocked ? Colors.grey[800] : accentColor,
                          size: 28,
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'PROTOCOLO ${arc.number}',
                          style: GoogleFonts.shareTechMono(
                            color: isLocked ? Colors.grey[700] : accentColor.withOpacity(0.8),
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          arc.title.toUpperCase(),
                          style: GoogleFonts.shareTechMono(
                            color: isLocked ? Colors.grey[600] : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          arc.subtitle,
                          style: GoogleFonts.shareTechMono(
                            color: isLocked ? Colors.grey[800] : Colors.grey[500],
                            fontSize: 9,
                            letterSpacing: 0.5,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (!isLocked && progress != null) ...[
                          Column(
                            children: [
                              LinearProgressIndicator(
                                value: progress.completionPercentage / 100,
                                backgroundColor: Colors.white.withOpacity(0.05),
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor.withOpacity(0.7)),
                                minHeight: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'COMPLETADO: ${progress.completionPercentage.toInt()}%',
                                style: GoogleFonts.shareTechMono(color: Colors.grey[800], fontSize: 8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isLocked ? Colors.transparent : accentColor.withOpacity(0.08),
                            border: Border.all(
                                color: isLocked ? Colors.white.withOpacity(0.05) : accentColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            isLocked ? 'ACCESO BLOQUEADO' : 'ENTRAR',
                            style: GoogleFonts.shareTechMono(
                              color: isLocked ? Colors.grey[800] : accentColor.withOpacity(0.9),
                              fontSize: 9,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProtocolBackground(String id) {
    // Retorna una textura técnica diferente según el protocolo
    return CustomPaint(
      painter: ProtocolTexturePainter(id: id),
    );
  }

  void _handleArcSelection(arc, bool isLocked) {
    if (isLocked) {
      _showLockedDialog(arc);
    } else {
      // Show briefing before starting
      _showArcBriefing(arc);
    }
  }

  void _showArcBriefing(arc) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Briefing',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
              child: _ArcBriefingScreen(
                arc: arc, 
                onStart: () => _startArc(arc)

              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }



  bool _isNavigating = false;

  void _startArc(arc) {
    if (_isNavigating) return;
    
    final implementedArcs = [
      'arc_0_inicio',
      'arc_1_envidia_lujuria',
      'arc_2_consumo_codicia',
      'arc_3_soberbia_pereza',
      'arc_4_ira',
    ];
    
    if (implementedArcs.contains(arc.id)) {
      _isNavigating = true;

      // Detener audio ambiental y video para no interferir con la música del arco
      _ambientPlayer.stop();
      _videoController.pause();

      // Cerrar el briefing primero
      Navigator.of(context).pop();

      // Navegar con animación de fade negro
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => ArcIntroScreen(
            arcId: arc.id,
            onComplete: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ArcGameScreen(
                    arcId: arc.id,
                  ),
                ),
              ).then((_) {
                _isNavigating = false;
              });
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: child,
            );
          },
        ),
      ).then((_) => _isNavigating = false);
    } else {
      _showComingSoonDialog(arc);
    }
  }



  void _showLockedDialog(arc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock,
                color: Colors.red[300],
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                'ARCO BLOQUEADO',
                style: GoogleFonts.shareTechMono(
                  fontSize: 20,
                  color: Colors.red[300],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              Text(
                'Completa los arcos anteriores para desbloquear',
                style: GoogleFonts.shareTechMono(
                  fontSize: 14,
                  color: Colors.grey[400],
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'ENTENDIDO',
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSeason2ComingSoon(dynamic arc, String creepyPhrase) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  color: Colors.red[700],
                  size: 42,
                ),
                const SizedBox(height: 16),
                Text(
                  arc.title.toUpperCase(),
                  style: GoogleFonts.pressStart2p(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  creepyPhrase,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 13,
                    color: Colors.red[400],
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.5,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'TEMPORADA 2 - PRÓXIMAMENTE',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 11,
                      color: Colors.red[300],
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  child: Text(
                    'VOLVER',
                    style: GoogleFonts.shareTechMono(
                      color: Colors.white,
                      letterSpacing: 2,
                      fontSize: 13,
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

  void _showSeasonTwoTeaser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SeasonTwoTeaserScreen(),
      ),
    );
  }

  void _showComingSoonDialog(arc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                arc.title,
                style: GoogleFonts.shareTechMono(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                arc.subtitle,
                style: GoogleFonts.shareTechMono(
                  fontSize: 16,
                  color: Colors.grey[400],
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 30),
              Text(
                '[GAMEPLAY EN DESARROLLO]',
                style: GoogleFonts.shareTechMono(
                  fontSize: 14,
                  color: Colors.red[300],
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'VOLVER',
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white,
                    letterSpacing: 2,
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

// Fullscreen Arc Briefing Screen
class _ArcBriefingScreen extends StatefulWidget {
  final dynamic arc;
  final Function() onStart;


  const _ArcBriefingScreen({
    required this.arc,
    required this.onStart,
  });

  @override
  State<_ArcBriefingScreen> createState() => _ArcBriefingScreenState();
}

class _ArcBriefingScreenState extends State<_ArcBriefingScreen> {
  // Linear progression only - selectedPhase removed


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    final arcDataProvider = ArcDataProvider();
    final arcContent = arcDataProvider.getArcContent(widget.arc.id);
    final progressProvider = Provider.of<ArcProgressProvider>(context, listen: false);
    final isCompleted = progressProvider.getStatus(widget.arc.id) == ArcStatus.completed;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          border: Border.all(color: Colors.red[900]!.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.red[900]!.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(color: Colors.red[900]!.withOpacity(0.3), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.red[900], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AUTORIZACIÓN_DE_ACCESO',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PROTOCOLO_${arcContent?.arcNumber ?? widget.arc.number}',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.red[900],
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      arcContent?.title.toUpperCase() ?? widget.arc.title.toUpperCase(),
                      style: GoogleFonts.shareTechMono(
                        fontSize: isSmallScreen ? 20 : 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildCompactInfoRow('DIRECTIVA', arcContent?.briefing.objective ?? 'Recolecta evidencias y sobrevive.'),
                    const SizedBox(height: 15),
                    _buildCompactInfoRow('INTERFAZ', arcContent?.briefing.controls ?? 'Joystick + Disparador'),
                    
                    const SizedBox(height: 25),

                    const SizedBox(height: 25),

                    // PHASE SELECTION REMOVED - ALWAYS LINEAR PROGRESSION AS PER SYSTEM REQUIREMENTS
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red[900]!.withOpacity(0.05),
                        border: Border.all(color: Colors.red[900]!.withOpacity(0.1)),
                      ),
                      child: Text(
                        'AVISO: PROTOCOLO PSÍQUICO EN EJECUCIÓN. NO HAY RESPALDO DE DATOS.',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 9,
                          color: Colors.red[900]!.withOpacity(0.9),
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Interaction Row
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        'ABORTAR',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onStart();

                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.red[900],

                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        'EJECUTAR_PROTOCOLO',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
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
    );
  }

  Widget _buildCompactInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(
            fontSize: 9,
            color: Colors.white24,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            fontSize: 13,
            color: Colors.white70,
            letterSpacing: 0.5,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleInfoRow(
    String label,
    String value,
    bool isSmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(
            fontSize: isSmallScreen ? 11 : 12,
            color: Colors.grey.shade500,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.white,
            letterSpacing: 0.5,
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMechanicSection(
    String title,
    String description,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.2),
        border: Border.all(
          color: Colors.red.shade700.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: isSmallScreen ? 14 : 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.shareTechMono(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.red.shade400,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            description,
            style: GoogleFonts.shareTechMono(
              fontSize: isSmallScreen ? 10 : 13,
              color: Colors.white,
              letterSpacing: 0.3,
              height: 1.4,
            ),
            maxLines: isSmallScreen ? 3 : null,
            overflow: isSmallScreen ? TextOverflow.ellipsis : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection(
    String tip,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade900.withOpacity(0.1),
        border: Border.all(
          color: Colors.amber.shade700.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber.shade600,
            size: isSmallScreen ? 14 : 18,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.shareTechMono(
                fontSize: isSmallScreen ? 10 : 13,
                color: Colors.grey.shade300,
                letterSpacing: 0.3,
                height: 1.4,
              ),
              maxLines: isSmallScreen ? 3 : null,
              overflow: isSmallScreen ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}



// Season 2 Teaser Screen
class SeasonTwoTeaserScreen extends StatefulWidget {
  const SeasonTwoTeaserScreen({super.key});

  @override
  State<SeasonTwoTeaserScreen> createState() => _SeasonTwoTeaserScreenState();
}

class _SeasonTwoTeaserScreenState extends State<SeasonTwoTeaserScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;
  int _currentPhase = 0;
  final List<String> _teaserTexts = [
    'La verdad que descubriste...',
    'Era solo el comienzo.',
    'Los pecados capitales fueron la primera capa.',
    'Pero hay algo más profundo.',
    'Algo que controla todo desde las sombras.',
    'TEMPORADA 2',
    'PRÓXIMAMENTE',
  ];

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat();
    
    _startTeaser();
  }

  @override
  void dispose() {
    _glitchController.dispose();
    super.dispose();
  }

  Future<void> _startTeaser() async {
    for (int i = 0; i < _teaserTexts.length; i++) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        setState(() {
          _currentPhase = i;
        });
      }
    }
    
    // Wait a bit before allowing to close
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              return CustomPaint(
                painter: TeaserBackgroundPainter(
                  animationValue: _glitchController.value,
                ),
              );
            },
          ),
          
          // Main content
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: _currentPhase < _teaserTexts.length
                  ? _buildTextPhase(_teaserTexts[_currentPhase], _currentPhase)
                  : const SizedBox.shrink(),
            ),
          ),
          
          // Close button (appears after teaser)
          if (_currentPhase >= _teaserTexts.length - 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    'VOLVER',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextPhase(String text, int phase) {
    // Special styling for "TEMPORADA 2"
    if (phase == _teaserTexts.length - 2) {
      return Column(
        key: ValueKey(phase),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: GoogleFonts.pressStart2p(
              fontSize: 32,
              color: Colors.purple.shade300,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Colors.purple.withOpacity(0.8),
                  blurRadius: 20,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    // Special styling for "PRÓXIMAMENTE"
    if (phase == _teaserTexts.length - 1) {
      return Column(
        key: ValueKey(phase),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_glitchController.value * 0.05),
                child: Text(
                  text,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 6,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.purple.withOpacity(0.6),
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
      );
    }
    
    // Normal text
    return Padding(
      key: ValueKey(phase),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        text,
        style: GoogleFonts.shareTechMono(
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 2,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TeaserBackgroundPainter extends CustomPainter {
  final double animationValue;

  TeaserBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((animationValue * 100).toInt());
    
    // Purple particles
    final paint = Paint()..color = Colors.purple.withOpacity(0.1);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
    
    // Glitch lines
    if (animationValue > 0.8) {
      for (int i = 0; i < 2; i++) {
        final y = random.nextDouble() * size.height;
        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, 1),
          Paint()..color = Colors.purple.withOpacity(0.3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(TeaserBackgroundPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

class TechnicalSelectionPainter extends CustomPainter {
  final double animationValue;
  final WitnessTheme theme;

  TechnicalSelectionPainter({required this.animationValue, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.primaryColor.withOpacity(0.05)
      ..strokeWidth = 0.5;

    // Cuadrícula técnica
    const double spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Línea de escaneo dinámica
    final scanPaint = Paint()
      ..color = theme.primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final scanY = (animationValue * size.height * 2) % size.height;
    canvas.drawRect(Rect.fromLTWH(0, scanY, size.width, 2), scanPaint);

    // Glow temático en los bordes
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [theme.primaryColor.withOpacity(0.05), Colors.transparent],
        center: Alignment.center,
        radius: 1.5,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(TechnicalSelectionPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

class ProtocolTexturePainter extends CustomPainter {
  final String id;

  ProtocolTexturePainter({required this.id});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final random = Random(id.hashCode);
    
    if (id.contains('consumo_codicia')) {
      // Patrón de círculos concéntricos (vacío/hambre)
      for (int i = 1; i <= 5; i++) {
        canvas.drawCircle(size.center(Offset.zero), i * 20.0, paint);
      }
    } else if (id.contains('envidia_lujuria')) {
      // Patrón de líneas cruzadas (red/espejos)
      for (int i = 0; i < 10; i++) {
        canvas.drawLine(Offset(i * 20.0, 0), Offset(size.width - i * 20.0, size.height), paint);
      }
    } else if (id == 'history') {
      // Patrón de ondas de memoria
      for (double i = 0; i < size.width; i += 5) {
        final y = size.height / 2 + sin(i * 0.1 + id.hashCode) * 15;
        canvas.drawCircle(Offset(i, y), 0.5, paint..style = PaintingStyle.fill);
      }
    } else if (id.contains('ira')) {
      // Patrón de líneas quebradas radiales
      final center = size.center(Offset.zero);
      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * pi / 180;
        canvas.drawLine(
          center,
          center + Offset(cos(angle) * 100, sin(angle) * 100),
          paint..color = Colors.red[900]!.withOpacity(0.2),
        );
      }
    } else {
      // Patrón de glitch genérico
      for (int i = 0; i < 15; i++) {
        final rect = Rect.fromLTWH(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
          random.nextDouble() * 50,
          2,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class VHSEffectPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random();

  VHSEffectPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ruido blanco sutil
    final noisePaint = Paint()..color = Colors.white.withOpacity(0.015);
    for (int i = 0; i < 50; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, noisePaint);
    }

    // 2. Línea de "tracking" de video (glitch horizontal)
    if (_random.nextDouble() > 0.95 || (animationValue > 0.8 && animationValue < 0.85)) {
      final trackingY = _random.nextDouble() * size.height;
      final trackingHeight = 2.0 + _random.nextDouble() * 10.0;
      
      canvas.drawRect(
        Rect.fromLTWH(0, trackingY, size.width, trackingHeight),
        Paint()..color = Colors.white.withOpacity(0.03),
      );
      
      // Desplazamiento de color sutil durante el tracking
      canvas.drawRect(
        Rect.fromLTWH(0, trackingY + trackingHeight, size.width, 1),
        Paint()..color = Colors.red.withOpacity(0.05),
      );
    }

    // 3. Aberración cromática sutil en los bordes (opcional/conceptual aquí)
    if (_random.nextDouble() > 0.98) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.blue.withOpacity(0.005),
      );
    }
  }

  @override
  bool shouldRepaint(VHSEffectPainter oldDelegate) => true;
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
