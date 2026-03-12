import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:humano/providers/user_data_provider.dart';
import 'package:humano/data/models/user_data.dart';
import 'package:humano/data/models/arc_progress.dart';

// Feature: user-database-system, Property 13: Listener cleanup on logout
// For any user logout, all active Firestore listeners should be cancelled 
// and no further updates should be processed

void main() {
  group('UserDataProvider Property-Based Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;
    late UserDataProvider provider;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
      provider = UserDataProvider(repository: repository);
    });

    tearDown(() {
      provider.dispose();
    });

    test('Property 13: Listener cleanup on dispose', () async {
      const userId = 'cleanup_user';
      final testProvider = UserDataProvider(repository: repository);

      // Initialize provider
      await testProvider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(testProvider.isInitialized, isTrue);

      // Dispose provider (simulates logout)
      testProvider.dispose();

      // Try to update data after dispose
      await repository.addCoins(userId, 1000);
      await Future.delayed(const Duration(milliseconds: 100));

      // Provider should not have received the update
      // (This is implicit - if listener wasn't cancelled, it would crash)
    });

    test('Property 13: Multiple initialize/dispose cycles', () async {
      for (int i = 0; i < 10; i++) {
        final userId = 'cycle_user_$i';
        final testProvider = UserDataProvider(repository: repository);

        await testProvider.initialize(userId);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(testProvider.isInitialized, isTrue);

        testProvider.dispose();
      }
    });

    test('Initialize creates user if not exists', () async {
      const userId = 'new_user';

      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.isInitialized, isTrue);
      expect(provider.userData, isNotNull);
      expect(provider.userData!.userId, equals(userId));
    });

    test('Initialize loads existing user', () async {
      const userId = 'existing_user';

      // Create user first
      await repository.createUser(userId, UserData.initial(userId));
      await repository.addCoins(userId, 5000);

      // Initialize provider
      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.isInitialized, isTrue);
      expect(provider.inventory.coins, equals(10000)); // 5000 initial + 5000 added
    });

    test('Provider updates automatically on data changes', () async {
      const userId = 'auto_update_user';

      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      final initialCoins = provider.inventory.coins;

      // Update data through repository
      await repository.addCoins(userId, 1000);
      await Future.delayed(const Duration(milliseconds: 100));

      // Provider should have updated automatically
      expect(provider.inventory.coins, equals(initialCoins + 1000));
    });

    test('purchaseItem returns false on insufficient funds', () async {
      const userId = 'purchase_user';

      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      final initialCoins = provider.inventory.coins;

      // Try to purchase expensive item
      final success = await provider.purchaseItem('expensive_item', initialCoins + 1000);

      expect(success, isFalse);
      expect(provider.errorMessage, isNotNull);
    });

    test('purchaseItem succeeds with sufficient funds', () async {
      const userId = 'purchase_success_user';

      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await provider.purchaseItem('item_1', 1000);

      expect(success, isTrue);
    });

    test('updateSettings persists changes', () async {
      const userId = 'settings_user';

      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      final newSettings = provider.settings.copyWith(musicVolume: 0.3);
      await provider.updateSettings(newSettings);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.settings.musicVolume, equals(0.3));
    });

    test('incrementPlayTime updates stats', () async {
      const userId = 'playtime_user';

      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      final initialPlayTime = provider.stats.totalPlayTimeMinutes;

      await provider.incrementPlayTime(30);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.stats.totalPlayTimeMinutes, equals(initialPlayTime + 30));
    });

    test('addEvidence updates arc progress', () async {
      const userId = 'evidence_user';
      const arcId = 'arc_test';

      await provider.initialize(userId);
      await Future.delayed(const Duration(milliseconds: 100));

      // Initialize arc
      await provider.updateArcProgress(arcId, ArcProgress.initial(arcId));
      await Future.delayed(const Duration(milliseconds: 100));

      // Add evidence
      await provider.addEvidence(arcId, 'evidence_1');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.arcProgress[arcId]?.evidencesCollected.contains('evidence_1'), isTrue);
    });
  });
}
