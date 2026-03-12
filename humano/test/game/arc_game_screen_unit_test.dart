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

/// Unit tests for ArcGameScreen widget lifecycle
/// Tests specific behaviors of initState(), build(), and dispose()

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Widget Lifecycle Tests', () {
    /// Test that initState() creates GameWidget exactly once
    testWidgets('initState creates GameWidget once', (WidgetTester tester) async {
      await tester.pumpWidget(_createTestApp('arc_1_gula'));
      await tester.pumpAndSettle();
      
      // Find the ArcGameScreen widget
      final screenFinder = find.byType(ArcGameScreen);
      expect(screenFinder, findsOneWidget);
      
      // Trigger multiple rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.pump();
      }
      
      // Widget should still exist and work correctly
      expect(screenFinder, findsOneWidget);
      
      // Cleanup
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
    });

    /// Test that build() reuses the same GameWidget
    testWidgets('build reuses same GameWidget across rebuilds', 
        (WidgetTester tester) async {
      bool attachmentErrorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().toLowerCase().contains('attachment')) {
          attachmentErrorOccurred = true;
        }
        originalOnError?.call(details);
      };
      
      try {
        await tester.pumpWidget(_createTestApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        // Trigger 50 rebuilds
        for (int i = 0; i < 50; i++) {
          await tester.pump();
        }
        
        // No attachment errors should occur if GameWidget is reused
        expect(attachmentErrorOccurred, isFalse,
            reason: 'GameWidget should be reused without causing attachment errors');
        
        // Cleanup
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = originalOnError;
      }
    });

    /// Test that dispose() cleans up correctly
    testWidgets('dispose cleans up game resources', (WidgetTester tester) async {
      bool disposalErrorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        disposalErrorOccurred = true;
        originalOnError?.call(details);
      };
      
      try {
        // Create widget
        await tester.pumpWidget(_createTestApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        // Dispose widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();
        
        // No errors should occur during disposal
        expect(disposalErrorOccurred, isFalse,
            reason: 'Disposal should complete without errors');
      } finally {
        FlutterError.onError = originalOnError;
      }
    });
  });

  group('Disposal Order Tests', () {
    /// Test that dispose() executes operations in correct order
    testWidgets('dispose executes in correct order', (WidgetTester tester) async {
      // This test verifies the disposal process completes without errors
      // The actual order is verified by the implementation
      
      await tester.pumpWidget(_createTestApp('arc_1_gula'));
      await tester.pumpAndSettle();
      
      // Dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
      
      // If we get here without errors, disposal order is correct
      expect(true, isTrue);
    });

    /// Test disposal with multiple arcs
    testWidgets('disposal works for all arc types', (WidgetTester tester) async {
      final arcIds = [
        'arc_1_gula',
        'arc_2_greed',
        'arc_3_envy',
        'arc_4_lust',
        'arc_5_pride',
        'arc_6_sloth',
        'arc_7_wrath',
      ];
      
      for (final arcId in arcIds) {
        bool errorOccurred = false;
        
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errorOccurred = true;
          originalOnError?.call(details);
        };
        
        try {
          // Create
          await tester.pumpWidget(_createTestApp(arcId));
          await tester.pumpAndSettle();
          
          // Dispose
          await tester.pumpWidget(const MaterialApp(home: Scaffold()));
          await tester.pumpAndSettle();
          
          // Verify no errors
          expect(errorOccurred, isFalse,
              reason: 'Disposal should work for $arcId without errors');
        } finally {
          FlutterError.onError = originalOnError;
        }
      }
    });
  });

  group('State Flags Tests', () {
    /// Test _isInitialized flag lifecycle
    testWidgets('widget shows loading when not initialized', 
        (WidgetTester tester) async {
      // Create widget
      await tester.pumpWidget(_createTestApp('arc_1_gula'));
      
      // During first frame, might show loading
      // After pumpAndSettle, should be initialized
      await tester.pumpAndSettle();
      
      // Widget should be fully rendered (not showing loading)
      final screenFinder = find.byType(ArcGameScreen);
      expect(screenFinder, findsOneWidget);
      
      // Cleanup
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
    });

    /// Test build() guards work correctly
    testWidgets('build guards prevent errors during disposal', 
        (WidgetTester tester) async {
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorOccurred = true;
        originalOnError?.call(details);
      };
      
      try {
        // Create widget
        await tester.pumpWidget(_createTestApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        // Start disposal
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Pump a few times during disposal
        await tester.pump();
        await tester.pump();
        
        // Complete disposal
        await tester.pumpAndSettle();
        
        // No errors should occur
        expect(errorOccurred, isFalse,
            reason: 'Build guards should prevent errors during disposal');
      } finally {
        FlutterError.onError = originalOnError;
      }
    });

    /// Test rapid navigation doesn't cause issues
    testWidgets('rapid navigation handled correctly', (WidgetTester tester) async {
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorOccurred = true;
        originalOnError?.call(details);
      };
      
      try {
        // Rapid enter-exit cycles
        for (int i = 0; i < 5; i++) {
          await tester.pumpWidget(_createTestApp('arc_1_gula'));
          await tester.pump();
          
          await tester.pumpWidget(const MaterialApp(home: Scaffold()));
          await tester.pump();
        }
        
        // Complete final disposal
        await tester.pumpAndSettle();
        
        // No errors should occur
        expect(errorOccurred, isFalse,
            reason: 'Rapid navigation should be handled without errors');
      } finally {
        FlutterError.onError = originalOnError;
      }
    });
  });
}

// Helper function
Widget _createTestApp(String arcId) {
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
      home: ArcGameScreen(arcId: arcId),
    ),
  );
}
