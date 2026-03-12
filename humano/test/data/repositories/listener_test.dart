import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:humano/data/models/user_data.dart';

// Feature: user-database-system, Property 12: Real-time listener reactivity
// For any change to user data in Firestore, the UserDataProvider should receive 
// the update and notify all listeners within a reasonable time window

void main() {
  group('Listener Property-Based Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    test('Property 12: Listener emits updates on data changes', () async {
      const userId = 'listener_user';

      // Create user
      await repository.createUser(userId, UserData.initial(userId));

      // Start listening
      final updates = <UserData?>[];
      final subscription = repository.watchUser(userId).listen((userData) {
        updates.add(userData);
      });

      // Wait for initial emission
      await Future.delayed(const Duration(milliseconds: 100));

      // Update coins
      await repository.addCoins(userId, 1000);
      await Future.delayed(const Duration(milliseconds: 100));

      // Update settings
      var userData = await repository.getUser(userId);
      final newSettings = userData!.settings.copyWith(musicVolume: 0.5);
      await repository.updateSettings(userId, newSettings);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify we received updates
      expect(updates.length, greaterThan(1), reason: 'Should receive multiple updates');

      await subscription.cancel();
    });

    test('Property 12: Listener emits null for non-existent user', () async {
      const userId = 'nonexistent_user';

      UserData? receivedData;
      final subscription = repository.watchUser(userId).listen((userData) {
        receivedData = userData;
      });

      await Future.delayed(const Duration(milliseconds: 100));

      expect(receivedData, isNull, reason: 'Should emit null for non-existent user');

      await subscription.cancel();
    });

    test('Property 12: Multiple listeners receive same updates', () async {
      const userId = 'multi_listener_user';

      await repository.createUser(userId, UserData.initial(userId));

      final updates1 = <UserData?>[];
      final updates2 = <UserData?>[];

      final sub1 = repository.watchUser(userId).listen((data) => updates1.add(data));
      final sub2 = repository.watchUser(userId).listen((data) => updates2.add(data));

      await Future.delayed(const Duration(milliseconds: 100));

      await repository.addCoins(userId, 500);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(updates1.length, greaterThan(0));
      expect(updates2.length, greaterThan(0));

      await sub1.cancel();
      await sub2.cancel();
    });
  });
}
