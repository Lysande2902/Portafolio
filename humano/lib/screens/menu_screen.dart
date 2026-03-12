import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/arc_progress_provider.dart';
import '../data/providers/fragments_provider.dart';
import 'package:humano/providers/store_provider.dart';
import 'package:humano/providers/audio_provider.dart';
import 'package:humano/data/models/arc_progress.dart';
import 'arc_selection_screen.dart';
import 'settings_screen.dart';
import 'archive_screen.dart';
import 'store_screen.dart';
import '../widgets/monitor_effect.dart';
import '../widgets/monitor_effect.dart';
import 'prologue_tutorial_screen.dart';
import 'intro_screen.dart';
import 'battle_pass_screen.dart';
import 'subject_file_screen.dart';
import 'notifications_screen.dart';
import '../providers/theme_provider.dart';
import '../core/theme/app_theme.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  int _selectedIndex = 0;
  
  // Sistema de glitch aleatorio para textos
  Timer? _glitchTimer;
  bool _isTextGlitching = false;
  final Random _random = Random();
  
  // Easter Egg states
  bool _isShowingSecret = false;
  String _secretTitle = '';
  String _secretBody = '';
  Color _secretColor = Colors.blue;
  int _kernelTaps = 0;
  bool _headerIsLongPressed = false;

  final List<String> _menuItems = [
    'JUGAR',
    'TIENDA',
    'ARCHIVO',
    'AJUSTES',
    'SALIR',
  ];

  final List<String> _menuDescriptions = [
    'Entrar al próximo Arco',
    'Tienda y Acceso Total',
    'Galería de evidencias',
    'Configuración',
    '¿Realmente puedes escapar?',
  ];

  // Easter Egg states

  @override
  void initState() {
    super.initState();

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _initVideo();
    _startRandomGlitch();
    _ensureUserDataInitialized();
    _checkForNewNotifications();

    // Asegurar que la música equipada siga sonando
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = Provider.of<AudioProvider>(context, listen: false);
      audio.playArcMusic('current');
    });
  }
  
  void _startRandomGlitch() {
    // Glitch aleatorio cada 15-30 segundos
    _glitchTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted && _random.nextDouble() < 0.4) { // 40% de probabilidad
        setState(() {
          _isTextGlitching = true;
        });
        
        // Durar solo 150ms
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _isTextGlitching = false;
            });
          }
        });
      }
    });
  }

  /// Asegura que UserDataProvider esté inicializado
  void _ensureUserDataInitialized() async {
    // Esperar un frame para que los providers estén listos
    await Future.delayed(Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    
    print('🔍 [MenuScreen] Verificando inicialización...');
    print('   Usuario autenticado: ${authProvider.currentUser?.uid ?? "null"}');
    print('   UserDataProvider inicializado: ${userDataProvider.isInitialized}');
    print('   UserData es null: ${userDataProvider.userData == null}');
    
    if (authProvider.currentUser != null && !userDataProvider.isInitialized) {
      print('🔄 [MenuScreen] Inicializando UserDataProvider para usuario: ${authProvider.currentUser!.uid}');
      await userDataProvider.initialize(authProvider.currentUser!.uid);
      print('✅ [MenuScreen] Inicialización completada');
    } else if (userDataProvider.isInitialized) {
      print('✅ [MenuScreen] UserDataProvider ya está inicializado');
    } else {
      print('⚠️ [MenuScreen] No hay usuario autenticado');
    }
  }
  
  /// Verificar si hay notificaciones nuevas y reproducir sonido
  void _checkForNewNotifications() async {
    await Future.delayed(Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
    
    if (notificationsProvider.hasUnread) {
      // Reproducir sonido de notificación usando el provider global
      context.read<AudioProvider>().playSfx('assets/sounds/glitch_09-226602.mp3');
    }
  }

  void _initVideo() {
    // Video eliminado para usar fondo dinámico técnico
    setState(() {
      _isVideoInitialized = false;
    });
  }

  // _initAudio method removed as its functionality is now in initState

  void _handleMenuSelection(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // PLAY
        // Verificar si ya completó el prólogo
        final prefs = await SharedPreferences.getInstance();
        final prologueCompleted = prefs.getBool('prologue_completed') ?? false;
        
        if (prologueCompleted) {
          // Si ya completó el prólogo, ir directo a selección de arcos
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ArcSelectionScreen()),
          );
        } else {
          // Si no ha completado el prólogo, mostrarlo
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrologueTutorialScreen()),
          );
        }
        break;
      case 1: // STORE
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StoreScreen()),
        );
        break;
      case 2: // ARCHIVE
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArchiveScreen()),
        );
        break;
      case 3: // SETTINGS
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4: // REPLAY INTRO
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
        break;
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _glitchController.dispose();
    _glitchTimer?.cancel();
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
          // 1. FONDO ATMOSFÉRICO TÉCNICO
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AtmosphericBackgroundPainter(
                    animationValue: _glitchController.value,
                    theme: appTheme,
                  ),
                );
              },
            ),
          ),
          
          // 2. Viñeta de Inmersión
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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

          // 3. TERMINAL DE CONTROL (UI MODULAR)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Más aire en los bordes
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 900;
                  
                  return Column(
                    children: [
                      // CABECERA DE SISTEMA
                      _buildTerminalHeader(),

                      const SizedBox(height: 10),

                      // BARRA DE PROGRESO GLOBAL
                      _buildGlobalProgressBar(),
                      
                      const SizedBox(height: 20),
                      
                      Expanded(
                        child: isWide 
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ZONA A: OPERACIONES
                                  Expanded(flex: 2, child: _buildOperationPanel(appTheme)),
                                  const SizedBox(width: 20),
                                  // ZONA B: BASE DE DATOS
                                  Expanded(flex: 3, child: _buildDatabasePanel(appTheme)),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildOperationPanel(appTheme),
                                  const SizedBox(height: 20),
                                  _buildDatabasePanel(appTheme),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // ZONA D: SERVICIOS DEL SISTEMA (BASE)
                      _buildSystemServicesBar(),
                    ],
                  );
                },
              ),
            ),
          ),
          _buildSecretOverlay(),
        ],
        ),
      ),
    );
  }

  void _showSecret(String title, String body, {Color color = Colors.blue}) {
    setState(() {
      _secretTitle = title;
      _secretBody = body;
      _secretColor = color;
      _isShowingSecret = true;
    });
    
    // Auto hide after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => _isShowingSecret = false);
      }
    });
  }

  Widget _buildSecretOverlay() {
    if (!_isShowingSecret) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _isShowingSecret = false),
        child: Container(
          color: Colors.black.withOpacity(0.92),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: _secretColor, size: 50),
              const SizedBox(height: 25),
              _GlitchText(
                text: _secretTitle,
                isGlitching: true,
                style: GoogleFonts.shareTechMono(
                  color: _secretColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _secretBody,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                '[ TOCAR PARA CERRAR EL ACCESO ]',
                style: GoogleFonts.shareTechMono(
                  color: Colors.white24,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalHeader() {
    final appTheme = Provider.of<AppThemeProvider>(context, listen: false).currentTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appTheme.primaryColor.withOpacity(0.3), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                _showSecret(
                  'INTERRUPCIÓN DE DATOS',
                  'Ellos no son pecadores. Son los únicos que saben que tú eres el que tiene las manos manchadas.',
                  color: Colors.blue,
                );
              },
              onLongPressStart: (_) => setState(() => _headerIsLongPressed = true),
              onLongPressEnd: (_) => setState(() => _headerIsLongPressed = false),
              onLongPressDown: (_) => setState(() => _headerIsLongPressed = true),
              onLongPressCancel: () => setState(() => _headerIsLongPressed = false),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: _GlitchText(
                  text: 'WITNESS OS v4.0',
                  isGlitching: _isTextGlitching,
                  style: GoogleFonts.shareTechMono(
                    color: _headerIsLongPressed ? Colors.blue : appTheme.primaryColor.withOpacity(0.6), 
                    fontSize: 10,
                    fontWeight: _headerIsLongPressed ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: appTheme.secondaryColor, size: 8),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  _kernelTaps++;
                  if (_kernelTaps >= 5) {
                    _kernelTaps = 0;
                    _showSecret(
                      'ERROR DE SISTEMA',
                      'Deja de mirar la pantalla. Mira tu reflejo. ¿Ese que te devuelve la mirada eres realmente tú?',
                      color: Colors.white,
                    );
                  }
                },
                child: _GlitchText(
                  text: 'ACTIVO',
                  isGlitching: _isTextGlitching,
                  style: GoogleFonts.shareTechMono(color: appTheme.secondaryColor, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalProgressBar() {
    final appTheme = Provider.of<AppThemeProvider>(context, listen: false).currentTheme;
    return Consumer<FragmentsProvider>(
      builder: (context, fragmentsProvider, child) {
        final collected = fragmentsProvider.totalUnlockedFragments;
        const total = 19;
        final progress = (collected / total).clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlitchText(
                  text: 'PRUEBAS RECOLECTADAS',
                  isGlitching: _isTextGlitching,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 8,
                    color: Colors.grey[700],
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '$collected / $total',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 9,
                    color: collected == total
                        ? appTheme.accentColor
                        : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  collected == total
                      ? appTheme.accentColor
                      : appTheme.primaryColor.withOpacity(0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOperationPanel(WitnessTheme appTheme) {
    return _TerminalPanel(
      title: 'PROTOCOLOS',
      id: '0x01',
      isGlitching: _isTextGlitching,
      appTheme: appTheme,
      child: Column(
        children: [
          _TerminalButton(
            title: 'ENTRAR AL JUICIO',
            subtitle: 'Continúa donde lo dejaste',
            icon: Icons.electrical_services,
            isPrimary: true,
            isGlitching: _isTextGlitching,
            onTap: () => _handleMenuSelection(0),
          ),
          const SizedBox(height: 5),
          // Easter Egg: Pulsación en el hueco vacío
          GestureDetector(
            onLongPress: () {
              _showSecret(
                'NODO_VACÍO',
                'Cierra los ojos un segundo. Si al abrirlos todo sigue igual, es que ya es demasiado tarde para salir.',
                color: Colors.orange,
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 20,
              width: double.infinity,
              color: Colors.transparent,
            ),
          ),
          const SizedBox(height: 5),
          _TerminalButton(
            title: 'VER EL INICIO',
            subtitle: 'Revive cómo empezó todo',
            icon: Icons.history_edu,
            isGlitching: _isTextGlitching,
            onTap: () => _handleMenuSelection(4),
          ),
        ],
      ),
    );
  }


  Widget _buildDatabasePanel(WitnessTheme appTheme) {
    return _TerminalPanel(
      title: 'REGISTROS',
      id: '0x02',
      isGlitching: _isTextGlitching,
      appTheme: appTheme,
      child: Column(
        children: [
          _TerminalButton(
            title: 'ARCHIVO DE EVIDENCIAS',
            subtitle: 'Lo que el sistema encontró',
            icon: Icons.folder_special,
            isGlitching: _isTextGlitching,
            onTap: () => _handleMenuSelection(2),
          ),
          const SizedBox(height: 15),
          Consumer<ArcProgressProvider>(
            builder: (context, progressProvider, _) {
              // Conteo de arcos completados para Punto 9
              int completedCount = progressProvider.progressMap.values
                  .where((p) => p.status == ArcStatus.completed)
                  .length;
              
              // Si el Arco 4 (Ira) está completo, cambiar nombre
              final bool isMaxLevel = completedCount >= 4; 

              return _TerminalButton(
                title: isMaxLevel ? 'PERSONAS' : 'EXPEDIENTE X',
                subtitle: isMaxLevel ? 'Ellos no son solo datos' : 'Los sujetos del juicio',
                icon: isMaxLevel ? Icons.people_outline : Icons.menu_book,
                isGlitching: _isTextGlitching,
                onTap: () async {
                  if (!mounted) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubjectFileScreen()),
                  );
                  
                  if (mounted) {
                    context.read<AudioProvider>().playArcMusic('current');
                  }
                },
              );
            },
          ),
          const SizedBox(height: 15),
          _TerminalButton(
            title: 'PASE DEL JUEZ',
            subtitle: 'Tu progreso en el juicio',
            icon: Icons.balance,
            isGlitching: _isTextGlitching,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BattlePassScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSystemServicesBar() {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmall = constraints.maxWidth < 600;
            
            if (isSmall) {
              return Column(
                children: [
                  _NotificationButton(
                    hasUnread: notificationsProvider.hasUnread,
                    unreadCount: notificationsProvider.unreadCount,
                    isGlitching: _isTextGlitching,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _TerminalButton(
                    title: 'TIENDA',
                    subtitle: 'Cambia seguidores por poder',
                    icon: Icons.remove_red_eye_outlined,
                    isGlitching: _isTextGlitching,
                    onTap: () => _handleMenuSelection(1),
                  ),
                  const SizedBox(height: 10),
                  _TerminalButton(
                    title: 'AJUSTES',
                    subtitle: 'Opciones del juicio',
                    icon: Icons.tune,
                    isGlitching: _isTextGlitching,
                    onTap: () => _handleMenuSelection(3),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _NotificationButton(
                    hasUnread: notificationsProvider.hasUnread,
                    unreadCount: notificationsProvider.unreadCount,
                    isGlitching: _isTextGlitching,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TerminalButton(
                    title: 'TIENDA',
                    subtitle: 'Cambia seguidores por poder',
                    icon: Icons.remove_red_eye_outlined,
                    isGlitching: _isTextGlitching,
                    onTap: () => _handleMenuSelection(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TerminalButton(
                    title: 'AJUSTES',
                    subtitle: 'Opciones del juicio',
                    icon: Icons.tune,
                    isGlitching: _isTextGlitching,
                    onTap: () => _handleMenuSelection(3),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

}

// --- COMPONENTES DE LA TERMINAL (UI MODULAR) ---

class _TerminalPanel extends StatelessWidget {
  final String title;
  final String id;
  final Widget child;
  final bool isGlitching;
  final WitnessTheme appTheme;

  const _TerminalPanel({
    required this.title, 
    required this.id, 
    required this.child,
    required this.appTheme,
    this.isGlitching = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: appTheme.primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: appTheme.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlitchText(
                  text: title,
                  isGlitching: isGlitching,
                  style: GoogleFonts.shareTechMono(
                    color: appTheme.accentColor, 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  id, 
                  style: GoogleFonts.shareTechMono(
                    color: appTheme.primaryColor.withOpacity(0.4), 
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _TerminalButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isGlitching;

  const _TerminalButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isGlitching = false,
  });

  @override
  State<_TerminalButton> createState() => _TerminalButtonState();
}

class _TerminalButtonState extends State<_TerminalButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered ? (widget.isPrimary ? appTheme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05)) : Colors.transparent,
            border: Border.all(
              color: isHovered ? (widget.isPrimary ? appTheme.secondaryColor : Colors.white.withOpacity(0.2)) : Colors.white.withOpacity(0.05),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: isHovered ? (widget.isPrimary ? appTheme.accentColor : Colors.white) : Colors.grey[600], size: 18),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GlitchText(
                      text: widget.title,
                      isGlitching: widget.isGlitching,
                      style: GoogleFonts.shareTechMono(
                        color: isHovered ? Colors.white : Colors.grey[300],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    _GlitchText(
                      text: widget.subtitle,
                      isGlitching: widget.isGlitching,
                      style: GoogleFonts.shareTechMono(
                        color: isHovered ? (widget.isPrimary ? appTheme.accentColor : Colors.grey[400]) : Colors.grey[700],
                        fontSize: 8,
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
}

class AtmosphericBackgroundPainter extends CustomPainter {
  final double animationValue;
  final WitnessTheme theme;

  AtmosphericBackgroundPainter({required this.animationValue, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fondo base muy oscuro
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);

    // 2. Niebla Digital Carmesí simplificada
    final paint = Paint();
    for (int i = 0; i < 2; i++) {
      final x = size.width * (0.5 + sin(animationValue * pi * 0.4 + i) * 0.3);
      final y = size.height * (0.5 + cos(animationValue * pi * 0.2 + i) * 0.15);
      
      paint.color = theme.primaryColor.withOpacity(0.06);
      canvas.drawCircle(Offset(x, y), size.width * 0.4, paint);
    }

    // 3. Grano estático reducido
    final random = Random(1234);
    for (int i = 0; i < 20; i++) {
      final dotX = random.nextDouble() * size.width;
      final dotY = random.nextDouble() * size.height;
      paint.color = theme.primaryColor.withOpacity(0.03);
      canvas.drawCircle(Offset(dotX, dotY), 0.8, paint);
    }

    // 4. Líneas de escaneo CRT
    paint.color = Colors.black.withOpacity(0.15);
    paint.strokeWidth = 0.5;
    for (double i = 0; i < size.height; i += 6) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(AtmosphericBackgroundPainter oldDelegate) {
    // Solo repintar si la animación cambió significativamente (cada 5%)
    return (animationValue - oldDelegate.animationValue).abs() > 0.05;
  }
}

class VHSEffectPainter extends CustomPainter {
  final double animationValue;
  VHSEffectPainter({required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(VHSEffectPainter oldDelegate) => false;
}

// Botón de notificaciones con animación de brillo
class _NotificationButton extends StatefulWidget {
  final bool hasUnread;
  final int unreadCount;
  final bool isGlitching;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.hasUnread,
    required this.unreadCount,
    required this.isGlitching,
    required this.onTap,
  });

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: widget.hasUnread
                    ? Provider.of<AppThemeProvider>(context, listen: false).currentTheme.secondaryColor.withOpacity(0.5)
                    : Colors.grey[800]!,
                width: 1,
              ),
              boxShadow: widget.hasUnread
                  ? [
                      BoxShadow(
                        color: Provider.of<AppThemeProvider>(context, listen: false).currentTheme.secondaryColor.withOpacity(_pulseController.value * 0.5),
                        blurRadius: 10 + (_pulseController.value * 10),
                        spreadRadius: _pulseController.value * 3,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: widget.hasUnread ? Provider.of<AppThemeProvider>(context, listen: false).currentTheme.accentColor : Colors.grey[600],
                      size: 20,
                    ),
                    if (widget.hasUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Provider.of<AppThemeProvider>(context, listen: false).currentTheme.secondaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Provider.of<AppThemeProvider>(context, listen: false).currentTheme.secondaryColor,
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            widget.unreadCount > 9 ? '9+' : '${widget.unreadCount}',
                            style: GoogleFonts.courierPrime(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GlitchText(
                        text: 'NOTIFICACIONES',
                        isGlitching: widget.isGlitching,
                        style: GoogleFonts.shareTechMono(
                          fontSize: 11,
                          color: widget.hasUnread ? Provider.of<AppThemeProvider>(context, listen: false).currentTheme.accentColor : Colors.grey[400],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _GlitchText(
                        text: widget.hasUnread ? 'Mensajes nuevos' : 'Sin mensajes',
                        isGlitching: widget.isGlitching,
                        style: GoogleFonts.courierPrime(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget de texto con efecto glitch aleatorio
class _GlitchText extends StatelessWidget {
  final String text;
  final bool isGlitching;
  final TextStyle style;

  const _GlitchText({
    required this.text,
    required this.isGlitching,
    required this.style,
  });

  String _glitchText(String original) {
    if (!isGlitching) return original;
    
    final random = Random();
    final glitchChars = ['█', '▓', '▒', '░', '▀', '▄', '■', '□', '▪', '▫'];
    final buffer = StringBuffer();
    
    for (int i = 0; i < original.length; i++) {
      if (random.nextDouble() < 0.3) { // 30% de probabilidad por letra
        buffer.write(glitchChars[random.nextInt(glitchChars.length)]);
      } else {
        buffer.write(original[i]);
      }
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    return Text(
      _glitchText(text),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style.copyWith(
        color: isGlitching ? appTheme.accentColor : style.color,
      ),
    );
  }
}

