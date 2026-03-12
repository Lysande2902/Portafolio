import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:humano/data/models/user_data.dart';
import 'package:humano/data/models/game_settings.dart';

void main() {
  group('Settings and Stats Property-Based Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;
    final random = Random(42);

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    // Feature: user-database-system, Property 8: Settings update persistence
    // For any settings field (musicVolume, sfxVolume, vhsEffectsEnabled, etc.), 
    // updating the value should persist it to Firestore and subsequent reads should return the updated value
    test('Property 8: Settings update persistence - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'settings_user_$i';

        // Create user
        await repository.createUser(userId, UserData.initial(userId));

        // Generate random settings
        final newSettings = GameSettings(
          musicVolume: random.nextDouble(),
          sfxVolume: random.nextDouble(),
          ambientVolume: random.nextDouble(),
          vhsEffectsEnabled: random.nextBool(),
          glitchEffectsEnabled: random.nextBool(),
          screenShakeEnabled: random.nextBool(),
        );

        // Update settings
        await repository.updateSettings(userId, newSettings);

        // Read back and verify
        final userData = await repository.getUser(userId);
        expect(userData, isNotNull);
        expect(userData!.settings.musicVolume, equals(newSettings.musicVolume));
        expect(userData.settings.sfxVolume, equals(newSettings.sfxVolume));
        expect(userData.settings.ambientVolume, equals(newSettings.ambientVolume));
        expect(userData.settings.vhsEffectsEnabled, equals(newSettings.vhsEffectsEnabled));
        expect(userData.settings.glitchEffectsEnabled, equals(newSettings.glitchEffectsEnabled));
        expect(userData.settings.screenShakeEnabled, equals(newSettings.screenShakeEnabled));
      }
    });

    test('Property 8: Individual setting fields persist correctly', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'individual_settings_user_$i';
        await repository.createUser(userId, UserData.initial(userId));

        // Update only music volume
        var userData = await repository.getUser(userId);
        final musicVolume = random.nextDouble();
        var newSettings = userData!.settings.copyWith(musicVolume: musicVolume);
        await repository.updateSettings(userId, newSettings);

        userData = await repository.getUser(userId);
        expect(userData!.settings.musicVolume, equals(musicVolume));

        // Update only vhs effects
        final vhsEnabled = random.nextBool();
        newSettings = userData.settings.copyWith(vhsEffectsEnabled: vhsEnabled);
        await repository.updateSettings(userId, newSettings);

        userData = await repository.getUser(userId);
        expect(userData!.settings.vhsEffectsEnabled, equals(vhsEnabled));
        expect(userData.settings.musicVolume, equals(musicVolume)); // Previous value preserved
      }
    });

    // Feature: user-database-system, Property 9: Stats accumulation
    // For any user, completing sessions and arcs should monotonically increase 
    // totalPlayTimeMinutes, arcsCompleted, and totalAttempts (never decrease)
    test('Property 9: Stats accumulation - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'stats_user_$i';

        // Create user
        await repository.createUser(userId, UserData.initial(userId));

        var userData = await repository.getUser(userId);
        var previousPlayTime = userData!.stats.totalPlayTimeMinutes;
        var previousArcsCompleted = userData.stats.arcsCompleted;
        var previousAttempts = userData.stats.totalAttempts;

        // Perform random stat updates
        final updateCount = random.nextInt(10) + 1;
        for (int j = 0; j < updateCount; j++) {
          final updateType = random.nextInt(3);

          if (updateType == 0) {
            // Increment play time
            final minutes = random.nextInt(60) + 1;
            await repository.incrementPlayTime(userId, minutes);
            previousPlayTime += minutes;
          } else if (updateType == 1) {
            // Increment arcs completed
            await repository.incrementArcsCompleted(userId);
            previousArcsCompleted += 1;
          } else {
            // Increment attempts
            await repository.incrementAttempts(userId);
            previousAttempts += 1;
          }

          // Verify monotonic increase
          userData = await repository.getUser(userId);
          expect(
            userData!.stats.totalPlayTimeMinutes,
            greaterThanOrEqualTo(previousPlayTime),
            reason: 'Play time should never decrease',
          );
          expect(
            userData.stats.arcsCompleted,
            greaterThanOrEqualTo(previousArcsCompleted),
            reason: 'Arcs completed should never decrease',
          );
          expect(
            userData.stats.totalAttempts,
            greaterThanOrEqualTo(previousAttempts),
            reason: 'Total attempts should never decrease',
          );
        }

        // Verify final values match expected
        userData = await repository.getUser(userId);
        expect(userData!.stats.totalPlayTimeMinutes, equals(previousPlayTime));
        expect(userData.stats.arcsCompleted, equals(previousArcsCompleted));
        expect(userData.stats.totalAttempts, equals(previousAttempts));
      }
    });

    test('Property 9: Stats never decrease', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'monotonic_user_$i';
        await repository.createUser(userId, UserData.initial(userId));

        // Increment multiple times
        for (int j = 0; j < 10; j++) {
          await repository.incrementPlayTime(userId, random.nextInt(30) + 1);
          await repository.incrementAttempts(userId);
          if (j % 3 == 0) {
            await repository.incrementArcsCompleted(userId);
          }
        }

        // All stats should be positive
        final userData = await repository.getUser(userId);
        expect(userData!.stats.totalPlayTimeMinutes, greaterThan(0));
        expect(userData.stats.totalAttempts, greaterThan(0));
        expect(userData.stats.arcsCompleted, greaterThanOrEqualTo(0));
      }
    });

    test('Property 9: Multiple increments accumulate correctly', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'accumulate_user_$i';
        await repository.createUser(userId, UserData.initial(userId));

        // Increment play time multiple times
        var expectedPlayTime = 0;
        for (int j = 0; j < 5; j++) {
          final minutes = random.nextInt(30) + 1;
          await repository.incrementPlayTime(userId, minutes);
          expectedPlayTime += minutes;
        }

        var userData = await repository.getUser(userId);
        expect(userData!.stats.totalPlayTimeMinutes, equals(expectedPlayTime));

        // Increment attempts multiple times
        var expectedAttempts = 0;
        for (int j = 0; j < 5; j++) {
          await repository.incrementAttempts(userId);
          expectedAttempts += 1;
        }

        userData = await repository.getUser(userId);
        expect(userData!.stats.totalAttempts, equals(expectedAttempts));
      }
    });
  });

  group('Settings and Stats Unit Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    test('updateSettings updates all fields', () async {
      const userId = 'test_user';
      await repository.createUser(userId, UserData.initial(userId));

      const newSettings = GameSettings(
        musicVolume: 0.5,
        sfxVolume: 0.6,
        ambientVolume: 0.4,
        vhsEffectsEnabled: false,
        glitchEffectsEnabled: false,
        screenShakeEnabled: false,
      );

      await repository.updateSettings(userId, newSettings);

      final userData = await repository.getUser(userId);
      expect(userData!.settings.musicVolume, equals(0.5));
      expect(userData.settings.vhsEffectsEnabled, isFalse);
    });

    test('incrementPlayTime adds minutes correctly', () async {
      const userId = 'playtime_user';
      await repository.createUser(userId, UserData.initial(userId));

      await repository.incrementPlayTime(userId, 30);
      await repository.incrementPlayTime(userId, 45);

      final userData = await repository.getUser(userId);
      expect(userData!.stats.totalPlayTimeMinutes, equals(75));
    });

    test('incrementArcsCompleted increases counter', () async {
      const userId = 'arcs_user';
      await repository.createUser(userId, UserData.initial(userId));

      await repository.incrementArcsCompleted(userId);
      await repository.incrementArcsCompleted(userId);
      await repository.incrementArcsCompleted(userId);

      final userData = await repository.getUser(userId);
      expect(userData!.stats.arcsCompleted, equals(3));
    });

    test('incrementAttempts increases counter', () async {
      const userId = 'attempts_user';
      await repository.createUser(userId, UserData.initial(userId));

      for (int i = 0; i < 10; i++) {
        await repository.incrementAttempts(userId);
      }

      final userData = await repository.getUser(userId);
      expect(userData!.stats.totalAttempts, equals(10));
    });
  });
}
