import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:humano/screens/splash_screen.dart';
import 'package:humano/core/config/firebase_config.dart';
import 'package:humano/providers/auth_provider.dart';
import 'package:humano/providers/user_data_provider.dart';
import 'package:humano/providers/arc_progress_provider.dart';
import 'package:humano/providers/settings_provider.dart';
import 'package:humano/providers/evidence_provider.dart';
import 'package:humano/providers/store_provider.dart';
import 'package:humano/providers/leaderboard_provider.dart';
import 'package:humano/providers/notifications_provider.dart';
import 'package:humano/providers/theme_provider.dart';
import 'package:humano/providers/audio_provider.dart';
import 'package:humano/data/providers/fragments_provider.dart';
import 'package:humano/data/providers/puzzle_data_provider.dart';
import 'package:humano/data/repositories/firebase_auth_repository.dart';
import 'package:humano/data/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await FirebaseConfig.initialize();
  
  // Inicializar Stripe en modo test
  Stripe.publishableKey = 'pk_test_51SVyk1Gr2CjLtfKaDO85Sz5zfnf7gB4H5YkI2geUFkANrTiL9uaWejOynm8m9Rj39XIIjmqrdc89vVNT5m4IJsbc00Y4ufsxte';
  Stripe.merchantIdentifier = 'merchant.com.humano';
  
  // Forzar orientación vertical (portrait) en todo el sistema
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - Base de autenticación
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: FirebaseAuthRepository(),
          ),
        ),
        
        // User Data Provider - Sistema central de base de datos
        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          create: (_) => UserDataProvider(
            repository: UserRepository(),
          ),
          update: (_, authProvider, previous) {
            final provider = previous ?? UserDataProvider(repository: UserRepository());
            
            // Inicializar automáticamente cuando hay usuario autenticado
            if (authProvider.currentUser != null && !provider.isInitialized) {
              provider.initialize(authProvider.currentUser!.uid);
            }
            
            return provider;
          },
        ),
        
        // Providers que dependen de UserDataProvider
        ChangeNotifierProxyProvider<UserDataProvider, StoreProvider>(
          create: (context) => StoreProvider(
            userDataProvider: context.read<UserDataProvider>(),
          ),
          update: (_, userDataProvider, previous) =>
              previous ?? StoreProvider(userDataProvider: userDataProvider),
        ),
        ChangeNotifierProxyProvider<UserDataProvider, AppThemeProvider>(
          create: (_) => AppThemeProvider(),
          update: (_, userDataProvider, previous) {
            final provider = previous ?? AppThemeProvider();
            if (userDataProvider.isInitialized) {
              provider.updateThemeFromInventory(userDataProvider.inventory.equippedTheme);
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserDataProvider, EvidenceProvider>(
          create: (context) => EvidenceProvider(
            userDataProvider: context.read<UserDataProvider>(),
          ),
          update: (_, userDataProvider, previous) =>
              previous ?? EvidenceProvider(userDataProvider: userDataProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ArcProgressProvider>(
          create: (_) => ArcProgressProvider(),
          update: (_, authProvider, previous) {
            final provider = previous ?? ArcProgressProvider();
            if (authProvider.currentUser != null) {
              provider.loadProgress(authProvider.currentUser!.uid);
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProxyProvider2<SettingsProvider, UserDataProvider, AudioProvider>(
          create: (context) => AudioProvider(
            context.read<SettingsProvider>(),
            context.read<UserDataProvider>(),
          ),
          update: (_, settings, userData, previous) {
            final provider = previous ?? AudioProvider(settings, userData);
            provider.updateUserData(userData);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, FragmentsProvider>(
          create: (_) => FragmentsProvider(),
          update: (_, authProvider, previous) {
            final provider = previous ?? FragmentsProvider();
            
            // Cargar progreso automáticamente cuando hay usuario autenticado
            if (authProvider.currentUser != null) {
              provider.loadProgress();
            }
            
            return provider;
          },
        ),
        // Puzzle Data Provider - Sistema de rompecabezas
        ChangeNotifierProxyProvider<AuthProvider, PuzzleDataProvider>(
          create: (context) {
            final authProvider = context.read<AuthProvider>();
            final userId = authProvider.currentUser?.uid ?? 'anonymous';
            return PuzzleDataProvider(userId);
          },
          update: (_, authProvider, previous) {
            final userId = authProvider.currentUser?.uid ?? 'anonymous';
            // Si cambió el usuario, crear nueva instancia
            if (previous == null || previous.userId != userId) {
              return PuzzleDataProvider(userId);
            }
            return previous;
          },
        ),
        
        // Leaderboard Provider - Sistema de clasificación
        ChangeNotifierProxyProvider<AuthProvider, LeaderboardProvider>(
          create: (_) => LeaderboardProvider(),
          update: (_, authProvider, previous) {
            final provider = previous ?? LeaderboardProvider();
            
            // Cargar leaderboard automáticamente cuando hay usuario autenticado
            if (authProvider.currentUser != null) {
              provider.loadLeaderboard();
            }
            
            return provider;
          },
        ),
        
        // Notifications Provider - Sistema de notificaciones progresivas
        ChangeNotifierProxyProvider<AuthProvider, NotificationsProvider>(
          create: (_) => NotificationsProvider(),
          update: (_, authProvider, previous) {
            final provider = previous ?? NotificationsProvider();
            
            // Inicializar notificaciones cuando hay usuario autenticado
            if (authProvider.currentUser != null) {
              provider.initialize(authProvider.currentUser!.uid);
            }
            
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Witness.me',
        debugShowCheckedModeBanner: false, // Quitar banner de debug
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
