import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:humano/screens/arc_game_screen.dart';
import 'package:humano/providers/arc_progress_provider.dart';
import 'package:humano/providers/evidence_provider.dart';
import 'package:humano/providers/store_provider.dart';
import 'package:humano/providers/user_data_provider.dart';
import 'package:humano/data/providers/puzzle_data_provider.dart';
import 'package:humano/data/providers/fragments_provider.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Integration tests for arc navigation flow
/// Tests complete user journeys through the game

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Full Navigation Flow Integration Tests', () {
    /// Test complete enter-exit-reenter flow for a single arc
    testWidgets('Complete navigation flow for single arc', 
        (WidgetTester tester) async {
      bool errorOccurred = false;
      String? errorMessage;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorOccurred = true;
        errorMessage = details.exception.toString();
        originalOnError?.call(details);
      };
      
      try {
        // Step 1: Navigate to arc
        await tester.pumpWidget(_createNavigationApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        expect(find.byType(ArcGameScreen), findsOneWidget,
            reason: 'ArcGameScreen should be visible');
        
        // Step 2: Exit arc (simulate back button)
        await tester.pumpWidget(_createNavigationApp(null));
        await tester.pumpAndSettle();
        
        expect(find.byType(ArcGameScreen), findsNothing,
            reason: 'ArcGameScreen should be disposed');
        
        // Step 3: Re-enter same arc
        await tester.pumpWidget(_createNavigationApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        expect(find.byType(ArcGameScreen), findsOneWidget,
            reason: 'ArcGameScreen should be visible again');
        
        // Step 4: Exit again
        await tester.pumpWidget(_createNavigationApp(null));
        await tester.pumpAndSettle();
        
        // Verify no errors occurred
        expect(errorOccurred, isFalse,
            reason: 'No errors should occur during navigation flow. Error: $errorMessage');
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    /// Test navigation flow with multiple enter-exit cycles
    testWidgets('Multiple enter-exit cycles work correctly', 
        (WidgetTester tester) async {
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().toLowerCase().contains('attachment')) {
          errorOccurred = true;
        }
        originalOnError?.call(details);
      };
      
      try {
        // Perform 5 complete cycles
        for (int cycle = 0; cycle < 5; cycle++) {
          // Enter
          await tester.pumpWidget(_createNavigationApp('arc_1_gula'));
          await tester.pumpAndSettle();
          
          expect(find.byType(ArcGameScreen), findsOneWidget,
              reason: 'Cycle $cycle: ArcGameScreen should be visible');
          
          // Exit
          await tester.pumpWidget(_createNavigationApp(null));
          await tester.pumpAndSettle();
          
          expect(find.byType(ArcGameScreen), findsNothing,
              reason: 'Cycle $cycle: ArcGameScreen should be disposed');
        }
        
        // Verify no attachment errors
        expect(errorOccurred, isFalse,
            reason: 'No attachment errors should occur across multiple cycles');
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    /// Test navigation with different arcs in sequence
    testWidgets('Sequential navigation between different arcs', 
        (WidgetTester tester) async {
      final arcIds = ['arc_1_gula', 'arc_2_greed', 'arc_3_envy'];
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().toLowerCase().contains('attachment')) {
          errorOccurred = true;
        }
        originalOnError?.call(details);
      };
      
      try {
        for (final arcId in arcIds) {
          // Enter arc
          await tester.pumpWidget(_createNavigationApp(arcId));
          await tester.pumpAndSettle();
          
          expect(find.byType(ArcGameScreen), findsOneWidget,
              reason: '$arcId should be visible');
          
          // Exit arc
          await tester.pumpWidget(_createNavigationApp(null));
          await tester.pumpAndSettle();
          
          expect(find.byType(ArcGameScreen), findsNothing,
              reason: '$arcId should be disposed');
        }
        
        // Verify no errors
        expect(errorOccurred, isFalse,
            reason: 'Sequential navigation should work without attachment errors');
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('Multiple Arcs Integration Tests', () {
    /// Test navigating between different arcs consecutively
    testWidgets('Navigate between all arcs consecutively', 
        (WidgetTester tester) async {
      final arcIds = [
        'arc_1_gula',
        'arc_2_greed',
        'arc_3_envy',
        'arc_4_lust',
        'arc_5_pride',
        'arc_6_sloth',
        'arc_7_wrath',
      ];
      
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().toLowerCase().contains('attachment')) {
          errorOccurred = true;
        }
        originalOnError?.call(details);
      };
      
      try {
        for (final arcId in arcIds) {
          // Navigate to arc
          await tester.pumpWidget(_createNavigationApp(arcId));
          await tester.pumpAndSettle();
          
          // Verify arc is loaded
          expect(find.byType(ArcGameScreen), findsOneWidget,
              reason: '$arcId should load successfully');
          
          // Navigate away
          await tester.pumpWidget(_createNavigationApp(null));
          await tester.pumpAndSettle();
        }
        
        // Verify no errors across all arcs
        expect(errorOccurred, isFalse,
            reason: 'All arcs should load and dispose without attachment errors');
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(minutes: 3)));

    /// Test rapid switching between arcs
    testWidgets('Rapid arc switching works correctly', 
        (WidgetTester tester) async {
      final arcIds = ['arc_1_gula', 'arc_2_greed', 'arc_3_envy'];
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().toLowerCase().contains('attachment')) {
          errorOccurred = true;
        }
        originalOnError?.call(details);
      };
      
      try {
        // Rapidly switch between arcs
        for (int i = 0; i < 10; i++) {
          final arcId = arcIds[i % arcIds.length];
          
          await tester.pumpWidget(_createNavigationApp(arcId));
          await tester.pump(); // Only one pump for rapid switching
          
          await tester.pumpWidget(_createNavigationApp(null));
          await tester.pump();
        }
        
        // Complete final disposal
        await tester.pumpAndSettle();
        
        // Verify no errors
        expect(errorOccurred, isFalse,
            reason: 'Rapid arc switching should not cause attachment errors');
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    /// Test each arc has independent state
    testWidgets('Each arc maintains independent state', 
        (WidgetTester tester) async {
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorOccurred = true;
        originalOnError?.call(details);
      };
      
      try {
        // Navigate to arc 1
        await tester.pumpWidget(_createNavigationApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        // Exit
        await tester.pumpWidget(_createNavigationApp(null));
        await tester.pumpAndSettle();
        
        // Navigate to arc 2
        await tester.pumpWidget(_createNavigationApp('arc_2_greed'));
        await tester.pumpAndSettle();
        
        // Exit
        await tester.pumpWidget(_createNavigationApp(null));
        await tester.pumpAndSettle();
        
        // Return to arc 1 - should be fresh instance
        await tester.pumpWidget(_createNavigationApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        // Exit
        await tester.pumpWidget(_createNavigationApp(null));
        await tester.pumpAndSettle();
        
        // Verify no errors
        expect(errorOccurred, isFalse,
            reason: 'Each arc should maintain independent state');
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}

// Helper function to create navigation app
Widget _createNavigationApp(String? arcId) {
  // Create mock providers for testing with fake firestore
  final fakeFirestore = FakeFirebaseFirestore();
  final userRepository = UserRepository(firestore: fakeFirestore);
  final userDataProvider = UserDataProvider(repository: userRepository);
  
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: userDataProvider),
      ChangeNotifierProvider(
        create: (_) => EvidenceProvider(userDataProvider: userDataProvider),
      ),
      ChangeNotifierProvider(
        create: (_) => StoreProvider(userDataProvider: userDataProvider),
      ),
      ChangeNotifierProvider(create: (_) => ArcProgressProvider()),
      ChangeNotifierProvider(create: (_) => PuzzleDataProvider('test_user')),
      ChangeNotifierProvider(create: (_) => FragmentsProvider()),
    ],
    child: MaterialApp(
      home: arcId != null 
          ? ArcGameScreen(arcId: arcId)
          : const Scaffold(
              body: Center(
                child: Text('Menu'),
              ),
            ),
    ),
  );
}
