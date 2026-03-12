import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humano/game/ui/arc_specific_tutorial_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ArcSpecificTutorialOverlay - Property Tests', () {
    // Property 23: Arc tutorials display correct objectives
    testWidgets('Property 23: Gluttony arc shows correct objective', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Skip confirmation dialog
      await tester.tap(find.text('SÍ'));
      await tester.pumpAndSettle();
      
      // Verify objective is displayed
      expect(find.textContaining('Recolecta 5 fragmentos y escapa del restaurante'), findsOneWidget);
    });
    
    testWidgets('Property 23: Greed arc shows correct objective', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_2_greed',
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Skip confirmation dialog
      await tester.tap(find.text('SÍ'));
      await tester.pumpAndSettle();
      
      // Verify objective is displayed
      expect(find.textContaining('Recolecta 5 fragmentos y escapa del banco'), findsOneWidget);
    });
    
    testWidgets('Property 23: Envy arc shows correct objective', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_3_envy',
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Skip confirmation dialog
      await tester.tap(find.text('SÍ'));
      await tester.pumpAndSettle();
      
      // Verify objective is displayed
      expect(find.textContaining('Recolecta 5 fragmentos y escapa del gimnasio'), findsOneWidget);
    });
    
    // Property 24: Tutorial terminology matches UI
    testWidgets('Property 24: uses consistent terminology', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      await tester.tap(find.text('SÍ'));
      await tester.pumpAndSettle();
      
      // Advance to controls slide
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify consistent terminology
      expect(find.textContaining('Joystick'), findsOneWidget);
      expect(find.textContaining('Botón morado'), findsOneWidget);
    });
    
    // Property 25: Manual tutorial shows correct arc content
    testWidgets('Property 25: manual trigger shows correct content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_2_greed',
              onComplete: () {},
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should skip confirmation dialog
      expect(find.text('¿VER TUTORIAL?'), findsNothing);
      
      // Should show arc content directly
      expect(find.textContaining('AVARICIA'), findsOneWidget);
    });
    
    // Property 26: Manual tutorial doesn't affect completion state
    testWidgets('Property 26: manual trigger mode is respected', (tester) async {
      bool completed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () => completed = true,
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Skip tutorial
      await tester.tap(find.text('SALTAR'));
      await tester.pumpAndSettle();
      
      // Verify completion callback was called
      expect(completed, isTrue);
    });
    
    testWidgets('confirmation dialog shows before tutorial', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify confirmation dialog is shown
      expect(find.text('¿VER TUTORIAL?'), findsOneWidget);
      expect(find.text('NO'), findsOneWidget);
      expect(find.text('SÍ'), findsOneWidget);
    });
    
    testWidgets('NO button skips tutorial', (tester) async {
      bool completed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () => completed = true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap NO
      await tester.tap(find.text('NO'));
      await tester.pumpAndSettle();
      
      // Should complete without showing tutorial
      expect(completed, isTrue);
    });
    
    testWidgets('skip button works during tutorial', (tester) async {
      bool completed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () => completed = true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Start tutorial
      await tester.tap(find.text('SÍ'));
      await tester.pumpAndSettle();
      
      // Skip
      await tester.tap(find.text('SALTAR'));
      await tester.pumpAndSettle();
      
      expect(completed, isTrue);
    });
  });
  
  group('ArcSpecificTutorialOverlay - Arc-Specific Content', () {
    testWidgets('Gluttony arc mentions hiding and devourer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Advance to mechanic slide
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify devourer mechanic is explained
      expect(find.textContaining('devora'), findsOneWidget);
      expect(find.textContaining('esconderte'), findsOneWidget);
    });
    
    testWidgets('Greed arc mentions sanity theft and cash registers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_2_greed',
              onComplete: () {},
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Advance to mechanic slide
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify theft mechanic is explained
      expect(find.textContaining('10%'), findsOneWidget);
      expect(find.textContaining('cordura'), findsOneWidget);
      
      // Advance to strategy slide
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify cash registers are mentioned
      expect(find.textContaining('cajas registradoras'), findsOneWidget);
      expect(find.textContaining('50%'), findsOneWidget);
    });
    
    testWidgets('Envy arc explicitly states NO hiding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_3_envy',
              onComplete: () {},
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Advance to mechanic slide
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify NO HIDING is explicitly stated
      expect(find.textContaining('NO HAY ESCONDITES'), findsOneWidget);
      
      // Advance to controls slide
      await tester.tap(find.byType(ArcSpecificTutorialOverlay));
      await tester.pumpAndSettle();
      
      // Verify NO HIDE BUTTON is stated
      expect(find.textContaining('NO HAY BOTÓN DE ESCONDERSE'), findsOneWidget);
      expect(find.textContaining('PURO MOVIMIENTO'), findsOneWidget);
    });
  });
  
  group('ArcSpecificTutorialOverlay - UI Properties', () {
    testWidgets('has skip button visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('SALTAR'), findsOneWidget);
    });
    
    testWidgets('has progress indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find progress dots
      final dots = find.byWidgetPredicate(
        (widget) => widget is Container &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
                    widget.constraints?.maxWidth == 12,
      );
      
      // Should have 4 dots for Gluttony arc
      expect(dots, findsNWidgets(4));
    });
    
    testWidgets('text meets accessibility standards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
              isManualTrigger: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find description text
      final descText = tester.widget<Text>(
        find.textContaining('Recolecta 5 fragmentos'),
      );
      
      // Verify font size >= 22px
      expect(descText.style?.fontSize, greaterThanOrEqualTo(22));
      
      // Verify high contrast (white on dark)
      expect(descText.style?.color, equals(Colors.white));
    });
    
    testWidgets('buttons have minimum 48x48 touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcSpecificTutorialOverlay(
              arcId: 'arc_1_gula',
              onComplete: () {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check YES button
      final yesButton = tester.getSize(
        find.ancestor(
          of: find.text('SÍ'),
          matching: find.byType(SizedBox),
        ),
      );
      expect(yesButton.height, greaterThanOrEqualTo(48));
      
      // Check NO button
      final noButton = tester.getSize(
        find.ancestor(
          of: find.text('NO'),
          matching: find.byType(SizedBox),
        ),
      );
      expect(noButton.height, greaterThanOrEqualTo(48));
    });
  });
}
