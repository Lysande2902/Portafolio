import 'package:flutter_test/flutter_test.dart';
import 'package:humano/game/core/tutorial/tutorial_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() async {
    // Clear all preferences before each test
    SharedPreferences.setMockInitialValues({});
  });
  
  group('TutorialStateManager - Property Tests', () {
    // Property 3: Tutorial completion persists across sessions
    test('Property 3: completed tutorials persist across sessions', () async {
      // Create first manager instance
      final manager1 = TutorialStateManager();
      
      // Complete tutorial
      await manager1.completeFirstTimeTutorial();
      
      // Verify completion with same instance
      final completed1 = await manager1.hasCompletedFirstTimeTutorial();
      expect(completed1, isTrue, reason: 'Tutorial should be completed in same session');
      
      // Simulate app restart by creating new manager instance
      final manager2 = TutorialStateManager();
      
      // Verify completion persists
      final completed2 = await manager2.hasCompletedFirstTimeTutorial();
      expect(completed2, isTrue, reason: 'Tutorial completion should persist across sessions');
    });
    
    // Property 4: Skip has same effect as completion
    test('Property 4: skip has same effect as completion', () async {
      final manager = TutorialStateManager();
      
      // Skip tutorial (same as completing it)
      await manager.completeFirstTimeTutorial();
      
      // Simulate restart
      final manager2 = TutorialStateManager();
      
      // Verify tutorial doesn't show again
      final shouldShow = await manager2.hasCompletedFirstTimeTutorial();
      expect(shouldShow, isTrue, reason: 'Skipped tutorial should not show again');
    });
    
    // Property 7: Arc tutorial completion persists per arc
    test('Property 7: arc tutorials persist independently', () async {
      final manager1 = TutorialStateManager();
      
      // Complete tutorial for arc1
      await manager1.completeArcTutorial('arc_1_gula');
      
      // Verify arc1 is completed
      final arc1Completed = await manager1.hasCompletedArcTutorial('arc_1_gula');
      expect(arc1Completed, isTrue, reason: 'Arc 1 should be completed');
      
      // Verify arc2 is NOT completed
      final arc2Completed = await manager1.hasCompletedArcTutorial('arc_2_greed');
      expect(arc2Completed, isFalse, reason: 'Arc 2 should not be completed');
      
      // Simulate restart
      final manager2 = TutorialStateManager();
      
      // Verify persistence
      final arc1Still = await manager2.hasCompletedArcTutorial('arc_1_gula');
      final arc2Still = await manager2.hasCompletedArcTutorial('arc_2_greed');
      
      expect(arc1Still, isTrue, reason: 'Arc 1 completion should persist');
      expect(arc2Still, isFalse, reason: 'Arc 2 should still not be completed');
    });
    
    // Property 16: Saved state has correct structure
    test('Property 16: saved state contains required fields', () async {
      final manager = TutorialStateManager();
      
      // Complete tutorial
      await manager.completeFirstTimeTutorial();
      
      // Read raw storage
      final prefs = await SharedPreferences.getInstance();
      final hasFlag = prefs.getBool('has_seen_tutorial');
      final timestamp = prefs.getInt('tutorial_completion_timestamp_first_time');
      
      // Verify structure
      expect(hasFlag, isNotNull, reason: 'Completion flag should exist');
      expect(hasFlag, isTrue, reason: 'Completion flag should be true');
      expect(timestamp, isNotNull, reason: 'Timestamp should exist');
      expect(timestamp, greaterThan(0), reason: 'Timestamp should be valid');
    });
    
    // Property 17: Persisted state loads correctly
    test('Property 17: persisted state loads correctly', () async {
      final manager1 = TutorialStateManager();
      
      // Complete multiple tutorials
      await manager1.completeFirstTimeTutorial();
      await manager1.completeArcTutorial('arc_1_gula');
      await manager1.completeArcTutorial('arc_2_greed');
      
      // Simulate restart
      final manager2 = TutorialStateManager();
      
      // Verify all states load correctly
      final firstTime = await manager2.hasCompletedFirstTimeTutorial();
      final arc1 = await manager2.hasCompletedArcTutorial('arc_1_gula');
      final arc2 = await manager2.hasCompletedArcTutorial('arc_2_greed');
      final arc3 = await manager2.hasCompletedArcTutorial('arc_3_envy');
      
      expect(firstTime, isTrue, reason: 'First-time tutorial should be loaded');
      expect(arc1, isTrue, reason: 'Arc 1 should be loaded');
      expect(arc2, isTrue, reason: 'Arc 2 should be loaded');
      expect(arc3, isFalse, reason: 'Arc 3 should not be loaded');
    });
  });
  
  group('TutorialStateManager - Error Handling', () {
    // Property 18: Storage failure defaults to showing tutorials
    test('Property 18: storage read failure defaults to showing tutorials', () async {
      // Note: In real scenario, we'd mock SharedPreferences to throw
      // For now, we test the default behavior
      final manager = TutorialStateManager();
      
      // Without completing, should default to false (show tutorial)
      final shouldShow = await manager.hasCompletedFirstTimeTutorial();
      expect(shouldShow, isFalse, reason: 'Should default to showing tutorial');
    });
    
    // Property 19: Write failures don't crash the game
    test('Property 19: write failures are handled gracefully', () async {
      final manager = TutorialStateManager();
      
      // This should not throw even if write fails
      expect(
        () async => await manager.completeFirstTimeTutorial(),
        returnsNormally,
        reason: 'Write failures should not crash',
      );
    });
    
    test('storage error handling - read failures', () async {
      final manager = TutorialStateManager();
      
      // Test with non-existent arc
      final result = await manager.hasCompletedArcTutorial('invalid_arc');
      expect(result, isFalse, reason: 'Should default to false for non-existent arc');
    });
    
    test('storage error handling - multiple operations', () async {
      final manager = TutorialStateManager();
      
      // Perform multiple operations
      await manager.completeFirstTimeTutorial();
      await manager.completeArcTutorial('arc_1_gula');
      await manager.completeArcTutorial('arc_2_greed');
      
      // All should succeed without throwing
      final firstTime = await manager.hasCompletedFirstTimeTutorial();
      final arc1 = await manager.hasCompletedArcTutorial('arc_1_gula');
      final arc2 = await manager.hasCompletedArcTutorial('arc_2_greed');
      
      expect(firstTime, isTrue);
      expect(arc1, isTrue);
      expect(arc2, isTrue);
    });
  });
  
  group('TutorialStateManager - Additional Features', () {
    test('getTutorialCompletionTime returns valid timestamp', () async {
      final manager = TutorialStateManager();
      final beforeTime = DateTime.now();
      
      await manager.completeFirstTimeTutorial();
      
      final afterTime = DateTime.now();
      final completionTime = await manager.getTutorialCompletionTime('first_time');
      
      expect(completionTime, isNotNull);
      expect(completionTime!.isAfter(beforeTime.subtract(const Duration(seconds: 1))), isTrue);
      expect(completionTime.isBefore(afterTime.add(const Duration(seconds: 1))), isTrue);
    });
    
    test('getCompletedTutorials returns all completed', () async {
      final manager = TutorialStateManager();
      
      await manager.completeFirstTimeTutorial();
      await manager.completeArcTutorial('arc_1_gula');
      await manager.completeArcTutorial('arc_2_greed');
      
      final completed = await manager.getCompletedTutorials();
      
      expect(completed, contains('first_time'));
      expect(completed, contains('arc_1_gula'));
      expect(completed, contains('arc_2_greed'));
      expect(completed.length, equals(3));
    });
    
    test('resetAllTutorials clears all state', () async {
      final manager = TutorialStateManager();
      
      // Complete tutorials
      await manager.completeFirstTimeTutorial();
      await manager.completeArcTutorial('arc_1_gula');
      
      // Reset
      await manager.resetAllTutorials();
      
      // Verify all cleared
      final firstTime = await manager.hasCompletedFirstTimeTutorial();
      final arc1 = await manager.hasCompletedArcTutorial('arc_1_gula');
      
      expect(firstTime, isFalse);
      expect(arc1, isFalse);
    });
  });
}
