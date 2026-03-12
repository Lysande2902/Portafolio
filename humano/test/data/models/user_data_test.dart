import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:humano/data/models/user_data.dart';
import 'package:humano/data/models/arc_progress.dart';
import 'package:humano/data/models/player_inventory.dart';
import 'package:humano/data/models/game_settings.dart';
import 'package:humano/data/models/user_stats.dart';

// Feature: user-database-system, Property 2: Data persistence round-trip
// For any user data changes (progress, inventory, settings, stats), 
// saving the data then loading it should return equivalent data

void main() {
  group('UserData Property-Based Tests', () {
    final random = Random(42); // Seed for reproducibility

    test('Property 2: Data persistence round-trip - 100 iterations', () {
      // Run 100 iterations as specified in design
      for (int i = 0; i < 100; i++) {
        // Generate random UserData
        final userData = _generateRandomUserData(random, 'user_$i');

        // Serialize to Firestore format
        final firestoreData = userData.toFirestore();

        // Create a mock DocumentSnapshot
        final mockDoc = _MockDocumentSnapshot(
          data: firestoreData,
          id: userData.userId,
        );

        // Deserialize from Firestore
        final deserializedData = UserData.fromFirestore(mockDoc);

        // Verify round-trip equality
        expect(deserializedData.userId, equals(userData.userId));
        expect(deserializedData.inventory.coins, equals(userData.inventory.coins));
        expect(
          deserializedData.inventory.ownedItems,
          equals(userData.inventory.ownedItems),
        );
        expect(
          deserializedData.inventory.hasBattlePass,
          equals(userData.inventory.hasBattlePass),
        );
        expect(
          deserializedData.inventory.battlePassLevel,
          equals(userData.inventory.battlePassLevel),
        );
        expect(
          deserializedData.settings.musicVolume,
          equals(userData.settings.musicVolume),
        );
        expect(
          deserializedData.settings.sfxVolume,
          equals(userData.settings.sfxVolume),
        );
        expect(
          deserializedData.settings.vhsEffectsEnabled,
          equals(userData.settings.vhsEffectsEnabled),
        );
        expect(
          deserializedData.stats.totalPlayTimeMinutes,
          equals(userData.stats.totalPlayTimeMinutes),
        );
        expect(
          deserializedData.stats.arcsCompleted,
          equals(userData.stats.arcsCompleted),
        );
        expect(
          deserializedData.arcProgress.length,
          equals(userData.arcProgress.length),
        );

        // Verify arc progress details
        for (var arcId in userData.arcProgress.keys) {
          expect(deserializedData.arcProgress.containsKey(arcId), isTrue);
          final original = userData.arcProgress[arcId]!;
          final deserialized = deserializedData.arcProgress[arcId]!;
          expect(deserialized.status, equals(original.status));
          expect(deserialized.progressPercent, equals(original.progressPercent));
          expect(deserialized.attemptsCount, equals(original.attemptsCount));
          expect(
            deserialized.evidencesCollected,
            equals(original.evidencesCollected),
          );
        }
      }
    });

    test('Property 2: Initial user data round-trip', () {
      for (int i = 0; i < 100; i++) {
        final userId = 'new_user_$i';
        final userData = UserData.initial(userId);

        final firestoreData = userData.toFirestore();
        final mockDoc = _MockDocumentSnapshot(
          data: firestoreData,
          id: userId,
        );

        final deserializedData = UserData.fromFirestore(mockDoc);

        expect(deserializedData.userId, equals(userId));
        expect(deserializedData.inventory.coins, equals(5000));
        expect(deserializedData.arcProgress.isEmpty, isTrue);
        expect(deserializedData.stats.arcsCompleted, equals(0));
      }
    });

    test('Property 2: Edge cases - empty and maximum values', () {
      // Test with empty arc progress
      final emptyUserData = UserData(
        userId: 'empty_user',
        arcProgress: {},
        inventory: PlayerInventory.empty(),
        settings: GameSettings.defaults,
        stats: UserStats.empty('empty_user'),
        lastUpdated: DateTime.now(),
      );

      final emptyFirestore = emptyUserData.toFirestore();
      final emptyMockDoc = _MockDocumentSnapshot(
        data: emptyFirestore,
        id: 'empty_user',
      );
      final emptyDeserialized = UserData.fromFirestore(emptyMockDoc);

      expect(emptyDeserialized.arcProgress.isEmpty, isTrue);
      expect(emptyDeserialized.userId, equals('empty_user'));

      // Test with maximum values
      final maxUserData = UserData(
        userId: 'max_user',
        arcProgress: {
          for (int i = 0; i < 10; i++)
            'arc_$i': ArcProgress(
              arcId: 'arc_$i',
              status: ArcStatus.completed,
              progressPercent: 100.0,
              lastPlayed: DateTime.now(),
              attemptsCount: 999,
              evidencesCollected: List.generate(50, (i) => 'evidence_$i'),
            ),
        },
        inventory: PlayerInventory(
          coins: 999999,
          ownedItems: Set.from(List.generate(100, (i) => 'item_$i')),
          hasBattlePass: true,
          battlePassLevel: 100,
        ),
        settings: const GameSettings(
          musicVolume: 1.0,
          sfxVolume: 1.0,
          ambientVolume: 1.0,
          vhsEffectsEnabled: true,
          glitchEffectsEnabled: true,
          screenShakeEnabled: true,
        ),
        stats: UserStats(
          userId: 'max_user',
          totalPlayTimeMinutes: 99999,
          accountCreatedAt: DateTime.now(),
          arcsCompleted: 100,
          totalAttempts: 9999,
        ),
        lastUpdated: DateTime.now(),
      );

      final maxFirestore = maxUserData.toFirestore();
      final maxMockDoc = _MockDocumentSnapshot(
        data: maxFirestore,
        id: 'max_user',
      );
      final maxDeserialized = UserData.fromFirestore(maxMockDoc);

      expect(maxDeserialized.arcProgress.length, equals(10));
      expect(maxDeserialized.inventory.coins, equals(999999));
      expect(maxDeserialized.inventory.ownedItems.length, equals(100));
    });
  });
}

