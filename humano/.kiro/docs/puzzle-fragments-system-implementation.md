# Implementación: Sistema de Fragmentos de Rompecabezas

## Fecha
21 de noviembre de 2025

## Resumen

Se ha implementado un sistema completo de fragmentos de rompecabezas para los tres arcos del juego (Gula, Avaricia, Envidia). Los jugadores recolectan 5 fragmentos por arco durante el gameplay y luego deben ensamblarlos manualmente en una interfaz interactiva de rompecabezas.

## Componentes Implementados

### 1. Modelos de Datos

#### ConnectionPoint (`lib/data/models/connection_point.dart`)
- Define puntos de conexión entre fragmentos
- Tipos: tab (pestaña), blank (hueco), flat (plano)
- Validación de complementariedad entre fragmentos adyacentes

#### FragmentShape (`lib/data/models/fragment_shape.dart`)
- Contiene path SVG de la forma del fragmento
- Lista de puntos de conexión
- Tamaño del fragmento

#### PuzzleFragment (`lib/data/models/puzzle_fragment.dart`)
- ID único del fragmento
- Forma del fragmento (FragmentShape)
- Región de imagen que muestra
- Posición y rotación correctas
- Estado de recolección
- Snippet narrativo

#### PuzzleEvidence (`lib/data/models/puzzle_evidence.dart`)
- Contiene 5 fragmentos
- Título y descripción narrativa
- Ruta de imagen completa
- Estado de completado
- Contador de intentos

### 2. Generador de Formas

#### ShapeGenerator (`lib/game/puzzle/logic/shape_generator.dart`)
- Genera 5 formas únicas de rompecabezas en layout 2x3
- Crea paths SVG con curvas bezier para pestañas y huecos
- Asegura que fragmentos adyacentes tengan conexiones complementarias
- **Optimización**: Cache de formas generadas

**Layout de Fragmentos:**
```
[0] [1] [2]
[3] [4] [ ]
```

### 3. Proveedor de Datos

#### PuzzleDataProvider (`lib/data/providers/puzzle_data_provider.dart`)
- Gestiona estado de fragmentos y evidencias
- Integración con Firebase para persistencia
- Métodos:
  - `collectFragment()`: Marca fragmento como recolectado
  - `completeEvidence()`: Guarda evidencia completada
  - `getEvidence()`: Obtiene evidencia por ID
  - `canAssembleEvidence()`: Verifica si todos los fragmentos están recolectados

#### EvidenceDefinitions (`lib/data/providers/evidence_definitions.dart`)
- Define las 3 evidencias para los arcos:
  - **Arc 1 (Gula)**: "Video Viral de Mateo"
  - **Arc 2 (Avaricia)**: "Doxeo Completo de Valeria"
  - **Arc 3 (Envidia)**: "Comparación Viral de Lucía"
- Cada evidencia tiene 5 fragmentos con snippets narrativos únicos

### 4. Componentes Visuales

#### FragmentShapeClipper (`lib/game/puzzle/components/fragment_shape_clipper.dart`)
- CustomClipper que renderiza formas de rompecabezas
- Parsea paths SVG usando package `path_drawing`
- Escala formas al tamaño requerido
- Fallback a rectángulo si falla el parsing

#### DraggableFragment (`lib/game/puzzle/components/draggable_fragment.dart`)
- Widget arrastrable para fragmentos
- Características:
  - Drag & drop con física
  - Rotación por tap (90° increments)
  - Animaciones de escala y sombra
  - Efecto de hover
  - Indicador de bloqueo
  - **Optimización**: RepaintBoundary para aislar repaints

### 5. Lógica del Juego

#### PuzzleValidator (`lib/game/puzzle/logic/puzzle_validator.dart`)
- Valida posición y rotación de fragmentos
- Tolerancias configurables (20px posición, 5° rotación)
- Métodos:
  - `isCorrectPlacement()`: Verifica si fragmento está correcto
  - `calculateSnapPosition()`: Calcula posición de snap
  - `isPuzzleComplete()`: Verifica si puzzle está completo
  - `isNearCorrectPosition()`: Para feedback de proximidad

#### DifficultyManager (`lib/game/puzzle/logic/difficulty_manager.dart`)
- Gestiona mecánicas de dificultad:
  - **Tolerancia progresiva**: Aumenta después de 2+ colocaciones correctas
  - **Bloqueo de fragmentos**: 3 segundos después de 3 errores
  - **Atracción magnética falsa**: Atrae fragmentos a posiciones incorrectas cercanas
  - **Sistema de hints**: Se ofrece después de 10 intentos con <2 correctos

### 6. Efectos Visuales

