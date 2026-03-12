# 🎬 Análisis Completo de Cinemáticas en los Arcos

## 📋 Resumen Ejecutivo

| Cinemática | Ubicación | Estado | Se Muestra |
|------------|-----------|--------|------------|
| **Cinemática Inicial** ("Miren a ese cerdo") | Al iniciar juego | ❌ ELIMINADA | NO |
| **Intro del Arco** | Antes de jugar | ✅ EXISTE | ❓ NO SE USA |
| **Victoria del Arco** | Al completar | ✅ EXISTE | ✅ SÍ |
| **Outro del Arco** | Después de victoria | ✅ EXISTE | ✅ SÍ |

---

## 🎮 Cinemáticas por Fase del Juego

### 1. ❌ Cinemática Inicial (ELIMINADA)

**Archivo**: `lib/game/ui/arc_cinematic_overlay.dart`

**Estado**: ✅ Código existe pero **NO SE USA**

**Contenido por Arco**:
- **Arco 1 (Gula)**: "HAMBRIENTO / NUNCA SATISFECHO"
- **Arco 2 (Avaricia)**: "AVARICIA / MONEDAS Y NADA MÁS"
- **Arco 3 (Envidia)**: "ENVIDIA / REFLEJO ROTO"

**Características**:
- Overlay semi-transparente sobre el mapa
- Efecto de glitch con colores específicos por arco
- Efecto typewriter
- Duración: 3 segundos
- Botón de skip

**¿Se Muestra?**: ❌ **NO** - Eliminada completamente del flujo

**Razón**: Variable `_showCinematic` eliminada de `arc_game_screen.dart`

---

### 2. 📖 Intro del Arco (ANTES DE JUGAR)

**Archivo**: `lib/screens/arc_intro_screen.dart`

**Estado**: ✅ Código existe pero **NO SE USA ACTUALMENTE**

**Contenido por Arco**:

#### Arco 1 - Gula
```
Abres los ojos.
Oscuridad.

¿Dónde estás?

Tu teléfono vibra:
"Dirección: █████████ Almacén 7"
"Ven solo. O todos lo sabrán."

No sabes qué hiciste.
Pero la amenaza es clara.

Llegaste al almacén abandonado.
La puerta se cierra detrás de ti.

Algo se mueve en la oscuridad.
Algo grande.
Algo hambriento.

Una máscara de cerdo emerge.

RUN.
```

#### Arco 2 - Avaricia
```
Llamada desconocida.
Contestas.

"Hola, P-L-A-Y-E-R."

Voz distorsionada. Femenina.

"¿Recuerdas lo que compartiste?"

[Cuelga]

Tu ubicación fue enviada.
Un mensaje nuevo:
"Banco Nacional - Bóveda C"
"Recupera lo que robaste."

No entiendes.
Pero vas.

El banco está vacío. Cerrado.
La puerta trasera está abierta.

Las bóvedas están saqueadas.
Algo brilla en la oscuridad.
Ojos rojos.

Una máscara de rata.

"Tú robaste mi vida.
Ahora robaré la tuya."
```

#### Arco 3 - Envidia
```
Mensaje directo de cuenta bloqueada:

"Hola. ¿Me recuerdas?"
[FOTO ADJUNTA: Antes/Después]

Tu estómago se retuerce.
Vagamente... reconoces algo.

Otro mensaje:
"Gimnasio Atlas. 3era Ave."
"Ven a verme."
"Tal vez ahora SOY suficiente para ti."

El gimnasio está oscuro.
Cerrado hace años según el cartel.

Pero la puerta está entreabierta.

Espejos rotos por todas partes.

Algo se mueve.
Demasiado rápido.
Demasiado delgado.

Una máscara de camaleón.
Se mueve exactamente como tú.

"¿Ahora me ves?"
```

**Características**:
- Pantalla completa negra
- Efecto typewriter (40ms por carácter)
- Botón "SALTAR [ESC]"
- Auto-continúa después de 2 segundos al terminar
- Fuente: VT323

**¿Se Muestra?**: ❓ **NO SE USA** - El código existe pero no se navega a esta pantalla

**Verificación**: 
- ✅ Archivo existe
- ❌ No hay navegación a `ArcIntroScreen` desde `arc_selection_screen.dart`
- ❌ No hay navegación desde ningún otro lugar

---

### 3. ✅ Victoria del Arco (AL COMPLETAR)

**Archivo**: `lib/game/ui/arc_victory_cinematic.dart`

**Estado**: ✅ **SE USA ACTIVAMENTE**

**Fases**:

#### Fase 1: Pantalla Negra (2 segundos)
- Solo negro

#### Fase 2: Texto Cinemático (4 segundos)
- Texto con efecto glitch
- Vibración del dispositivo
- Efecto de ruido estático
- Texto específico por arco (configurado en `arc_data_provider.dart`)

#### Fase 3: Estadísticas (5 segundos)
- Lado izquierdo: Número y título del arco
- Lado derecho: Estadísticas del juego
  - Evidencias recolectadas
  - Tiempo
  - Monedas ganadas
  - Estadísticas adicionales por arco

**Características**:
- Estilo VHS con scanlines
- Efecto de glitch en texto
- Botón "SKIP" (solo en fases 1-2)
- Auto-continúa después de 5 segundos
- Fuente: Courier Prime

**¿Se Muestra?**: ✅ **SÍ** - Se muestra al completar cualquier arco

**Flujo**:
```
Completar Arco → ArcVictoryCinematic → ArcOutroScreen → Volver al menú
```

---

### 4. ✅ Outro del Arco (DESPUÉS DE VICTORIA)

