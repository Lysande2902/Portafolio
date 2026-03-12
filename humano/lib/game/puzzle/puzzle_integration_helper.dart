import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/providers/puzzle_data_provider.dart';
import '../../data/providers/fragments_provider.dart';

/// Helper class to integrate puzzle fragment collection into gameplay
class PuzzleIntegrationHelper {
  /// @deprecated Use game.saveFragment() instead. This method requires BuildContext
  /// which can be null during gameplay. The new approach uses a direct provider reference.
  /// 
  /// Migration:
  /// ```dart
  /// // Old (deprecated):
  /// PuzzleIntegrationHelper.collectFragment(
  ///   context: buildContext!,
  ///   arcId: 'gluttony',
  ///   fragmentNumber: evidenceCollected,
  /// );
  /// 
  /// // New (recommended):
  /// saveFragment('gluttony', evidenceCollected);
  /// ```
  @Deprecated('Use game.saveFragment() instead. Will be removed in future version.')
  static Future<void> collectFragment({
    required BuildContext context,
    required String arcId,
    required int fragmentNumber,
  }) async {
    print('⚠️ [DEPRECATED] PuzzleIntegrationHelper.collectFragment is deprecated');
    print('   Use game.saveFragment() instead for better reliability');
    print('   This method will be removed in a future version');
    try {
      print('🔍 [FRAGMENT DEBUG] Starting collection...');
      print('   Arc ID: $arcId');
      print('   Fragment Number: $fragmentNumber');
      
      // Get user ID from Firebase Auth directly
      final userId = FirebaseAuth.instance.currentUser?.uid;
      print('   User ID: $userId');
      
      if (userId == null) {
        print('⚠️ No user logged in - CANNOT SAVE FRAGMENT');
        return;
      }

      // Use the globally registered puzzle provider
      final puzzleProvider = Provider.of<PuzzleDataProvider>(context, listen: false);
      print('   Puzzle Provider obtained: ${puzzleProvider != null}');

      // Map arc ID to evidence ID
      final evidenceId = _getEvidenceIdForArc(arcId);
      print('   Evidence ID: $evidenceId');
      
      if (evidenceId == null) {
        print('⚠️ No evidence ID found for arc: $arcId - CANNOT SAVE');
        return;
      }

      // Collect the fragment in PuzzleDataProvider (for puzzles)
      print('   Calling puzzleProvider.collectFragment...');
      await puzzleProvider.collectFragment(evidenceId, fragmentNumber);

      // ALSO collect in FragmentsProvider (for archive screen)
      print('   Calling fragmentsProvider.unlockFragment...');
      final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
      await fragmentsProvider.unlockFragment(arcId, fragmentNumber);

      print('✨ Fragment $fragmentNumber collected for $arcId (Evidence: $evidenceId) - SUCCESS!');
    } catch (e, stackTrace) {
      print('❌ Error collecting fragment: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  static String? _getEvidenceIdForArc(String arcId) {
    switch (arcId) {
      case 'gluttony':
      case 'arc_1_gula':
        return 'arc1_gluttony_evidence';
      case 'greed':
      case 'arc_2_greed':
      case 'arc_2_avaricia':
        return 'arc2_greed_evidence';
      case 'envy':
      case 'arc_3_envy':
      case 'arc_3_envidia':
        return 'arc3_envy_evidence';
      default:
        return null;
    }
  }

  /// Get the arc ID from evidence ID
  static String? getArcIdFromEvidence(String evidenceId) {
    if (evidenceId.contains('arc1') || evidenceId.contains('gluttony')) {
      return 'gluttony';
    } else if (evidenceId.contains('arc2') || evidenceId.contains('greed')) {
      return 'greed';
    } else if (evidenceId.contains('arc3') || evidenceId.contains('envy')) {
      return 'envy';
    }
    return null;
  }
}
