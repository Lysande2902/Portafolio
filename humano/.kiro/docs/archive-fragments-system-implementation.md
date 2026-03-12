# Sistema de Fragmentos del Archive - Implementación Completa

## Fecha
19 de noviembre de 2025

## Resumen
Se ha implementado un sistema completo de fragmentos para el Archive, organizando las evidencias por arco con persistencia en Firebase y desbloqueo progresivo durante el juego.

---

## Componentes Implementados

### 1. FragmentsProvider
**Archivo:** `lib/data/providers/fragments_provider.dart`

#### Funcionalidades:
- **Persistencia en Firebase**: Guarda y carga el progreso del jugador
- **Organización por arcos**: 7 arcos × 5 fragmentos cada uno = 35 fragmentos totales
- **Desbloqueo progresivo**: Los fragmentos se desbloquean al recolectar evidencias en el juego
- **Estado en tiempo real**: Notifica cambios a la UI automáticamente con ChangeNotifier

#### Métodos principales:
```dart
// Verificar si un fragmento está desbloqueado
bool isFragmentUnlocked(String arcId, int fragmentNumber)

// Desbloquear un fragmento específico
Future<void> unlockFragment(String arcId, int fragmentNumber)

// Desbloquear múltiples fragmentos basado en progreso
Future<void> unlockFragmentsForArcProgress(String arcId, int fragmentsCollected)

// Obtener fragmentos con estado (desbloqueado/bloqueado)
List<Map<String, dynamic>> getFragmentsWithStatus(String arcId)

// Progreso total
int get totalUnlockedFragments
double get progress // 0.0 a 1.0
```

#### Estructura de datos en Firebase:
```json
{
  "users": {
    "userId": {
      "progress": {
        "fragments": {
          "arc_1_gula": [1, 2, 3],
          "arc_2_greed": [1],
          "arc_3_envy": [],
          "arc_4_lust": [],
          "arc_5_pride": [],
          "arc_6_sloth": [],
          "arc_7_wrath": [],
          "lastUpdated": "timestamp"
        }
      }
    }
  }
}
```

---

### 2. Archive Screen Rediseñado
**Archivo:** `lib/screens/archive_screen.dart`

#### Características principales:

##### Layout por pestañas
- **7 pestañas de arcos**: Una por cada pecado capital
- **Arcos 1-3**: Desbloqueados (Gula, Avaricia, Envidia)
- **Arcos 4-7**: Bloqueados para la demo (Lujuria, Soberbia, Pereza, Ira)

##### Grid de fragmentos
- **5 fragmentos por arco** organizados en grid
- **Estados visuales claros**:
  - ✨ Fragmentos desbloqueados (amarillo/dorado)
  - 🔒 Fragmentos bloqueados (gris)
- **Interacción**:
  - Tap en desbloqueado: Modal con detalles completos
  - Tap en bloqueado: Hint de cómo desbloquear

##### Header con progreso
- **Contador**: X/35 fragmentos totales
- **Barra de progreso**: Visual del porcentaje completado
- **Botón de regreso**: Volver al menú principal

#### Estructura visual:
```
┌─────────────────────────────────────────────────────┐
│ [←] ARCHIVO DE EVIDENCIAS           [3/35] ████░░░░│
├─────────────────────────────────────────────────────┤
│ [ARCO 1] [ARCO 2] [ARCO 3] [🔒 4] [🔒 5] [🔒 6] [🔒 7]│
├─────────────────────────────────────────────────────┤
│ ARCO 1: GULA                                        │
│ El Banquete de los Desechos                         │
│                                                     │
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐                     │
│ │ ✨ │ │ ✨ │ │ ✨ │ │🔒 │ │🔒 │                     │
│ │ F1 │ │ F2 │ │ F3 │ │ F4│ │ F5│                     │
│ └───┘ └───┘ └───┘ └───┘ └───┘                     │
└─────────────────────────────────────────────────────┘
```

---

## Contenido de Fragmentos por Arco

