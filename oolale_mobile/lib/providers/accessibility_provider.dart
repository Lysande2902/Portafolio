import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider with ChangeNotifier {
  double _fontScale = 1.0;
  bool _highContrast = false;
  bool _accessibilityMode = false;

  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;
  bool get accessibilityMode => _accessibilityMode;

  AccessibilityProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontScale = prefs.getDouble('font_scale') ?? 1.0;
      _highContrast = prefs.getBool('high_contrast') ?? false;
      _accessibilityMode = prefs.getBool('accessibility_mode') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading accessibility settings: $e');
    }
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_scale', scale);
    } catch (e) {
      debugPrint('Error saving font scale: $e');
    }
  }

  Future<void> setHighContrast(bool enabled) async {
    _highContrast = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('high_contrast', enabled);
    } catch (e) {
      debugPrint('Error saving high contrast: $e');
    }
  }

  Future<void> setAccessibilityMode(bool enabled) async {
    _accessibilityMode = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('accessibility_mode', enabled);
    } catch (e) {
      debugPrint('Error saving accessibility mode: $e');
    }
  }

  // Obtener tamaño de texto ajustado
  double getAdjustedFontSize(double baseSize) {
    return baseSize * _fontScale;
  }

  // Obtener colores de alto contraste
  Color getContrastColor(Color baseColor, {bool isDark = false}) {
    if (!_highContrast) return baseColor;
    
    // En modo alto contraste, usar colores más intensos
    if (isDark) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
