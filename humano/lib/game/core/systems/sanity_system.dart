import 'package:flutter/foundation.dart';

/// Sanity system - manages player's "Cordura Digital" (health)
/// Drains when near enemy, regenerates when hiding
class SanitySystem {
  final ValueNotifier<double> sanityNotifier = ValueNotifier<double>(1.0);
  
  double get currentSanity => sanityNotifier.value;
  set currentSanity(double value) => sanityNotifier.value = value.clamp(0.0, 1.0);

  static const double drainRate = 0.03; // Reduced from 0.06 to 3% per second (gives double time)
  static const double regenRate = 0.15; // 15% per second (increased for balance)

  /// Update sanity based on game state
  /// [regenerateWhileHiding] - if false, hiding won't regenerate sanity (for Greed arc)
  void update(double dt, bool nearEnemy, bool isHiding, {bool regenerateWhileHiding = true}) {
    if (nearEnemy && !isHiding) {
      // Drain sanity when near enemy
      currentSanity -= drainRate * dt;
    } else if (isHiding && regenerateWhileHiding) {
      // Regenerate sanity when hiding (only if enabled)
      currentSanity += regenRate * dt;
    }
  }

  /// Get visual static intensity (0.0 = no static, 1.0 = full static)
  double getStaticIntensity() {
    return 1.0 - currentSanity;
  }

  /// Check if sanity is depleted
  bool isDepleted() {
    return currentSanity <= 0.0;
  }

  /// Reset sanity to full
  void reset() {
    currentSanity = 1.0;
  }

  /// Take damage to sanity (amount is percentage, e.g., 4.0 = 4%)
  void takeDamage(double percentage) {
    currentSanity -= percentage / 100.0;
  }

  /// Heal sanity (amount is percentage, e.g., 10.0 = 10%)
  void heal(double percentage) {
    currentSanity += percentage / 100.0;
  }
}
