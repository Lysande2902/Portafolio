# ESTRUCTURA TÉCNICA Y NARRATIVA: ARCO 0 (HANDSHAKE ORIGINAL)

Este documento sirve como referencia maestra para la creación y estandarización de los futuros arcos del proyecto.

---

## 1. FLUJO DE PANTALLAS (GAME FLOW)
El Arco 0 sigue una secuencia lineal obligatoria diseñada para generar tensión y atmósfera:

1.  **ArcIntroScreen**: Briefing de Juicio Neuronal. Presenta el estado de coma profundo de Alex y la necesidad de sincronizar el núcleo de su culpa.
2.  **ArcGameScreen (MindHackGame)**: El núcleo del juego. Interfaz de terminal vertical que simula el acceso al subconsciente.
3.  **ArcVictoryCinematic**: Pantalla de éxito de sincronía con acceso al Limbo.
4.  **ArcOutroScreen**: Epílogo perturbador con interferencias y revelación de que Alex es un "Testigo".

---

## 2. DISPOSICIÓN ESPACIAL (LAYOUT)
La pantalla de juego se organiza en tres capas verticales para optimizar la interacción táctil:

*   **ZONA SUPERIOR (Notificaciones)**: Área reservada para la `EvidenceCollectedNotification`. Aparece y desaparece sin solaparse con el puzzle activo.
*   **ZONA CENTRAL (Puzzle)**: Aquí es donde se renderiza el minijuego activo (`MindHackGame`). Ocupa aproximadamente el 70% del centro de la pantalla. Todo el 
gameplay es interactivo en este bloque central.
*   **ZONA INFERIOR (Status HUD)**:
    *   **Barra de INTEGRIDAD**: Se sitúa a ~150px del borde inferior (posicionada sobre la de tiempo). Es la prioridad visual del jugador.
    *   **Barra de TIEMPO**: Se sitúa en la base, justo debajo de la de Integridad, cerrando el HUD informativo.
    *   **Posicionamiento Técnico**: Las barras se centran horizontalmente con un ancho del 70% (`size.x * 0.7`).

---

## 3. GESTIÓN DE ORIENTACIÓN (DISPLAY)
El Arco 0 utiliza cambios de orientación forzados para dirigir la atención del jugador y adaptarse al tipo de contenido:

| Pantalla / Fase | Orientación | Razón de Diseño |
| :--- | :--- | :--- |
| **Intro (Briefing)** | `PORTRAIT` (Vertical) | Lectura cómoda de texto y preparación del terminal. |
| **Gameplay (MindHack)** | `PORTRAIT` (Vertical) | Simula una terminal de mano; facilita el uso de una mano para interactuar. |
| **Créditos (Victory Text)** | `PORTRAIT` (Vertical) | Mantiene el estilo de la terminal durante la confirmación inicial. |
| **Resultados (Stats)** | `LANDSCAPE` (Horizontal) | Espacio expandido para mostrar múltiples estadísticas una al lado de la otra sin desbordamientos. |
| **Epílogo (Outro)** | `PORTRAIT` (Vertical) | Genera una sensación claustrofóbica y opresiva para el cierre narrativo. |

*   **Nota Técnica**: El sistema fuerza el regreso a `PORTRAIT` al salir del arco o al entrar en el Game Over.

---

## 4. INTERFAZ Y HUD (MINDHACK TERMINAL)
La interfaz del Arco 0 es **vertical (Portrait)** y simula una terminal de hackeo multimodal.

### A. Barras de Estado (Status Bars)
Ubicadas en la parte inferior de la pantalla para visibilidad constante:
*   **Barra de INTEGRIDAD (Sanity)**: 
    *   **Comportamiento**: Representa la "salud mental" o estabilidad del enlace.
    *   **Colores**: Blanco (100%) -> Gris (50%) -> Negro (0%).
    *   **Visual**: Grosor de 8.0px con borde de contraste (0.12 opacity) para asegurar visibilidad en fondos oscuros.
*   **Barra de TIEMPO**: 
    *   **Comportamiento**: Cuenta regresiva por cada puzzle.
    *   **Color**: Rojo neón fijo.
    *   **Visual**: Ubicada justo debajo de la barra de Integridad.

### B. Sistema de Notificaciones Flotantes
Toda acción relevante debe generar feedback visual inmediato sin interrumpir el flujo del terminal:

