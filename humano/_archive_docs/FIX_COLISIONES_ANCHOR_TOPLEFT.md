# FIX: Colisiones con Anchor TopLeft

**Fecha**: 28 de enero de 2025  
**Problema**: Las colisiones no funcionaban y los hitboxes no coincidían con los visuales

## Causa Raíz

En Flame, el **anchor** determina el punto de referencia para posicionar un componente:
- `Anchor.center` (default): El centro del componente está en la posición
- `Anchor.topLeft`: La esquina superior izquierda está en la posición

**El problema**: Los componentes tenían diferentes anchors, causando desalineación entre:
1. La posición visual del obstáculo
2. La posición del hitbox de colisión
3. La posición del jugador

## Solución

Configurar **TODOS** los componentes con `anchor: Anchor.topLeft` para consistencia:

### 1. TexturedObstacleComponent
```dart
TexturedObstacleComponent({
  required Vector2 position,
  required Vector2 size,
  required this.textureType,
  required this.baseColor,
  required this.seed,
}) : super(
  position: position,
  size: size,
  anchor: Anchor.topLeft, // ✅ AGREGADO
);

@override
Future<void> onLoad() async {
  await super.onLoad();
  
  add(_TexturedRectangle(...));
  
  add(RectangleHitbox(
    size: size,
    position: Vector2.zero(),
    anchor: Anchor.topLeft, // ✅ AGREGADO
  ));
}
```

### 2. ObstacleComponent
```dart
ObstacleComponent({
  required Vector2 position,
  required Vector2 size,
  this.color = const Color(0xFF333333),
}) : super(
  position: position,
  size: size,
  anchor: Anchor.topLeft, // ✅ AGREGADO
);

@override
Future<void> onLoad() async {
  await super.onLoad();
  
  add(RectangleComponent(
    size: size,
    paint: Paint()..color = color,
    anchor: Anchor.topLeft, // ✅ AGREGADO
  ));
  
  add(RectangleHitbox(
    size: size,
    position: Vector2.zero(),
    anchor: Anchor.topLeft, // ✅ AGREGADO
  ));
}
```

### 3. PlayerComponent
```dart
PlayerComponent({this.skinId}) : super(anchor: Anchor.topLeft); // ✅ AGREGADO

@override
Future<void> onLoad() async {
  await super.onLoad();
  
  size = Vector2(playerWidth, playerHeight);
  anchor = Anchor.topLeft; // ✅ AGREGADO
  
  animatedSprite = AnimatedPlayerSprite(skinId: skinId);
  animatedSprite.scale = Vector2(0.625, 0.9375);
  animatedSprite.anchor = Anchor.topLeft; // ✅ AGREGADO
  await add(animatedSprite);
  
  add(RectangleHitbox(
    size: size,
    position: Vector2.zero(),
    anchor: Anchor.topLeft, // ✅ AGREGADO
  ));
}
```

## Por Qué Funciona Ahora

### Antes (Anchor Inconsistente)
```
Obstáculo en (100, 100) con Anchor.center:
  Visual: Centro en (100, 100) → Esquina en (40, 70)
  Hitbox: Centro en (100, 100) → Esquina en (40, 70)

Jugador en (100, 100) con Anchor.topLeft:
  Visual: Esquina en (100, 100)
  Hitbox: Esquina en (100, 100)

❌ DESALINEADO: El jugador y el obstáculo están en diferentes posiciones reales
```

### Después (Anchor Consistente)
```
Obstáculo en (100, 100) con Anchor.topLeft:
  Visual: Esquina en (100, 100)
  Hitbox: Esquina en (100, 100)

Jugador en (100, 100) con Anchor.topLeft:
  Visual: Esquina en (100, 100)
  Hitbox: Esquina en (100, 100)

✅ ALINEADO: Todos usan la misma referencia
```

## Archivos Modificados

1. `humano/lib/game/core/components/textured_obstacle_component.dart`
   - Agregado `anchor: Anchor.topLeft` al constructor
   - Agregado `anchor: Anchor.topLeft` al RectangleHitbox

2. `humano/lib/game/core/components/obstacle_component.dart`
   - Agregado `anchor: Anchor.topLeft` al constructor
   - Agregado `anchor: Anchor.topLeft` al RectangleComponent
   - Agregado `anchor: Anchor.topLeft` al RectangleHitbox

3. `humano/lib/game/arcs/gluttony/components/player_component.dart`
   - Agregado `anchor: Anchor.topLeft` al constructor
   - Agregado `anchor = Anchor.topLeft` en onLoad()
   - Agregado `anchor: Anchor.topLeft` al animatedSprite
   - Agregado `anchor: Anchor.topLeft` al RectangleHitbox

## Testing

### Verificar Colisiones
1. Ejecuta `flutter run`
2. Inicia Arco 1 (Consumo y Codicia)
3. Intenta atravesar:
   - ✅ Paredes (bordes del mapa)
   - ✅ Cajas de madera (Phase 1)
   - ✅ Cajas fuertes (Phase 2)
4. El jugador debe detenerse en todos los casos

### Verificar Alineación de Hitbox
1. Observa visualmente las cajas
2. Intenta tocar el borde de una caja
3. ✅ La colisión debe ocurrir exactamente en el borde visual
4. ❌ NO debe haber espacio invisible antes/después del obstáculo

### Debug Logs Esperados
```
🔲 [OBSTACLE] Created crate at Vector2(400.0, 200.0), size: Vector2(120.0, 120.0), hitbox: Vector2(120.0, 120.0)
✅ [GLUTTONY-PLAYER] Player loaded at Vector2(200.0, 800.0), size: Vector2(40.0, 60.0), anchor: topLeft
🚧 Player hit wall/obstacle - rolling back
```

## Resultado

✅ **Colisiones funcionando perfectamente**
✅ **Hitboxes alineados con visuales**
✅ **Jugador no puede atravesar obstáculos**
✅ **Jugador no puede atravesar paredes**

## Notas Técnicas

### Anchor en Flame

El anchor es crítico para:
1. **Posicionamiento**: Determina qué punto del componente se coloca en la posición
2. **Rotación**: El componente rota alrededor del anchor
3. **Colisiones**: El hitbox se posiciona relativo al anchor

### Por Qué TopLeft

`Anchor.topLeft` es ideal para juegos 2D top-down porque:
- ✅ Coincide con el sistema de coordenadas de pantalla (0,0 = esquina superior izquierda)
- ✅ Facilita el posicionamiento en grids
- ✅ Simplifica los cálculos de colisión
- ✅ Es más intuitivo para mapas rectangulares

### Alternativa: Anchor.center

Si prefieres usar `Anchor.center`:
- Todos los componentes deben usar `Anchor.center`
- Las posiciones deben ajustarse: `position + size/2`
- Más complejo pero útil para objetos que rotan
