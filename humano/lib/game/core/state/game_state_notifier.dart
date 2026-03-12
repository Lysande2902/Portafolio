import 'package:flutter/foundation.dart';

/// Notifier for game state changes
/// Uses individual ValueNotifiers for each state property
/// This allows fine-grained reactive updates without rebuilding entire widget tree
class GameStateNotifier {
  // Core game state
  final ValueNotifier<int> evidence = ValueNotifier<int>(0);
  final ValueNotifier<double> sanity = ValueNotifier<double>(1.0);
  final ValueNotifier<bool> gameOver = ValueNotifier<bool>(false);
  final ValueNotifier<bool> victory = ValueNotifier<bool>(false);
  final ValueNotifier<bool> paused = ValueNotifier<bool>(false);
  
  // Item states
  final ValueNotifier<bool> modoIncognito = ValueNotifier<bool>(false);
  final ValueNotifier<bool> firewall = ValueNotifier<bool>(false);
  final ValueNotifier<bool> vpn = ValueNotifier<bool>(false);
  final ValueNotifier<bool> altAccount = ValueNotifier<bool>(false);
  
  // Arc-specific states (nullable for arcs that don't use them)
  final ValueNotifier<double?> noiseLevel = ValueNotifier<double?>(null);
  final ValueNotifier<int?> foodInventory = ValueNotifier<int?>(null);
  final ValueNotifier<int?> coinInventory = ValueNotifier<int?>(null);
  final ValueNotifier<int?> cameraInventory = ValueNotifier<int?>(null);
  
  // Dialogue state
  final ValueNotifier<String?> dialogueSpeaker = ValueNotifier<String?>(null);
  final ValueNotifier<String?> dialogueText = ValueNotifier<String?>(null);
  
  // Available items map (for consumables)
  final ValueNotifier<Map<String, int>> availableItems = ValueNotifier<Map<String, int>>({});
  
  // Flag to defer updates (used during initialization)
  bool _deferUpdates = false;
  final List<VoidCallback> _deferredUpdates = [];
  
  /// Update evidence count (only notifies if changed)
  void updateEvidence(int count) {
    if (evidence.value != count) {
      evidence.value = count;
    }
  }
  
  /// Update sanity value (only notifies if changed)
  void updateSanity(double value) {
    if (sanity.value != value) {
      sanity.value = value;
    }
  }
  
  /// Update game over state (only notifies if changed)
  void updateGameOver(bool value) {
    if (gameOver.value != value) {
      gameOver.value = value;
    }
  }
  
  /// Update victory state (only notifies if changed)
  void updateVictory(bool value) {
    if (victory.value != value) {
      victory.value = value;
    }
  }
  
  /// Update paused state (only notifies if changed)
  void updatePaused(bool value) {
    if (paused.value != value) {
      paused.value = value;
    }
  }
  
  /// Update available items (only notifies if changed)
  void updateItems(Map<String, int> items) {
    if (!_mapsEqual(availableItems.value, items)) {
      availableItems.value = Map.from(items);
    }
  }
  
  /// Update modo incognito state (only notifies if changed)
  void updateModoIncognito(bool value) {
    if (modoIncognito.value != value) {
      modoIncognito.value = value;
    }
  }
  
  /// Update firewall state (only notifies if changed)
  void updateFirewall(bool value) {
    if (firewall.value != value) {
      firewall.value = value;
    }
  }
  
  /// Update VPN state (only notifies if changed)
  void updateVPN(bool value) {
    if (vpn.value != value) {
      vpn.value = value;
    }
  }
  
  /// Update alt account state (only notifies if changed)
  void updateAltAccount(bool value) {
    if (altAccount.value != value) {
      altAccount.value = value;
    }
  }
  
  /// Update noise level (Sloth arc specific)
  void updateNoiseLevel(double? value) {
    if (noiseLevel.value != value) {
      noiseLevel.value = value;
    }
  }
  
  /// Update food inventory count (Gluttony arc specific)
  void updateFoodInventory(int? value) {
    if (foodInventory.value != value) {
      foodInventory.value = value;
    }
  }
  
  /// Update coin inventory count (Greed arc specific)
  void updateCoinInventory(int? value) {
    if (coinInventory.value != value) {
      coinInventory.value = value;
    }
  }
  
  /// Update camera inventory count (Envy arc specific)
  void updateCameraInventory(int? value) {
    if (cameraInventory.value != value) {
      cameraInventory.value = value;
    }
  }

  /// Trigger or clear a dialogue
  void updateDialogue(String? speaker, String? text) {
    if (dialogueSpeaker.value != speaker || dialogueText.value != text) {
      dialogueSpeaker.value = speaker;
      dialogueText.value = text;
    }
  }
  
  /// Enable deferred updates mode
  void enableDeferredUpdates() {
    _deferUpdates = true;
    debugPrint('🔒 [NOTIFIER] Deferred updates enabled');
  }
  
  /// Disable deferred updates and flush pending updates
  void flushDeferredUpdates() {
    _deferUpdates = false;
    debugPrint('🔓 [NOTIFIER] Flushing ${_deferredUpdates.length} deferred updates');
    
    for (final update in _deferredUpdates) {
      try {
        update();
      } catch (e) {
        debugPrint('❌ [NOTIFIER] Error flushing deferred update: $e');
      }
    }
    
    _deferredUpdates.clear();
  }
  
  /// Execute an update immediately or defer it
  void _executeOrDefer(VoidCallback update) {
    if (_deferUpdates) {
      _deferredUpdates.add(update);
    } else {
      update();
    }
  }
  
  /// Batch multiple updates together
  void batchUpdate(VoidCallback updates) {
    final wasDeferring = _deferUpdates;
    _deferUpdates = true;
    
    try {
      updates();
    } finally {
      _deferUpdates = wasDeferring;
    }
  }
  
  /// Reset all state to initial values
  void reset() {
    evidence.value = 0;
    sanity.value = 1.0;
    gameOver.value = false;
    victory.value = false;
    paused.value = false;
    availableItems.value = {};
    modoIncognito.value = false;
    firewall.value = false;
    vpn.value = false;
    altAccount.value = false;
    noiseLevel.value = null;
    foodInventory.value = null;
    coinInventory.value = null;
    cameraInventory.value = null;
    _deferredUpdates.clear();
  }
  
  /// Dispose all ValueNotifiers
  void dispose() {
    evidence.dispose();
    sanity.dispose();
    gameOver.dispose();
    victory.dispose();
    paused.dispose();
    modoIncognito.dispose();
    firewall.dispose();
    vpn.dispose();
    altAccount.dispose();
    noiseLevel.dispose();
    foodInventory.dispose();
    coinInventory.dispose();
    cameraInventory.dispose();
    availableItems.dispose();
  }
  
  /// Helper to compare maps
  bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
