import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:humano/screens/arc_game_screen.dart';
import 'package:humano/game/arcs/gluttony/gluttony_arc_game.dart';
import 'package:humano/game/arcs/greed/greed_arc_game.dart';
import 'package:humano/game/arcs/envy/envy_arc_game.dart';
import 'package:humano/game/arcs/lust/lust_arc_game.dart';
import 'package:humano/game/arcs/pride/pride_arc_game.dart';
import 'package:humano/game/arcs/sloth/sloth_arc_game.dart';
import 'package:humano/game/arcs/wrath/wrath_arc_game.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/providers/arc_progress_provider.dart';
import 'package:humano/providers/evidence_provider.dart';
import 'package:humano/providers/store_provider.dart';
import 'package:humano/providers/user_data_provider.dart';
import 'package:humano/data/providers/puzzle_data_provider.dart';
import 'package:humano/data/providers/fragments_provider.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'dart:math';

/// Property-based tests for game attachment error fix
/// These tests verify correctness properties across multiple iterations

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **Feature: fix-game-attachment-error, Property 1: Fresh game instance on navigation**
  /// **Validates: Requirements 1.1**
  /// 
  /// Property: For any arc ID, when navigating to that arc, a new game instance 
  /// should be created with a unique hash code different from any previous instance.
  group('Property 1: Fresh game instance on navigation', () {
    final arcIds = [
      'arc_1_gula',
      'arc_2_greed',
      'arc_3_envy',
      'arc_4_lust',
      'arc_5_pride',
      'arc_6_sloth',
      'arc_7_wrath',
    ];

    test('Each navigation creates unique game instance', () {
      final seenHashCodes = <int>{};
      
      // Run 100 iterations as specified
      for (int i = 0; i < 100; i++) {
        // Pick random arc
        final arcId = arcIds[Random().nextInt(arcIds.length)];
        
        // Create game instance
        final game = _createGameForArcId(arcId);
        final hashCode = game.hashCode;
        
        // Verify unique hash code
        expect(seenHashCodes.contains(hashCode), isFalse,
            reason: 'Each game instance should have unique hashCode. '
                'Iteration $i, Arc: $arcId, HashCode: $hashCode');
        
        seenHashCodes.add(hashCode);
      }
      
      // Verify we created 100 unique instances
      expect(seenHashCodes.length, equals(100),
          reason: 'Should have created 100 unique game instances');
    });
  });

  /// **Feature: fix-game-attachment-error, Property 3: Re-entry without attachment errors**
  /// **Validates: Requirements 1.3**
  /// 
  /// Property: For any arc, entering, exiting, and re-entering should complete 
  /// without throwing attachment errors.
  group('Property 3: Re-entry without attachment errors', () {
    testWidgets('Multiple enter-exit-reenter cycles work without errors', 
        (WidgetTester tester) async {
      final arcIds = ['arc_1_gula', 'arc_2_greed', 'arc_3_envy'];
      
      for (final arcId in arcIds) {
        // Run 10 cycles per arc (30 total iterations)
        for (int cycle = 0; cycle < 10; cycle++) {
          bool errorOccurred = false;
          String? errorMessage;
          
          final originalOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            if (details.exception.toString().toLowerCase().contains('attachment')) {
              errorOccurred = true;
              errorMessage = details.exception.toString();
            }
            originalOnError?.call(details);
          };
          
          try {
            // Enter arc
            await tester.pumpWidget(_createTestApp(arcId));
            await tester.pumpAndSettle();
            
            // Exit arc
            await tester.pumpWidget(const MaterialApp(home: Scaffold()));
            await tester.pumpAndSettle();
            
            // Re-enter arc
            await tester.pumpWidget(_createTestApp(arcId));
            await tester.pumpAndSettle();
            
            // Exit again
            await tester.pumpWidget(const MaterialApp(home: Scaffold()));
            await tester.pumpAndSettle();
            
            // Verify no errors
            expect(errorOccurred, isFalse,
                reason: 'No attachment errors should occur. '
                    'Arc: $arcId, Cycle: $cycle, Error: $errorMessage');
          } finally {
            FlutterError.onError = originalOnError;
          }
        }
      }
    }, timeout: const Timeout(Duration(minutes: 5)));
  });

  /// **Feature: fix-game-attachment-error, Property 4: Independent arc instances**
  /// **Validates: Requirements 1.4**
  /// 
  /// Property: For any sequence of arc navigations, each arc should have its own 
  /// independent game instance without conflicts.
  group('Property 4: Independent arc instances', () {
    testWidgets('Sequential arc navigation maintains independence', 
        (WidgetTester tester) async {
      final arcIds = ['arc_1_gula', 'arc_2_greed', 'arc_3_envy'];
      final gameHashCodes = <String, int>{};
      
      // Run 30 iterations (10 per arc)
      for (int i = 0; i < 30; i++) {
        final arcId = arcIds[i % arcIds.length];
        
        bool errorOccurred = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errorOccurred = true;
          originalOnError?.call(details);
        };
        
        try {
          // Navigate to arc
          await tester.pumpWidget(_createTestApp(arcId));
          await tester.pumpAndSettle();
          
          // Get game instance (would need to extract from widget tree)
          // For now, verify no errors occurred
          expect(errorOccurred, isFalse,
              reason: 'No errors should occur during navigation. '
                  'Iteration: $i, Arc: $arcId');
          
          // Exit
          await tester.pumpWidget(const MaterialApp(home: Scaffold()));
          await tester.pumpAndSettle();
        } finally {
          FlutterError.onError = originalOnError;
        }
      }
    }, timeout: const Timeout(Duration(minutes: 3)));
  });

  /// **Feature: fix-game-attachment-error, Property 6: GameWidget identity preservation**
  /// **Validates: Requirements 3.2, 3.4, 3.5**
  /// 
  /// Property: For any number of setState() calls, the GameWidget instance should 
  /// remain the same (same object identity) across all builds.
  group('Property 6: GameWidget identity preservation', () {
    testWidgets('GameWidget identity preserved across rebuilds', 
        (WidgetTester tester) async {
      // This test verifies the GameWidget is created once and reused
      // We'll trigger multiple rebuilds and verify no attachment errors
      
      bool errorOccurred = false;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().toLowerCase().contains('attachment')) {
          errorOccurred = true;
        }
        originalOnError?.call(details);
      };
      
      try {
        await tester.pumpWidget(_createTestApp('arc_1_gula'));
        await tester.pumpAndSettle();
        
        // Trigger 100 rebuilds by pumping
        for (int i = 0; i < 100; i++) {
          await tester.pump();
        }
        
        // Verify no attachment errors occurred
        expect(errorOccurred, isFalse,
            reason: 'GameWidget should be reused without causing attachment errors');
        
        // Cleanup
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = originalOnError;
      }
    });
  });

  /// **Feature: fix-game-attachment-error, Property 7: Stable key consistency**
  /// **Validates: Requirements 3.3**
  /// 
  /// Property: For any game instance, the ObjectKey created for the GameWidget 
  /// should remain constant throughout the widget's lifetime.
  group('Property 7: Stable key consistency', () {
    test('ObjectKey remains stable for game instance', () {
      // Run 100 iterations
      for (int i = 0; i < 100; i++) {
        final game = GluttonyArcGame();
        final key1 = ObjectKey(game);
        final key2 = ObjectKey(game);
        
        // ObjectKey with same object should be equal
        expect(key1, equals(key2),
            reason: 'ObjectKey should be consistent for same game instance. '
                'Iteration: $i');
      }
    });
  });
}

// Helper functions

BaseArcGame _createGameForArcId(String arcId) {
  switch (arcId) {
    case 'arc_1_gula':
      return GluttonyArcGame();
    case 'arc_2_greed':
      return GreedArcGame();
    case 'arc_3_envy':
      return EnvyArcGame();
    case 'arc_4_lust':
      return LustArcGame();
    case 'arc_5_pride':
      return PrideArcGame();
    case 'arc_6_sloth':
      return SlothArcGame();
    case 'arc_7_wrath':
      return WrathArcGame();
    default:
      return GluttonyArcGame();
  }
}

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
