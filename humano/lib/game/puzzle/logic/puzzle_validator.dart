import 'package:flutter/material.dart';
import '../../../data/models/puzzle_fragment.dart';

class PuzzleValidator {
  static const double positionTolerance = 20.0; // pixels
  static const double rotationTolerance = 5.0; // degrees

  // Validate if fragment is in correct position and rotation
  static bool isCorrectPlacement({
    required PuzzleFragment fragment,
    required Offset currentPosition,
    required double currentRotation,
    double? customTolerance,
  }) {
    double tolerance = customTolerance ?? positionTolerance;

    // Check position
    final correctPos = Offset(
      fragment.correctPosition.x,
      fragment.correctPosition.y,
    );
    double distance = (currentPosition - correctPos).distance;

    if (distance > tolerance) {
      return false;
    }

    // Check rotation (normalized to 0-360)
    double normalizedCurrent = currentRotation % 360;
    double normalizedCorrect = fragment.correctRotation % 360;

    // Handle negative rotations
    if (normalizedCurrent < 0) normalizedCurrent += 360;
    if (normalizedCorrect < 0) normalizedCorrect += 360;

    double rotDiff = (normalizedCurrent - normalizedCorrect).abs();

    // Check if difference is within tolerance or close to 360 (wrapping)
    if (rotDiff > rotationTolerance && rotDiff < (360 - rotationTolerance)) {
      return false;
    }

    return true;
  }

  // Calculate snap position if within range
  static Offset? calculateSnapPosition({
    required PuzzleFragment fragment,
    required Offset currentPosition,
    required double currentRotation,
    double? customTolerance,
  }) {
    if (isCorrectPlacement(
      fragment: fragment,
      currentPosition: currentPosition,
      currentRotation: currentRotation,
      customTolerance: customTolerance,
    )) {
      return Offset(
        fragment.correctPosition.x,
        fragment.correctPosition.y,
      );
    }
    return null;
  }

  // Calculate snap rotation if within range
  static double? calculateSnapRotation({
    required PuzzleFragment fragment,
    required Offset currentPosition,
    required double currentRotation,
    double? customTolerance,
  }) {
    if (isCorrectPlacement(
      fragment: fragment,
      currentPosition: currentPosition,
      currentRotation: currentRotation,
      customTolerance: customTolerance,
    )) {
      return fragment.correctRotation;
    }
    return null;
  }

  // Check if all fragments are correctly placed
  static bool isPuzzleComplete(
    List<PuzzleFragment> fragments,
    Map<String, Offset> positions,
    Map<String, double> rotations,
  ) {
    for (var fragment in fragments) {
      final position = positions[fragment.id];
      final rotation = rotations[fragment.id];

      if (position == null || rotation == null) {
        return false;
      }

      if (!isCorrectPlacement(
        fragment: fragment,
        currentPosition: position,
        currentRotation: rotation,
      )) {
        return false;
      }
    }
    return true;
  }

  // Get distance from correct position
  static double getDistanceFromCorrect({
    required PuzzleFragment fragment,
    required Offset currentPosition,
  }) {
    final correctPos = Offset(
      fragment.correctPosition.x,
      fragment.correctPosition.y,
    );
    return (currentPosition - correctPos).distance;
  }

  // Check if fragment is near correct position (for proximity feedback)
  static bool isNearCorrectPosition({
    required PuzzleFragment fragment,
    required Offset currentPosition,
    double proximityThreshold = 50.0,
  }) {
    return getDistanceFromCorrect(
          fragment: fragment,
          currentPosition: currentPosition,
        ) <
        proximityThreshold;
  }
}