**Archivo**: `lib/screens/arc_outro_screen.dart`

**Estado**: ✅ **SE USA ACTIVAMENTE**

**Contenido por Arco**:

#### Arco 1 - Gula
```
Compartiste el video.
"MIREN A ESTE GORDO COMIENDO BASURA"

2.3 millones de vistas
847,392 likes

Mateo leyó los comentarios.
Todos los comentarios.

Ya no sale de su casa.
Ya no come.

¿Valió la pena?
```

#### Arco 2 - Avaricia
```
Compartiste algo que no debías.
Número de cuenta: ████████
Dirección: █████████

Valeria lo perdió todo.
Su casa. Sus ahorros. Sus hijos.

Tú ganaste 15,632 likes.

¿Valió la pena?
```

#### Arco 3 - Envidia
```
Comparaste.
Humillaste.
Repetiste.

Cada comentario era un golpe.
Cada comparación, una herida.

Ella cambió.
Tú seguiste igual.

¿Valió la pena?
```

**Características**:
- Pantalla negra con efecto glitch rojo
- Efecto typewriter (60ms por carácter)
- "¿Valió la pena?" aparece con efecto especial (rojo, sombra brillante)
- Botón "SALTAR"
- Botón "CONTINUAR" al terminar
- Auto-continúa después de 4 segundos
- Fuente: VT323

**¿Se Muestra?**: ✅ **SÍ** - Se muestra después de `ArcVictoryCinematic`

**Flujo**:
```
ArcVictoryCinematic → ArcOutroScreen → Navigator.pop() → Volver al menú
```

---

## 📊 Flujo Actual del Juego

```
Selección de Arco
       ↓
   [NO HAY INTRO] ← ArcIntroScreen NO SE USA
       ↓
  Juego Inicia
       ↓
   [NO HAY CINEMÁTICA INICIAL] ← arc_cinematic_overlay NO SE USA
       ↓
  Jugando...
       ↓
  Completar Arco
       ↓
✅ ArcVictoryCinematic (SE MUESTRA)
   - Fase 1: Negro (2s)
   - Fase 2: Texto glitch (4s)
   - Fase 3: Stats (5s)
       ↓
✅ ArcOutroScreen (SE MUESTRA)
   - Texto de culpabilidad
   - "¿Valió la pena?"
       ↓
  Volver al Menú
```

---

## 🔍 Verificación de Uso

### Cinemáticas que SÍ se Muestran

1. ✅ **ArcVictoryCinematic**
   - Llamada en: `lib/screens/arc_game_screen.dart` línea ~1108
   - Se muestra cuando: `game.isVictory == true`
   - Duración total: ~11 segundos (skippable)

2. ✅ **ArcOutroScreen**
   - Llamada en: `lib/screens/arc_game_screen.dart` línea ~1114
   - Se muestra después de: `ArcVictoryCinematic.onComplete()`
   - Duración: ~4 segundos + tiempo de lectura (skippable)

### Cinemáticas que NO se Muestran

1. ❌ **ArcCinematicOverlay** (Cinemática inicial)
   - Archivo existe: `lib/game/ui/arc_cinematic_overlay.dart`
   - Importado en: ❌ Ya no se importa (eliminado)
   - Variable `_showCinematic`: ❌ Eliminada
   - Estado: **CÓDIGO MUERTO** - Nunca se ejecuta

2. ❓ **ArcIntroScreen** (Intro antes de jugar)
   - Archivo existe: `lib/screens/arc_intro_screen.dart`
   - Importado en: `lib/screens/arc_selection_screen.dart` línea 15
   - Navegación: ❌ **NO SE NAVEGA A ESTA PANTALLA**
   - Estado: **CÓDIGO NO USADO** - Existe pero no se llama

---

## 💡 Recomendaciones

### Opción 1: Limpiar Código Muerto

Si no planeas usar las cinemáticas de intro:

1. ❌ Eliminar `lib/game/ui/arc_cinematic_overlay.dart`
2. ❌ Eliminar `lib/screens/arc_intro_screen.dart`
3. ❌ Eliminar import en `arc_selection_screen.dart`

**Beneficio**: Código más limpio, menos archivos sin usar

### Opción 2: Activar Intro del Arco

Si quieres mostrar la intro antes de jugar:

```dart
// En arc_selection_screen.dart, al seleccionar un arco:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ArcIntroScreen(
      arcId: arcId,
      onComplete: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ArcGameScreen(arcId: arcId),
          ),
        );
      },
    ),
  ),
);
```

**Beneficio**: Más contexto narrativo antes de jugar

### Opción 3: Mantener Como Está

Dejar el código por si lo necesitas en el futuro.

**Beneficio**: Flexibilidad para activarlo después

---

## 📝 Resumen Final

| Cinemática | Archivo | Se Muestra | Duración | Skippable |
|------------|---------|------------|----------|-----------|
| Inicial (Glitch) | `arc_cinematic_overlay.dart` | ❌ NO | 3s | ✅ |
| Intro del Arco | `arc_intro_screen.dart` | ❌ NO | ~30s | ✅ |
| Victoria | `arc_victory_cinematic.dart` | ✅ SÍ | 11s | ✅ |
| Outro | `arc_outro_screen.dart` | ✅ SÍ | ~4s | ✅ |

**Total de cinemáticas activas**: 2 de 4 (50%)

**Tiempo total de cinemáticas al completar un arco**: ~15 segundos (ambas skippables)

---

**Fecha de Análisis**: Diciembre 5, 2024  
**Estado**: ✅ Análisis Completo
