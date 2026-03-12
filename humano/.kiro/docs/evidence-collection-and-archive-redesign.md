# Rediseño: Recolección de Evidencias y Archivo

## Fecha
19 de noviembre de 2025

## Objetivos

1. **Animación al recoger evidencia**: Feedback visual inmediato cuando el jugador recoge una evidencia
2. **Rediseño completo del Archive**: Todo en español, estructura simplificada y temática

---

## 1. Animación de Recolección de Evidencia

### Concepto
Cuando el jugador recoge una evidencia, debe haber un feedback visual claro y satisfactorio.

### Elementos de la Animación

#### A. Efecto en el Item de Evidencia
- **Scale up + fade out**: El item crece ligeramente y desaparece
- **Partículas**: Pequeñas partículas amarillas/doradas que se dispersan
- **Duración**: 0.5 segundos

#### B. Notificación en Pantalla
- **Popup temporal** en la parte superior central
- **Contenido**:
  - Icono de evidencia (📄)
  - Texto: "EVIDENCIA RECOLECTADA"
  - Contador: "X/5"
- **Animación**: Slide down + fade in, luego fade out después de 2 segundos
- **Estilo**: Fondo negro semi-transparente, borde rojo, texto blanco

#### C. Efecto de Sonido
- Sonido de "clic" o "captura" al recoger
- Volumen: 0.6

### Implementación Técnica

```dart
// En el componente de evidencia
void onCollected() {
  // 1. Animación del item
  add(ScaleEffect.to(
    Vector2.all(1.5),
    EffectController(duration: 0.3),
  ));
  
  add(OpacityEffect.fadeOut(
    EffectController(duration: 0.5),
  ));
  
  // 2. Partículas
  _spawnCollectionParticles();
  
  // 3. Sonido
  _playCollectionSound();
  
  // 4. Notificación en HUD
  gameRef.showEvidenceCollectedNotification();
  
  // 5. Remover después de animación
  Future.delayed(Duration(milliseconds: 500), () {
    removeFromParent();
  });
}
```

---

## 2. Rediseño del Archive (Archivo)

### Concepto General
El Archive es donde el jugador puede ver todas las evidencias recolectadas a través de los arcos. Debe sentirse como un "expediente digital oscuro" con estética de vigilancia.

### Estructura Simplificada

#### Categorías de Evidencias (por Arco)
En lugar de tipos genéricos, organizamos por arco:

1. **ARCO 1: GULA** (5 evidencias)
2. **ARCO 2: AVARICIA** (5 evidencias)
3. **ARCO 3: ENVIDIA** (5 evidencias)
4. **ARCO 4-7**: Bloqueados para la demo

### Diseño Visual

#### Header
```
[← ATRÁS]  ARCHIVO DE EVIDENCIAS  [3/15 DESBLOQUEADAS]
                                    [████░░░░░░░░░░░] 20%
```

#### Filtros
```
[TODO] [ARCO 1] [ARCO 2] [ARCO 3] [BLOQUEADO] [BLOQUEADO] [BLOQUEADO] [BLOQUEADO]
```

#### Grid de Evidencias
- **Layout**: Grid 3x5 (3 columnas, 5 filas por arco)
- **Card bloqueada**: Silueta oscura con candado, texto "???"
- **Card desbloqueada**: Imagen/icono, título, fecha de recolección

### Contenido de Evidencias (TODO EN ESPAÑOL)

#### ARCO 1: GULA - Mateo

1. **Video del Restaurante**
   - Título: "Video: Mateo en el Restaurante"
   - Descripción: "Grabación de Mateo comiendo de la basura. 2.3M vistas."
   - Fecha: "Recolectada: [fecha]"
   - Hint (bloqueada): "Completa el Arco 1: Gula"

2. **Captura de Comentarios**
   - Título: "Comentarios Crueles"
   - Descripción: "Los peores comentarios sobre Mateo. Todos los leyó."
   - Hint: "Recolecta 2 evidencias en el Arco 1"

3. **Foto del Perfil**
   - Título: "Perfil de Mateo"
   - Descripción: "Su última foto antes de desaparecer de redes."
   - Hint: "Recolecta 3 evidencias en el Arco 1"

4. **Mensaje Privado**
   - Título: "Último Mensaje"
   - Descripción: "Su último mensaje antes de dejar de responder."
   - Hint: "Recolecta 4 evidencias en el Arco 1"

5. **Estadísticas Virales**
   - Título: "Impacto Viral"
   - Descripción: "Números que destruyeron una vida."
   - Hint: "Completa el Arco 1 completamente"

#### ARCO 2: AVARICIA - Valeria

1. **Foto del Banco**
   - Título: "Foto: Valeria en el Banco"
   - Descripción: "Momento privado convertido en contenido público."
   - Hint: "Completa el Arco 2: Avaricia"

