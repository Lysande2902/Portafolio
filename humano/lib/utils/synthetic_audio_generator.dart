import 'dart:typed_data';
import 'dart:math' as math;

/// Generates synthetic audio beeps for character dialogue
class SyntheticAudioGenerator {
  /// Generate a simple sine wave beep
  /// 
  /// [frequency] - Frequency in Hz (e.g., 440 for A4)
  /// [duration] - Duration in milliseconds
  /// [sampleRate] - Sample rate (default 44100 Hz)
  static Uint8List generateBeep({
    required double frequency,
    int duration = 50,
    int sampleRate = 44100,
  }) {
    final numSamples = (sampleRate * duration / 1000).round();
    final samples = Float32List(numSamples);
    
    // Generate sine wave
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final sample = math.sin(2 * math.pi * frequency * t);
      
      // Apply envelope (fade in/out) to avoid clicks
      double envelope = 1.0;
      final fadeLength = (numSamples * 0.1).round(); // 10% fade
      
      if (i < fadeLength) {
        envelope = i / fadeLength;
      } else if (i > numSamples - fadeLength) {
        envelope = (numSamples - i) / fadeLength;
      }
      
      samples[i] = (sample * envelope * 0.3).toDouble(); // 30% volume
    }
    
    // Convert to 16-bit PCM
    final bytes = ByteData(numSamples * 2);
    for (int i = 0; i < numSamples; i++) {
      final value = (samples[i] * 32767).round().clamp(-32768, 32767);
      bytes.setInt16(i * 2, value, Endian.little);
    }
    
    return bytes.buffer.asUint8List();
  }
  
  /// Character-specific frequencies
  static const double victorFrequency = 220.0;    // A3 - Low, somber
  static const double magnoliaFrequency = 330.0;  // E4 - Warm, gentle
  static const double alexFrequency = 440.0;      // A4 - Medium, nervous
  static const double doctorFrequency = 370.0;    // F#4 - Professional
  static const double systemFrequency = 880.0;    // A5 - High, robotic
  
  /// Get frequency for character name
  static double getFrequencyForCharacter(String characterName) {
    if (characterName.contains('VÍCTØR')) {
      return victorFrequency;
    } else if (characterName.contains('MÅGNØŁIÅ')) {
      return magnoliaFrequency;
    } else if (characterName.contains('ÅL€X')) {
      return alexFrequency;
    } else if (characterName.contains('ĐR. LØPZ')) {
      return doctorFrequency;
    } else {
      return systemFrequency;
    }
  }
}
