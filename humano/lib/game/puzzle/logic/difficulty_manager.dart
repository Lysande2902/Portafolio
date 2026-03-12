import 'package:flutter/material.dart';

class DifficultyManager {
  int correctPlacements = 0;
  int totalAttempts = 0;

  // Calculate current snap tolerance (increases with correct placements)
  double getSnapTolerance() {
    double baseTolerance = 20.0;
    double bonus = correctPlacements >= 2 ? 10.0 : 0.0;
    return baseTolerance + bonus;
  }

  // Check if fragment should be locked due to repeated errors
  bool shouldLockFragment(String fragmentId, Map<String, int> errorCounts) {
    return (errorCounts[fragmentId] ?? 0) >= 3;
  }

  // Calculate lock duration
  Duration getLockDuration() {
    return const Duration(seconds: 3);
  }

  // Check if hints should be offered
  bool shouldOfferHint() {
    return totalAttempts >= 10 && correctPlacements < 2;
  }

  // Calculate false magnetic attraction strength
  double getFalseMagneticStrength(
    Offset fragmentPos,
    List<Offset> otherFragmentPositions,
  ) {
    // Create subtle attraction to nearby fragments even if incorrect
    double minDistance = double.infinity;

    for (var otherPos in otherFragmentPositions) {
      double dist = (fragmentPos - otherPos).distance;
      if (dist < minDistance && dist > 10) {
        minDistance = dist;
      }
    }

    // Stronger attraction when closer
    if (minDistance < 50) {
      return 0.3; // 30% pull towards nearby fragment
    }
    return 0.0;
  }

  // Apply false magnetic attraction to position
  Offset applyFalseMagneticAttraction(
    Offset currentPosition,
    List<Offset> otherFragmentPositions,
  ) {
    if (otherFragmentPositions.isEmpty) return currentPosition;

    // Find nearest fragment
    Offset? nearestPos;
    double minDistance = double.infinity;

    for (var otherPos in otherFragmentPositions) {
      double dist = (currentPosition - otherPos).distance;
      if (dist < minDistance && dist > 10 && dist < 50) {
        minDistance = dist;
        nearestPos = otherPos;
      }
    }

    if (nearestPos == null) return currentPosition;

    // Apply attraction
    double strength = getFalseMagneticStrength(
      currentPosition,
      otherFragmentPositions,
    );

    if (strength > 0) {
      // Pull towards nearest fragment
      final direction = nearestPos - currentPosition;
      return currentPosition + (direction * strength);
    }

    return currentPosition;
  }

  // Reset manager for new puzzle attempt
  void reset() {
    correctPlacements = 0;
    totalAttempts = 0;
  }

  // Increment correct placements
  void incrementCorrectPlacements() {
    correctPlacements++;
  }

  // Increment total attempts
  void incrementTotalAttempts() {
    totalAttempts++;
  }
}
