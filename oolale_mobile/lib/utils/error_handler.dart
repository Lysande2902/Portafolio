import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../config/theme_colors.dart';

/// Centraliza el manejo de errores con mensajes amigables para el usuario
class ErrorHandler {
  
  /// Determina si un error es de conectividad
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
           errorString.contains('connection') ||
           errorString.contains('timed out') ||
           errorString.contains('network') ||
           errorString.contains('unreachable');
  }

  /// Determina si un error es de base de datos/esquema
  static bool isDatabaseError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('postgrest') ||
           errorString.contains('pgrst') ||
           errorString.contains('table') ||
           errorString.contains('column') ||
           errorString.contains('schema');
  }

  /// Obtiene un mensaje amigable según el tipo de error
  static String getFriendlyMessage(dynamic error) {
    if (isNetworkError(error)) {
      return '🌐 Sin conexión a Internet\n\nVerifica tu conexión Wi-Fi o datos móviles e intenta nuevamente.';
    }
    
    if (isDatabaseError(error)) {
      return '⚙️ Error del servidor\n\nEstamos trabajando en solucionarlo. Por favor, intenta más tarde.';
    }

    // Error genérico
    return '❌ Algo salió mal\n\nPor favor, intenta nuevamente en unos momentos.';
  }

  /// Muestra un SnackBar con el error apropiado
  static void showErrorSnackBar(BuildContext context, dynamic error, {String? customMessage}) {
    if (!context.mounted) return;

    final message = customMessage ?? _getShortErrorMessage(error);
    final color = isNetworkError(error) ? Colors.orange : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNetworkError(error) ? Icons.wifi_off : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Muestra un diálogo completo con el error
  static void showErrorDialog(BuildContext context, dynamic error, {String? title, VoidCallback? onRetry}) {
    if (!context.mounted) return;

    final isNetwork = isNetworkError(error);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isNetwork ? Colors.orange : Colors.red).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetwork ? Icons.wifi_off : Icons.error_outline,
                color: isNetwork ? Colors.orange : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title ?? (isNetwork ? 'Sin Conexión' : 'Error'),
                style: GoogleFonts.outfit(
                  color: ThemeColors.primaryText(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          getFriendlyMessage(error),
          style: GoogleFonts.outfit(
            color: ThemeColors.secondaryText(context),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          if (onRetry != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              onRetry != null ? 'Cancelar' : 'Entendido',
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Versión corta del mensaje de error para SnackBars
  static String _getShortErrorMessage(dynamic error) {
    if (isNetworkError(error)) {
      return 'Sin conexión a Internet';
    }
    
    if (isDatabaseError(error)) {
      return 'Error del servidor';
    }

    return 'Ocurrió un error. Intenta nuevamente';
  }

  /// Registra el error en consola con formato
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('❌ [$context] Error: $error');
    if (stackTrace != null) {
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }
}
