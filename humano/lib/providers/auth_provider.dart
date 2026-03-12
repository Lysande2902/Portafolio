import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';
import '../core/utils/auth_error_mapper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _isLoading = true; // Iniciar en estado de carga para esperar a Firebase
    _initAuthListener();
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _initAuthListener() {
    _authRepository.authStateChanges.listen((User? user) {
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authRepository.signUp(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthErrorMapper.mapFirebaseError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('SEÑAL_PERDIDA // El intento de acceso no llegó al servidor. Verifica tu conexión.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authRepository.signIn(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthErrorMapper.mapFirebaseError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('SEÑAL_PERDIDA // El intento de acceso no llegó al servidor. Verifica tu conexión.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authRepository.signInWithGoogle();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ERROR_ABORTED_BY_USER') {
        _setError('Inicio de sesión cancelado');
      } else {
        _setError(AuthErrorMapper.mapFirebaseError(e));
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('AUTENTICACIÓN_EXTERNA_FALLIDA // Google no respondió como se esperaba. ¿Estás conectado?');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authRepository.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError('CIERRE_DE_SESIÓN_FALLIDO // La desconexión no fue limpia. Vuelve a intentarlo.');
      _setLoading(false);
    }
  }

  /// Refresca el usuario actual desde Firebase
  Future<void> refreshUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        _currentUser = FirebaseAuth.instance.currentUser;
        notifyListeners();
      }
    } catch (e) {
      _setError('SINCRONIZACIÓN_FALLIDA // No se pudo actualizar el estado del sujeto.');
    }
  }
}
