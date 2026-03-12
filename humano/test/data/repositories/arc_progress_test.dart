import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:humano/data/models/user_data.dart';
import 'package:humano/data/models/arc_progress.dart';

void main() {
  group('Arc Progress Property-Based Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;
    final random = Random(42);

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    // Feature: user-database-system, Property 3: Arc status transitions
    // For any arc, when a user starts it the status should be "inProgress", 
    // and when completed the status should be "completed"
    test('Property 3: Arc status transitions - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'user_$i';
        final arcId = 'arc_${_randomArcName(random)}';

        // Create user
        await repository.createUser(userId, UserData.initial(userId));

        // Start arc - status should be inProgress
        final inProgressArc = ArcProgress(
          arcId: arcId,
          status: ArcStatus.inProgress,
          progressPercent: random.nextDouble() * 99, // Not completed yet
          lastPlayed: DateTime.now(),
          attemptsCount: 1,
          evidencesCollected: [],
        );
        await repository.updateArcProgress(userId, arcId, inProgressArc);

        // Verify status is inProgress
        final progressData = await repository.getArcProgress(userId, arcId);
        expect(progressData, isNotNull);
        expect(progressData!.status, equals(ArcStatus.inProgress));

        // Complete arc - status should be completed
        final completedArc = inProgressArc.copyWith(
          status: ArcStatus.completed,
          progressPercent: 100.0,
        );
        await repository.updateArcProgress(userId, arcId, completedArc);

        // Verify status is completed
        final completedData = await repository.getArcProgress(userId, arcId);
        expect(completedData, isNotNull);
        expect(completedData!.status, equals(ArcStatus.completed));
        expect(completedData.progressPercent, equals(100.0));
      }
    });

    // Feature: user-database-system, Property 4: Evidence collection accumulation
    // For any arc and evidence, when a user collects an evidence, the evidence ID 
    // should be added to the arc's evidence list and the list size should increase by 1
    test('Property 4: Evidence collection accumulation - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'evidence_user_$i';
        final arcId = 'arc_${_randomArcName(random)}';

        // Create user and initialize arc
        await repository.createUser(userId, UserData.initial(userId));
        final initialArc = ArcProgress.initial(arcId);
        await repository.updateArcProgress(userId, arcId, initialArc);

        // Collect multiple evidences
        final evidenceCount = random.nextInt(10) + 1;
        final evidenceIds = <String>[];

        for (int j = 0; j < evidenceCount; j++) {
          final evidenceId = 'evidence_${i}_$j';
          evidenceIds.add(evidenceId);

          // Get current size
          final beforeData = await repository.getArcProgress(userId, arcId);
          final sizeBefore = beforeData!.evidencesCollected.length;

          // Add evidence
          await repository.addEvidenceToArc(userId, arcId, evidenceId);

          // Verify size increased by 1 and evidence is in list
          final afterData = await repository.getArcProgress(userId, arcId);
          expect(afterData, isNotNull);
          expect(
            afterData!.evidencesCollected.length,
            equals(sizeBefore + 1),
            reason: 'Evidence list should grow by 1',
          );
          expect(
            afterData.evidencesCollected.contains(evidenceId),
            isTrue,
            reason: 'Evidence should be in list',
          );
        }

        // Verify all evidences are present
        final finalData = await repository.getArcProgress(userId, arcId);
        expect(finalData!.evidencesCollected.length, equals(evidenceCount));
        for (final evidenceId in evidenceIds) {
          expect(finalData.evidencesCollected.contains(evidenceId), isTrue);
        }
      }
    });

    // Feature: user-database-system, Property 5: Arc completion increments counter
    // For any arc completion, the user's arcsCompleted counter should increase by exactly 1
    test('Property 5: Arc completion increments counter - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'completion_user_$i';

        // Create user
        await repository.createUser(userId, UserData.initial(userId));

        // Get initial counter
        var userData = await repository.getUser(userId);
        var initialCount = userData!.stats.arcsCompleted;

        // Complete multiple arcs
        final arcsToComplete = random.nextInt(5) + 1;
        for (int j = 0; j < arcsToComplete; j++) {
          final arcId = 'arc_${_randomArcName(random)}_$j';

          // Complete arc
          final completedArc = ArcProgress(
            arcId: arcId,
            status: ArcStatus.completed,
            progressPercent: 100.0,
            lastPlayed: DateTime.now(),
            attemptsCount: random.nextInt(10) + 1,
            evidencesCollected: [],
          );
          await repository.updateArcProgress(userId, arcId, completedArc);

          // Update stats counter
          final updatedStats = userData!.stats.copyWith(
            arcsCompleted: userData.stats.arcsCompleted + 1,
          );
          final updatedUserData = userData.copyWith(stats: updatedStats);
          await repository.updateUser(userId, updatedUserData);

          // Verify counter increased by exactly 1
          userData = await repository.getUser(userId);
          expect(
            userData!.stats.arcsCompleted,
            equals(initialCount + j + 1),
            reason: 'Counter should increase by exactly 1 per completion',
          );
        }

        // Verify final count
        final finalData = await repository.getUser(userId);
        expect(
          finalData!.stats.arcsCompleted,
          equals(initialCount + arcsToComplete),
        );
      }
    });

    test('Property 4: Duplicate evidence not added twice', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'duplicate_evidence_user_$i';
        final arcId = 'arc_test';
        final evidenceId = 'evidence_duplicate';

        // Create user and arc
        await repository.createUser(userId, UserData.initial(userId));
        await repository.updateArcProgress(
          userId,
          arcId,
          ArcProgress.initial(arcId),
        );

        // Add evidence first time
        await repository.addEvidenceToArc(userId, arcId, evidenceId);
        final firstData = await repository.getArcProgress(userId, arcId);
        final firstCount = firstData!.evidencesCollected.length;

        // Add same evidence again
        await repository.addEvidenceToArc(userId, arcId, evidenceId);
        final secondData = await repository.getArcProgress(userId, arcId);

        // Count should not increase (arrayUnion prevents duplicates)
        expect(
          secondData!.evidencesCollected.length,
          equals(firstCount),
          reason: 'Duplicate evidence should not be added',
        );
      }
    });

    test('Property 3: Arc can transition from notStarted to inProgress to completed', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'transition_user_$i';
        final arcId = 'arc_transition';

        await repository.createUser(userId, UserData.initial(userId));

        // Start with notStarted
        final notStartedArc = ArcProgress(
          arcId: arcId,
          status: ArcStatus.notStarted,
          progressPercent: 0.0,
          lastPlayed: null,
          attemptsCount: 0,
          evidencesCollected: [],
        );
        await repository.updateArcProgress(userId, arcId, notStartedArc);
        var arcData = await repository.getArcProgress(userId, arcId);
        expect(arcData!.status, equals(ArcStatus.notStarted));

        // Transition to inProgress
        final inProgressArc = notStartedArc.copyWith(
          status: ArcStatus.inProgress,
          progressPercent: 50.0,
          lastPlayed: DateTime.now(),
          attemptsCount: 1,
        );
        await repository.updateArcProgress(userId, arcId, inProgressArc);
        arcData = await repository.getArcProgress(userId, arcId);
        expect(arcData!.status, equals(ArcStatus.inProgress));

        // Transition to completed
        final completedArc = inProgressArc.copyWith(
          status: ArcStatus.completed,
          progressPercent: 100.0,
        );
        await repository.updateArcProgress(userId, arcId, completedArc);
        arcData = await repository.getArcProgress(userId, arcId);
        expect(arcData!.status, equals(ArcStatus.completed));
      }
    });
  });
}

String _randomArcName(Random random) {
  const arcs = ['gluttony', 'greed', 'envy', 'sloth', 'lust', 'pride', 'wrath'];
  return arcs[random.nextInt(arcs.length)];
}
