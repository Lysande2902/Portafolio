import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:humano/data/repositories/user_repository.dart';
import 'package:humano/data/models/user_data.dart';
import 'package:humano/data/models/arc_progress.dart';

// Feature: user-database-system, Property 14: Evidence preservation on arc restart
// For any arc that is restarted, the previously collected evidences should remain 
// in the evidencesCollected list

void main() {
  group('Evidence Preservation Property-Based Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;
    final random = Random(42);

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    test('Property 14: Evidence preservation on arc restart - 100 iterations', () async {
      for (int i = 0; i < 100; i++) {
        final userId = 'preservation_user_$i';
        final arcId = 'arc_test';

        // Create user
        await repository.createUser(userId, UserData.initial(userId));

        // Start arc and collect evidences
        final evidenceCount = random.nextInt(10) + 1;
        final evidences = <String>[];

        final initialProgress = ArcProgress(
          arcId: arcId,
          status: ArcStatus.inProgress,
          progressPercent: 50.0,
          lastPlayed: DateTime.now(),
          attemptsCount: 1,
          evidencesCollected: [],
        );
        await repository.updateArcProgress(userId, arcId, initialProgress);

        // Collect evidences
        for (int j = 0; j < evidenceCount; j++) {
          final evidenceId = 'evidence_$j';
          evidences.add(evidenceId);
          await repository.addEvidenceToArc(userId, arcId, evidenceId);
        }

        // Verify evidences are collected
        var progress = await repository.getArcProgress(userId, arcId);
        expect(progress!.evidencesCollected.length, equals(evidenceCount));

        // Restart arc
        await repository.restartArc(userId, arcId);

        // Verify evidences are preserved
        progress = await repository.getArcProgress(userId, arcId);
        expect(
          progress!.evidencesCollected.length,
          equals(evidenceCount),
          reason: 'Evidences should be preserved on restart',
        );

        for (final evidenceId in evidences) {
          expect(
            progress.evidencesCollected.contains(evidenceId),
            isTrue,
            reason: 'Evidence $evidenceId should still be present',
          );
        }

        // Verify arc is reset
        expect(progress.status, equals(ArcStatus.notStarted));
        expect(progress.progressPercent, equals(0.0));
        expect(progress.attemptsCount, equals(2)); // Incremented
      }
    });

    test('Property 14: Multiple restarts preserve all evidences', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'multi_restart_user_$i';
        final arcId = 'arc_multi';

        await repository.createUser(userId, UserData.initial(userId));

        // Initial progress
        await repository.updateArcProgress(
          userId,
          arcId,
          ArcProgress.initial(arcId),
        );

        // Collect evidences and restart multiple times
        final allEvidences = <String>[];
        for (int restart = 0; restart < 3; restart++) {
          // Collect some evidences
          for (int j = 0; j < 3; j++) {
            final evidenceId = 'evidence_${restart}_$j';
            allEvidences.add(evidenceId);
            await repository.addEvidenceToArc(userId, arcId, evidenceId);
          }

          // Restart
          await repository.restartArc(userId, arcId);

          // Verify all evidences are still there
          final progress = await repository.getArcProgress(userId, arcId);
          expect(progress!.evidencesCollected.length, equals(allEvidences.length));
        }
      }
    });

    test('getAllEvidences returns all evidences from all arcs', () async {
      for (int i = 0; i < 50; i++) {
        final userId = 'all_evidences_user_$i';

        await repository.createUser(userId, UserData.initial(userId));

        // Create multiple arcs with evidences
        final arcCount = random.nextInt(3) + 1;
        for (int arcIndex = 0; arcIndex < arcCount; arcIndex++) {
          final arcId = 'arc_$arcIndex';

          await repository.updateArcProgress(
            userId,
            arcId,
            ArcProgress.initial(arcId),
          );

          // Add evidences
          final evidenceCount = random.nextInt(5) + 1;
          for (int j = 0; j < evidenceCount; j++) {
            await repository.addEvidenceToArc(
              userId,
              arcId,
              'evidence_${arcIndex}_$j',
            );
          }
        }

        // Get all evidences
        final allEvidences = await repository.getAllEvidences(userId);

        expect(allEvidences.length, equals(arcCount));
        for (int arcIndex = 0; arcIndex < arcCount; arcIndex++) {
          final arcId = 'arc_$arcIndex';
          expect(allEvidences.containsKey(arcId), isTrue);
          expect(allEvidences[arcId]!.isNotEmpty, isTrue);
        }
      }
    });
  });
}
