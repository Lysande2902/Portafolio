import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../config/constants.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthStatus _status = AuthStatus.checking;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _apiService.getToken();
    if (token == null) {
      _logoutLocal();
      return;
    }

    try {
      // Validar token intentando obtener perfil básico o ping de auth
      // Como no tenemos endpoint de "me" específico documentado rápido, 
      // asumiremos que si hay token intentamos loguear con lo que tenemos persistido
      // O idealmente, hacemos un GET /api/usuarios/perfil si existiera.
      // Por ahora, asumiremos 'authenticated' si hay token, pero lo ideal es validar.
      
      // Simulación de "Check Token":
      // Si el backend tuviera endpoint de validar token: await _apiService.get('/auth/check');
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      
    } catch (e) {
      _logoutLocal();
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.checking;
    _errorMessage = null;
    notifyListeners();

    print('AUTH: Iniciando login para $email en ${AppConstants.baseUrl}');
    try {
      final dynamic response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password
      });
      print('AUTH: Respuesta del servidor recibida: $response');

      if (response is Map && (response['token'] != null || response['success'] == true)) {
        final token = response['token'];
        if (token != null) await _apiService.setToken(token);
        
        final userData = response['user'] ?? response['usuario'];
        print('AUTH: Datos de usuario: $userData');
        
        if (userData != null) {
          final normalizedData = {
            'id_usuario': userData['id'] ?? userData['id_usuario'] ?? 0,
            'correo_electronico': userData['email'] ?? userData['correo_electronico'] ?? email,
            'nombre_completo': userData['name'] ?? userData['nombre_completo'] ?? 'Demo User',
          };
          _user = User.fromJson(normalizedData);
        } else {
          _user = User(id: 0, email: email, name: 'Demo User');
        }
        _status = AuthStatus.authenticated;
        print('AUTH: Login exitoso, redirigiendo...');
        notifyListeners();
        return true;
      } else {
        print('AUTH: Login fallido - Sin token');
        _errorMessage = 'Respuesta inválida del servidor';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AUTH ERROR: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _status = AuthStatus.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'fullName': name
      });

      // Si el registro es exitoso, intentamos loguear automáticamente
      return await login(email, password);

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.removeToken();
    _logoutLocal();
  }

  void _logoutLocal() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }
}
