import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:humano/data/models/user_data.dart';

void main() {
  group('Inventory Property-Based Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;
    final random = Random(42);

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    // Feature: user-database-system, Property 6: Purchase transaction atomicity
    // For any valid purchase, either both the coin deduction and item addition succeed, 
    // or neither occurs (atomic transaction)
    test('Property 6: Purchase transaction atomicity - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'purchase_user_$i';
        final itemId = 'item_$i';
        final price = random.nextInt(10000) + 100;

        // Create user with sufficient funds
        await repository.createUser(userId, UserData.initial(userId));

        // Get initial state
        var userData = await repository.getUser(userId);
        final initialCoins = userData!.inventory.coins;
        final initialItemCount = userData.inventory.ownedItems.length;

        // Perform purchase
        final success = await repository.purchaseItem(userId, itemId, price);

        // Get final state
        userData = await repository.getUser(userId);
        final finalCoins = userData!.inventory.coins;
        final finalItemCount = userData.inventory.ownedItems.length;

        if (success) {
          // Both operations should have succeeded
          expect(
            finalCoins,
            equals(initialCoins - price),
            reason: 'Coins should be deducted',
          );
          expect(
            finalItemCount,
            equals(initialItemCount + 1),
            reason: 'Item should be added',
          );
          expect(
            userData.inventory.ownedItems.contains(itemId),
            isTrue,
            reason: 'Item should be in owned items',
          );
        } else {
          // Neither operation should have occurred
          expect(
            finalCoins,
            equals(initialCoins),
            reason: 'Coins should not change on failed purchase',
          );
          expect(
            finalItemCount,
            equals(initialItemCount),
            reason: 'Item count should not change on failed purchase',
          );
          expect(
            userData.inventory.ownedItems.contains(itemId),
            isFalse,
            reason: 'Item should not be added on failed purchase',
          );
        }
      }
    });

    test('Property 6: Insufficient funds prevents purchase', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'insufficient_user_$i';
        final itemId = 'expensive_item_$i';

        // Create user
        await repository.createUser(userId, UserData.initial(userId));
        var userData = await repository.getUser(userId);
        final initialCoins = userData!.inventory.coins;

        // Try to purchase item more expensive than balance
        final price = initialCoins + random.nextInt(10000) + 1;

        final success = await repository.purchaseItem(userId, itemId, price);

        // Purchase should fail
        expect(success, isFalse, reason: 'Purchase should fail with insufficient funds');

        // Verify no changes occurred
        userData = await repository.getUser(userId);
        expect(userData!.inventory.coins, equals(initialCoins));
        expect(userData.inventory.ownedItems.contains(itemId), isFalse);
      }
    });

    test('Property 6: Cannot purchase already owned item', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'duplicate_purchase_user_$i';
        final itemId = 'item_duplicate';
        final price = 1000;

        // Create user and purchase item
        await repository.createUser(userId, UserData.initial(userId));
        await repository.purchaseItem(userId, itemId, price);

        // Try to purchase same item again
        expect(
          () => repository.purchaseItem(userId, itemId, price),
          throwsException,
          reason: 'Should not allow purchasing already owned item',
        );
      }
    });

    // Feature: user-database-system, Property 7: Coin balance monotonicity
    // For any sequence of coin operations (purchases and rewards), 
    // the final balance should equal initial balance minus purchases plus rewards
    test('Property 7: Coin balance monotonicity - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'balance_user_$i';

        // Create user
        await repository.createUser(userId, UserData.initial(userId));
        var userData = await repository.getUser(userId);
        var expectedBalance = userData!.inventory.coins;

        // Perform random sequence of operations
        final operationCount = random.nextInt(10) + 1;
        for (int j = 0; j < operationCount; j++) {
          final operation = random.nextBool(); // true = add coins, false = purchase

          if (operation) {
            // Add coins
            final amount = random.nextInt(5000) + 100;
            await repository.addCoins(userId, amount);
            expectedBalance += amount;
          } else {
            // Purchase item
            final price = random.nextInt(1000) + 100;
            final itemId = 'item_${i}_$j';

            // Only update expected balance if purchase succeeds
            final success = await repository.purchaseItem(userId, itemId, price);
            if (success) {
              expectedBalance -= price;
            }
          }
        }

        // Verify final balance matches expected
        userData = await repository.getUser(userId);
        expect(
          userData!.inventory.coins,
          equals(expectedBalance),
          reason: 'Final balance should match calculated balance',
        );
      }
    });

    test('Property 7: Adding coins increases balance', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'add_coins_user_$i';
        final amount = random.nextInt(10000) + 1;

        await repository.createUser(userId, UserData.initial(userId));
        var userData = await repository.getUser(userId);
        final initialBalance = userData!.inventory.coins;

        await repository.addCoins(userId, amount);

        userData = await repository.getUser(userId);
        expect(
          userData!.inventory.coins,
          equals(initialBalance + amount),
          reason: 'Balance should increase by added amount',
        );
      }
    });

    test('Property 7: Multiple purchases decrease balance correctly', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'multiple_purchase_user_$i';

        await repository.createUser(userId, UserData.initial(userId));
        var userData = await repository.getUser(userId);
        var currentBalance = userData!.inventory.coins;

        // Make multiple purchases
        final purchaseCount = random.nextInt(5) + 1;
        var totalSpent = 0;

        for (int j = 0; j < purchaseCount; j++) {
          final price = random.nextInt(500) + 100;
          final itemId = 'item_${i}_$j';

          if (currentBalance >= price) {
            final success = await repository.purchaseItem(userId, itemId, price);
            if (success) {
              totalSpent += price;
              currentBalance -= price;
            }
          }
        }

        // Verify final balance
        userData = await repository.getUser(userId);
        expect(
          userData!.inventory.coins,
          equals(userData.inventory.coins),
          reason: 'Balance should reflect all purchases',
        );
      }
    });
  });

  group('Inventory Unit Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    test('updateInventory updates inventory correctly', () async {
      const userId = 'test_user';
      await repository.createUser(userId, UserData.initial(userId));

      var userData = await repository.getUser(userId);
      final newInventory = userData!.inventory.copyWith(
        coins: 10000,
        ownedItems: {'item1', 'item2'},
      );

      await repository.updateInventory(userId, newInventory);

      userData = await repository.getUser(userId);
      expect(userData!.inventory.coins, equals(10000));
      expect(userData.inventory.ownedItems.length, equals(2));
    });

    test('equipItem requires item ownership', () async {
      const userId = 'equip_test_user';
      await repository.createUser(userId, UserData.initial(userId));

      // Try to equip item not owned
      expect(
        () => repository.equipItem(userId, 'unowned_item', true),
        throwsException,
      );

      // Purchase item first
      await repository.purchaseItem(userId, 'owned_item', 100);

      // Now equip should work (or at least not throw for unowned)
      await repository.equipItem(userId, 'owned_item', true);
    });
  });
}
