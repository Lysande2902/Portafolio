import 'package:cloud_firestore/cloud_firestore.dart';

/// Estrategia de reintentos con backoff exponencial para operaciones de Firestore
class RetryStrategy {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(milliseconds: 500);
  static const double backoffMultiplier = 2.0;

  /// Ejecuta una operación con reintentos automáticos
  /// Reintenta hasta maxRetries veces con backoff exponencial
  /// Solo reintenta errores que son retriables (red, timeout, etc.)
  Future<T> executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        // Si alcanzamos el máximo de reintentos, lanzar el error
        if (attempts >= maxRetries) {
          rethrow;
        }

        // Si el error no es retriable, lanzar inmediatamente
        if (e is FirebaseException && !_isRetriableError(e)) {
          rethrow;
        }

        // Si es otro tipo de error no esperado, lanzar
        if (e is! FirebaseException) {
          rethrow;
        }

        // Esperar antes del siguiente intento
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Determina si un error de Firebase es retriable
  bool _isRetriableError(FirebaseException e) {
    // Errores que indican problemas temporales de red o servicio
    return e.code == 'unavailable' ||
        e.code == 'deadline-exceeded' ||
        e.code == 'resource-exhausted' ||
        e.code == 'aborted' ||
        e.code == 'internal' ||
        e.code == 'unknown';
  }

  /// Ejecuta una operación con reintentos y callback de progreso
  Future<T> executeWithRetryAndCallback<T>(
    Future<T> Function() operation, {
    void Function(int attempt, Exception error)? onRetry,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          rethrow;
        }

        if (e is FirebaseException && !_isRetriableError(e)) {
          rethrow;
        }

        if (e is! FirebaseException) {
          rethrow;
        }

        // Notificar del reintento
        if (onRetry != null) {
          onRetry(attempts, e);
        }

        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }

    throw Exception('Max retries exceeded');
  }
}
