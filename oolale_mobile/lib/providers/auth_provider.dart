import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user.dart';
import '../services/storage_service_auth.dart';
import '../utils/error_handler.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;
  
  AuthStatus _status = AuthStatus.checking;
  User? _user;
  String? _errorMessage;
  bool _rememberMe = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;

  AuthProvider() {
    _init();
  }

  void _init() async {
    // Cargar preferencia de "Recordarme"
    _rememberMe = await StorageServiceAuth.getRememberMe();
    
    // Verificar sesión actual al inicio
    final session = _supabase.auth.currentSession;
    _updateUserFromSession(session);
    
    // Escuchar cambios
    _supabase.auth.onAuthStateChange.listen((data) {
      final sb.AuthChangeEvent event = data.event;
      final sb.Session? session = data.session;
      
      debugPrint('AUTH_PROVIDER: Evento recibido: $event');
      _updateUserFromSession(session);
    });
  }

  void setRememberMe(bool value) async {
    _rememberMe = value;
    await StorageServiceAuth.setRememberMe(value);
    notifyListeners();
  }

  void _updateUserFromSession(sb.Session? session) {
    if (session != null) {
      _user = User(
        id: session.user.id,
        email: session.user.email ?? '',
        name: session.user.userMetadata?['full_name'] ?? 'Usuario',
        isAdmin: session.user.userMetadata?['is_admin'] ?? false,
      );
      _status = AuthStatus.authenticated;
      debugPrint('AUTH_PROVIDER: Estado -> AUTHENTICATED (${_user!.email})');
    } else {
      _user = null;
      _status = AuthStatus.unauthenticated;
      debugPrint('AUTH_PROVIDER: Estado -> UNAUTHENTICATED');
    }
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final session = _supabase.auth.currentSession;
    _updateUserFromSession(session);
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('AUTH_PROVIDER: Intentando login con $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        debugPrint('AUTH_PROVIDER: Login exitoso para ${response.user!.id}');
        
        // Guardar email si "Recordarme" está activado
        if (_rememberMe) {
          await StorageServiceAuth.saveEmail(email);
          debugPrint('AUTH_PROVIDER: Email guardado para recordar');
        } else {
          await StorageServiceAuth.clearEmail();
        }
        
        // Forzamos actualización inmediata para que la UI reaccione rápido
        _updateUserFromSession(response.session);
        return true;
      }
      return false;
    } on sb.AuthException catch (e) {
      ErrorHandler.logError('AuthProvider.login', e);
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      ErrorHandler.logError('AuthProvider.login', e);
      _errorMessage = 'Ocurrió un error inesperado: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<String?> getSavedEmail() async {
    return await StorageServiceAuth.getSavedEmail();
  }

  Future<bool> register(String email, String password, String name, String rol) async {
    _status = AuthStatus.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('AUTH_PROVIDER: Registrando $email');
      debugPrint('AUTH_PROVIDER: Nombre: $name, Rol: $rol');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'rol_principal': rol,
        },
      );
      
      debugPrint('AUTH_PROVIDER: Response user: ${response.user?.id}');
      debugPrint('AUTH_PROVIDER: Response session: ${response.session != null}');
      
      if (response.user != null) {
        debugPrint('AUTH_PROVIDER: Registro exitoso para ${response.user!.id}');
        
        // Verificar si hay sesión
        if (response.session != null) {
          debugPrint('AUTH_PROVIDER: Sesión creada automáticamente');
          _updateUserFromSession(response.session);
          return true;
        } else {
          debugPrint('AUTH_PROVIDER: Usuario creado pero sin sesión (verificación de email requerida)');
          _errorMessage = 'Revisa tu correo para verificar tu cuenta';
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }
      }
      
      debugPrint('AUTH_PROVIDER: Registro falló - no se creó usuario');
      _errorMessage = 'No se pudo crear la cuenta';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on sb.AuthException catch (e) {
      ErrorHandler.logError('AuthProvider.register', e);
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      ErrorHandler.logError('AuthProvider.register', e);
      _errorMessage = 'Ocurrió un error inesperado: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    
    // Limpiar email guardado si no está "Recordarme" activado
    if (!_rememberMe) {
      await StorageServiceAuth.clearEmail();
    }
    
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }
}
