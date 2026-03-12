import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import 'auth_screen.dart';
import 'intro_screen.dart';
import 'menu_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final bool _isInitializing = true;
  String _statusMessage = 'CONECTANDO NEURONAS...';

  @override
  void initState() {
    super.initState();
    
    // Crear AnimationController con duración de 2 segundos y repeat infinito
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Inicializar datos del usuario
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      
      final user = authProvider.currentUser;
      
      // Si no hay usuario autenticado, ir a login
      if (user == null) {
        await Future.delayed(Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: Duration(milliseconds: 300),
            ),
          );
        }
        return;
      }

      // Usuario autenticado - inicializar datos
      setState(() {
        _statusMessage = 'ABRIENDO MEMORIAS...';
      });

      // Inicializar UserDataProvider (crea documento si es primera vez)
      await userDataProvider.initialize(user.uid);

      // Verificar si es primera vez del usuario
      final isFirstTime = await _checkIfFirstTime(user.uid);

      // Pequeña pausa para mostrar el loading
      await Future.delayed(Duration(milliseconds: 1000));

      if (!mounted) return;

      // Navegar según si es primera vez o no
      if (isFirstTime) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => IntroScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MenuScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      print('Error initializing user data: $e');
      
      // En caso de error, ir a login
      if (mounted) {
        setState(() {
          _statusMessage = ' FALLO EN EL NODO';
        });
        
        await Future.delayed(Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: Duration(milliseconds: 300),
            ),
          );
        }
      }
    }
  }

  /// Verifica si es la primera vez del usuario
  Future<bool> _checkIfFirstTime(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'first_time_$userId';
      final isFirstTime = prefs.getBool(key) ?? true;
      
      if (isFirstTime) {
        await prefs.setBool(key, false);
      }
      
      return isFirstTime;
    } catch (e) {
      print('Error checking first time: $e');
      return false; // Por defecto, no es primera vez si hay error
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            RotationTransition(
              turns: _animation,
              child: Image.asset(
                'assets/images/heart.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.favorite,
                    size: 120,
                    color: Color(0xFF8B0000),
                  );
                },
              ),
            ),
            
            SizedBox(height: 30),
            
            // Mensaje de estado
            Text(
              _statusMessage,
              style: GoogleFonts.courierPrime(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Indicador de progreso
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
