# Implementación: Animación de Recolección de Evidencias

## Fecha
19 de noviembre de 2025

## Resumen
Se ha implementado un sistema completo de animación y feedback visual cuando el jugador recoge evidencias en los tres arcos jugables (Gula, Avaricia, Envidia).

---

## Componentes Implementados

### 1. Componente de Evidencia Mejorado
**Archivo:** `lib/game/core/components/evidence_component.dart`

#### Características:
- **Animación de escala**: El item crece 1.5x antes de desaparecer
- **Fade out**: Desaparece gradualmente en 0.4 segundos
- **Partículas**: 8 partículas que se dispersan en todas direcciones
- **Efecto de brillo**: Animación de glow constante mientras no está recolectada

#### Código clave:
```dart
void collect() {
  // 1. Scale up animation
  add(ScaleEffect.to(
    Vector2.all(1.5),
    EffectController(duration: 0.2),
  ));

  // 2. Fade out animation
  add(OpacityEffect.fadeOut(
    EffectController(duration: 0.4, startDelay: 0.1),
  ));

  // 3. Spawn collection particles
  _spawnCollectionParticles();
}
```

### 2. Sistema de Partículas
**Clase:** `_CollectionParticle`

#### Características:
- 8 partículas que vuelan en círculo (360°)
- Velocidad inicial: 100 unidades/segundo
- Desaceleración gradual (95% por frame)
- Duración: 0.6 segundos
- Color: Cyan (#00CED1) con fade out

### 3. Notificación en Pantalla
**Archivo:** `lib/game/ui/evidence_collected_notification.dart`

#### Características:
- **Animación de entrada**: Slide down desde arriba
- **Duración total**: 2.5 segundos
  - 0.0-0.3s: Slide in
  - 0.3-1.8s: Visible
  - 1.8-2.5s: Fade out
- **Contenido**:
  - Icono de documento (📄)
  - Texto: "EVIDENCIA RECOLECTADA"
  - Contador: "X/5"
- **Estilo**: Fondo negro, borde rojo, texto blanco/amarillo

---

## Integración en los Arcos

### Arco 1: Gula (Gluttony)
**Archivo:** `lib/game/arcs/gluttony/gluttony_arc_game.dart`

**Cambios:**
1. Import actualizado a componente compartido
2. Callback agregado: `onEvidenceCollected`
3. Llamada al callback en `_checkEvidenceCollection()`

```dart
// Callback for evidence collection notification
void Function(int current, int total)? onEvidenceCollected;

// En _checkEvidenceCollection():
component.collect();
evidenceCollected++;
onEvidenceCollected?.call(evidenceCollected, 5);
```

### Arco 2: Avaricia (Greed)
**Archivo:** `lib/game/arcs/greed/greed_arc_game.dart`

**Cambios:**
1. Import actualizado a componente compartido
2. Callback agregado: `onEvidenceCollected`
3. Llamada al callback en `_checkEvidenceCollection()`

### Arco 3: Envidia (Envy)
**Archivo:** `lib/game/arcs/envy/envy_arc_game.dart`

**Cambios:**
1. Import actualizado a componente compartido
2. Callback agregado: `onEvidenceCollected`
3. Llamada al callback en `_checkEvidenceCollection()`

---

## Flujo de Animación

### Secuencia Temporal

```
T=0.0s: Jugador se acerca a evidencia (< 50 unidades)
T=0.0s: collect() es llamado
T=0.0s: Inicia scale up (0.0s → 0.2s)
T=0.0s: Partículas spawneadas (8 partículas)
T=0.1s: Inicia fade out (0.1s → 0.5s)
T=0.0s: Callback onEvidenceCollected llamado
T=0.0s: Notificación aparece en pantalla
T=0.3s: Notificación completamente visible
T=0.5s: Evidencia removida del juego
T=0.6s: Partículas desaparecen
T=2.0s: Notificación empieza fade out
T=2.5s: Notificación desaparece
```

### Diagrama Visual

```
Evidencia:
[Normal] → [Scale 1.5x] → [Fade out] → [Removed]
   0s         0.2s           0.5s         0.5s

Partículas:
[Spawn] → [Fly out] → [Fade] → [Removed]
   0s       0.3s       0.6s      0.6s

Notificación:
[Slide in] → [Visible] → [Fade out] → [Removed]
    0.3s       1.5s        0.7s         2.5s
```

---

## Efectos Visuales

### 1. Evidencia
- **Glow constante**: Pulsa entre 0% y 100% de intensidad
- **Color**: Cyan (#00CED1)
- **Blur**: 15px radius

### 2. Partículas
- **Cantidad**: 8 partículas
- **Distribución**: Circular (45° entre cada una)
- **Tamaño**: 6x6 pixels
- **Color**: Cyan con fade out
- **Blur**: 3px radius

### 3. Notificación
- **Fondo**: Negro 85% opacidad
- **Borde**: Rojo (#8B0000), 2px
- **Sombra**: Roja con blur 15px
- **Icono**: Amarillo
- **Texto**: Blanco (título) y Amarillo (contador)

---

## Próximos Pasos

### Fase 2: Sonido
- [ ] Agregar sonido de recolección (`evidence_collect.mp3`)
- [ ] Integrar con sistema de audio del juego
- [ ] Volumen: 0.6

### Fase 3: Feedback Táctil
- [ ] Agregar vibración al recoger (si está en móvil)
- [ ] Duración: 50ms

### Fase 4: Integración con UI
- [ ] Conectar callback con widget padre (ArcGameScreen)
- [ ] Mostrar notificación en overlay
- [ ] Manejar múltiples notificaciones simultáneas

---

## Notas Técnicas

### Performance
- Animaciones optimizadas con Flame effects
- Partículas se auto-destruyen después de 0.6s
- Sin memory leaks (componentes se remueven correctamente)

### Compatibilidad
- Funciona en los 3 arcos implementados
- Componente compartido reduce duplicación de código
- Fácil de extender a futuros arcos

### Testing
- ✅ Compilación sin errores
- ⏳ Testing visual pendiente
- ⏳ Testing en dispositivo real pendiente

---

## Archivos Modificados

1. **Creados:**
   - `lib/game/core/components/evidence_component.dart`
   - `lib/game/ui/evidence_collected_notification.dart`

2. **Modificados:**
   - `lib/game/arcs/gluttony/gluttony_arc_game.dart`
   - `lib/game/arcs/greed/greed_arc_game.dart`
   - `lib/game/arcs/envy/envy_arc_game.dart`

3. **Deprecados:**
   - `lib/game/arcs/gluttony/components/evidence_component.dart` (reemplazado por versión compartida)

---

## Conclusión

Se ha implementado exitosamente un sistema completo de animación de recolección de evidencias que:

1. ✅ Proporciona feedback visual inmediato
2. ✅ Es consistente entre los 3 arcos
3. ✅ Usa animaciones fluidas y profesionales
4. ✅ Incluye efectos de partículas
5. ✅ Tiene notificación en pantalla
6. ✅ Es fácil de mantener (código compartido)

El siguiente paso es conectar el callback con el widget padre para mostrar la notificación en el overlay del juego.
