import 'package:flutter/material.dart';
import 'constants.dart';

/// Helper class para obtener colores que se adaptan al tema actual
class ThemeColors {
  /// Texto principal (Premium Soft White en oscuro, Deep Onyx en claro)
  static Color primaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.textPrimary
        : AppConstants.textLightPrimary;
  }

  /// Texto secundario (Muted Silver en oscuro, Iron Gray en claro)
  static Color secondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.textSecondary
        : AppConstants.textLightSecondary;
  }

  /// Texto terciario/hint
  static Color hintText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.textMuted
        : AppConstants.textLightSecondary.withOpacity(0.5);
  }

  /// Texto deshabilitado
  static Color disabledText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.bgDarkTertiary
        : AppConstants.bgLightSecondary;
  }

  /// Fondo de tarjetas
  static Color cardBackground(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  /// Fondo de la pantalla
  static Color scaffoldBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Color de divisores/bordes (Glassmorphism sutil en oscuro)
  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.borderColor
        : AppConstants.borderLight; // Sólido, sin opacidad
  }

  /// Fondo de inputs
  static Color inputBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.bgDarkSecondary
        : AppConstants.bgLightSecondary;
  }

  /// Iconos principales
  static Color icon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.textPrimary
        : AppConstants.textLightPrimary;
  }

  /// Iconos secundarios
  static Color iconSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.textSecondary
        : AppConstants.textLightSecondary;
  }

  /// Overlay oscuro (para imágenes, etc)
  static Color overlay(BuildContext context) {
    return Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.4);
  }

  /// Fondo alternativo
  static Color alternativeBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppConstants.bgDarkPanel
        : AppConstants.bgLightSecondary;
  }
}
