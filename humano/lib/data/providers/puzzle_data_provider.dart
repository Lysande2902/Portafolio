import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puzzle_evidence.dart';
import 'evidence_definitions.dart';

class PuzzleDataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  Map<String, PuzzleEvidence> _evidences = {};
  bool _isLoading = false;

  PuzzleDataProvider(this.userId) {
    _loadPuzzleData();
  }

  bool get isLoading => _isLoading;
  Map<String, PuzzleEvidence> get evidences => _evidences;

  // Load all puzzle definitions and player progress
  Future<void> _loadPuzzleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load puzzle definitions from EvidenceDefinitions
      final evidenceList = EvidenceDefinitions.getAllEvidences();
      _evidences = {for (var e in evidenceList) e.id: e};

      print('📦 Loaded ${_evidences.length} evidence definitions');

      // Load player's progress from Firestore
      await _loadPlayerProgress();
    } catch (e) {
      print('Error loading puzzle data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load player's collected fragments and completion status
  Future<void> _loadPlayerProgress() async {
    if (userId.isEmpty || userId == 'anonymous') {
      print('⚠️ Cannot load progress: user not authenticated (userId: $userId)');
      return;
    }
    
    try {
      print('📦 Loading player progress for user: $userId');
      
      // Load collected fragments
      final fragmentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('fragments')
          .get();

      for (var doc in fragmentsSnapshot.docs) {
        final fragmentId = doc.id;
        final data = doc.data();

        // Find the fragment in evidences and update its collection status
        for (var evidence in _evidences.values) {
          final fragment =
              evidence.fragments.firstWhere((f) => f.id == fragmentId,
                  orElse: () => evidence.fragments.first);

          if (fragment.id == fragmentId) {
            fragment.isCollected = data['collected'] as bool? ?? false;
            fragment.collectedAt = data['collectedAt'] != null
                ? (data['collectedAt'] as Timestamp).toDate()
                : null;
          }
        }
      }

      // Load completed evidences
      final evidencesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('evidences')
          .get();

      for (var doc in evidencesSnapshot.docs) {
        final evidenceId = doc.id;
        final data = doc.data();

        if (_evidences.containsKey(evidenceId)) {
          _evidences[evidenceId]!.isCompleted =
              data['completed'] as bool? ?? false;
          _evidences[evidenceId]!.completedAt = data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null;
          _evidences[evidenceId]!.attemptCount =
              data['attemptCount'] as int? ?? 0;
        }
      }
    } catch (e) {
      print('Error loading player progress: $e');
    }
  }

  // Mark fragment as collected
  Future<void> collectFragment(String evidenceId, int fragmentNumber) async {
    print('📦 [PUZZLE PROVIDER] collectFragment called');
    print('   Evidence ID: $evidenceId');
    print('   Fragment Number: $fragmentNumber');
    print('   User ID: $userId');
    
    if (userId.isEmpty || userId == 'anonymous') {
      print('❌ Cannot collect fragment: user not authenticated');
      return;
    }
    
    final evidence = _evidences[evidenceId];
    if (evidence == null) {
      print('❌ Evidence not found: $evidenceId');
      print('   Available evidences: ${_evidences.keys.toList()}');
      return;
    }

    if (fragmentNumber < 1 || fragmentNumber > 5) {
      print('❌ Invalid fragment number: $fragmentNumber');
      return;
    }

    final fragment = evidence.fragments[fragmentNumber - 1];
    print('   Fragment ID: ${fragment.id}');

    // Don't collect if already collected
    if (fragment.isCollected) {
      print('⚠️ Fragment already collected: ${fragment.id}');
      return;
    }

    fragment.isCollected = true;
    fragment.collectedAt = DateTime.now();
    print('   Fragment marked as collected locally');

    // Save to Firestore
    try {
      print('   Saving to Firestore: users/$userId/fragments/${fragment.id}');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fragments')
          .doc(fragment.id)
          .set({
        'collected': true,
        'collectedAt': FieldValue.serverTimestamp(),
        'evidenceId': evidenceId,
        'fragmentNumber': fragmentNumber,
      });

      print('✅ Fragment saved to Firestore successfully!');
      print('✨ Fragment collected: ${fragment.id} ($fragmentNumber/5)');
      notifyListeners();
      print('   Listeners notified');
    } catch (e, stackTrace) {
      print('❌ Error saving fragment collection: $e');
      print('   Stack trace: $stackTrace');
      // Revert on error
      fragment.isCollected = false;
      fragment.collectedAt = null;
    }
  }

  // Mark evidence as completed
  Future<void> completeEvidence(String evidenceId) async {
    final evidence = _evidences[evidenceId];
    if (evidence == null) {
      print('Evidence not found: $evidenceId');
      return;
    }

    evidence.isCompleted = true;
    evidence.completedAt = DateTime.now();
    evidence.attemptCount++;

    // Save to Firestore
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('evidences')
          .doc(evidenceId)
          .set({
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
        'attemptCount': evidence.attemptCount,
      });

      print('🎉 Evidence completed: $evidenceId');
      notifyListeners();
    } catch (e) {
      print('Error saving evidence completion: $e');
      // Revert on error
      evidence.isCompleted = false;
      evidence.completedAt = null;
      evidence.attemptCount--;
    }
  }

  // Increment attempt count without completing
  Future<void> incrementAttemptCount(String evidenceId) async {
    final evidence = _evidences[evidenceId];
    if (evidence == null) return;

    evidence.attemptCount++;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('evidences')
          .doc(evidenceId)
          .update({
        'attemptCount': evidence.attemptCount,
      });
    } catch (e) {
      print('Error updating attempt count: $e');
    }
  }

  // Get evidence by ID
  PuzzleEvidence? getEvidence(String evidenceId) {
    return _evidences[evidenceId];
  }

  // Get all evidences for an arc
  List<PuzzleEvidence> getEvidencesForArc(String arcId) {
    return _evidences.values.where((e) => e.arcId == arcId).toList();
  }

  // Check if evidence can be assembled (all fragments collected)
  bool canAssembleEvidence(String evidenceId) {
    final evidence = _evidences[evidenceId];
    if (evidence == null) return false;

    return evidence.canAssemble;
  }

  // Get collection progress for an evidence
  String getCollectionProgress(String evidenceId) {
    final evidence = _evidences[evidenceId];
    if (evidence == null) return '0/5';

    return '${evidence.collectedFragmentCount}/5';
  }

  // Add evidence definition (used during initialization)
  void addEvidenceDefinition(PuzzleEvidence evidence) {
    _evidences[evidence.id] = evidence;
    notifyListeners();
  }

  // Reload data from Firestore
  Future<void> reload() async {
    await _loadPuzzleData();
  }
}