#### ParticleSystem (`lib/game/puzzle/effects/particle_system.dart`)
- Sistema de partículas con física (gravedad, velocidad)
- Tipos de emisiones:
  - **Trail**: Partículas que siguen el fragmento al arrastrarlo
  - **Snap**: Explosión al colocar correctamente
  - **Error**: Partículas rojas al colocar incorrectamente
  - **Confetti**: Celebración al completar puzzle
  - **Proximity**: Glow al acercarse a posición correcta
- **Optimización**: Pooling de partículas (max 200)

#### SoundManager (`lib/game/puzzle/effects/sound_manager.dart`)
- Gestiona efectos de sonido:
  - `pickup.mp3`: Al levantar fragmento
  - `snap.mp3`: Al colocar correctamente
  - `error.mp3`: Al colocar incorrectamente
  - `completion.mp3`: Al completar puzzle
  - `proximity.mp3`: Al acercarse a posición correcta
  - `rotate.mp3`: Al rotar fragmento
- Feedback háptico:
  - Light: Pickup, hover
  - Medium: Snap correcto
  - Heavy: Eventos importantes
  - Error: Doble vibración
  - Success: Triple vibración

### 7. Pantalla Principal

#### PuzzleAssemblyScreen (`lib/game/puzzle/puzzle_assembly_screen.dart`)
- Pantalla principal de ensamblaje
- Características:
  - Inicialización con fragmentos en posiciones y rotaciones aleatorias
  - Drag & drop con validación
  - Rotación por tap
  - Sistema de bloqueo temporal
  - Indicador de tiempo
  - Sistema de hints visual
  - Detección de completado
  - Diálogo de victoria con estadísticas
  - Integración con sistema de partículas
  - Efectos de sonido y hápticos

**Estados Gestionados:**
- Posiciones de fragmentos
- Rotaciones de fragmentos
- Errores por fragmento
- Bloqueos temporales
- Fragmentos correctamente colocados
- Partículas activas

### 8. Integración con Archive

#### Actualización de ArchiveScreen (`lib/screens/archive_screen.dart`)
- Muestra progreso de fragmentos por evidencia
- Abre PuzzleAssemblyScreen cuando todos los fragmentos están recolectados
- Muestra diálogo de progreso si faltan fragmentos
- Mapeo de arcos a evidencias:
  - `arc_1_gula` → `arc1_gluttony_evidence`
  - `arc_2_avaricia` → `arc2_greed_evidence`
  - `arc_3_envidia` → `arc3_envy_evidence`

### 9. Helper de Integración

#### PuzzleIntegrationHelper (`lib/game/puzzle/puzzle_integration_helper.dart`)
- Facilita integración con gameplay
- Método `collectFragment()` para recolectar fragmentos durante el juego
- Mapeo entre IDs de arcos y evidencias

## Dependencias Agregadas

```yaml
dependencies:
  path_drawing: ^1.0.1      # Para renderizar paths SVG
  vector_math: ^2.1.4       # Para Vector2 y matemáticas
  audioplayers: ^5.2.1      # Para efectos de sonido
  vibration: ^1.8.4         # Para feedback háptico
```

## Mecánicas de Dificultad

### 1. Rotación Aleatoria
- Fragmentos inician con rotación aleatoria (0°, 90°, 180°, 270°)
- Jugador debe rotar con tap para orientación correcta

### 2. Posiciones Aleatorias
- Fragmentos se distribuyen aleatoriamente en la pantalla
- Evita bordes para mejor jugabilidad

### 3. Atracción Magnética Falsa
- Fragmentos cercanos (< 50px) se atraen entre sí
- Fuerza de atracción: 30% cuando distancia < 50px
- Aumenta dificultad creando "trampas" visuales

### 4. Bloqueo Temporal
- Después de 3 errores consecutivos en un fragmento
- Bloqueo de 3 segundos con indicador visual
- Previene spam de intentos

### 5. Tolerancia Progresiva
- Tolerancia base: 20px posición, 5° rotación
- Bonus: +10px después de 2+ colocaciones correctas
- Recompensa progreso del jugador

### 6. Sistema de Hints
- Se activa después de 10 intentos con <2 correctos
- Muestra borde amarillo brillante en posición correcta
- Un hint por intento de puzzle

## Flujo de Usuario

### 1. Recolección Durante Gameplay
```
Jugador encuentra fragmento → Colisiona → collectFragment() → 
Notificación "FRAGMENTO RECOLECTADO X/5" → Guardado en Firebase
```

### 2. Acceso desde Archive
```
Archive Screen → Selecciona evidencia → 
Si 5/5 fragmentos → Abre PuzzleAssemblyScreen
Si <5 fragmentos → Muestra progreso
```

### 3. Ensamblaje del Puzzle
```
Pantalla carga → Fragmentos aleatorios → 
Jugador arrastra/rota → Validación → 
Snap correcto o rechazo → 
5/5 correctos → Animación de completado → 
Diálogo de victoria → Guardado en Firebase
```