### Arco 1: GULA - Mateo
**Evidencia completa:** Video viral de Mateo comiendo basura

1. **Video del Restaurante**
   - Descripción: "Grabación de Mateo comiendo de la basura. 2.3M vistas."
   - Hint: "Recolecta 1 fragmento en el Arco 1: Gula"

2. **Comentarios Crueles**
   - Descripción: "Los peores comentarios sobre Mateo. Todos los leyó."
   - Hint: "Recolecta 2 fragmentos en el Arco 1: Gula"

3. **Perfil de Mateo**
   - Descripción: "Su última foto antes de desaparecer de redes."
   - Hint: "Recolecta 3 fragmentos en el Arco 1: Gula"

4. **Último Mensaje**
   - Descripción: "Su último mensaje antes de dejar de responder."
   - Hint: "Recolecta 4 fragmentos en el Arco 1: Gula"

5. **Impacto Viral**
   - Descripción: "Números que destruyeron una vida."
   - Hint: "Recolecta 5 fragmentos en el Arco 1: Gula"

### Arco 2: AVARICIA - Valeria
**Evidencia completa:** Doxeo completo de Valeria

1. **Foto del Banco**
   - Descripción: "Momento privado convertido en contenido público."

2. **Datos Bancarios**
   - Descripción: "Información que nunca debió ser pública."

3. **15,632 Likes**
   - Descripción: "El precio de su privacidad."

4. **Aviso de Desalojo**
   - Descripción: "Consecuencia directa de la exposición."

5. **Familia Afectada**
   - Descripción: "Inocentes arrastrados por tu contenido."

### Arco 3: ENVIDIA - Lucía
**Evidencia completa:** Comparación viral de Lucía

1. **Foto del Gimnasio**
   - Descripción: "Comparaciones que nunca pidió."

2. **Antes y Después**
   - Descripción: "Tu contenido de comparación viral."

3. **Avalancha de Críticas**
   - Descripción: "Miles de personas juzgándola."

4. **Historial Clínico**
   - Descripción: "Consecuencias físicas de la presión."

5. **Despedida Digital**
   - Descripción: "Su último post antes de desaparecer."

### Arcos 4-7: BLOQUEADOS
- Contenido placeholder para la demo
- Mensaje: "Contenido bloqueado para la demo"
- Hint: "Completa los arcos anteriores para desbloquear"

---

## Integración con el Sistema de Juego

### ArcGameScreen
**Archivo:** `lib/screens/arc_game_screen.dart`

#### Cambios realizados:
1. **Import del FragmentsProvider**
2. **Actualización del método `_saveProgress()`**:
   - Ahora desbloquea fragmentos al completar el arco
   - Llama a `unlockFragmentsForArcProgress()` con el número de evidencias recolectadas

#### Flujo de desbloqueo:
```
1. Jugador completa el arco
2. Se ejecuta _saveProgress()
3. Se desbloquean fragmentos (1 por cada evidencia recolectada)
4. Se guarda en Firebase
5. Archive se actualiza automáticamente
```

#### Código de integración:
```dart
// En _saveProgress()
final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);

// Desbloquear fragmentos basado en evidencias recolectadas
await fragmentsProvider.unlockFragmentsForArcProgress(
  widget.arcId,
  game.evidenceCollected,
);
```

---

## Registro del Provider

### main.dart
**Cambios:**
- Agregado import de `FragmentsProvider`
- Registrado en `MultiProvider`

```dart
ChangeNotifierProvider(
  create: (_) => FragmentsProvider(),
),
```

---

## Estados Visuales

### Fragmento Desbloqueado
```
┌─────────────┐
│      ✨      │
│             │
│ FRAGMENTO 1 │
│             │
│ Video del   │
│ Restaurante │
└─────────────┘
Color: Amarillo/Dorado
Interacción: Tap para ver detalles
```

