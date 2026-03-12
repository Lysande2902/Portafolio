# Design Document - Firebase Authentication

## Overview

Este documento describe el diseño técnico para integrar Firebase Authentication en la aplicación Flutter "humano". La solución implementará un sistema completo de autenticación que incluye registro, inicio de sesión, cierre de sesión y persistencia de sesión, integrándose con la pantalla de autenticación existente (AuthScreen).

### Objetivos del Diseño

- Integrar Firebase Authentication de manera no invasiva con la UI existente
- Proporcionar una arquitectura limpia y mantenible usando el patrón Repository
- Gestionar estados de autenticación de forma reactiva usando Streams
- Manejar errores de manera robusta y user-friendly
- Mantener la experiencia visual única de la aplicación (tema de suspenso/horror)

## Architecture

### Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                         Presentation Layer                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ AuthScreen   │  │ HomeScreen   │  │ SplashScreen │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼──────────────┐
│         │         Business Logic Layer        │              │
│  ┌──────▼──────────────────▼──────────────────▼───────┐     │
│  │            AuthProvider (ChangeNotifier)            │     │
│  │  - authStateChanges Stream                          │     │
│  │  - currentUser                                      │     │
│  │  - isLoading                                        │     │
│  │  - errorMessage                                     │     │
│  └──────────────────────┬──────────────────────────────┘     │
│                         │                                     │
└─────────────────────────┼─────────────────────────────────────┘
                          │
┌─────────────────────────┼─────────────────────────────────────┐
│                         │      Data Layer                     │
│  ┌──────────────────────▼──────────────────────────────┐     │
│  │            AuthRepository                            │     │
│  │  - signUp(email, password)                          │     │
│  │  - signIn(email, password)                          │     │
│  │  - signOut()                                        │     │
│  │  - getCurrentUser()                                 │     │
│  │  - authStateChanges                                 │     │
│  └──────────────────────┬──────────────────────────────┘     │
│                         │                                     │
│  ┌──────────────────────▼──────────────────────────────┐     │
│  │         Firebase Authentication SDK                  │     │
│  │  - FirebaseAuth.instance                            │     │
│  └─────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Patrón de Arquitectura

Utilizaremos una arquitectura en capas con el patrón **Repository + Provider**:

1. **Presentation Layer**: Widgets de Flutter (AuthScreen, HomeScreen, etc.)
2. **Business Logic Layer**: AuthProvider (gestión de estado con ChangeNotifier)
3. **Data Layer**: AuthRepository (abstracción de Firebase Auth)

## Components and Interfaces

### 1. Firebase Configuration

**Archivo**: `lib/core/config/firebase_config.dart`

```dart
class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
```

**Responsabilidades**:
- Inicializar Firebase una sola vez al inicio de la aplicación
- Usar configuración específica de plataforma (Android/iOS)

### 2. Auth Repository

**Archivo**: `lib/data/repositories/auth_repository.dart`

```dart
abstract class AuthRepository {
  Future<UserCredential> signUp(String email, String password);
  Future<UserCredential> signIn(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
  Stream<User?> get authStateChanges;
}
```

**Implementación**: `lib/data/repositories/firebase_auth_repository.dart`

```dart
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  
  @override
  Future<UserCredential> signUp(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  @override
  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
  
  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
```

**Responsabilidades**:
- Encapsular todas las operaciones de Firebase Auth
- Proporcionar una interfaz limpia para la capa de negocio
- Facilitar testing mediante inyección de dependencias

### 3. Auth Provider

**Archivo**: `lib/providers/auth_provider.dart`

```dart
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _initAuthListener();
  }
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  // Methods
  Future<bool> signUp(String email, String password);
  Future<bool> signIn(String email, String password);
  Future<void> signOut();
  void _initAuthListener();
  void _setLoading(bool value);
  void _setError(String? message);
}
```

**Responsabilidades**:
- Gestionar el estado de autenticación de la aplicación
- Notificar a los widgets cuando cambia el estado
- Manejar la lógica de negocio (validaciones, mensajes de error)
- Escuchar cambios en el estado de autenticación de Firebase

### 4. Auth Wrapper

**Archivo**: `lib/screens/auth_wrapper.dart`

```dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return LoadingScreen();
        }
        
        if (authProvider.isAuthenticated) {
          return HomeScreen(); // Pantalla principal después del login
        }
        
        return AuthScreen();
      },
    );
  }
}
```

**Responsabilidades**:
- Decidir qué pantalla mostrar según el estado de autenticación
- Actuar como punto de entrada después del SplashScreen

### 5. Updated AuthScreen

**Modificaciones en**: `lib/screens/auth_screen.dart`

La pantalla existente se modificará para:
- Inyectar AuthProvider mediante Provider
- Llamar a métodos de AuthProvider en lugar de solo hacer print
- Mostrar mensajes de error del AuthProvider
- Mostrar indicador de carga durante operaciones
- Cambiar campos de "Usuario" y "PIN" a "Email" y "Contraseña"

## Data Models

### User Model (Firebase User)

Firebase proporciona su propio modelo `User` que incluye:

```dart
class User {
  String uid;              // ID único del usuario
  String? email;           // Email del usuario
  bool emailVerified;      // Si el email está verificado
  String? displayName;     // Nombre para mostrar (opcional)
  String? photoURL;        // URL de foto de perfil (opcional)
  // ... otros campos
}
```

No necesitamos crear un modelo personalizado inicialmente, pero podemos extenderlo en el futuro si necesitamos almacenar datos adicionales en Firestore.

