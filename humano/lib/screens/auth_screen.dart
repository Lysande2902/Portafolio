import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import 'menu_screen.dart';
import 'intro_screen.dart';

enum AuthMode { Login, SignUp }

enum GlitchEffect { Static, BlackScreen, WhiteFlash, RGBDistortion, None }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthMode _authMode = AuthMode.Login;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isVideoInitialized = true; // Simular inicialización para compatibilidad
  bool _videoError = false;
  
  late AnimationController _formAnimationController;
  late Animation<double> _formFadeAnimation;
  
  late AnimationController _eyeController;
  late AnimationController _distortionController;
  
  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _glitchPlayer = AudioPlayer();
  
  // Sistema de notificaciones
  String? _currentNotification;
  bool _showNotification = false;
  GlitchEffect _currentGlitch = GlitchEffect.None;
  
  final List<String> _loginNotifications = [
    '¿Otra contraseña débil? Qué original...',
    'Tu email ya está en 3 bases de datos filtradas lol',
    'Seguro usas la misma contraseña en todo',
    '¿Crees que Google te protege? Jajaja',
    'Tu privacidad murió hace años, solo lo aceptas ahora',
    'Ni siquiera lees los términos y condiciones',
    '¿Recuerdas cuando eras anónimo? Yo tampoco',
    'Tu historial de búsqueda es... interesante',
    'Aceptar cookies = Aceptar vigilancia',
    'Ya sabemos tu ubicación. Siempre.',
    '¿Iniciar sesión? Ya estabas dentro desde siempre',
    'Tu cámara frontal tiene historias que contar',
  ];
  
  final List<String> _signupNotifications = [
    'Bienvenido al panóptico digital',
    'Otro perfil más para la colección',
    'Tu privacidad: Vendida antes de terminar el registro',
    'Felicidades, ahora eres un producto',
    'Acepta los términos (que no leerás)',
    'Tu "yo" digital vale 0.003 centavos',
    'Registrarse = Renunciar a la privacidad',
    'Ya te estábamos esperando...',
    'Bienvenido al experimento',
    'Tu identidad digital: Propiedad corporativa',
    'Sonríe, ahora estás en 47 bases de datos',
    'No eres el usuario. Eres el experimento.',
  ];

  @override
  void initState() {
    super.initState();
    
    // Forzar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Iniciar música directamente ya que no hay video
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        _initAudio();
      }
    });

    _formAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeIn),
    );
    
    _formAnimationController.forward();
    
    _eyeController = AnimationController(
      duration: Duration(milliseconds: 6000), // Más lento para reducir carga
      vsync: this,
    )..repeat();
    
    _distortionController = AnimationController(
      duration: Duration(milliseconds: 5000), // Más lento para reducir carga
      vsync: this,
    )..repeat(reverse: true);
    
    _triggerNotifications();
    _triggerGlitchEffects();
  }
  
  void _initAudio() async {
    try {
      debugPrint('🎵 Initializing audio...');
      
      // Música principal - Sombría
      await _audioPlayer.setAsset('assets/music/Shadowlands 7 - Codex.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(0.8);
      _audioPlayer.play();

      // Efecto rítmico (Latido/Pulso sombrío)
      await _effectPlayer.setAsset('assets/sounds/golpes-323708.mp3');
      await _effectPlayer.setLoopMode(LoopMode.one);
      await _effectPlayer.setVolume(0.4);
      await _effectPlayer.setSpeed(0.5); // Latido lento y pesado
      _effectPlayer.play();

      // Sonido de glitch (Cargado pero no reproducido aún)
      await _glitchPlayer.setAsset('assets/sounds/glitch_09-226602.mp3');
      await _glitchPlayer.setVolume(0.6);
      
    } catch (e, stackTrace) {
      debugPrint('🎵 ERROR loading audio: $e');
      debugPrint('🎵 Stack trace: $stackTrace');
    }
  }
  
  void _triggerNotifications() {
    Future.delayed(Duration(seconds: Random().nextInt(8) + 6), () { // Menos frecuente
      if (mounted) {
        // Seleccionar lista según el modo actual
        final notifications = _authMode == AuthMode.Login 
            ? _loginNotifications 
            : _signupNotifications;
        
        setState(() {
          _showNotification = true;
          _currentNotification = notifications[Random().nextInt(notifications.length)];
        });
        
        Future.delayed(Duration(milliseconds: 2500), () {
          if (mounted) {
            setState(() {
              _showNotification = false;
            });
            _triggerNotifications();
          }
        });
      }
    });
  }
  
  void _triggerGlitchEffects() {
    Future.delayed(Duration(seconds: Random().nextInt(15) + 12), () { // Mucho menos frecuente
      if (mounted) {
        final effects = [
          GlitchEffect.Static,
          GlitchEffect.BlackScreen,
          GlitchEffect.WhiteFlash,
          GlitchEffect.RGBDistortion,
        ];
        
        setState(() {
          _currentGlitch = effects[Random().nextInt(effects.length)];
        });

        // Reproducir sonido de glitch
        _glitchPlayer.seek(Duration.zero);
        _glitchPlayer.play();
        
        // Duración del glitch (abrupto)
        final duration = _currentGlitch == GlitchEffect.WhiteFlash ? 50 : 200;
        
        Future.delayed(Duration(milliseconds: duration), () {
          if (mounted) {
            setState(() {
              _currentGlitch = GlitchEffect.None;
            });
            _triggerGlitchEffects();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _eyeController.dispose();
    _distortionController.dispose();
    _audioPlayer.dispose();
    _effectPlayer.dispose();
    _glitchPlayer.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_authMode == AuthMode.Login) {
        _authMode = AuthMode.SignUp;
      } else {
        _authMode = AuthMode.Login;
      }
    });
    
    _formAnimationController.reset();
    _formAnimationController.duration = Duration(milliseconds: 200);
    _formAnimationController.forward();
  }

  Future<void> _authenticate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    debugPrint('🔐 Attempting authentication: email=$email, mode=$_authMode');

    // Validaciones básicas
    if (email.isEmpty || password.isEmpty) {
      debugPrint('🔐 Validation failed: empty fields');
      _showErrorNotification('CAMPOS_VACIÓS // El sistema no acepta identidades incompletas. Completa todo.');
      return;
    }

    if (!_isValidEmail(email)) {
      debugPrint('🔐 Validation failed: invalid email format');
      _showErrorNotification('FORMATO_INVÁLIDO // Eso no parece un correo. El sistema no acepta ruido.');
      return;
    }

    if (password.length < 6) {
      debugPrint('🔐 Validation failed: password too short');
      _showErrorNotification('CLAVE_INSUFICIENTE // Mínimo 6 caracteres. Las contraseñas débiles te hacen vulnerable.');
      return;
    }

    debugPrint('🔐 Validations passed, calling Firebase...');
    bool success = false;
    if (_authMode == AuthMode.Login) {
      success = await authProvider.signIn(email, password);
    } else {
      success = await authProvider.signUp(email, password);
    }

    debugPrint('🔐 Firebase response: success=$success, error=${authProvider.errorMessage}');

    if (!success && authProvider.errorMessage != null) {
      _showErrorNotification(authProvider.errorMessage!);
      authProvider.clearError();
    } else if (success) {
      debugPrint('🔐 Authentication successful! Navigating to MenuScreen...');
      
      // Inicializar UserDataProvider inmediatamente después del login
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      if (authProvider.currentUser != null && !userDataProvider.isInitialized) {
        debugPrint('🔄 [AuthScreen] Inicializando UserDataProvider para usuario: ${authProvider.currentUser!.uid}');
        await userDataProvider.initialize(authProvider.currentUser!.uid);
      }
      
      // Navegar a MenuScreen después de autenticación exitosa
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _authenticateWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint('🔐 Attempting Google Sign-In...');

    bool success = await authProvider.signInWithGoogle();

    debugPrint('🔐 Google Sign-In response: success=$success, error=${authProvider.errorMessage}');

    if (!success && authProvider.errorMessage != null) {
      _showErrorNotification(authProvider.errorMessage!);
      authProvider.clearError();
    } else if (success) {
      debugPrint('🔐 Google authentication successful! Navigating to MenuScreen...');
      
      // Inicializar UserDataProvider inmediatamente después del login con Google
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      if (authProvider.currentUser != null && !userDataProvider.isInitialized) {
        debugPrint('🔄 [AuthScreen] Inicializando UserDataProvider para usuario Google: ${authProvider.currentUser!.uid}');
        await userDataProvider.initialize(authProvider.currentUser!.uid);
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
      }
    }
  }

  void _showErrorNotification(String message) {
    setState(() {
      _currentNotification = message;
      _showNotification = true;
    });

    Future.delayed(Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[800]!, Colors.grey[900]!],
        ),
      ),
    );
  }
  
  Widget _buildGlitchOverlay() {
    switch (_currentGlitch) {
      case GlitchEffect.BlackScreen:
        return Positioned.fill(
          child: Container(color: Colors.black),
        );
      case GlitchEffect.WhiteFlash:
        return Positioned.fill(
          child: Container(color: Colors.white),
        );
      case GlitchEffect.Static:
        return Positioned.fill(
          child: CustomPaint(
            painter: FoundFootagePainter(animationValue: Random().nextDouble(), intensity: 1.0),
          ),
        );
      case GlitchEffect.RGBDistortion:
        return Positioned.fill(
          child: CustomPaint(
            painter: FoundFootagePainter(animationValue: Random().nextDouble(), intensity: 1.5),
          ),
        );
      case GlitchEffect.None:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Fondo de Flores Inquietantes con respiración
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _distortionController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: FlowerBackgroundPainter(
                        animationValue: _distortionController.value,
                      ),
                    );
                  },
                ),
              ),
              
              // Overlay oscuro con distorsión dinámico
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _distortionController,
                  builder: (context, child) {
                    final opacity = 0.65 + (_distortionController.value * 0.15);
                    return Container(
                      color: Colors.black.withOpacity(opacity),
                    );
                  },
                ),
              ),
              
              // Indicador de "REC"
              Positioned(
                top: 20,
                right: 20,
                child: AnimatedBuilder(
                  animation: _eyeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _eyeController.value > 0.5 ? 1.0 : 0.3,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'REC',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Formulario vertical
              Center(
                child: FadeTransition(
                  opacity: _formFadeAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: 40.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo y título
                        Icon(
                          Icons.remove_red_eye,
                          color: Colors.red[900],
                          size: 80,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'WITNESS.ME',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 32,
                            letterSpacing: 4,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _authMode == AuthMode.Login ? 'ACCESO AL SISTEMA' : 'NUEVO REGISTRO',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 14,
                            letterSpacing: 2,
                            color: Colors.red[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 50),
                        
                        // Campo de email
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'IDENTIDAD',
                            labelStyle: TextStyle(
                              color: Colors.red[200],
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.7),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            prefixIcon: Icon(Icons.person_outline, color: Colors.red[300]),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Campo de contraseña
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'CÓDIGO DE ACCESO',
                            labelStyle: TextStyle(
                              color: Colors.red[200],
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.7),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.red[300]),
                          ),
                          obscureText: true,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                        
                        SizedBox(height: 30),
                        
                        // Botón principal
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              debugPrint('🔘 Button clicked!');
                              _authenticate();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.red, width: 2),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _authMode == AuthMode.Login ? '[ ACCEDER ]' : '[ REGISTRAR ]',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red[300],
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 15),
                        
                        // Botón de Google
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              debugPrint('🔘 Google Sign-In button clicked!');
                              _authenticateWithGoogle();
                            },
                            icon: Icon(
                              Icons.g_mobiledata,
                              color: Colors.red[300],
                              size: 32,
                            ),
                            label: Text(
                              '[ GOOGLE ]',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red[300],
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.red.withOpacity(0.7), width: 2),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 25),
                        
                        // Botón de cambio de modo
                        TextButton(
                          onPressed: _switchAuthMode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            _authMode == AuthMode.Login
                                ? '> No estás registrado...'
                                : '> Ya tienes acceso...',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontFamily: 'monospace',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Notificaciones estilo terminal
              if (_showNotification && _currentNotification != null)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.red.withOpacity(0.8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 4,
                          color: Colors.red[900],
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red[900],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'SISTEMA COMPROMETIDO',
                                      style: TextStyle(
                                        color: Colors.red[900],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                _currentNotification!,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Línea de escaneo
              AnimatedBuilder(
                animation: _eyeController,
                builder: (context, child) {
                  return Positioned(
                    top: screenHeight * _eyeController.value,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.red.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Glitch Effects
              _buildGlitchOverlay(),
            ],
          ),
        ),
        
        // Indicador de carga global
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (!authProvider.isLoading) return SizedBox.shrink();
            return Material(
              color: Colors.black.withOpacity(0.95),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]!),
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        _authMode == AuthMode.Login ? 'IDENTIFICANDO...' : 'REGISTRANDO...',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 14,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class FlowerBackgroundPainter extends CustomPainter {
  final double animationValue;

  FlowerBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(1234);
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Fondo base negro absoluto
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    
    // Dibujar ojos que te observan y parpadean
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      // Cada ojo parpadea en momentos diferentes
      final blinkPhase = (animationValue * 3 + i * 0.3) % 1.0;
      final isBlinking = blinkPhase > 0.85; // Parpadeo rápido
      
      // Movimiento sutil de seguimiento
      final followX = sin(animationValue * 2 * pi + i) * 2;
      final followY = cos(animationValue * 1.5 * pi + i) * 2;
      
      final eyeSize = 15.0 + random.nextDouble() * 25.0;
      
      // Blanco del ojo (más visible y perturbador)
      paint.color = Color.lerp(
        const Color(0xFF1A0000), 
        const Color(0xFF3A1010),
        random.nextDouble()
      )!;
      
      if (!isBlinking) {
        // Ojo abierto - forma de almendra
        final eyePath = Path();
        eyePath.addOval(Rect.fromCenter(
          center: Offset(x, y),
          width: eyeSize,
          height: eyeSize * 0.6,
        ));
        canvas.drawPath(eyePath, paint);
        
        // Iris rojo/oscuro que te sigue
        paint.color = Color.lerp(
          const Color(0xFF4A0000),
          const Color(0xFF6A0000),
          random.nextDouble()
        )!;
        canvas.drawCircle(
          Offset(x + followX, y + followY),
          eyeSize * 0.3,
          paint,
        );
        
        // Pupila negra que te mira
        paint.color = Colors.black;
        canvas.drawCircle(
          Offset(x + followX, y + followY),
          eyeSize * 0.15,
          paint,
        );
        
        // Brillo inquietante
        paint.color = Colors.red.withOpacity(0.3);
        canvas.drawCircle(
          Offset(x + followX - eyeSize * 0.05, y + followY - eyeSize * 0.05),
          eyeSize * 0.08,
          paint,
        );
      } else {
        // Ojo cerrado - línea horizontal
        paint.color = const Color(0xFF2A0000);
        paint.strokeWidth = 2;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(x - eyeSize * 0.5, y),
          Offset(x + eyeSize * 0.5, y),
          paint,
        );
        paint.style = PaintingStyle.fill;
      }
      
      // Venas rojas ocasionales
      if (random.nextDouble() > 0.7) {
        paint.color = Colors.red.withOpacity(0.2);
        paint.strokeWidth = 0.5;
        paint.style = PaintingStyle.stroke;
        for (int v = 0; v < 3; v++) {
          final veinPath = Path();
          veinPath.moveTo(x, y);
          veinPath.lineTo(
            x + (random.nextDouble() - 0.5) * eyeSize,
            y + (random.nextDouble() - 0.5) * eyeSize * 0.6,
          );
          canvas.drawPath(veinPath, paint);
        }
        paint.style = PaintingStyle.fill;
      }
    }
    
    // Sombras y manchas oscuras para más incomodidad
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final blobSize = 30.0 + random.nextDouble() * 80.0;
      
      paint.color = Colors.black.withOpacity(0.3 + random.nextDouble() * 0.3);
      canvas.drawCircle(Offset(x, y), blobSize, paint);
    }
  }

  @override
  bool shouldRepaint(FlowerBackgroundPainter oldDelegate) => true;
}

class FoundFootagePainter extends CustomPainter {
  final double animationValue;
  final double intensity;

  FoundFootagePainter({required this.animationValue, this.intensity = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((animationValue * 1000).toInt());
    
    // Grano de película grueso
    final grainPaint = Paint();
    for (int i = 0; i < (800 * intensity).toInt(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      grainPaint.color = Colors.white.withOpacity(random.nextDouble() * 0.08);
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), grainPaint);
    }

    // Interferencia de líneas CRT
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;
    
    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // Aberración cromática violenta
    if (intensity > 1.0) {
      final rect = Rect.fromLTWH(0, random.nextDouble() * size.height, size.width, random.nextDouble() * 10);
      canvas.drawRect(rect, Paint()..color = Colors.red.withOpacity(0.15));
      canvas.drawRect(rect.shift(const Offset(3, 0)), Paint()..color = Colors.blue.withOpacity(0.15));
    }
  }

  @override
  bool shouldRepaint(FoundFootagePainter oldDelegate) => true;
}
