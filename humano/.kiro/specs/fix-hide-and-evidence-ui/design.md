# Design Document

## Overview

Este diseño aborda dos problemas críticos en el juego:

1. **Crash del botón de ocultar**: El método `_handleHide()` intenta acceder a propiedades del jugador usando reflexión dinámica (`as dynamic`), lo que puede causar crashes si el jugador no está completamente inicializado o si hay problemas de sincronización.

2. **Actualización de evidencias en tiempo real**: El HUD lee `game.evidenceCollected` directamente, pero no hay un mecanismo de notificación que fuerce la reconstrucción del widget cuando este valor cambia. El widget solo se reconstruye cuando se llama explícitamente a `setState()`.

## Architecture

### Componentes Afectados

1. **ArcGameScreen** (`lib/screens/arc_game_screen.dart`)
   - Método `_handleHide()` - Necesita mejor manejo de errores y validación
   - Método `_buildGameHUD()` - Necesita mecanismo de actualización reactiva

2. **GluttonyArcGame** (`lib/game/arcs/gluttony/gluttony_arc_game.dart`)
   - Método `toggleHide()` - Ya existe pero no se está usando correctamente
   - Método `_checkEvidenceCollection()` - Necesita notificar cambios de estado

3. **BaseArcGame** (`lib/game/core/base/base_arc_game.dart`)
   - Propiedad `evidenceCollected` - Necesita callback de notificación

## Components and Interfaces

### 1. Sistema de Callbacks para Notificaciones

```dart
// En BaseArcGame
VoidCallback? onEvidenceCollectedChanged;
VoidCallback? onGameStateChanged;
```

### 2. Método Seguro para Ocultar

```dart
// En ArcGameScreen
void _handleHide() {
  if (widget.arcId != 'arc_1_gula') return;
  
  // Validación robusta
  if (game is! GluttonyArcGame) {
    debugPrint('⚠️ Game is not GluttonyArcGame');
    return;
  }
  
  final gluttonyGame = game as GluttonyArcGame;
  
  // Usar el método público en lugar de acceso directo
  gluttonyGame.toggleHide();
}
```

### 3. Actualización Reactiva del HUD

```dart
// En ArcGameScreen initState
game.onEvidenceCollectedChanged = () {
  if (mounted) {
    setState(() {
      // Forzar reconstrucción del HUD
    });
  }
};
```

## Data Models

No se requieren cambios en los modelos de datos. Los cambios son principalmente en la lógica de control y notificación.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Hide action safety
*For any* game state, when the hide button is pressed, the system should handle the action without throwing unhandled exceptions
**Validates: Requirements 1.1, 1.5**

### Property 2: Hide state consistency
*For any* player near a hiding spot, toggling hide should alternate between hidden and visible states
**Validates: Requirements 1.2, 1.3**

### Property 3: Evidence counter synchronization
*For any* evidence collection event, the HUD counter should reflect the new value within one frame update
**Validates: Requirements 2.1, 2.2**

### Property 4: UI state consistency
*For any* game state change, all UI components displaying that state should show consistent values
**Validates: Requirements 2.4, 2.5**

## Error Handling

### Hide Button Errors

1. **Null Player**: Si el jugador es null, registrar advertencia y retornar sin acción
2. **Type Mismatch**: Si el juego no es del tipo correcto, registrar advertencia y retornar
3. **Uninitialized State**: Si el juego no está inicializado, deshabilitar el botón

### Evidence Update Errors

1. **Callback Null**: Verificar que el callback existe antes de invocarlo
2. **Widget Disposed**: Verificar `mounted` antes de llamar `setState()`
3. **Concurrent Updates**: Usar sincronización apropiada para evitar condiciones de carrera

## Testing Strategy

### Unit Tests

1. **Test de manejo de errores en hide**
   - Verificar que no se lanzan excepciones con jugador null
   - Verificar que no se lanzan excepciones con tipo de juego incorrecto

2. **Test de actualización de evidencias**
   - Verificar que el callback se invoca cuando se recolecta evidencia
   - Verificar que setState se llama correctamente

### Property-Based Tests

Se utilizará el framework de testing de Flutter para las pruebas.

1. **Property Test: Hide toggle consistency**
   - Generar estados aleatorios del jugador (cerca/lejos de escondite, oculto/visible)
   - Verificar que toggle siempre produce el estado esperado

2. **Property Test: Evidence counter updates**
   - Generar secuencias aleatorias de recolección de evidencias
   - Verificar que el contador siempre refleja el número correcto

### Integration Tests

1. **Test de flujo completo de ocultar**
   - Iniciar juego
   - Mover jugador cerca de escondite
   - Presionar botón de ocultar
   - Verificar cambio de estado visual

2. **Test de flujo completo de recolección**
   - Iniciar juego
   - Recolectar evidencia
   - Verificar actualización inmediata del HUD
   - Verificar notificación visual

## Implementation Notes

### Prioridad de Cambios

1. **Alta Prioridad**: Arreglar el crash del botón de ocultar
   - Usar el método `toggleHide()` existente en lugar de acceso directo
   - Agregar validación de tipos robusta

2. **Alta Prioridad**: Implementar sistema de callbacks
   - Agregar callbacks en BaseArcGame
   - Conectar callbacks en ArcGameScreen

3. **Media Prioridad**: Optimizar actualizaciones de UI
   - Considerar usar ValueNotifier o ChangeNotifier para evitar rebuilds completos

### Consideraciones de Rendimiento

- Los callbacks deben ser ligeros y no bloquear el game loop
- Usar `setState()` solo cuando sea necesario para minimizar rebuilds
- Considerar debouncing si las actualizaciones son muy frecuentes