### Auth Result

Para manejar resultados de autenticación de manera consistente:

```dart
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;
  
  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });
  
  factory AuthResult.success(User user) {
    return AuthResult(success: true, user: user);
  }
  
  factory AuthResult.failure(String message) {
    return AuthResult(success: false, errorMessage: message);
  }
}
```

## Error Handling

### Estrategia de Manejo de Errores

1. **Captura en Repository**: Todos los errores de Firebase se capturan en el repository
2. **Traducción de Errores**: Convertir códigos de error de Firebase a mensajes user-friendly en español
3. **Propagación**: Propagar errores al Provider
4. **Presentación**: Mostrar errores en la UI de manera consistente con el tema de la app

### Error Mapper

**Archivo**: `lib/core/utils/auth_error_mapper.dart`

```dart
class AuthErrorMapper {
  static String mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error: ${e.message ?? 'Desconocido'}';
    }
  }
}
```

### Manejo de Errores en UI

Los errores se mostrarán de dos formas:
1. **Notificaciones existentes**: Usar el sistema de notificaciones de la pantalla actual (esquina inferior izquierda)
2. **SnackBar**: Para errores críticos que requieren atención inmediata

## Testing Strategy

### Unit Tests

**Archivo**: `test/data/repositories/firebase_auth_repository_test.dart`

Probar:
- Registro exitoso
- Registro con email duplicado
- Inicio de sesión exitoso
- Inicio de sesión con credenciales incorrectas
- Cierre de sesión
- Obtención de usuario actual

**Archivo**: `test/providers/auth_provider_test.dart`

Probar:
- Estado inicial
- Cambios de estado durante operaciones
- Manejo de errores
- Listener de cambios de autenticación

### Widget Tests

**Archivo**: `test/screens/auth_screen_test.dart`

Probar:
- Renderizado de formulario de login
- Cambio entre login y registro
- Validación de campos
- Interacción con botones

### Integration Tests

**Archivo**: `integration_test/auth_flow_test.dart`

Probar:
- Flujo completo de registro
- Flujo completo de login
- Persistencia de sesión
- Cierre de sesión

## Dependencies

### Nuevas Dependencias Requeridas

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  provider: ^6.1.2

dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.13
```

### Configuración de Firebase

1. **Android**: `android/app/google-services.json`
2. **iOS**: `ios/Runner/GoogleService-Info.plist`
3. **Web**: Configuración en `web/index.html`

Estos archivos se obtienen de la consola de Firebase después de crear el proyecto.

## Navigation Flow

```
SplashScreen (3 segundos)
    │
    ▼
AuthWrapper (verifica estado de autenticación)
    │
    ├─── Si NO autenticado ──▶ AuthScreen
    │                              │
    │                              ├─ Login exitoso ──┐
    │                              │                   │
    │                              └─ Registro exitoso ┘
    │                                                   │
    └─── Si autenticado ────────────────────────────────▶ HomeScreen
                                                          │
                                                          │
                                                    Logout ──▶ AuthScreen
```

## Security Considerations

1. **Validación de Email**: Validar formato de email antes de enviar a Firebase
2. **Longitud de Contraseña**: Mínimo 6 caracteres (requisito de Firebase)
3. **No almacenar contraseñas**: Firebase maneja esto automáticamente
4. **Tokens seguros**: Firebase maneja refresh tokens automáticamente
5. **HTTPS**: Todas las comunicaciones con Firebase son sobre HTTPS
6. **Rate Limiting**: Firebase tiene rate limiting incorporado

## Performance Considerations

1. **Inicialización única**: Firebase se inicializa una sola vez en main()
2. **Lazy loading**: AuthProvider solo se crea cuando se necesita
3. **Stream eficiente**: Usar authStateChanges stream en lugar de polling
4. **Caché local**: Firebase Auth cachea tokens localmente
5. **Operaciones asíncronas**: Todas las operaciones de red son asíncronas

## Future Enhancements

Funcionalidades que se pueden agregar en el futuro:

1. **Verificación de email**: Enviar email de verificación después del registro
2. **Recuperación de contraseña**: Implementar "Olvidé mi contraseña"
3. **Autenticación social**: Google, Facebook, Apple Sign-In
4. **Perfil de usuario**: Almacenar datos adicionales en Firestore
5. **Autenticación biométrica**: Huella digital / Face ID
6. **Multi-factor authentication**: Agregar capa extra de seguridad

## Implementation Notes

### Orden de Implementación Recomendado

1. Configurar Firebase en el proyecto (Android/iOS)
2. Agregar dependencias al pubspec.yaml
3. Crear estructura de carpetas (core, data, providers)
4. Implementar AuthRepository
5. Implementar AuthProvider
6. Crear AuthWrapper
7. Modificar main.dart para inicializar Firebase
8. Actualizar AuthScreen para usar AuthProvider
9. Crear HomeScreen básico (placeholder)
10. Probar flujo completo

### Integración con Código Existente

- **SplashScreen**: Mantener como está, pero navegar a AuthWrapper en lugar de AuthScreen
- **AuthScreen**: Mantener toda la estética visual (video, glitches, notificaciones), solo cambiar la lógica de autenticación
- **LoadingScreen**: Usar durante operaciones de autenticación
- **Assets**: No se requieren cambios en assets existentes

### Consideraciones de UI/UX

- Mantener el tema oscuro y de suspenso
- Los mensajes de error deben integrarse con el sistema de notificaciones existente
- El indicador de carga debe ser consistente con el tema visual
- Transiciones suaves entre pantallas
