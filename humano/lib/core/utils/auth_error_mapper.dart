import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMapper {
  static String mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'CONTRASEÑA_INSEGURA // El sistema rechaza claves predecibles. Sé menos obvio.';
      case 'email-already-in-use':
        return 'IDENTIDAD_DUPLICADA // Este correo ya existe en la base de datos. ¿Lo olvidaste?';
      case 'invalid-email':
        return 'FORMATO_INVÁLIDO // Eso no parece un correo. El sistema no acepta ruido.';
      case 'user-not-found':
        return 'SUJETO_NO_ENCONTRADO // No hay registro de esa identidad. Nunca exististe aquí.';
      case 'wrong-password':
        return 'ACCESO_DENEGADO // La clave no coincide. Alguien miente: tú o tu memoria.';
      case 'network-request-failed':
        return 'ENLACE_INTERRUMPIDO // No hay conexión al servidor. ¿Dónde estás exactamente?';
      case 'too-many-requests':
        return 'PROTOCOLO_DE_BLOQUEO_ACTIVO // Demasiados intentos. El sistema te ha marcado.';
      case 'operation-not-allowed':
        return 'ACCESO_RESTRINGIDO // Esta operación no está autorizada para tu nivel de acceso.';
      case 'user-disabled':
        return 'CUENTA_DESACTIVADA // Esta identidad ha sido eliminada del sistema. Ya no eres nadie aquí.';
      case 'invalid-credential':
        return 'CREDENCIALES_CORRUPTAS // Los datos no son válidos. O alguien los alteró.';
      case 'ERROR_ABORTED_BY_USER':
        return 'AUTENTICACIÓN_CANCELADA // Casi entrabas. ¿Cambiaste de opinión?';
      case 'account-exists-with-different-credential':
        return 'COLISIÓN_DE_IDENTIDAD // Ya existe una cuenta con ese correo pero otro método. ¿Cuántas identidades tienes?';
      case 'requires-recent-login':
        return 'SESIÓN_EXPIRADA // El sistema no confía en sesiones viejas. Vuelve a autenticarte.';
      case 'email-change-needs-verification':
        return 'VERIFICACIÓN_PENDIENTE // El cambio de correo requiere confirmación. Revisa tu bandeja.';
      case 'provider-already-linked':
        return 'ENLACE_DUPLICADO // Ese proveedor ya está vinculado a tu cuenta. No puedes conectarte dos veces.';
      default:
        return 'ANOMALÍA_DESCONOCIDA // Algo falló sin dejar rastro. Inténtalo de nuevo.';
    }
  }
}
