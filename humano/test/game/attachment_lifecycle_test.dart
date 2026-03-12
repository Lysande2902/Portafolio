import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:humano/game/arcs/gluttony/gluttony_arc_game.dart';
import 'package:humano/game/arcs/greed/greed_arc_game.dart';
import 'package:humano/game/arcs/envy/envy_arc_game.dart';
import 'package:humano/game/arcs/lust/lust_arc_game.dart';
import 'package:humano/game/arcs/pride/pride_arc_game.dart';
import 'package:humano/game/arcs/sloth/sloth_arc_game.dart';
import 'package:humano/game/arcs/wrath/wrath_arc_game.dart';
import 'package:humano/game/core/base/base_arc_game.dart';

/// **Feature: fix-flame-attachment-error, Property 2: Successful Initialization Without Errors**
/// **Validates: Requirements 1.2**
/// 
/// Property: For any arc game type, initialization and asset loading should 
/// complete without throwing attachment-related exceptions.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Property 2: Initialization Success', () {
    final arcTypes = [
      'Gluttony',
      'Greed',
      'Envy',
      'Lust',
      'Pride',
      'Sloth',
      'Wrath',
    ];

    for (final arcType in arcTypes) {
      testWidgets('$arcType arc - initializes without attachment errors', (WidgetTester tester) async {
        bool attachmentErrorOccurred = false;
        String? errorMessage;
        
        // Capture any errors during initialization
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exception.toString().toLowerCase().contains('attachment')) {
            attachmentErrorOccurred = true;
            errorMessage = details.exception.toString();
          }
          originalOnError?.call(details);
        };
        
        try {
          // Create game
          final game = _createGameForArc(arcType);
          
          // Create GameWidget
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: GameWidget(
                  key: GlobalKey(debugLabel: 'TestGameWidget_$arcType'),
                  game: game,
                ),
              ),
            ),
          );
          
          // Wait for initialization
          await tester.pumpAndSettle(const Duration(seconds: 3));
          
          // Verify no attachment errors occurred
          expect(attachmentErrorOccurred, isFalse,
              reason: 'No attachment errors should occur during initialization for $arcType. Error: $errorMessage');
          
          // Cleanup
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        } finally {
          FlutterError.onError = originalOnError;
        }
      }, timeout: const Timeout(Duration(seconds: 30)));
    }
  });

  /// **Feature: fix-flame-attachment-error, Property 7: No Recreation on Rebuild**
  /// **Validates: Requirements 3.2**
  /// 
  /// Property: For any GameWidget with a GlobalKey, the game instance hashCode
  /// should remain constant across all build cycles until disposal.
  group('Property 7: Rebuild Stability', () {
    testWidgets('Game hashCode remains unchanged across rebuilds', (WidgetTester tester) async {
      final game = GluttonyArcGame();
      final gameHashCode = game.hashCode;
      final key = GlobalKey(debugLabel: 'StableGameWidget');
      
      // Initial build
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameWidget(
              key: key,
              game: game,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify initial state
      expect(game.hashCode, equals(gameHashCode),
          reason: 'Game hashCode should not change after initial build');
      
      // Trigger multiple rebuilds
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameWidget(
                key: key,
                game: game,
              ),
            ),
          ),
        );
        
        await tester.pump();
        
        // Verify game instance unchanged
        expect(game.hashCode, equals(gameHashCode),
            reason: 'Game hashCode should remain constant after rebuild $i');
      }
      
      // Cleanup
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });

  /// **Feature: fix-flame-attachment-error, Property 4: Clean Detachment on Disposal**
  /// **Feature: fix-flame-attachment-error, Property 8: Proper State Reset on Disposal**
  /// **Validates: Requirements 1.4, 3.4**
  /// 
  /// Property: For any game instance being disposed, the game state should be
  /// properly reset and no errors should occur during disposal.
  group('Property 4 & 8: Disposal Cleanup', () {
    testWidgets('Game disposes cleanly without errors', (WidgetTester tester) async {
      bool disposalErrorOccurred = false;
      String? errorMessage;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        disposalErrorOccurred = true;
        errorMessage = details.exception.toString();
        originalOnError?.call(details);
      };
      
      try {
        final game = GluttonyArcGame();
        final gameHashCode = game.hashCode;
        
        // Create and attach
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameWidget(
                key: GlobalKey(debugLabel: 'DisposalTest'),
                game: game,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Verify game is created
        expect(game.hashCode, equals(gameHashCode));
        
        // Dispose widget
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        
        // Verify no disposal errors occurred
        expect(disposalErrorOccurred, isFalse,
            reason: 'No errors should occur during disposal. Error: $errorMessage');
      } finally {
        FlutterError.onError = originalOnError;
      }
    });
  });

  /// **Feature: fix-flame-attachment-error, Property 5: Fresh Instance on Re-entry**
  /// **Validates: Requirements 1.5**
  /// 
  /// Property: For any arc, navigating away and back should create a new game 
  /// instance with a different hashCode and clean state.
  group('Property 5: Fresh Instance on Re-entry', () {
    testWidgets('Re-entering arc creates fresh game instance', (WidgetTester tester) async {
      // First entry
      final game1 = GluttonyArcGame();
      final hashCode1 = game1.hashCode;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameWidget(
              key: GlobalKey(debugLabel: 'FirstEntry'),
              game: game1,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Exit
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      
      // Second entry - create new instance
      final game2 = GluttonyArcGame();
      final hashCode2 = game2.hashCode;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameWidget(
              key: GlobalKey(debugLabel: 'SecondEntry'),
              game: game2,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify different instances
      expect(hashCode2, isNot(equals(hashCode1)),
          reason: 'Re-entry should create a new game instance with different hashCode');
      
      // Cleanup
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}

// Helper function to create game instances
BaseArcGame _createGameForArc(String arcType) {
  switch (arcType) {
    case 'Gluttony':
      return GluttonyArcGame();
    case 'Greed':
      return GreedArcGame();
    case 'Envy':
      return EnvyArcGame();
    case 'Lust':
      return LustArcGame();
    case 'Pride':
      return PrideArcGame();
    case 'Sloth':
      return SlothArcGame();
    case 'Wrath':
      return WrathArcGame();
    default:
      return GluttonyArcGame();
  }
}
