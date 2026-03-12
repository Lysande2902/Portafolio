import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:humano/data/models/user_data.dart';

// Feature: user-database-system, Property 1: User document creation on authentication
// For any authenticated user, when they sign in, the system should either create 
// a new user document in Firestore or retrieve their existing document

void main() {
  group('UserRepository Property-Based Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;
    final random = Random(42);

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    test('Property 1: User document creation - 100 iterations', () async {
      // Run 100 iterations as specified in design
      for (int i = 0; i < 100; i++) {
        final userId = 'test_user_$i';
        final initialData = UserData.initial(userId);

        // Create user document
        await repository.createUser(userId, initialData);

        // Verify document exists
        final exists = await repository.userExists(userId);
        expect(exists, isTrue, reason: 'User document should exist after creation');

        // Retrieve the document
        final retrievedData = await repository.getUser(userId);
        expect(retrievedData, isNotNull, reason: 'Should retrieve created user');
        expect(retrievedData!.userId, equals(userId));
        expect(retrievedData.inventory.coins, equals(5000));
        expect(retrievedData.arcProgress.isEmpty, isTrue);
      }
    });

    test('Property 1: Retrieve existing user document - 100 iterations', () async {
      // Create users first
      final userIds = <String>[];
      for (int i = 0; i < 100; i++) {
        final userId = 'existing_user_$i';
        userIds.add(userId);
        final initialData = UserData.initial(userId);
        await repository.createUser(userId, initialData);
      }

      // Now retrieve each one
      for (final userId in userIds) {
        final userData = await repository.getUser(userId);
        expect(userData, isNotNull, reason: 'Should retrieve existing user');
        expect(userData!.userId, equals(userId));
      }
    });

    test('Property 1: Non-existent user returns null', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'nonexistent_user_$i';
        final userData = await repository.getUser(userId);
        expect(userData, isNull, reason: 'Non-existent user should return null');
      }
    });

    test('Property 1: Cannot create duplicate user', () async {
      for (int i = 0; i < 10; i++) {
        final userId = 'duplicate_user_$i';
        final initialData = UserData.initial(userId);

        // Create user first time
        await repository.createUser(userId, initialData);

        // Attempt to create again should throw
        expect(
          () => repository.createUser(userId, initialData),
          throwsException,
          reason: 'Should not allow duplicate user creation',
        );
      }
    });

    test('Property 1: Update existing user preserves userId', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'update_user_$i';
        final initialData = UserData.initial(userId);

        // Create user
        await repository.createUser(userId, initialData);

        // Update with modified data
        final updatedData = initialData.copyWith(
          inventory: initialData.inventory.copyWith(
            coins: random.nextInt(100000),
          ),
        );
        await repository.updateUser(userId, updatedData);

        // Retrieve and verify
        final retrievedData = await repository.getUser(userId);
        expect(retrievedData, isNotNull);
        expect(retrievedData!.userId, equals(userId));
        expect(retrievedData.inventory.coins, equals(updatedData.inventory.coins));
      }
    });

    test('Property 1: Delete user removes document', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'delete_user_$i';
        final initialData = UserData.initial(userId);

        // Create user
        await repository.createUser(userId, initialData);
        expect(await repository.userExists(userId), isTrue);

        // Delete user
        await repository.deleteUser(userId);

        // Verify deletion
        expect(await repository.userExists(userId), isFalse);
        final userData = await repository.getUser(userId);
        expect(userData, isNull);
      }
    });
  });

  group('UserRepository Unit Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    test('createUser initializes with correct default values', () async {
      const userId = 'test_user';
      final initialData = UserData.initial(userId);

      await repository.createUser(userId, initialData);

      final userData = await repository.getUser(userId);
      expect(userData, isNotNull);
      expect(userData!.userId, equals(userId));
      expect(userData.inventory.coins, equals(5000));
      expect(userData.inventory.hasBattlePass, isFalse);
      expect(userData.inventory.battlePassLevel, equals(0));
      expect(userData.arcProgress.isEmpty, isTrue);
      expect(userData.stats.arcsCompleted, equals(0));
      expect(userData.stats.totalAttempts, equals(0));
      expect(userData.stats.totalPlayTimeMinutes, equals(0));
    });

    test('updateUser merges data correctly', () async {
      const userId = 'merge_test_user';
      final initialData = UserData.initial(userId);

      await repository.createUser(userId, initialData);

      // Update only inventory
      final updatedData = initialData.copyWith(
        inventory: initialData.inventory.copyWith(coins: 10000),
      );
      await repository.updateUser(userId, updatedData);

      final userData = await repository.getUser(userId);
      expect(userData!.inventory.coins, equals(10000));
      expect(userData.stats.arcsCompleted, equals(0)); // Other fields preserved
    });

    test('userExists returns correct boolean', () async {
      const userId = 'exists_test_user';

      expect(await repository.userExists(userId), isFalse);

      final initialData = UserData.initial(userId);
      await repository.createUser(userId, initialData);

      expect(await repository.userExists(userId), isTrue);
    });
  });
}
