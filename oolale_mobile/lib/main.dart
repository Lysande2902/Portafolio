import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/home_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/events/create_event_screen.dart';
import 'screens/connections/connections_screen.dart';
import 'screens/reports/create_report_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/messages/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Configuración de rutas
    final GoRouter router = GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.status == AuthStatus.authenticated;
        final isLoggingIn = state.uri.toString() == '/login';
        final isAtRoot = state.uri.toString() == '/';
        
        debugPrint('ROUTER: path=${state.uri}, status=${authProvider.status}, isLoggedIn=$isLoggedIn');

        if (authProvider.status == AuthStatus.checking) return null;

        if (!isLoggedIn) {
          return isLoggingIn ? null : '/login';
        }

        if (isLoggedIn) {
          if (isLoggingIn || isAtRoot) return '/dashboard';
        }
        
        return null;
      },
      routes: [
         GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/create-event',
          builder: (context, state) => const CreateEventScreen(),
        ),
        GoRoute(
          path: '/connections',
          builder: (context, state) => const ConnectionsScreen(),
        ),
        GoRoute(
          path: '/create-report',
          builder: (context, state) => const CreateReportScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
        ),
        GoRoute(
          path: '/messages/:id',
          builder: (context, state) {
            final userId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            final userName = state.extra as String? ?? 'Chat';
            return ChatScreen(userId: userId, userName: userName);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.accentColor,
          surface: AppConstants.cardColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.cardColor,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
