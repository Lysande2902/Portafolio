# Implementation Plan

- [x] 1. Configurar Firebase en el proyecto


  - Agregar dependencias de Firebase al pubspec.yaml (firebase_core, firebase_auth, provider)
  - Ejecutar flutter pub get para instalar las dependencias
  - Crear archivos de configuración de Firebase para Android (google-services.json) e iOS (GoogleService-Info.plist)
  - Configurar Firebase CLI y FlutterFire CLI para generar configuración automática
  - _Requirements: 5.1, 5.2, 5.4_


- [ ] 2. Crear estructura de carpetas y archivos base
  - Crear carpeta lib/core/config para configuración
  - Crear carpeta lib/core/utils para utilidades
  - Crear carpeta lib/data/repositories para repositorios
  - Crear carpeta lib/providers para providers


  - _Requirements: 5.3_

- [ ] 3. Implementar configuración de Firebase
  - Crear archivo lib/core/config/firebase_config.dart con clase FirebaseConfig




  - Implementar método initialize() para inicializar Firebase
  - Generar archivo firebase_options.dart usando FlutterFire CLI
  - _Requirements: 5.1, 5.4_



- [ ] 4. Implementar Auth Repository
- [ ] 4.1 Crear interfaz AuthRepository
  - Crear archivo lib/data/repositories/auth_repository.dart
  - Definir interfaz abstracta con métodos: signUp, signIn, signOut, getCurrentUser, authStateChanges
  - _Requirements: 1.1, 2.1, 3.1, 4.1_



- [ ] 4.2 Implementar FirebaseAuthRepository
  - Crear archivo lib/data/repositories/firebase_auth_repository.dart
  - Implementar clase FirebaseAuthRepository que extiende AuthRepository
  - Implementar método signUp con createUserWithEmailAndPassword




  - Implementar método signIn con signInWithEmailAndPassword
  - Implementar método signOut
  - Implementar getter getCurrentUser
  - Implementar stream authStateChanges
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 3.1, 3.2, 4.1, 4.5_


- [ ] 5. Implementar utilidades de manejo de errores
  - Crear archivo lib/core/utils/auth_error_mapper.dart
  - Implementar clase AuthErrorMapper con método mapFirebaseError
  - Mapear códigos de error de Firebase a mensajes en español (weak-password, email-already-in-use, invalid-email, user-not-found, wrong-password, network-request-failed, too-many-requests)
  - _Requirements: 1.3, 1.5, 2.3_

- [x] 6. Implementar Auth Provider


- [ ] 6.1 Crear clase AuthProvider base
  - Crear archivo lib/providers/auth_provider.dart
  - Crear clase AuthProvider que extiende ChangeNotifier
  - Definir propiedades privadas: _currentUser, _isLoading, _errorMessage
  - Implementar getters: currentUser, isLoading, errorMessage, isAuthenticated
  - Implementar constructor con inyección de AuthRepository


  - _Requirements: 2.2, 4.1_

- [ ] 6.2 Implementar métodos de autenticación en AuthProvider
  - Implementar método signUp que llama al repository y maneja estados
  - Implementar método signIn que llama al repository y maneja estados


  - Implementar método signOut que llama al repository y limpia estado
  - Implementar método privado _initAuthListener para escuchar cambios de autenticación
  - Implementar métodos privados _setLoading y _setError para gestión de estado
  - Agregar manejo de errores usando AuthErrorMapper
  - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.1, 2.2, 2.3, 3.1, 3.2, 4.1, 4.4, 4.5_

- [x] 7. Crear AuthWrapper para navegación condicional


  - Crear archivo lib/screens/auth_wrapper.dart
  - Implementar widget AuthWrapper que usa Consumer<AuthProvider>
  - Mostrar LoadingScreen cuando isLoading es true




  - Mostrar HomeScreen cuando isAuthenticated es true
  - Mostrar AuthScreen cuando no está autenticado
  - _Requirements: 2.4, 4.2, 4.3_

- [ ] 8. Crear HomeScreen placeholder
  - Crear archivo lib/screens/home_screen.dart
  - Implementar HomeScreen básico con AppBar y botón de logout

  - Agregar Consumer<AuthProvider> para acceder al método signOut
  - Implementar botón que llama a authProvider.signOut()
  - _Requirements: 2.4, 3.3_

- [ ] 9. Actualizar main.dart para inicializar Firebase
  - Importar Firebase y configuración necesaria




  - Hacer main() async
  - Llamar a WidgetsFlutterBinding.ensureInitialized()
  - Llamar a FirebaseConfig.initialize() antes de runApp
  - Envolver MyApp con MultiProvider incluyendo AuthProvider
  - Cambiar home de MyApp para usar AuthWrapper en lugar de SplashScreen directamente
  - _Requirements: 5.1, 5.3, 5.4_

- [ ] 10. Actualizar SplashScreen para navegar a AuthWrapper
  - Modificar lib/screens/splash_screen.dart
  - Cambiar navegación para ir a AuthWrapper en lugar de AuthScreen
  - _Requirements: 4.2, 4.3_

- [ ] 11. Actualizar AuthScreen para usar AuthProvider
- [ ] 11.1 Modificar campos de entrada
  - Cambiar label de "Usuario" a "Correo Electrónico"
  - Cambiar label de "PIN" a "Contraseña"
  - Cambiar keyboardType del campo de email a TextInputType.emailAddress
  - Cambiar campo de contraseña para aceptar texto en lugar de solo números
  - Agregar validación de formato de email
  - Agregar validación de longitud mínima de contraseña (6 caracteres)
  - _Requirements: 1.4_

- [ ] 11.2 Integrar AuthProvider en AuthScreen
  - Agregar Consumer<AuthProvider> o Provider.of<AuthProvider> en el widget
  - Modificar método _authenticate para llamar a authProvider.signUp o authProvider.signIn según _authMode
  - Mostrar indicador de carga cuando authProvider.isLoading es true
  - Mostrar mensajes de error usando el sistema de notificaciones existente cuando authProvider.errorMessage no es null
  - Limpiar errorMessage después de mostrar notificación
  - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.1, 2.3, 2.4, 3.1_

- [ ] 12. Probar flujo completo de autenticación
  - Ejecutar la aplicación en un dispositivo o emulador
  - Probar registro de nuevo usuario con email y contraseña válidos
  - Verificar que después del registro se navega automáticamente a HomeScreen
  - Probar cierre de sesión desde HomeScreen
  - Probar inicio de sesión con credenciales existentes
  - Probar manejo de errores (email duplicado, contraseña incorrecta, email inválido)
  - Verificar persistencia de sesión cerrando y reabriendo la app
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4_