/// Generates random UserData for property-based testing
UserData _generateRandomUserData(Random random, String userId) {
  // Generate random arc progress
  final arcCount = random.nextInt(5) + 1;
  final arcProgress = <String, ArcProgress>{};
  for (int i = 0; i < arcCount; i++) {
    final arcId = 'arc_${_randomArcName(random)}';
    arcProgress[arcId] = ArcProgress(
      arcId: arcId,
      status: _randomArcStatus(random),
      progressPercent: random.nextDouble() * 100,
      lastPlayed: DateTime.now().subtract(Duration(days: random.nextInt(30))),
      attemptsCount: random.nextInt(20),
      evidencesCollected: List.generate(
        random.nextInt(10),
        (i) => 'evidence_${random.nextInt(100)}',
      ),
    );
  }

  // Generate random inventory
  final inventory = PlayerInventory(
    coins: random.nextInt(100000),
    ownedItems: Set.from(
      List.generate(
        random.nextInt(20),
        (i) => 'item_${random.nextInt(1000)}',
      ),
    ),
    hasBattlePass: random.nextBool(),
    battlePassLevel: random.nextInt(50),
  );

  // Generate random settings
  final settings = GameSettings(
    musicVolume: random.nextDouble(),
    sfxVolume: random.nextDouble(),
    ambientVolume: random.nextDouble(),
    vhsEffectsEnabled: random.nextBool(),
    glitchEffectsEnabled: random.nextBool(),
    screenShakeEnabled: random.nextBool(),
  );

  // Generate random stats
  final stats = UserStats(
    userId: userId,
    totalPlayTimeMinutes: random.nextInt(10000),
    accountCreatedAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    arcsCompleted: random.nextInt(10),
    totalAttempts: random.nextInt(100),
  );

  return UserData(
    userId: userId,
    arcProgress: arcProgress,
    inventory: inventory,
    settings: settings,
    stats: stats,
    lastUpdated: DateTime.now(),
  );
}

String _randomArcName(Random random) {
  const arcs = ['gluttony', 'greed', 'envy', 'sloth', 'lust', 'pride', 'wrath'];
  return arcs[random.nextInt(arcs.length)];
}

ArcStatus _randomArcStatus(Random random) {
  const statuses = ArcStatus.values;
  return statuses[random.nextInt(statuses.length)];
}

/// Mock DocumentSnapshot for testing
class _MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  final String _id;

  _MockDocumentSnapshot({required Map<String, dynamic> data, required String id})
      : _data = data,
        _id = id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _id;

  @override
  bool get exists => true;

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  dynamic get(Object field) => _data[field];

  @override
  dynamic operator [](Object field) => _data[field];
}
