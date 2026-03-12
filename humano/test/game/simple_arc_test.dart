import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:humano/game/arcs/gluttony/gluttony_arc_game.dart';
import 'package:humano/game/arcs/greed/greed_arc_game.dart';
import 'package:humano/game/arcs/envy/envy_arc_game.dart';

/// Simple test to verify the three main arcs can be created and initialized
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Arc Game Creation', () {
    test('Gluttony arc can be created', () {
      final game = GluttonyArcGame();
      expect(game, isNotNull);
      expect(game.isGameOver, isFalse);
      expect(game.evidenceCollected, equals(0));
    });

    test('Greed arc can be created', () {
      final game = GreedArcGame();
      expect(game, isNotNull);
      expect(game.isGameOver, isFalse);
      expect(game.evidenceCollected, equals(0));
    });

    test('Envy arc can be created', () {
      final game = EnvyArcGame();
      expect(game, isNotNull);
      expect(game.isGameOver, isFalse);
      expect(game.evidenceCollected, equals(0));
    });
  });

  group('Arc Game Initialization', () {
    testWidgets('Gluttony arc initializes without errors', (WidgetTester tester) async {
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorOccurred = true;
        originalOnError?.call(details);
      };
      
      try {
        final game = GluttonyArcGame();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameWidget(
                key: GlobalKey(debugLabel: 'GluttonyTest'),
                game: game,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        expect(errorOccurred, isFalse, reason: 'No errors should occur during Gluttony initialization');
        
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(seconds: 15)));

    testWidgets('Greed arc initializes without errors', (WidgetTester tester) async {
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorOccurred = true;
        originalOnError?.call(details);
      };
      
      try {
        final game = GreedArcGame();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameWidget(
                key: GlobalKey(debugLabel: 'GreedTest'),
                game: game,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        expect(errorOccurred, isFalse, reason: 'No errors should occur during Greed initialization');
        
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(seconds: 15)));

    testWidgets('Envy arc initializes without errors', (WidgetTester tester) async {
      bool errorOccurred = false;
      
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorOccurred = true;
        originalOnError?.call(details);
      };
      
      try {
        final game = EnvyArcGame();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameWidget(
                key: GlobalKey(debugLabel: 'EnvyTest'),
                game: game,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        expect(errorOccurred, isFalse, reason: 'No errors should occur during Envy initialization');
        
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = originalOnError;
      }
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}
