# Design Document

## Overview

Este documento describe el diseño técnico para rediseñar el flujo de autenticación de "The Quiescent Heart". El diseño incluye tres pantallas principales con transiciones suaves y elementos visuales elegantes que reflejan la identidad de marca de la aplicación.

## Architecture

### Screen Flow

```
SplashScreen (2-3s) → LoadingScreen (animación) → AuthScreen (video background)
```

### Component Hierarchy

```
MyApp (MaterialApp)
└── SplashScreen
    └── LoadingScreen
        └── AuthScreen
```

### Key Design Decisions

1. **Video Background**: Usar el paquete `video_player` de Flutter para reproducir el video de fondo en bucle
2. **Typography**: Usar Google Fonts (específicamente la fuente "Playfair Display" o "Cormorant Garamond") para el nombre de la empresa
3. **Animations**: Usar `AnimationController` y `RotationTransition` para la animación del corazón giratorio
4. **Transitions**: Usar `PageRouteBuilder` con `FadeTransition` para transiciones suaves entre pantallas
5. **Video Overlay**: Usar `Container` con `Colors.black.withOpacity(0.6)` para oscurecer el video

## Components and Interfaces

### 1. SplashScreen

**Purpose**: Mostrar el branding inicial de la aplicación con fondo blanco y tipografía elegante.

**Key Properties**:
- Background: `Colors.white`
- Logo: `assets/images/heart.png` (tamaño: 120-150px)
- Typography: Google Font elegante, tamaño 28-32px
- Duration: 2.5 segundos

**Implementation Details**:
```dart
class SplashScreen extends StatefulWidget
├── Timer para navegación automática (2.5s)
├── Scaffold con fondo blanco
└── Column centrada
    ├── Image.asset (heart.png)
    ├── SizedBox (spacing)
    └── Text con Google Font
```

**Transition**: Fade out hacia LoadingScreen usando `PageRouteBuilder`

### 2. LoadingScreen

**Purpose**: Mostrar animación de carga con el corazón girando mientras se inicializan recursos.

**Key Properties**:
- Background: Fondo neutro (gris claro o blanco)
- Animation: Corazón rotando 360° cada 2 segundos
- Duration: Hasta que se complete la inicialización (mínimo 1.5s)

**Implementation Details**:
```dart
class LoadingScreen extends StatefulWidget
├── AnimationController (duration: 2s, repeat)
├── RotationTransition
└── Center
    └── AnimatedBuilder
        └── Transform.rotate (heart.png)
```

**Animation Specs**:
- Rotation: 0 to 2π radianes
- Curve: `Curves.linear`
- Repeat: Infinito hasta navegación

**Transition**: Fade out hacia AuthScreen usando `PageRouteBuilder`

### 3. AuthScreen

**Purpose**: Pantalla de autenticación con video de fondo oscurecido y formularios de login/registro.

**Key Properties**:
- Background: Video en bucle con overlay oscuro
- Video: `assets/videos/Whisk_gto5q2y1ujmhzdn00so3ydotumn2qtlyqzyx0yy.mp4`
- Overlay opacity: 0.6
- Forms: Login y Sign Up con campos de usuario y PIN

**Implementation Details**:
```dart
class AuthScreen extends StatefulWidget
├── VideoPlayerController (looping, muted)
├── Stack
    ├── VideoPlayer (positioned fill)
    ├── Container (overlay oscuro)
    └── Center
        └── SingleChildScrollView
            └── Form widgets
```

**Video Configuration**:
- Looping: `setLooping(true)`
- Muted: `setVolume(0.0)`
- Auto-play: `initialize().then(() => play())`
- Aspect ratio: `BoxFit.cover` para llenar pantalla

**Subtle Animations**:
- Fade in de formularios al cargar (300ms)
- Animación suave al cambiar entre Login/SignUp (200ms)
- Opcional: Partículas flotantes sutiles usando `AnimatedPositioned`

## Data Models

### AuthMode Enum
```dart
enum AuthMode {
  Login,
  SignUp
}
```

### Screen State Management

**SplashScreen**:
- No state management necesario (solo Timer)

**LoadingScreen**:
- `AnimationController _controller`
- `Animation<double> _animation`

**AuthScreen**:
- `VideoPlayerController _videoController`
- `AuthMode _authMode`
- `TextEditingController _usernameController`
- `TextEditingController _pinController`
- `bool _isVideoInitialized`

## Error Handling

### Video Loading Errors

**Scenario**: El video no se puede cargar o reproducir

**Handling**:
1. Mostrar un fondo de respaldo (imagen estática o color degradado)
2. Log del error para debugging
3. Continuar con la funcionalidad de autenticación

```dart
_videoController.initialize().catchError((error) {
  setState(() {
    _isVideoInitialized = false;
  });
  print('Error loading video: $error');
});
```

### Asset Loading Errors

**Scenario**: El logo o imágenes no se cargan

**Handling**:
1. Usar un placeholder o icono de Flutter
2. Log del error
3. Continuar con el flujo

### Navigation Errors

**Scenario**: Error al navegar entre pantallas

**Handling**:
1. Catch exceptions en Navigator
2. Mostrar mensaje de error al usuario
3. Intentar navegación alternativa

## Testing Strategy

### Unit Tests

1. **Timer Tests**: Verificar que los timers de navegación funcionen correctamente
2. **Animation Tests**: Verificar que las animaciones se inicialicen y ejecuten
3. **Form Validation**: Verificar validación de campos de usuario y PIN

### Widget Tests

1. **SplashScreen**: Verificar que muestre logo y texto correctamente
2. **LoadingScreen**: Verificar que la animación de rotación funcione
3. **AuthScreen**: Verificar que los formularios se rendericen y cambien entre modos

### Integration Tests

1. **Full Flow**: Verificar navegación completa desde Splash hasta Auth
2. **Video Playback**: Verificar que el video se reproduzca en bucle
3. **Form Submission**: Verificar que los formularios envíen datos correctamente

## Dependencies Required

```yaml
dependencies:
  flutter:
    sdk: flutter
  video_player: ^2.8.0  # Para reproducir video de fondo
  google_fonts: ^6.1.0  # Para tipografía elegante
```

## Implementation Notes

### Performance Considerations

1. **Video Memory**: El video debe ser optimizado para móviles (resolución y bitrate apropiados)
2. **Animation Performance**: Usar `RepaintBoundary` para aislar animaciones costosas
3. **Asset Preloading**: Precargar assets críticos durante el SplashScreen

### Accessibility

1. **Semantic Labels**: Agregar labels semánticos a todos los widgets interactivos
2. **Contrast Ratio**: Asegurar contraste suficiente (mínimo 4.5:1) entre texto y fondo
3. **Screen Reader**: Asegurar que los formularios sean navegables con screen readers

### Platform Considerations

1. **iOS**: Verificar permisos de video en Info.plist si es necesario
2. **Android**: Verificar permisos en AndroidManifest.xml
3. **Web**: Considerar fallback para video (puede no funcionar en todos navegadores)
