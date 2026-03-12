# Implementation Plan

- [ ] 1. Configurar dependencias y assets
  - Agregar dependencias `video_player` y `google_fonts` al pubspec.yaml
  - Registrar el video en la sección de assets del pubspec.yaml
  - Ejecutar `flutter pub get` para instalar las dependencias
  - _Requirements: 3.1, 3.2_

- [ ] 2. Rediseñar SplashScreen con fondo blanco y tipografía elegante
  - Cambiar el fondo de negro a blanco en el Scaffold
  - Implementar Google Font (Playfair Display o Cormorant Garamond) para el texto "The Quiescent Heart"
  - Ajustar el tamaño del logo a 120-150px
  - Ajustar el tamaño de fuente a 28-32px
  - Implementar transición fade hacia LoadingScreen usando PageRouteBuilder
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 5.1_

- [ ] 3. Implementar LoadingScreen con animación de corazón giratorio
  - Crear AnimationController con duración de 2 segundos y repeat infinito
  - Implementar RotationTransition para rotar el logo del corazón 360 grados
  - Remover el fondo de imagen estática y usar fondo neutro
  - Remover el texto "Cargando..." y el CircularProgressIndicator
  - Implementar transición fade hacia AuthScreen usando PageRouteBuilder
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 5.2_

- [ ] 4. Implementar video de fondo en AuthScreen
  - Inicializar VideoPlayerController con el archivo de video
  - Configurar el video para reproducirse en bucle (setLooping)
  - Configurar el video sin audio (setVolume 0.0)
  - Implementar VideoPlayer widget como fondo en un Stack
  - Configurar BoxFit.cover para que el video llene la pantalla
  - Manejar el estado de inicialización del video con _isVideoInitialized
  - _Requirements: 3.1, 3.2, 3.4, 3.5_

- [ ] 5. Aplicar overlay oscuro y optimizar formularios
  - Aplicar Container con Colors.black.withOpacity(0.6) sobre el video
  - Verificar que los formularios de login/registro tengan suficiente contraste
  - Implementar fade-in animation para los formularios (300ms)
  - Implementar animación suave al cambiar entre Login/SignUp (200ms)
  - _Requirements: 3.3, 4.1, 4.2, 4.3, 4.4_

- [ ] 6. Implementar manejo de errores para video y assets
  - Agregar catchError al inicializar VideoPlayerController
  - Implementar fallback visual si el video no carga (imagen estática o degradado)
  - Agregar logging de errores para debugging
  - Verificar que la app continúe funcionando si hay errores de carga
  - _Requirements: 3.1, 4.3_

- [ ] 7. Optimizar rendimiento y accesibilidad
  - Agregar RepaintBoundary alrededor de animaciones costosas
  - Agregar semantic labels a widgets interactivos
  - Verificar contraste de texto (mínimo 4.5:1)
  - Asegurar que formularios sean navegables con screen readers
  - _Requirements: 4.1, 4.2, 5.3_

- [ ] 8. Crear tests para el flujo de autenticación
  - Escribir widget tests para SplashScreen verificando logo y texto
  - Escribir widget tests para LoadingScreen verificando animación
  - Escribir widget tests para AuthScreen verificando formularios
  - Escribir integration test para el flujo completo de navegación
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 3.1, 4.1_
