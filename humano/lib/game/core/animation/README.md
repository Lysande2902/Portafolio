# Player Animation System

Sistema de animación para el personaje jugador usando sprites LPC (Liberated Pixel Cup).

## Estructura

### Archivos

- **player_animation_types.dart**: Define enums y tipos de datos para el sistema de animación
- **animated_player_sprite.dart**: Componente que maneja la carga y renderizado de animaciones

### Componentes

#### PlayerAnimationState
Estados de animación disponibles:
- `idle`: Personaje quieto
- `walk`: Personaje caminando
- `run`: Personaje corriendo (futuro)

#### PlayerDirection
Direcciones que el personaje puede mirar:
- `up`: Arriba (fila 0 del spritesheet)
- `left`: Izquierda (fila 1 del spritesheet)
- `down`: Abajo (fila 2 del spritesheet)
- `right`: Derecha (fila 3 del spritesheet)

## Uso

### En PlayerComponent

```dart
// Crear el sprite animado
animatedSprite = AnimatedPlayerSprite();
await add(animatedSprite);

// Actualizar animación basada en movimiento
void _updateAnimationState() {
  final newState = isMoving ? PlayerAnimationState.walk : PlayerAnimationState.idle;
  final newDirection = _getDirectionFromVelocity();
  animatedSprite.updateAnimationState(newState, newDirection);
}
```

## Assets

Los sprites deben estar en:
```
assets/images/animations/lpc_male_animations_2025-11-14T19-18-55/standard/
├── idle.png
├── walk.png
└── run.png
```

**Nota**: Flame busca automáticamente en `assets/images/` por lo que la ruta en el código es `animations/lpc_male_animations_2025-11-14T19-18-55/standard/`

Cada spritesheet tiene:
- 4 filas (una por dirección)
- Múltiples columnas (frames de animación)
- Tamaño de frame: 64x64 pixels

## Configuración

### Velocidad de Animación

Ajustar en `AnimationConfig`:
```dart
stepTime: 0.125  // 8 FPS para walk
stepTime: 0.1    // 10 FPS para run
```

### Tamaño del Sprite

Ajustar en `PlayerComponent.onLoad()`:
```dart
animatedSprite.scale = Vector2(0.625, 0.9375);
```

## Fallback

Si los assets no se cargan, el sistema usa automáticamente un rectángulo de color como fallback visual.

## Performance

- Los sprites se cachean automáticamente por Flame
- Las animaciones solo se actualizan cuando cambia el estado
- Optimizado para mantener 60 FPS

## Debug

Descomentar en `PlayerComponent._updateAnimationState()`:
```dart
print('🎬 Animation: ${newState.name} ${newDirection.name}');
```

O usar:
```dart
print(animatedSprite.getDebugInfo());
```
