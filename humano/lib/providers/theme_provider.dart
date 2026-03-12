import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'user_data_provider.dart';

class AppThemeProvider extends ChangeNotifier {
  WitnessTheme _currentTheme = WitnessTheme.defaultRed;

  WitnessTheme get currentTheme => _currentTheme;

  void updateThemeFromInventory(String? themeId) {
    final newTheme = WitnessTheme.fromId(themeId);
    if (_currentTheme.id != newTheme.id) {
      _currentTheme = newTheme;
      notifyListeners();
    }
  }
  
  // Para uso manual si fuera necesario
  void setTheme(WitnessTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
