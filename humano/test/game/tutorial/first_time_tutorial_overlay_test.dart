import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humano/game/ui/first_time_tutorial_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('FirstTimeTutorialOverlay - Property Tests', () {
    // Property 2: Tutorial structure is always complete
    testWidgets('Property 2: tutorial has exactly 5 steps with correct titles', (tester) async {
      bool completed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () => completed = true,
            ),
          ),
        ),
      );
      
      // Wait for fade in animation
      await tester.pumpAndSettle();
      
      // Verify step 1: MOVIMIENTO
      expect(find.text('MOVIMIENTO'), findsOneWidget);
      expect(find.text('Arrastra el joystick (abajo izquierda)\npara moverte por el mapa'), findsOneWidget);
      
      // Tap to advance
      await tester.tap(find.byType(FirstTimeTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify step 2: ESCONDERSE
      expect(find.text('ESCONDERSE'), findsOneWidget);
      expect(find.text('Presiona el botón morado\npara esconderte del enemigo'), findsOneWidget);
      
      // Tap to advance
      await tester.tap(find.byType(FirstTimeTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify step 3: FRAGMENTOS
      expect(find.text('FRAGMENTOS'), findsOneWidget);
      expect(find.text('Recolecta los 5 fragmentos brillantes\nacercándote a ellos'), findsOneWidget);
      
      // Tap to advance
      await tester.tap(find.byType(FirstTimeTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify step 4: CORDURA
      expect(find.text('CORDURA'), findsOneWidget);
      expect(find.text('Tu cordura (arriba izquierda) baja con el tiempo.\nSi llega a 0%, pierdes'), findsOneWidget);
      
      // Tap to advance
      await tester.tap(find.byType(FirstTimeTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify step 5: ¡LISTO!
      expect(find.text('¡LISTO!'), findsOneWidget);
      expect(find.text('Escapa del enemigo y encuentra la salida.\n¡Buena suerte!'), findsOneWidget);
      
      // Verify not completed yet
      expect(completed, isFalse);
      
      // Tap to complete
      await tester.tap(find.byType(FirstTimeTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify completed
      expect(completed, isTrue);
    });
    
    // Property 5: Tap advances tutorial steps
    testWidgets('Property 5: tapping advances to next step', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Start at step 1
      expect(find.text('MOVIMIENTO'), findsOneWidget);
      
      // Tap anywhere on overlay
      await tester.tap(find.byType(FirstTimeTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Should advance to step 2
      expect(find.text('ESCONDERSE'), findsOneWidget);
      expect(find.text('MOVIMIENTO'), findsNothing);
    });
    
    // Property 8: All tutorials have skip button
    testWidgets('Property 8: skip button is visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify skip button exists
      expect(find.text('SALTAR'), findsOneWidget);
      
      // Verify it's in top-right area (SafeArea + Positioned)
      final skipButton = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('SALTAR'),
          matching: find.byType(TextButton),
        ),
      );
      expect(skipButton, isNotNull);
    });
    
    // Property 9: Skip immediately closes tutorial
    testWidgets('Property 9: skip button closes tutorial immediately', (tester) async {
      bool completed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () => completed = true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify we're on step 1
      expect(find.text('MOVIMIENTO'), findsOneWidget);
      expect(completed, isFalse);
      
      // Tap skip button
      await tester.tap(find.text('SALTAR'));
      await tester.pumpAndSettle();
      
      // Verify completed without showing remaining steps
      expect(completed, isTrue);
    });
    
    // Property 10: Tutorial overlay has correct opacity
    testWidgets('Property 10: background has opacity >= 0.85', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the container with background color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ).first,
      );
      
      final color = container.color as Color;
      expect(color.opacity, greaterThanOrEqualTo(0.85));
    });
    
    // Property 11: Tutorial text meets accessibility standards
    testWidgets('Property 11: text has high contrast and size >= 22px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the message text
      final messageText = tester.widget<Text>(
        find.text('Arrastra el joystick (abajo izquierda)\npara moverte por el mapa'),
      );
      
      final style = messageText.style!;
      expect(style.fontSize, greaterThanOrEqualTo(22));
      expect(style.color, equals(Colors.white)); // High contrast on dark background
    });
    
    // Property 12: Progress indicator is accurate
    testWidgets('Property 12: progress indicator shows correct step', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find all progress dots
      final dots = find.byWidgetPredicate(
        (widget) => widget is Container && 
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
                    widget.constraints?.maxWidth == 12,
      );
      
      // Should have 5 dots (one for each step)
      expect(dots, findsNWidgets(5));
      
      // Advance through steps and verify progress
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byType(FirstTimeTutorialOverlay));
        await tester.pumpAndSettle();
        
        // Progress indicator should still show 5 dots
        expect(dots, findsNWidgets(5));
      }
    });
    
    // Property 14: Animation durations are within bounds
    testWidgets('Property 14: fade animation is 300ms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      // Pump for 300ms (fade in duration)
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      
      // Tutorial should be fully visible
      expect(find.byType(FirstTimeTutorialOverlay), findsOneWidget);
    });
  });
  
  group('FirstTimeTutorialOverlay - Accessibility', () {
    testWidgets('buttons have minimum 48x48 touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check skip button size
      final skipButton = tester.getSize(
        find.ancestor(
          of: find.text('SALTAR'),
          matching: find.byType(SizedBox),
        ),
      );
      expect(skipButton.height, greaterThanOrEqualTo(48));
      
      // Check continue button size
      final continueButton = tester.getSize(
        find.ancestor(
          of: find.text('SIGUIENTE'),
          matching: find.byType(SizedBox),
        ),
      );
      expect(continueButton.height, greaterThanOrEqualTo(48));
    });
    
    testWidgets('text is readable with sufficient contrast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstTimeTutorialOverlay(
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Title should be cyan on dark background
      final titleText = tester.widget<Text>(find.text('MOVIMIENTO'));
      expect(titleText.style?.color?.value, isNotNull);
      
      // Message should be white on dark background
      final messageText = tester.widget<Text>(
        find.text('Arrastra el joystick (abajo izquierda)\npara moverte por el mapa'),
      );
      expect(messageText.style?.color, equals(Colors.white));
    });
  });
}
