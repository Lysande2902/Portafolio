import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/arc_progress_provider.dart';
import '../providers/audio_provider.dart';
import '../data/subjects_registry.dart';
import '../data/models/arc_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectFileScreen extends StatefulWidget {
  const SubjectFileScreen({super.key});

  @override
  State<SubjectFileScreen> createState() => _SubjectFileScreenState();
}

class _SubjectFileScreenState extends State<SubjectFileScreen> with TickerProviderStateMixin {
  bool _isCensored = true;
  String _narrativeText = "";
  int _currentSubjectIndex = 0;
  int _expedienteLevel = 0; // Nivel de sincronización (0-4)
  
  Timer? _typewriterTimer;
  int _charIndex = 0;
  
  AnimationController? _fadeController;
  AnimationController? _scannerController;
  AnimationController? _glowController;
  AnimationController? _jitterController;
  final ScrollController _scrollController = ScrollController();
  
  final math.Random _random = math.Random();
  bool _witnessTriggered = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scannerController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    
    _jitterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))
      ..addListener(() => setState(() {}));

    _startRandomJitter();
    
    // Calcular nivel de sincronización basado en arcos completados
    _calculateAndSetExpedienteLevel();
  }
  
  /// Calcula el nivel de sincronización basado en arcos completados
  void _calculateAndSetExpedienteLevel() async {
    final progressProvider = Provider.of<ArcProgressProvider>(context, listen: false);
    
    // Verificar si cada arco está completado en el proveedor real
    bool isArc0Completed = progressProvider.getStatus('arc_0_inicio') == ArcStatus.completed;
    bool isArc1Completed = progressProvider.getStatus('arc_1_envidia_lujuria') == ArcStatus.completed;
    bool isArc2Completed = progressProvider.getStatus('arc_2_consumo_codicia') == ArcStatus.completed;
    bool isArc3Completed = progressProvider.getStatus('arc_3_soberbia_pereza') == ArcStatus.completed;
    bool isArc4Completed = progressProvider.getStatus('arc_4_ira') == ArcStatus.completed;
    
    // Fallback: Verificar si el prólogo está completado en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    bool prologueCompleted = prefs.getBool('prologue_completed') ?? false;

    // Conteo orgánico de arcos completados
    int completedCount = progressProvider.progressMap.values
        .where((p) => p.status == ArcStatus.completed)
        .length;

    // El Prólogo cuenta como un arco si no se ha registrado el Arco 0
    if (prologueCompleted && !isArc0Completed) {
      completedCount++;
    }

    // El nivel es simplemente el total de arcos conquistados (máximo 5 para esta temporada)
    int level = completedCount.clamp(0, 5);
    
    if (mounted) {
      setState(() {
        _expedienteLevel = level;
      });
      // Recargar el sujeto actual con el nuevo nivel
      _loadSubject(_currentSubjectIndex, initial: true);
    }
  }
  
  /// Obtiene la lista de sujetos visibles según el nivel actual
  List<SubjectData> _getVisibleSubjects() {
    return subjectsRegistry.where((subject) => subject.minLevelToShow <= _expedienteLevel).toList();
  }

  void _loadSubject(int index, {bool initial = false}) {
    _typewriterTimer?.cancel();
    _fadeController?.reset();
    
    final visibleSubjects = _getVisibleSubjects();
    
    // Reset scroll to top
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }

    setState(() {
      _currentSubjectIndex = index;
      _narrativeText = "";
      _charIndex = 0;
      _isCensored = true;
    });

    // Detectar si es el expediente de Alex al nivel máximo: reproducir WITNESS
    final subject = visibleSubjects.isNotEmpty ? visibleSubjects[index] : null;
    final isAlexAtMax = subject?.id == 'AL_00' && _expedienteLevel >= 5;

    if (isAlexAtMax && !_witnessTriggered) {
      _witnessTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<AudioProvider>(context, listen: false).playWitnessTheme();
        }
      });
    } else if (!isAlexAtMax && _witnessTriggered) {
      // Si cambió de sujeto, resetear para que WITNESS vuelva si regresa a Alex
      _witnessTriggered = false;
      Provider.of<AudioProvider>(context, listen: false).playArcMusic('current');
    }

    // Pequeña espera para la "sincronización"
    Future.delayed(Duration(seconds: initial ? 3 : 1), () {
      if (mounted) {
        setState(() => _isCensored = false);
        _startTypewriter();
      }
    });
  }

  void _skipTypewriter() {
    _typewriterTimer?.cancel();
    final visibleSubjects = _getVisibleSubjects();
    final currentSubject = visibleSubjects[_currentSubjectIndex];
    final narrative = currentSubject.getNarrativeForLevel(_expedienteLevel);
    
    if (mounted) {
      setState(() {
        _narrativeText = narrative;
        _charIndex = narrative.length;
      });
      _fadeController?.forward();
    }
  }

  void _startRandomJitter() {
    Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_random.nextDouble() > 0.7) {
        _jitterController?.repeat(reverse: true);
        Future.delayed(const Duration(milliseconds: 300), () {
          _jitterController?.stop();
          _jitterController?.reset();
        });
      }
    });
  }

  void _startTypewriter() {
    final visibleSubjects = _getVisibleSubjects();
    final currentSubject = visibleSubjects[_currentSubjectIndex];
    final narrative = currentSubject.getNarrativeForLevel(_expedienteLevel);
    
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_charIndex < narrative.length) {
        if (mounted) {
          setState(() {
            _narrativeText += narrative[_charIndex];
            _charIndex++;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          _fadeController?.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    // Restaurar orientaciones disponibles al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _typewriterTimer?.cancel();
    _fadeController?.dispose();
    _scannerController?.dispose();
    _glowController?.dispose();
    _jitterController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleSubjects = _getVisibleSubjects();
    
    // Validación de seguridad: si no hay sujetos visibles, mostrar mensaje
    if (visibleSubjects.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GlitchText(
                text: "ACCESO DENEGADO",
                fontSize: 24,
                color: Color(0xFF8B0000),
              ),
              const SizedBox(height: 20),
              Text(
                "REQUIERE SINCRONIZACIÓN NEURONAL\nCOMPLETA EL PROTOCOLO 0 PRIMERO",
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("REGRESAR"),
              ),
            ],
          ),
        ),
      );
    }
    
    // Validación de seguridad: ajustar índice si está fuera de rango
    if (_currentSubjectIndex >= visibleSubjects.length) {
      _currentSubjectIndex = visibleSubjects.length - 1;
    }
    
    final currentSubject = visibleSubjects[_currentSubjectIndex];
    final narrative = currentSubject.getNarrativeForLevel(_expedienteLevel);

    double jitterX = (_jitterController?.isAnimating ?? false) ? (_random.nextDouble() * 4 - 2) : 0;
    double jitterY = (_jitterController?.isAnimating ?? false) ? (_random.nextDouble() * 4 - 2) : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Transform.translate(
        offset: Offset(jitterX, jitterY),
        child: Stack(
          children: [
            _buildCinematicBackground(currentSubject.themeColor),

            // Scanlines Globales (Coherencia con Prólogo)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.12,
                  child: CustomPaint(
                    painter: ScanlinePainter(),
                  ),
                ),
              ),
            ),
            
            SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverHeader(),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header del sujeto
                            _buildBioScanHeader(currentSubject),
                            const SizedBox(height: 30),
                            
                            // Foto bioscan
                            _buildPhotoBioScan(currentSubject),
                            const SizedBox(height: 40),
                            
                            // Narrativa del Juez
                            _buildJuiceNarrative(),
                            
                            // Botón de saltar
                            if (_charIndex < narrative.length)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: TextButton(
                                    onPressed: _skipTypewriter,
                                    child: GlitchText(
                                      text: "[ SALTAR ANIMACIÓN ]",
                                      fontSize: 10,
                                      color: currentSubject.themeColor.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                              
                            const SizedBox(height: 50),

                            // Resto de info que aparece después
                            FadeTransition(
                              opacity: _fadeController ?? const AlwaysStoppedAnimation(0.0),
                              child: Column(
                                children: [
                                  _buildDataModule("REGISTRO DE TESTIGO", {
                                    "SUJETO": currentSubject.name,
                                    "ROL": currentSubject.codename,
                                    "ARCO": currentSubject.arcLabel,
                                    "PECADO": currentSubject.sin,
                                    "ESTADO": currentSubject.getStatusForLevel(_expedienteLevel),
                                    "INTEGRIDAD": currentSubject.getIntegrityForLevel(_expedienteLevel),
                                  }, currentSubject.themeColor),
                                  const SizedBox(height: 50),
                                  
                                  _buildFinalVerdictStamp(currentSubject.themeColor),
                                  const SizedBox(height: 60),
                                  
                                  _buildNavigationButtons(),
                                  const SizedBox(height: 40),
                                  
                                  _buildSystemFootprint(),
                                  const SizedBox(height: 60),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            if (_isCensored)
              _buildAtmosphericLoading(),

            if ((_jitterController?.isAnimating ?? false) && _random.nextDouble() > 0.8)
              Positioned.fill(
                child: Container(
                  color: currentSubject.themeColor.withOpacity(0.05),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinematicBackground(Color themeColor) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              themeColor.withOpacity(0.08),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Grid pattern
            Opacity(
              opacity: 0.03,
              child: CustomPaint(
                size: Size.infinite,
                painter: GridPainter(color: themeColor),
              ),
            ),
            // Vignette effect
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Latido de Conciencia (Pulse of Conscience)
            Center(
              child: AnimatedBuilder(
                animation: _glowController!,
                builder: (context, child) {
                  final scale = 1.0 + (_glowController!.value * 0.1);
                  final opacity = 0.04 + (_glowController!.value * 0.04);
                  return Container(
                    width: 350 * scale,
                    height: 350 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(opacity),
                          blurRadius: 120,
                          spreadRadius: 60,
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

  Widget _buildSliverHeader() {
    return SliverAppBar(
      backgroundColor: Colors.black.withOpacity(0.8),
      floating: true,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white54,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF8B0000),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const GlitchText(
            text: "TERMINAL ARCHIVO JUICIO",
            fontSize: 12,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildBioScanHeader(SubjectData subject) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: subject.themeColor.withOpacity(0.5), width: 2),
        ),
        gradient: LinearGradient(
          colors: [
            subject.themeColor.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: subject.themeColor.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "OBJETIVO",
                style: GoogleFonts.shareTechMono(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlitchText(
            text: subject.name,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: subject.themeColor.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            "ID JUICIO: ${subject.id}",
            style: GoogleFonts.shareTechMono(
              color: Colors.white24,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBioScan(SubjectData subject) {
    final bool shouldShowCensored = _shouldCensorImage(subject);
    final String displayImagePath = shouldShowCensored 
        ? 'assets/images/censored_image.png' 
        : subject.imagePath;
    final double blurAmount = _getBlurForLevel(subject);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle glow
          Container(
            width: 280,
            height: 420,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: subject.themeColor.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          
          // Main image container
          Container(
            width: 260,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: subject.themeColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          subject.themeColor.withOpacity(0.05),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                  
                  // Image with blur
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: shouldShowCensored ? 0 : blurAmount,
                      sigmaY: shouldShowCensored ? 0 : blurAmount,
                    ),
                    child: Opacity(
                      opacity: shouldShowCensored ? 1.0 : 0.85,
                      child: Image.asset(
                        displayImagePath,
                        fit: shouldShowCensored ? BoxFit.contain : BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Center(
                            child: Icon(
                              Icons.person_outline,
                              size: 120,
                              color: subject.themeColor.withOpacity(0.2),
                            ),
                          ),
                      ),
                    ),
                  ),

                  // Efecto de Glitch en Censura (Punto 7 de la lista)
                  if (shouldShowCensored)
                    _buildCensorshipGlitch(subject.themeColor),
                  
                  // Scanner line (más sutil)
                  if (!shouldShowCensored)
                    AnimatedBuilder(
                      animation: _scannerController ?? const AlwaysStoppedAnimation(0.0),
                      builder: (context, child) {
                        final val = _scannerController?.value ?? 0.0;
                        return Positioned(
                          top: val * 400,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  subject.themeColor.withOpacity(0.4),
                                  subject.themeColor.withOpacity(0.6),
                                  subject.themeColor.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: subject.themeColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Corner decorations
                  ..._buildCornerDecorations(subject.themeColor),
                ],
              ),
            ),
          ),
          
          // Top label
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: subject.themeColor.withOpacity(0.8),
              ),
              child: Text(
                "BIOSCAN NEURAL",
                style: GoogleFonts.shareTechMono(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildCornerDecorations(Color color) {
    return [
      // Top-left
      Positioned(
        top: 8,
        left: 8,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 3),
              left: BorderSide(color: color, width: 3),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 3),
              right: BorderSide(color: color, width: 3),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 8,
        left: 8,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: 3),
              left: BorderSide(color: color, width: 3),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: 3),
              right: BorderSide(color: color, width: 3),
            ),
          ),
        ),
      ),
    ];
  }
  
  /// Calcula el blur según el nivel de sincronización (solo para Alex)
  double _getBlurForLevel(SubjectData subject) {
    if (subject.id == 'AL_00') {
      // Alex: blur progresivo
      switch (_expedienteLevel) {
        case 1: return 15.0; // 90% blur
        case 2: return 10.0; // 60% blur
        case 3: return 6.0;  // 40% blur
        case 4: return 2.0;  // 10% blur
        case 5: return 0.0;  // sin blur
        default: return 20.0;
      }
    }
    return 5.0; // Blur por defecto para otros
  }
  
  /// Determina si la imagen debe estar censurada
  bool _shouldCensorImage(SubjectData subject) {
    // Alex nunca está censurado (solo tiene blur progresivo)
    if (subject.id == 'AL_00') {
      return false;
    }
    
    // Víctor y Magnolia censurados hasta nivel 4
    // Víctor es el 7mo pecado (IRA) pero es REAL, por eso su foto se revela
    if (subject.id == 'VI_07' || subject.id == 'MA_08') {
      return _expedienteLevel < 5;
    }
    
    // Los primeros 6 pecados (abstractos) siempre están censurados
    // porque no son personas reales, son facetas de Alex
    return true;
  }

  Widget _buildCornerDeco(Alignment align, Color color) {
    return Positioned(
      top: align.y == -1 ? 0 : null,
      bottom: align.y == 1 ? 0 : null,
      left: align.x == -1 ? 0 : null,
      right: align.x == 1 ? 0 : null,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          border: Border(
            top: align.y == -1 ? BorderSide(color: color, width: 2) : BorderSide.none,
            bottom: align.y == 1 ? BorderSide(color: color, width: 2) : BorderSide.none,
            left: align.x == -1 ? BorderSide(color: color, width: 2) : BorderSide.none,
            right: align.x == 1 ? BorderSide(color: color, width: 2) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDataModule(String title, Map<String, String> data, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: themeColor.withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: themeColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                GlitchText(
                  text: title,
                  fontSize: 12,
                  letterSpacing: 3,
                  color: themeColor.withOpacity(0.9),
                ),
              ],
            ),
          ),
          
          // Data rows
          ...data.entries.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.key,
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    e.value,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.shareTechMono(
                      color: themeColor.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildJuiceNarrative() {
    final visibleSubjects = _getVisibleSubjects();
    final currentSubject = visibleSubjects[_currentSubjectIndex];
    final narrative = currentSubject.getNarrativeForLevel(_expedienteLevel);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: currentSubject.themeColor.withOpacity(0.4),
            width: 2,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            currentSubject.themeColor.withOpacity(0.06),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: currentSubject.themeColor.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              GlitchText(
                text: "INF DIAGNÓSTICO EL JUEZ",
                fontSize: 11,
                color: currentSubject.themeColor.withOpacity(0.6),
                letterSpacing: 2,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _narrativeText,
            style: GoogleFonts.shareTechMono(
              fontSize: 15,
              height: 1.8,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 0.5,
            ),
          ),
          if (_charIndex < narrative.length)
            AnimatedBuilder(
              animation: _glowController ?? const AlwaysStoppedAnimation(0.0),
              builder: (context, child) {
                final val = _glowController?.value ?? 0.0;
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 10,
                  height: 18,
                  decoration: BoxDecoration(
                    color: currentSubject.themeColor.withOpacity(val * 0.6),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFinalVerdictStamp(Color themeColor) {
    return Center(
      child: AnimatedBuilder(
        animation: _glowController ?? const AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          final val = _glowController?.value ?? 0.0;
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              border: Border.all(
                color: themeColor.withOpacity(0.3 + (val * 0.2)),
                width: 2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeColor.withOpacity(0.05),
                  Colors.transparent,
                  themeColor.withOpacity(0.03),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: themeColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: GlitchText(
                    text: "EL JUEZ",
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                    color: themeColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  width: 200,
                  color: themeColor.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  "EL JUICIO NO TIENE APELACIÓN",
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "TESTIGO REGISTRADO EN: LIBRO DE LOS TESTIGOS",
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white24,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemFootprint() {
    final syncPercentage = (_expedienteLevel * 25).clamp(0, 100);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SINCRONIZACIÓN NEURONAL: $syncPercentage%',
                style: GoogleFonts.shareTechMono(
                  color: Colors.white24,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'PROTOCOLO ESPEJO ROTO v1.0',
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(
              color: Colors.white12,
              fontSize: 8,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SISTEMA: LIBRO DE LOS TESTIGOS — REGISTRO PERMANENTE',
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(
              color: Colors.white12,
              fontSize: 8,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Text(
              'ADVERTENCIA: LOS DATOS AQUÍ CONTENIDOS NO PUEDEN SER BORRADOS.\n'
              'ESTE ARCHIVO EXISTE MIENTRAS ALEX EXISTA.',
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                color: Colors.white10,
                fontSize: 7,
                letterSpacing: 0.5,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final visibleSubjects = _getVisibleSubjects();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentSubjectIndex > 0)
            _buildNavButton(
              "<< ANTERIOR",
              Icons.arrow_back_ios_new,
              () => _loadSubject(_currentSubjectIndex - 1),
            )
          else
            const SizedBox(width: 120),
          
          if (_currentSubjectIndex < visibleSubjects.length - 1)
            _buildNavButton(
              "SIGUIENTE >>",
              Icons.arrow_forward_ios,
              () => _loadSubject(_currentSubjectIndex + 1),
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (text.startsWith("<<")) ...[
                Icon(icon, color: Colors.white54, size: 14),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.shareTechMono(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              if (text.endsWith(">>")) ...[
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white54, size: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtmosphericLoading() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF8B0000).withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF8B0000).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const GlitchText(
                  text: "ACCEDIENDO AL SUBSISTEMA DE CONCIENCIAS",
                  fontSize: 13,
                  color: Color(0xFF8B0000),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: const Color(0xFF8B0000).withOpacity(0.7),
                      minHeight: 2,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "SINCRONIZANDO...",
                      style: GoogleFonts.shareTechMono(
                        color: Colors.white24,
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCensorshipGlitch(Color themeColor) {
    return AnimatedBuilder(
      animation: _jitterController!,
      builder: (context, child) {
        // Solo mostrar glitch el 5% del tiempo para que sea sutil
        final showGlitch = _random.nextDouble() > 0.95;
        if (!showGlitch) return const SizedBox.shrink();
        
        return Container(
          color: themeColor.withOpacity(0.05),
          child: Stack(
            children: [
              // Líneas horizontales de "revelación" parcial
              for (int i = 0; i < 4; i++)
                Positioned(
                  top: _random.nextDouble() * 400,
                  left: 0,
                  right: 0,
                  height: _random.nextDouble() * 15 + 1,
                  child: Container(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class GlitchText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double letterSpacing;

  const GlitchText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.letterSpacing = 0,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        bool isGlitching = _random.nextDouble() > 0.95;
        double offset = isGlitching ? (_random.nextDouble() * 2 - 1) : 0;
        
        return Stack(
          children: [
            if (isGlitching)
              Transform.translate(
                offset: Offset(offset * 2, 0),
                child: Text(
                  widget.text,
                  style: GoogleFonts.shareTechMono(
                    fontSize: widget.fontSize,
                    color: Colors.red.withOpacity(0.5),
                    fontWeight: widget.fontWeight,
                    letterSpacing: widget.letterSpacing,
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(-offset, 0),
              child: Text(
                widget.text,
                style: GoogleFonts.shareTechMono(
                  fontSize: widget.fontSize,
                  color: isGlitching ? ( _random.nextBool() ? Colors.cyan.withOpacity(0.5) : widget.color) : widget.color,
                  fontWeight: widget.fontWeight,
                  letterSpacing: widget.letterSpacing,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


// Grid painter for background
class GridPainter extends CustomPainter {
  final Color color;
  
  GridPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    const spacing = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
