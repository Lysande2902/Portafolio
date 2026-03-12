# Implementación: Concepto de Fragmentos

## Fecha
19 de noviembre de 2025

## Concepto

### Antes: Evidencias
- Recolectabas **5 evidencias** independientes
- Cada una era un item completo

### Ahora: Fragmentos
- Recolectas **5 fragmentos** que forman **1 evidencia completa**
- Los fragmentos se ensamblan visualmente para revelar la historia completa

---

## Cambios Narrativos

### Concepto Mejorado
**5 fragmentos → 1 evidencia completa**

Esto hace que:
1. **Sea más narrativo**: Los fragmentos cuentan una historia fragmentada
2. **Sea más visual**: El HUD muestra cómo se va completando la evidencia
3. **Tenga más sentido**: Estás reconstruyendo lo que pasó, pieza por pieza

### Ejemplo por Arco

#### Arco 1: Gula - Mateo
**Evidencia completa:** "Video viral de Mateo comiendo basura"
- Fragmento 1: Inicio del video
- Fragmento 2: Momento más humillante
- Fragmento 3: Reacciones de la gente
- Fragmento 4: Comentarios crueles
- Fragmento 5: Estadísticas virales

#### Arco 2: Avaricia - Valeria
**Evidencia completa:** "Doxeo completo de Valeria"
- Fragmento 1: Foto en el banco
- Fragmento 2: Número de cuenta
- Fragmento 3: Dirección de casa
- Fragmento 4: Información de hijos
- Fragmento 5: Likes y compartidos

#### Arco 3: Envidia - Lucía
**Evidencia completa:** "Comparación viral de Lucía"
- Fragmento 1: Foto "antes"
- Fragmento 2: Foto "después"
- Fragmento 3: Comentarios de odio
- Fragmento 4: Shares y tags
- Fragmento 5: Consecuencias médicas

---

## Cambios Implementados

### 1. Notificación de Recolección
**Archivo:** `lib/game/ui/evidence_collected_notification.dart`

**Antes:**
```
EVIDENCIA RECOLECTADA
3/5
```

**Ahora:**
```
FRAGMENTO RECOLECTADO
3/5 FRAGMENTOS
```

**Cambios:**
- Icono cambiado de `Icons.description` a `Icons.auto_awesome` (✨)
- Texto: "FRAGMENTO RECOLECTADO"
- Contador: "X/5 FRAGMENTOS"

### 2. HUD - Contador Visual
**Archivo:** `lib/game/ui/game_hud.dart`

**Antes:**
```
📄 3/5
```

**Ahora:**
```
✨✨✨☆☆
3/5 FRAGMENTOS
```

**Cambios:**
- Muestra 5 iconos de fragmentos
- Fragmentos recolectados: ✨ (amarillo, filled)
- Fragmentos faltantes: ☆ (gris, outlined)
- Texto debajo: "X/5 FRAGMENTOS"

**Código:**
```dart
// Fragment icons (visual representation)
Row(
  children: List.generate(totalEvidence, (index) {
    final isCollected = index < evidenceCollected;
    return Icon(
      isCollected ? Icons.auto_awesome : Icons.auto_awesome_outlined,
      color: isCollected ? Colors.yellow : Colors.grey.shade700,
    );
  }),
),
```

### 3. Objetivos de Misión
**Archivo:** `lib/data/providers/arc_data_provider.dart`

**Cambios en todos los arcos:**
- "Recolecta 5 evidencias" → "Recolecta 5 fragmentos"

### 4. Estadísticas de Victoria
**Archivo:** `lib/data/providers/arc_data_provider.dart`

**Cambios:**
- "Evidencias Recolectadas" → "Fragmentos Recolectados"
- "Evidencias" → "Fragmentos"

### 5. Mensajes de Consola
**Archivos:** 
- `lib/game/arcs/gluttony/gluttony_arc_game.dart`
- `lib/game/arcs/greed/greed_arc_game.dart`
- `lib/game/arcs/envy/envy_arc_game.dart`

**Cambios:**
```dart
// Antes
print('✨ Evidence collected! Total: $evidenceCollected/5');

// Ahora
print('✨ Fragmento recolectado! Total: $evidenceCollected/5 fragmentos');
```

### 6. Comentarios en Código
**Archivo:** `lib/game/core/components/evidence_component.dart`

**Actualizado:**
```dart
/// Fragment component - collectible pieces that form complete evidence
/// 5 fragments = 1 complete evidence
/// Shared across all arcs with collection animation
```

---

## Impacto Visual

### HUD Mejorado

**Antes:**
```
┌─────────────────┐
│ 📄 3/5          │
└─────────────────┘
```

**Ahora:**
```
┌─────────────────┐
│ ✨✨✨☆☆        │
│ 3/5 FRAGMENTOS  │
└─────────────────┘
```

### Notificación Mejorada

**Antes:**
```
┌──────────────────────────┐
│ 📄 EVIDENCIA RECOLECTADA │
│    3/5                   │
└──────────────────────────┘
```

**Ahora:**
```
┌──────────────────────────┐
│ ✨ FRAGMENTO RECOLECTADO │
│    3/5 FRAGMENTOS        │
└──────────────────────────┘
```

---

## Beneficios del Cambio

### 1. Narrativa Más Fuerte
- Los fragmentos cuentan una historia fragmentada
- El jugador "reconstruye" lo que pasó
- Más inmersivo y temático

### 2. Feedback Visual Mejorado
- El HUD muestra progreso visual claro
- Los iconos de fragmentos se van "llenando"
- Más satisfactorio ver el progreso

### 3. Coherencia Temática
- Encaja con el tema de "reconstruir evidencias"
- Más apropiado para un juego de investigación
- Refuerza la mecánica de recolección

### 4. Escalabilidad
- Fácil de extender a futuros arcos
- El concepto es claro y consistente
- Permite variaciones (diferentes tipos de fragmentos)

---

## Próximos Pasos Sugeridos

### Fase 1: Visualización Avanzada (Opcional)
- [ ] Mostrar preview de la evidencia completa al recoger el 5to fragmento
- [ ] Animación de "ensamblaje" cuando completas los 5 fragmentos
- [ ] Efecto especial al completar la evidencia

### Fase 2: Archive Redesign
- [ ] Mostrar evidencias completas en el Archive
- [ ] Cada evidencia muestra sus 5 fragmentos
- [ ] Indicador visual de fragmentos recolectados vs faltantes

### Fase 3: Narrativa Expandida
- [ ] Cada fragmento tiene su propia descripción
- [ ] Los fragmentos revelan la historia progresivamente
- [ ] Orden de recolección afecta la narrativa

---

## Archivos Modificados

1. `lib/game/ui/evidence_collected_notification.dart`
2. `lib/game/ui/game_hud.dart`
3. `lib/data/providers/arc_data_provider.dart`
4. `lib/game/arcs/gluttony/gluttony_arc_game.dart`
5. `lib/game/arcs/greed/greed_arc_game.dart`
6. `lib/game/arcs/envy/envy_arc_game.dart`
7. `lib/game/core/components/evidence_component.dart`

---

## Conclusión

El cambio de "evidencias" a "fragmentos" mejora significativamente:
- ✅ La narrativa del juego
- ✅ El feedback visual
- ✅ La coherencia temática
- ✅ La experiencia del jugador

Los 5 fragmentos ahora forman una evidencia completa, haciendo que el jugador sienta que está "reconstruyendo" la historia pieza por pieza, lo cual es mucho más inmersivo y apropiado para el tema del juego.
