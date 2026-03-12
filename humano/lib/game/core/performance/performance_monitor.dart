import 'package:flutter/foundation.dart';

/// Performance monitor for game
/// Tracks frame times and adjusts update frequency
class PerformanceMonitor {
  final List<double> _frameTimeHistory = [];
  static const int _maxFrameHistory = 60; // Track last 60 frames
  static const double _targetFrameTime = 33.33; // 30 FPS restoration target
  static const double _slowFrameThreshold = 80.0; // 12 FPS threshold for reduction
  
  double _updateFrequencyMultiplier = 1.0;
  
  /// Get current update frequency multiplier
  double get updateFrequencyMultiplier => _updateFrequencyMultiplier;
  
  /// Get average frame time over last N frames
  double get averageFrameTime {
    if (_frameTimeHistory.isEmpty) return 0.0;
    return _frameTimeHistory.reduce((a, b) => a + b) / _frameTimeHistory.length;
  }
  
  /// Get current FPS
  double get currentFPS {
    final avg = averageFrameTime;
    if (avg == 0) return 60.0;
    return 1000.0 / avg;
  }
  
  /// Track a frame time
  void trackFrame(double frameTimeMs) {
    _frameTimeHistory.add(frameTimeMs);
    
    // Keep only last N frames
    if (_frameTimeHistory.length > _maxFrameHistory) {
      _frameTimeHistory.removeAt(0);
    }
    
    // Adjust update frequency if needed
    _adjustUpdateFrequency();
  }
  
  /// Adjust update frequency based on performance
  void _adjustUpdateFrequency() {
    if (_frameTimeHistory.length < 30) return; // Need enough samples
    
    final avg = averageFrameTime;
    
    if (avg > _slowFrameThreshold) {
      // Performance is poor, reduce update frequency
      _updateFrequencyMultiplier = 0.5;
      debugPrint('⚠️ [PERFORMANCE] Reducing update frequency to 50% (avg frame time: ${avg.toStringAsFixed(1)}ms)');
    } else if (avg < _targetFrameTime * 1.2) {
      // Performance is good, restore normal frequency
      if (_updateFrequencyMultiplier != 1.0) {
        _updateFrequencyMultiplier = 1.0;
        debugPrint('✅ [PERFORMANCE] Restoring normal update frequency (avg frame time: ${avg.toStringAsFixed(1)}ms)');
      }
    }
  }
  
  /// Reset monitor
  void reset() {
    _frameTimeHistory.clear();
    _updateFrequencyMultiplier = 1.0;
  }
}