*   **Evidencias (`EvidenceCollectedNotification`)**:
    *   **Trigger**: Se activa al completar con éxito un puzzle (un fragmento).
    *   **Diseño**: Caja semi-transparente en la parte superior.
    *   **Contenido**: Icono de carpeta `Icons.folder_open` + Texto "EVIDENCIA RECOLECTADA: [Nombre del Fragmento]".
    *   **Lógica**: Se usa un `Flexible` y `ConstrainedBox` para evitar desbordamientos en móviles estrechos. Dura 3 segundos en pantalla.
*   **Recompensas de Seguidores (`SnackBar` Cyberpunk)**:
    *   **Trigger**: Al sumar seguidores al balance del jugador.
    *   **Diseño**: Estilo terminal cian (`Color(0xFF00F0FF)`).
    *   **Contenido**: `+X SEGUIDORES GANADOS`.
    *   **Regla**: Se eliminó la notificación de "ITEM USADO" para recompensas para evitar confusión con el inventario.

---

## 3. LÓGICA DE FRAGMENTOS Y PERSISTENCIA (FRAGMENTS SYSTEM)
El Arco 0 registra el progreso técnico del jugador para desbloquear contenido en el Archivo y avanzar en la trama.

### A. Recolección de Fragmentos
*   Cada fase del terminal del Arco 0 (Fases 1 a 5) corresponde a un **Fragmento ID**.
*   **ID Estándar**: `arc_0_inicio_[N]`.
*   **Lógica de Guardado**:
    1. El minijuego (`MindHackGame`) invoca `saveFragment()`.
    2. Se comunica con el `FragmentsProvider` para marcar el fragmento como `unlocked`.
    3. Esto permite que el fragmento aparezca en la pantalla de "Archivos" (Archivo del Jugador).

### B. Progresión del Arco
*   **Marcador Global**: `evidenceCollected`.
*   **Persistencia**: Al ganar el arco completo, el `ArcGameScreen` llama a `_saveProgress()`.
*   **Contabilidad**:
    *   `baseReward`: 1000 seguidores (por ser el Arco 0).
    *   `fragmentBonus`: 200 seguidores adicionales por cada fragmento recolectado (Total potencial: +1000).
    *   `Battle Pass Bonus`: Multiplicador de 1.15x si el usuario tiene el pase activo.

---

## 4. SECCIONES Y MINIJUEGOS (PUZZLES)
El Arco 0 consta de **5 fases** de reconexión procedimentales. Cada una aumenta en complejidad y recompensa.

| Fase | Nombre del Módulo | ID de Fragmento | Recompensa (Seguidores) | Sanación (Integridad) |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **Handshake** | `arc_0_inicio_1` | +50 | +10% |
| 2 | **Conciencia** | `arc_0_inicio_2` | +100 | +15% |
| 3 | **Purga** | `arc_0_inicio_3` | +150 | +20% |
| 4 | **Memoria** | `arc_0_inicio_4` | +200 | +25% |
| 5 | **Aceptación** | `arc_0_inicio_5` | +500 | +40% |

---

## 5. RECONSTRUCCIÓN DE INTEGRIDAD (SANITY LOGIC)
El sistema de cordura en el Arco 0 se llama **INTEGRIDAD**.

*   **Drenaje**: El tiempo actúa como un drenaje constante (presión del sistema).
*   **Recuperación**:
    *   No hay regeneración pasiva (es un hackeo activo).
    *   La única forma de recuperar integridad es completando módulos con éxito.
*   **Muerte (0%)**: Dispara la pantalla de `GameOverScreen` con mensajes de burla aleatorios configurados en el `ArcDataProvider`.

---

## 6. CINEMÁTICAS FINALIZADORAS (ESTÁNDAR)

### A. Pantalla de Éxito (ArcVictoryCinematic)
*   **Estética**: Hacker/Tech-Noir. 
*   **Contenido**: 
    1.  **Mensaje de Sincronía**: `SINCRO_DETECTADA: ALEX - ESTABILIZADO EN EL LIMBO - BIENVENIDO AL ESPEJO`.
    2.  **Estadísticas**: Eslabones de Culpa (X de 5) y Seguidores del Juicio ganados.
*   **Orientación**: Cambia dinámicamente de Vertical a **Horizontal (Landscape)** para mostrar las estadísticas.

### B. Pantalla de Epílogo (ArcOutroScreen)
*   **Estética**: Glitch/Horror Psicológico.
*   **Comportamiento de Ofuscación**:
    1.  **Typewriter Errático**: El texto se detiene ante errores de sistema.
    2.  **Corrupción de Texto**: Los caracteres parpadean entre letras reales y símbolos (`Ø`, `Ł`, `€`, `¶`).
    3.  **Ráfagas de Error**: Inserción de códigos como `[DÅTÅ_PURG€_ERROR_XXX]`.
    4.  **Censura**: No permite saltar (No hay botón de SKIP).
