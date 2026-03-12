import 'package:flutter/material.dart';

class WitnessTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color terminalTextColor;

  const WitnessTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.backgroundColor = Colors.black,
    this.terminalTextColor = Colors.white,
  });

  static const WitnessTheme defaultRed = WitnessTheme(
    id: 'default',
    name: 'WITNESS_OS_DEFAULT',
    primaryColor: Color(0xFFB71C1C), // red[900]
    secondaryColor: Color(0xFFD32F2F), // red[700]
    accentColor: Color(0xFFEF5350), // red[400]
    terminalTextColor: Colors.white,
  );

  static const WitnessTheme matrix = WitnessTheme(
    id: 'theme_matrix',
    name: 'KERNEL_MATRIZ',
    primaryColor: Color(0xFF1B5E20), // green[900]
    secondaryColor: Color(0xFF388E3C), // green[700]
    accentColor: Color(0xFF00FF41), // Matrix Green
    terminalTextColor: Color(0xFF00FF41),
  );

  static const WitnessTheme amber = WitnessTheme(
    id: 'theme_amber',
    name: 'NODO_AMBAR',
    primaryColor: Color(0xFFFF6F00), // amber[900]
    secondaryColor: Color(0xFFFFA000), // amber[700]
    accentColor: Color(0xFFFFB300), // amber[600]
    terminalTextColor: Color(0xFFFFB300),
  );

  static const WitnessTheme cyber = WitnessTheme(
    id: 'theme_cyber',
    name: 'PROTOCOLO_NEÓN',
    primaryColor: Color(0xFF006064), // cyan[900]
    secondaryColor: Color(0xFF00ACC1), // cyan[600]
    accentColor: Color(0xFFFF00FF), // Magenta
    terminalTextColor: Color(0xFF00F0FF), // Cyan
  );

  static const WitnessTheme ghost = WitnessTheme(
    id: 'theme_ghost',
    name: 'NÚCLEO_ESPECTRAL',
    primaryColor: Color(0xFF263238), // blueGrey[900]
    secondaryColor: Color(0xFFB0BEC5), // blueGrey[200]
    accentColor: Color(0xFFFFFFFF), // White
    terminalTextColor: Color(0xFFECEFF1),
  );

  static const WitnessTheme blood = WitnessTheme(
    id: 'theme_blood',
    name: 'PROTOCOLO_SANGRE_GLITCH',
    primaryColor: Color(0xFF3E2723), // brown[900]
    secondaryColor: Color(0xFFD50000), // red accent[400]
    accentColor: Color(0xFFFF5252), // red accent[200]
    terminalTextColor: Color(0xFFFF8A80),
  );

  static WitnessTheme fromId(String? id) {
    switch (id) {
      case 'theme_matrix':
        return matrix;
      case 'theme_amber':
        return amber;
      case 'theme_cyber':
        return cyber;
      case 'theme_ghost':
        return ghost;
      case 'theme_blood':
        return blood;
      default:
        return defaultRed;
    }
  }
}