### 4. Visualización Completada
```
Archive Screen → Evidencia completada → 
Muestra imagen completa sin líneas de puzzle → 
Descripción narrativa completa
```

## Optimizaciones de Rendimiento

### 1. Cache de Formas
- Shapes generados se cachean por tamaño
- Evita regeneración en cada uso
- Método `clearCache()` para gestión de memoria

### 2. Pooling de Partículas
- Pool de hasta 200 partículas reutilizables
- Reduce garbage collection
- Mejora rendimiento en animaciones intensas

### 3. RepaintBoundary
- Cada fragmento arrastrable tiene RepaintBoundary
- Aísla repaints a fragmentos individuales
- Mejora fluidez de animaciones

### 4. Lazy Loading
- Evidencias se cargan solo cuando se necesitan
- Imágenes se cargan bajo demanda
- Reduce uso de memoria inicial

## Narrativa por Arco

### Arco 1: Gula - Mateo
**Evidencia**: "Video Viral de Mateo"

**Fragmentos:**
1. Inicio del video: Mateo se acerca al contenedor
2. Momento más humillante: Mateo toma comida del contenedor
3. Reacciones de la gente: Risas y burlas
4. Comentarios crueles: Miles de insultos
5. Estadísticas virales: 2.3M vistas, 45K compartidos

### Arco 2: Avaricia - Valeria
**Evidencia**: "Doxeo Completo de Valeria"

**Fragmentos:**
1. Foto en el banco: Reflejo revela información sensible
2. Número de cuenta: Ampliado y compartido
3. Dirección de casa: Su hogar ya no es seguro
4. Información de hijos: Seguridad familiar comprometida
5. Likes y compartidos: 89K likes, privacidad destruida

### Arco 3: Envidia - Lucía
**Evidencia**: "Comparación Viral de Lucía"

**Fragmentos:**
1. Foto "antes": Lucía joven y sonriente
2. Foto "después": Lucía actual, feliz
3. Comentarios de odio: Crueldad sin filtro
4. Shares y tags: 156K compartidos
5. Consecuencias médicas: Trastorno alimenticio y depresión

## Assets Requeridos

### Imágenes
```
assets/evidences/
├── arc1_complete.png  # Imagen completa Arco 1
├── arc2_complete.png  # Imagen completa Arco 2
└── arc3_complete.png  # Imagen completa Arco 3
```

### Sonidos
```
assets/sounds/puzzle/
├── pickup.mp3       # Levantar fragmento
├── snap.mp3         # Colocar correctamente
├── error.mp3        # Colocar incorrectamente
├── completion.mp3   # Completar puzzle
├── proximity.mp3    # Acercarse a posición correcta
└── rotate.mp3       # Rotar fragmento
```

## Próximos Pasos

### Fase 1: Assets
- [ ] Crear imágenes completas para las 3 evidencias
- [ ] Grabar/obtener efectos de sonido
- [ ] Optimizar tamaños de assets

### Fase 2: Integración Completa
- [ ] Conectar recolección de fragmentos con sistema de colisiones
- [ ] Integrar con sistema de autenticación para user ID
- [ ] Probar flujo completo end-to-end

### Fase 3: Pulido
- [ ] Ajustar dificultad basado en playtesting
- [ ] Mejorar animaciones de completado
- [ ] Agregar más feedback visual

### Fase 4: Expansión (Opcional)
- [ ] Agregar más arcos (4-7)
- [ ] Diferentes layouts de puzzle (3x3, 4x2)
- [ ] Modos de dificultad seleccionables
- [ ] Leaderboards de tiempo de completado

## Notas Técnicas

### Firebase Structure
```
users/{userId}/
├── fragments/
│   ├── {fragmentId}/
│   │   ├── collected: bool
│   │   ├── collectedAt: timestamp
│   │   ├── evidenceId: string
│   │   └── fragmentNumber: int
│   └── ...
└── evidences/
    ├── {evidenceId}/
    │   ├── completed: bool
    │   ├── completedAt: timestamp
    │   └── attemptCount: int
    └── ...
```

### Consideraciones de Diseño

1. **Formas de Puzzle**: Se usan paths SVG para máxima flexibilidad
2. **Rotación**: Solo 90° increments para simplificar validación
3. **Tolerancia**: Balanceada para ser desafiante pero no frustrante
4. **Feedback**: Rico en efectos visuales, auditivos y hápticos
5. **Narrativa**: Cada fragmento cuenta parte de la historia

## Conclusión

El sistema de fragmentos de rompecabezas está completamente implementado y listo para integración con assets y gameplay. Proporciona una experiencia interactiva y desafiante que refuerza la narrativa del juego mientras mantiene alto rendimiento y buena UX.

**Estado**: ✅ Implementación Core Completa
**Pendiente**: Assets, Integración Final, Testing
