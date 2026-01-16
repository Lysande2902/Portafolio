import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Óolale';
  static const String baseUrl = 'http://192.168.1.86:3000/api'; // Local IP for Real Devices

  // Professional Premium Palette (Óolale V2.0)
  static const Color primaryColor = Color(0xFF00BFA5); // Vibrant Cyan/Teal
  static const Color accentColor = Color(0xFFFFD600); // Premium Gold
  static const Color backgroundColor = Color(0xFF000000); // Pure Black for OLED depth
  static const Color cardColor = Color(0xFF111111); // Deep Grey for Glass Cards
  static const Color errorColor = Color(0xFFFF5252);
  
  static const double defaultPadding = 24.0;
  static const double borderRadius = 20.0;
}
