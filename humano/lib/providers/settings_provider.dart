import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import '../data/models/game_settings.dart';

class SettingsProvider extends ChangeNotifier {
  GameSettings _settings = GameSettings.defaults;
  Timer? _saveTimer;
  final AudioPlayer _previewPlayer = AudioPlayer();
  Timer? _previewTimer;

  GameSettings get settings => _settings;

  // Individual getters for convenience
  double get masterVolume => _settings.masterVolume;
  double get musicVolume => _settings.musicVolume;
  double get sfxVolume => _settings.sfxVolume;
  double get touchSensitivity => _settings.touchSensitivity;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  bool get vhsEffectsEnabled => _settings.vhsEffectsEnabled;
  bool get glitchEffectsEnabled => _settings.glitchEffectsEnabled;
  bool get screenShakeEnabled => _settings.screenShakeEnabled;

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final masterVol = prefs.getDouble('master_volume');
      final musicVol = prefs.getDouble('music_volume');
      final sfxVol = prefs.getDouble('sfx_volume');
      final touchSens = prefs.getDouble('touch_sensitivity');
      final vibEnabled = prefs.getBool('vibration_enabled');
      final vhsEnabled = prefs.getBool('vhs_effects_enabled');
      final glitchEnabled = prefs.getBool('glitch_effects_enabled');
      final shakeEnabled = prefs.getBool('screen_shake_enabled');

      _settings = GameSettings(
        masterVolume: masterVol ?? GameSettings.defaults.masterVolume,
        musicVolume: musicVol ?? GameSettings.defaults.musicVolume,
        sfxVolume: sfxVol ?? GameSettings.defaults.sfxVolume,
        touchSensitivity: touchSens ?? GameSettings.defaults.touchSensitivity,
        vibrationEnabled: vibEnabled ?? GameSettings.defaults.vibrationEnabled,
        vhsEffectsEnabled: vhsEnabled ?? GameSettings.defaults.vhsEffectsEnabled,
        glitchEffectsEnabled: glitchEnabled ?? GameSettings.defaults.glitchEffectsEnabled,
        screenShakeEnabled: shakeEnabled ?? GameSettings.defaults.screenShakeEnabled,
      );
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
      // Use defaults on error
    }
  }

  /// Save settings to SharedPreferences with debouncing
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('master_volume', _settings.masterVolume);
      await prefs.setDouble('music_volume', _settings.musicVolume);
      await prefs.setDouble('sfx_volume', _settings.sfxVolume);
      await prefs.setDouble('touch_sensitivity', _settings.touchSensitivity);
      await prefs.setBool('vibration_enabled', _settings.vibrationEnabled);
      await prefs.setBool('vhs_effects_enabled', _settings.vhsEffectsEnabled);
      await prefs.setBool('glitch_effects_enabled', _settings.glitchEffectsEnabled);
      await prefs.setBool('screen_shake_enabled', _settings.screenShakeEnabled);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  /// Debounced save - waits 500ms after last change
  void _debouncedSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveSettings();
    });
  }

  /// Set master volume
  void setMasterVolume(double volume) {
    _settings = _settings.copyWith(masterVolume: volume.clamp(0.0, 1.0));
    notifyListeners();
    _debouncedSave();
    _playPreview();
  }

  /// Set music volume
  void setMusicVolume(double volume) {
    _settings = _settings.copyWith(musicVolume: volume.clamp(0.0, 1.0));
    notifyListeners();
    _debouncedSave();
    _playPreview();
  }

  /// Set SFX volume
  void setSfxVolume(double volume) {
    _settings = _settings.copyWith(sfxVolume: volume.clamp(0.0, 1.0));
    notifyListeners();
    _debouncedSave();
    _playPreview();
  }

  /// Set touch sensitivity
  void setTouchSensitivity(double sensitivity) {
    _settings = _settings.copyWith(touchSensitivity: sensitivity.clamp(0.5, 2.0));
    notifyListeners();
    _debouncedSave();
  }

  /// Toggle vibration
  void toggleVibration(bool enabled) {
    _settings = _settings.copyWith(vibrationEnabled: enabled);
    notifyListeners();
    _debouncedSave();
    
    // Test vibration if enabled
    if (enabled) {
      _testVibration();
    }
  }

  /// Test vibration (short pulse)
  Future<void> _testVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      print('Error testing vibration: $e');
    }
  }

  /// Toggle VHS effects
  void toggleVhsEffects(bool enabled) {
    _settings = _settings.copyWith(vhsEffectsEnabled: enabled);
    notifyListeners();
    _debouncedSave();
  }

  /// Toggle glitch effects
  void toggleGlitchEffects(bool enabled) {
    _settings = _settings.copyWith(glitchEffectsEnabled: enabled);
    notifyListeners();
    _debouncedSave();
  }

  /// Toggle screen shake
  void toggleScreenShake(bool enabled) {
    _settings = _settings.copyWith(screenShakeEnabled: enabled);
    notifyListeners();
    _debouncedSave();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _settings = GameSettings.defaults;
    notifyListeners();
    await _saveSettings();
  }

  /// Play preview sound with debouncing (max once per 200ms)
  void _playPreview() {
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 200), () async {
      try {
        await _previewPlayer.setAsset('assets/sounds/new-notification-09-352705.mp3');
        // Apply both master and SFX volume
        final finalVolume = _settings.masterVolume * _settings.sfxVolume;
        await _previewPlayer.setVolume(finalVolume);
        await _previewPlayer.play();
      } catch (e) {
        print('Error playing preview: $e');
      }
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _previewTimer?.cancel();
    _previewPlayer.dispose();
    super.dispose();
  }
}