*   **Orientación**: Regresa a **Vertical (Portrait)** para mayor claustrofobia.

---

## 7. FLUJOS LÓGICOS DEL USUARIO (USER DECISION TREE)
El sistema gestiona tres caminos principales basados en el desempeño y las decisiones del usuario:

### A. El Camino de la Sincronización (Victoria)
1. **Acción**: El usuario completa las 5 fases del terminal.
2. **Lógica**: 
   * `onVictory()` bloquea el motor de juego.
   * `_saveProgress()` persiste seguidores y fragmentos.
   * Dispara el flujo: `Cinemática Técnica` -> `Estadísticas (Landscape)` -> `Epílogo (Glitch)`.
3. **Resultado**: El arco se marca como completado y se desbloquea el siguiente en el menú principal.

### B. El Camino del Fracaso (Derrota)
1. **Acción**: La Integridad llega a 0% o el Tiempo se agota.
2. **Lógica**:
   * `onGameOver()` congela el juego.
   * No se guardan seguidores parciales ni fragmentos de esa sesión.
   * Muestra la `GameOverScreen` con el sistema de burlas (ver Sección 8).
3. **Opciones del Usuario**:
   * **Reintentar**: Reinicia el loop del Arco 0 desde la Fase 1.
   * **Salir**: Regresa al Menú Principal (forzando Portrait).

### C. El Camino de la Interrupción (Abandono Inevitable)
1. **Acción**: El usuario presiona el botón físico de "Atrás" del dispositivo.
2. **Lógica**:
   * **Sin Botón de Pausa**: El diseño del Arco 0 elimina intencionalmente el botón de pausa para generar una sensación de urgencia e inevitabilidad. El tiempo no se detiene.
   * **Abandono**: Toda interrupción fuera del flujo de victoria se considera un fallo en la sincronización.
3. **Resultado**: El progreso de la sesión actual se pierde por completo (no se guardan fragmentos ni monedas). El sistema no permite pausas en el hackeo del núcleo.

---

## 8. SISTEMA DE DERROTA Y PSICOLOGÍA DEL SISTEMA (MOCKING)
La derrota en el Arco 0 no es solo un fin de partida, es una herramienta narrativa para desalentar e incomodar al jugador.

### A. Lógica de Mensajes (The Mocking System)
Cuando el usuario pierde, el `ArcDataProvider` selecciona aleatoriamente de un pool de mensajes diseñados para atacar tres frentes:
*   **El Juicio**: Cuestiona la capacidad de Alex para aceptar sus actos ("No estás aquí para ganar, estás aquí para ser juzgado").
*   **Magnolia**: Ataca el único vínculo con el mundo real ("Magnolia te está perdiendo", "Magnolia no puede detenerse").
*   **La Verdad/Víctor**: Recuerda el trauma central ("Víctor sí recuerda el sonido de la alarma", "No puedes documentar tu propia muerte").

### B. Estética de la Derrota
*   **Color**: Rojo sangre dominante (`Colors.red.shade700`).
*   **Tipografía**: `PressStart2P` para el mensaje "GAME OVER" (estilo arcade clásico pero distorsionado).
*   **Atmósfera**: Fondo negro al 95% de opacidad para aislar el mensaje de fallo.
*   **Flavor Texts**: Textos adicionales de una sola línea que aparecen debajo del mensaje principal ("Tu persistencia es adorablemente inútil").

### C. Persistencia del Fracaso
*   A diferencia de otros juegos, el sistema "recuerda" visualmente que has fallado (el contador de intentos en el briefing puede aumentar implícitamente en la narrativa), reforzando la sensación de cansancio digital.

---

## 9. REGLAS DE ORO PARA NUEVOS ARCOS (MAINTENANCE)
1.  Toda la lógica de juego debe ser escalable en la clase `BaseArcGame`.
2.  Las barras de estado SIEMPRE deben usar el esquema Blanco-Gris-Negro para coherencia.
3.  Cualquier mensaje de victoria debe ir precedido por el éxito técnico antes de la revelación narrativa.
4.  El epílogo debe ser progresivamente más difícil de entender/leer a medida que avanza la trama.
5. El sistema de burlas ("Mocking") debe ser específico para cada pecado/arco.
