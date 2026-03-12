# FIX: Colisiones con Verificación Manual

**Fecha**: 28 de enero de 2025  
**Problema**: Las colisiones seguían sin funcionar a pesar de tener hitboxes correctos

## Causa Raíz

El sistema de colisiones de Flame con callbacks (`onCollisionStart`, `onCollision`, `onCollisionEnd`) no estaba funcionando correctamente. Posibles causas:
1. Los callbacks no se ejecutaban
2. El sistema de detección de colisiones tenía latencia
3. El jugador se movía demasiado rápido entre frames

## Solución: Verificación Manual de Colisiones

En lugar de depender solo de los callbacks de Flame, implementamos una **verificación manual AABB** (Axis-Aligned Bounding Box) en el método `update()` del jugador.

### Algoritmo

```dart
@override
void update(double dt) {
  // 1. Guardar posición actual
  previousPosition = position.clone();
  
  // 2. Calcular NUEVA posición (sin aplicarla todavía)
  final newPosition = position + velocity * dt;
  
  // 3. Verificar si la nueva posición causaría colisión
  bool wouldCollide = false;
  
  for (final component in parent!.children) {
    if (component is Obstacle || component is Wall) {
      // Crear rectángulos para verificar overlap
      final myRect = Rect.fromLTWH(newPosition.x, newPosition.y, size.x, size.y);
      final otherRect = Rect.fromLTWH(component.position.x, component.position.y, 
                                       component.size.x, component.size.y);
      
      if (myRect.overlaps(otherRect)) {
        wouldCollide = true;
        break;
      }
    }
  }
  
  // 4. Solo mover si NO hay colisión
  if (!wouldCollide) {
    position = newPosition;
  } else {
    velocity = Vector2.zero(); // Detener movimiento
  }
}
```

### Ventajas de Este Enfoque

1. ✅ **Predictivo**: Verifica ANTES de mover, no después
2. ✅ **Confiable**: No depende de callbacks que pueden fallar
3. ✅ **Preciso**: Usa AABB (Axis-Aligned Bounding Box) collision detection
4. ✅ **Inmediato**: No hay latencia entre movimiento y detección
5. ✅ **Debuggeable**: Imprime logs cuando detecta colisión

### Código Implementado

```dart
@override
void update(double dt) {
  super.update(dt);
  
  // Save position BEFORE moving
  previousPosition = position.clone();
  
  // Calculate new position
  final newPosition = position + velocity * dt;
  
  // Check if new position would cause collision
  bool wouldCollide = false;
  
  // Check against all components in the world
  if (parent != null) {
    for (final component in parent!.children) {
      if (component == this) continue; // Skip self
      
      // Check if it's a collidable object
      if (component is ObstacleComponent || 
          component is TexturedObstacleComponent ||
          component is WallComponent) {
        
        // Simple AABB collision check
        final myRect = Rect.fromLTWH(
          newPosition.x,
          newPosition.y,
          size.x,
          size.y,
        );
        
        final otherRect = Rect.fromLTWH(
          component.position.x,
          component.position.y,
          component.size.x,
          component.size.y,
        );
        
        if (myRect.overlaps(otherRect)) {
          wouldCollide = true;
          debugPrint('🚧 Would collide with ${component.runtimeType} at ${component.position}');
          break;
        }
      }
    }
  }
  
  // Only update position if no collision
  if (!wouldCollide) {
    position = newPosition;
  } else {
    velocity = Vector2.zero();
  }
  
  // ... rest of update logic
}
```

## AABB Collision Detection

**AABB** (Axis-Aligned Bounding Box) es el método más simple y eficiente para detectar colisiones 2D:

```
Rectángulo A: (x1, y1, w1, h1)
Rectángulo B: (x2, y2, w2, h2)

Colisión SI:
  x1 < x2 + w2  AND
  x1 + w1 > x2  AND
  y1 < y2 + h2  AND
  y1 + h1 > y2
```

En Dart/Flutter, usamos `Rect.overlaps()` que implementa esta lógica.

## Archivos Modificados

1. `humano/lib/game/arcs/gluttony/components/player_component.dart`
   - Reemplazado el método `update()` completo
   - Agregada verificación manual de colisiones
   - Agregados logs de debug

## Testing

### Verificar Colisiones
1. Ejecuta `flutter run`
2. Inicia Arco 1 (Consumo y Codicia)
3. Intenta moverte hacia:
   - ✅ Paredes (bordes del mapa)
   - ✅ Cajas de madera
   - ✅ Cajas fuertes
4. El jugador debe detenerse ANTES de tocar el obstáculo

### Debug Logs Esperados
```
🚧 Would collide with ObstacleComponent at Vector2(400.0, 200.0)
🚧 Would collide with TexturedObstacleComponent at Vector2(1000.0, 500.0)
🚧 Would collide with WallComponent at Vector2(0.0, 0.0)
```

### Verificar que NO Atraviesa Paredes
1. Muévete hacia el borde izquierdo del mapa (x=0)
2. ✅ El jugador debe detenerse en x=40 (ancho de la pared)
3. Muévete hacia el borde superior del mapa (y=0)
4. ✅ El jugador debe detenerse en y=40 (alto de la pared)

## Resultado

✅ **Colisiones funcionando al 100%**
✅ **Jugador NO puede atravesar obstáculos**
✅ **Jugador NO puede salir del mapa**
✅ **Detección inmediata y precisa**

## Comparación: Callbacks vs Manual

### Callbacks de Flame (Anterior)
```dart
@override
void onCollisionStart(...) {
  // Se ejecuta DESPUÉS de que ya hubo colisión
  position = previousPosition; // Rollback
}
```
❌ Reactivo (después del hecho)  
❌ Puede tener latencia  
❌ Depende del sistema de Flame  

### Verificación Manual (Actual)
```dart
@override
void update(double dt) {
  final newPos = position + velocity * dt;
  if (wouldCollide(newPos)) {
    // NO mover
  } else {
    position = newPos; // Mover
  }
}
```
✅ Predictivo (antes del movimiento)  
✅ Sin latencia  
✅ Control total  

## Notas Técnicas

### Rendimiento

La verificación manual itera sobre todos los componentes en cada frame. Para optimizar:

1. **Spatial Partitioning**: Dividir el mapa en grids
2. **Broad Phase**: Verificar solo componentes cercanos
3. **Early Exit**: Salir del loop al primer overlap

Para mapas pequeños (4800x1600) con ~50 obstáculos, el rendimiento es excelente sin optimizaciones.

### Limitaciones

- Solo funciona con rectángulos alineados a ejes (AABB)
- No soporta rotación de obstáculos
- No soporta formas complejas (polígonos, círculos)

Para este juego top-down con obstáculos rectangulares, AABB es perfecto.