2. **Datos Bancarios Filtrados**
   - Título: "Información Sensible"
   - Descripción: "Datos que nunca debieron ser públicos."
   - Hint: "Recolecta 2 evidencias en el Arco 2"

3. **Captura de Likes**
   - Título: "15,632 Likes"
   - Descripción: "El precio de su privacidad."
   - Hint: "Recolecta 3 evidencias en el Arco 2"

4. **Mensaje de Desalojo**
   - Título: "Aviso de Desalojo"
   - Descripción: "Consecuencia directa de la exposición."
   - Hint: "Recolecta 4 evidencias en el Arco 2"

5. **Foto de sus Hijos**
   - Título: "Familia Afectada"
   - Descripción: "Inocentes arrastrados por tu contenido."
   - Hint: "Completa el Arco 2 completamente"

#### ARCO 3: ENVIDIA - Lucía

1. **Foto del Gimnasio**
   - Título: "Foto: Lucía Entrenando"
   - Descripción: "Comparaciones que nunca pidió."
   - Hint: "Completa el Arco 3: Envidia"

2. **Comparaciones Crueles**
   - Título: "Antes y Después"
   - Descripción: "Tu contenido de comparación viral."
   - Hint: "Recolecta 2 evidencias en el Arco 3"

3. **Comentarios de Odio**
   - Título: "Avalancha de Críticas"
   - Descripción: "Miles de personas juzgándola."
   - Hint: "Recolecta 3 evidencias en el Arco 3"

4. **Registro Médico**
   - Título: "Historial Clínico"
   - Descripción: "Consecuencias físicas de la presión."
   - Hint: "Recolecta 4 evidencias en el Arco 3"

5. **Última Publicación**
   - Título: "Despedida Digital"
   - Descripción: "Su último post antes de desaparecer."
   - Hint: "Completa el Arco 3 completamente"

### Interacción con Evidencias

#### Evidencia Bloqueada
Al hacer clic:
```
┌─────────────────────────────┐
│         🔒                  │
│  EVIDENCIA BLOQUEADA        │
│                             │
│  [Hint de desbloqueo]       │
│                             │
│      [ENTENDIDO]            │
└─────────────────────────────┘
```

#### Evidencia Desbloqueada
Al hacer clic, se abre un modal con:
- Imagen/icono grande
- Título
- Descripción completa
- Fecha de recolección
- Botón "CERRAR"

### Estilo Visual

#### Colores
- **Fondo**: Negro con video de fondo (igual que ahora)
- **Cards bloqueadas**: Gris oscuro (#1a1a1a) con borde gris (#333)
- **Cards desbloqueadas**: Negro (#000) con borde rojo (#8B0000)
- **Texto**: Blanco (#fff) y gris claro (#ccc)
- **Acentos**: Rojo oscuro (#8B0000)

#### Tipografía
- **Títulos**: Courier Prime, bold, 14px
- **Descripciones**: Courier Prime, regular, 12px
- **Hints**: Courier Prime, italic, 11px

---

## 3. Implementación por Fases

### Fase 1: Animación de Recolección ✅
1. Crear componente de partículas
2. Agregar efectos de escala y fade
3. Implementar notificación en HUD
4. Agregar sonido de recolección

### Fase 2: Rediseño del Archive
1. Actualizar modelo de Evidence
2. Crear provider simplificado
3. Rediseñar UI del Archive
4. Agregar contenido en español para Arcos 1-3
5. Implementar sistema de desbloqueo

### Fase 3: Integración
1. Conectar recolección con desbloqueo
2. Guardar progreso en Firebase
3. Testing completo

---

## 4. Notas de Implementación

### Persistencia
- Guardar evidencias desbloqueadas en Firebase por usuario
- Estructura: `users/{uid}/evidences/{evidenceId}: {unlocked: true, unlockedAt: timestamp}`

### Performance
- Lazy loading de imágenes de evidencias
- Cache de evidencias desbloqueadas
- Animaciones optimizadas (60 FPS)

### Accesibilidad
- Textos con contraste adecuado
- Feedback táctil al recoger evidencia
- Mensajes claros de progreso

---

## 5. Assets Necesarios

### Sonidos
- `evidence_collect.mp3` - Sonido al recoger evidencia

### Imágenes (Placeholders por ahora)
- Iconos para cada tipo de evidencia
- Imágenes de fondo para cards desbloqueadas

---

## Conclusión

Este rediseño hace que:
1. **Recoger evidencias sea más satisfactorio** con feedback visual inmediato
2. **El Archive sea más claro y temático** con todo en español
3. **La narrativa sea más fuerte** al organizar por arcos y víctimas
4. **El progreso sea más visible** con sistema de desbloqueo claro