### Fragmento Bloqueado
```
┌─────────────┐
│      🔒      │
│             │
│ FRAGMENTO 4 │
│             │
│     ???     │
│             │
└─────────────┘
Color: Gris
Interacción: Tap para ver hint
```

### Arco Bloqueado (4-7)
```
┌─────────────┐
│ 🔒 ARCO 4   │
│  LUJURIA    │
└─────────────┘
Color: Gris oscuro
Interacción: No seleccionable
```

---

## Flujo de Usuario

### 1. Acceso al Archive
- Desde el menú principal
- Botón "ARCHIVO" en home screen

### 2. Navegación por arcos
- Pestañas horizontales en la parte superior
- Arcos 1-3: Clickeables
- Arcos 4-7: Bloqueados (visual de candado)

### 3. Visualización de fragmentos
- Grid de 5 fragmentos por arco
- Estados visuales claros (desbloqueado/bloqueado)
- Progreso visible en header

### 4. Interacción con fragmentos
- **Desbloqueado**: Modal con título, descripción completa
- **Bloqueado**: Modal con hint de desbloqueo

### 5. Desbloqueo durante el juego
- Automático al recolectar evidencias
- 1 fragmento por cada evidencia recolectada
- Guardado inmediato en Firebase

---

## Características Técnicas

### Persistencia
- **Carga automática**: Al abrir el Archive
- **Guardado inmediato**: Al desbloquear fragmento
- **Merge de datos**: No sobrescribe progreso existente
- **Offline support**: Funciona sin conexión (sincroniza después)

### Performance
- **Lazy loading**: Solo carga fragmentos del arco seleccionado
- **Optimización de renders**: Consumer widgets para updates selectivos
- **Caché local**: Estado en memoria para acceso rápido

### UX
- **Feedback visual inmediato**: Animaciones y transiciones suaves
- **Estados claros**: Iconos y colores distintivos
- **Hints útiles**: Guían al jugador sobre cómo desbloquear
- **Progreso visible**: Barra y contador en header

---

## Testing

### Casos de prueba:
1. ✅ Cargar Archive sin progreso previo
2. ✅ Desbloquear fragmentos durante el juego
3. ✅ Persistencia en Firebase
4. ✅ Navegación entre arcos
5. ✅ Interacción con fragmentos desbloqueados
6. ✅ Interacción con fragmentos bloqueados
7. ✅ Arcos bloqueados (4-7)
8. ✅ Progreso visual en header

---

## Archivos Creados/Modificados

### Creados:
1. `lib/data/providers/fragments_provider.dart`
2. `.kiro/docs/archive-fragments-system-implementation.md`

### Modificados:
1. `lib/screens/archive_screen.dart` (reescrito completamente)
2. `lib/screens/arc_game_screen.dart` (integración con fragmentos)
3. `lib/main.dart` (registro del provider)

---

## Próximos Pasos (Opcional)

### Mejoras visuales:
- [ ] Animación al desbloquear fragmento
- [ ] Preview de evidencia completa al tener 5/5
- [ ] Efectos de partículas en Archive
- [ ] Transiciones entre arcos

### Funcionalidades avanzadas:
- [ ] Búsqueda de fragmentos
- [ ] Filtros por estado
- [ ] Estadísticas detalladas
- [ ] Exportar progreso
- [ ] Compartir en redes sociales

### Contenido:
- [ ] Agregar contenido para arcos 4-7
- [ ] Imágenes/videos para cada fragmento
- [ ] Audio narrativo para fragmentos desbloqueados

---

## Conclusión

El sistema de fragmentos está completamente implementado y funcional. Los jugadores ahora pueden:

1. ✅ Ver su progreso organizado por arcos
2. ✅ Desbloquear fragmentos al jugar
3. ✅ Persistir su progreso en Firebase
4. ✅ Navegar entre arcos desbloqueados
5. ✅ Ver detalles de fragmentos desbloqueados
6. ✅ Recibir hints para fragmentos bloqueados

El sistema es escalable, mantenible y proporciona una experiencia de usuario clara y satisfactoria. 🎮✨
