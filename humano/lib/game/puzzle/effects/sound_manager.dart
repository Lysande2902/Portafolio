import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  // Pool de reproductores para permitir sonidos simultáneos rápidos (como la máquina de escribir)
  final List<AudioPlayer> _playerPool = List.generate(5, (_) => AudioPlayer());
  int _poolIndex = 0;
  
  // Reproductor dedicado para el ambiente (looping)
  final AudioPlayer _ambientPlayer = AudioPlayer();

  SoundManager._internal() {
    _initPool();
  }

  void _initPool() {
    final context = AudioContext(
      android: AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
      ),
    );

    for (var player in _playerPool) {
      player.setAudioContext(context);
      player.setPlayerMode(PlayerMode.lowLatency);
    }
    _ambientPlayer.setAudioContext(context);
  }

  bool _soundEnabled = false; // Desactivado por petición del usuario
  bool _hapticEnabled = true;

  // Sound paths...
  static const String _pickupSound = 'sounds/ui_confirm.mp3';
  static const String _snapSound = 'sounds/ui_confirm.mp3';
  static const String _errorSound = 'sounds/glitch_error.mp3';
  static const String _completionSound = 'sounds/data_transfer.mp3';
  static const String _proximitySound = 'sounds/keyboard_click.mp3';
  static const String _rotateSound = 'sounds/keyboard_click.mp3';
  static const String _blipSound = 'sounds/keyboard_click.mp3';

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
  }

  Future<void> _safePlay(String asset, {double volume = 1.0}) async {
    if (!_soundEnabled) return;
    try {
      // Rotamos el pool para no pisar el sonido que está sonando justo antes
      final player = _playerPool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _playerPool.length;

      // Importante: No llamar a setPlayerMode aquí, ya se hizo en el init
      await player.play(AssetSource(asset), volume: volume);
    } catch (e) {
      debugPrint('Error playing sound ($asset): $e');
    }
  }

  Future<void> playBlip() async => await _safePlay(_blipSound, volume: 0.15);
  Future<void> playPickupSound() async => await _safePlay(_pickupSound, volume: 0.4);
  Future<void> playSnapSound() async => await _safePlay(_snapSound, volume: 0.6);
  Future<void> playErrorSound() async => await _safePlay(_errorSound, volume: 0.5);
  Future<void> playCompletionSound() async => await _safePlay(_completionSound, volume: 0.7);
  Future<void> playRotateSound() async => await _safePlay(_rotateSound, volume: 0.3);

  Future<void> playProximitySound() async {
    await _safePlay('sounds/clock_ticking.mp3', volume: 0.7);
  }

  Future<void> playAmbientSound() async {
    if (!_soundEnabled) return;
    try {
      // Para sonidos ambientales, usamos el reproductor dedicado
      // Desactivado para que la música elegida por el usuario sea la principal
      // await _ambientPlayer.stop();
      // await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      // await _ambientPlayer.play(AssetSource('sounds/ambient_servers.mp3'), volume: 0.15);
    } catch (e) {
      debugPrint('Error playing ambient sound: $e');
    }
  }

  // Haptic feedback...
  Future<void> lightHaptic() async {
    if (!_hapticEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 10);
      }
    } catch (e) {
      debugPrint('Error with haptic feedback: $e');
    }
  }

  Future<void> mediumHaptic() async {
    if (!_hapticEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 30);
      }
    } catch (e) {
      debugPrint('Error with haptic feedback: $e');
    }
  }

  Future<void> heavyHaptic() async {
    if (!_hapticEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Error with haptic feedback: $e');
    }
  }

  Future<void> errorHaptic() async {
    if (!_hapticEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Double vibration for error
        Vibration.vibrate(duration: 50);
        await Future.delayed(const Duration(milliseconds: 100));
        Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      debugPrint('Error with haptic feedback: $e');
    }
  }

  Future<void> successHaptic() async {
    if (!_hapticEnabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        // Triple vibration for success
        Vibration.vibrate(duration: 30);
        await Future.delayed(const Duration(milliseconds: 50));
        Vibration.vibrate(duration: 30);
        await Future.delayed(const Duration(milliseconds: 50));
        Vibration.vibrate(duration: 30);
      }
    } catch (e) {
      debugPrint('Error with haptic feedback: $e');
    }
  }

  void dispose() {
    for (var player in _playerPool) {
      player.dispose();
    }
    _ambientPlayer.dispose();
  }
}
