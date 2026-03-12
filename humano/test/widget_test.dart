import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humano/main.dart';
import 'package:humano/screens/splash_screen.dart';
import 'package:humano/screens/loading_screen.dart';
import 'package:humano/screens/auth_screen.dart';

void main() {
  group('SplashScreen Tests', () {
    testWidgets('displays heart logo and app name', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SplashScreen()));

      // Verify heart logo is displayed
      expect(find.byType(Image), findsOneWidget);
      
      // Verify app name text is displayed
      expect(find.text('The Quiescent Heart'), findsOneWidget);
    });

    testWidgets('has black background', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SplashScreen()));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('navigates to LoadingScreen after timer', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SplashScreen()));

      // Verify we're on SplashScreen
      expect(find.text('The Quiescent Heart'), findsOneWidget);

      // Wait for timer to complete (3 seconds)
      await tester.pumpAndSettle(Duration(seconds: 4));

      // Verify navigation to LoadingScreen occurred
      expect(find.byType(LoadingScreen), findsOneWidget);
      expect(find.text('The Quiescent Heart'), findsNothing);
    });
  });

  group('LoadingScreen Tests', () {
    testWidgets('displays loading indicator and text', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoadingScreen()));

      // Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify loading text is displayed
      expect(find.text('Cargando...'), findsOneWidget);
    });

    testWidgets('has background image with overlay', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoadingScreen()));

      // Verify Stack is used for layering
      expect(find.byType(Stack), findsOneWidget);
      
      // Verify Container with opacity exists (overlay)
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.any((c) => c.color?.opacity == 0.5), isTrue);
    });

    testWidgets('navigates to AuthScreen after timer', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoadingScreen()));

      // Verify we're on LoadingScreen
      expect(find.text('Cargando...'), findsOneWidget);

      // Wait for timer to complete (3 seconds)
      await tester.pumpAndSettle(Duration(seconds: 4));

      // Verify navigation to AuthScreen occurred
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Cargando...'), findsNothing);
    });
  });

  group('AuthScreen Tests', () {
    testWidgets('displays login form by default', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Verify login title is displayed
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      
      // Verify username field exists
      expect(find.widgetWithText(TextField, 'Usuario'), findsOneWidget);
      
      // Verify PIN field exists
      expect(find.widgetWithText(TextField, 'PIN'), findsOneWidget);
      
      // Verify login button exists
      expect(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('displays heart logo', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Verify heart logo is displayed
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('switches to signup mode when toggle is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Verify we start in login mode
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('¿No tienes una cuenta? Regístrate'), findsOneWidget);

      // Tap the toggle button
      await tester.tap(find.text('¿No tienes una cuenta? Regístrate'));
      await tester.pumpAndSettle();

      // Verify we switched to signup mode
      expect(find.text('Crear Cuenta'), findsOneWidget);
      expect(find.text('¿Ya tienes una cuenta? Inicia Sesión'), findsOneWidget);
    });

    testWidgets('switches back to login mode from signup', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Switch to signup mode
      await tester.tap(find.text('¿No tienes una cuenta? Regístrate'));
      await tester.pumpAndSettle();

      // Verify we're in signup mode
      expect(find.text('Crear Cuenta'), findsOneWidget);

      // Switch back to login mode
      await tester.tap(find.text('¿Ya tienes una cuenta? Inicia Sesión'));
      await tester.pumpAndSettle();

      // Verify we're back in login mode
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('username and PIN fields accept input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Enter username
      await tester.enterText(find.widgetWithText(TextField, 'Usuario'), 'testuser');
      expect(find.text('testuser'), findsOneWidget);

      // Enter PIN
      await tester.enterText(find.widgetWithText(TextField, 'PIN'), '1234');
      // PIN field is obscured, so we can't verify the text directly
      // but we can verify the field accepted input
      final pinField = tester.widget<TextField>(find.widgetWithText(TextField, 'PIN'));
      expect(pinField.obscureText, isTrue);
    });

    testWidgets('has background with overlay', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthScreen()));

      // Verify Stack is used for layering
      expect(find.byType(Stack), findsOneWidget);
      
      // Verify Container with opacity exists (overlay)
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.any((c) => c.color?.opacity == 0.6), isTrue);
    });
  });

  group('Full Authentication Flow Integration Test', () {
    testWidgets('completes full navigation flow from splash to auth', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Step 1: Verify we start on SplashScreen
      expect(find.text('The Quiescent Heart'), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);

      // Step 2: Wait for SplashScreen timer and verify navigation to LoadingScreen
      await tester.pumpAndSettle(Duration(seconds: 4));
      expect(find.byType(LoadingScreen), findsOneWidget);
      expect(find.text('Cargando...'), findsOneWidget);

      // Step 3: Wait for LoadingScreen timer and verify navigation to AuthScreen
      await tester.pumpAndSettle(Duration(seconds: 4));
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);

      // Step 4: Verify auth form is functional
      await tester.enterText(find.widgetWithText(TextField, 'Usuario'), 'testuser');
      await tester.enterText(find.widgetWithText(TextField, 'PIN'), '1234');
      
      // Verify inputs were accepted
      expect(find.text('testuser'), findsOneWidget);
    });
  });
}
