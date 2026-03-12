# 📖 DOCUMENTO COMPLETO - CONDICIÓN: HUMANO
## Guía Exhaustiva del Juego

**Fecha de Creación:** 27 de Enero, 2026  
**Versión del Juego:** 1.0 (Completo)  
**Estado:** Listo para Testing  
**Plataformas:** Android, iOS, Web, Desktop

---

## 📑 ÍNDICE

1. [Descripción General](#descripción-general)
2. [Concepto y Narrativa](#concepto-y-narrativa)
3. [Los 7 Pecados Digitales](#los-7-pecados-digitales)
4. [Flujo del Juego](#flujo-del-juego)
5. [Mecánicas de Juego](#mecánicas-de-juego)
6. [Sistemas del Juego](#sistemas-del-juego)
7. [Pantallas y UI](#pantallas-y-ui)
8. [Tienda y Monetización](#tienda-y-monetización)
9. [Multijugador](#multijugador)
10. [Logros y Leaderboard](#logros-y-leaderboard)
11. [Expedientes Completos](#expedientes-completos)
12. [Arquitectura Técnica](#arquitectura-técnica)
13. [Estado de Desarrollo](#estado-de-desarrollo)
14. [Guía de Testing](#guía-de-testing)

---

## 🎮 DESCRIPCIÓN GENERAL

**CONDICIÓN: HUMANO** es un juego narrativo de terror psicológico y suspenso que explora las consecuencias devastadoras del acoso digital, la viralización de contenido humillante y la deshumanización en redes sociales.

### Características Principales

- **Género:** Terror Psicológico + Aventura de Sigilo + Puzzle Narrativo
- **Perspectiva:** Top-down 2D
- **Duración:** 35-56 minutos (juego completo)
- **Arcos Narrativos:** 7 historias completas
- **Mecánicas Únicas:** Cada arco tiene su propia mecánica distintiva
- **Propósito:** Reflexión sobre empatía digital y consecuencias reales de acciones virtuales

### Premisa Central

El jugador no es un héroe. Eres un perpetrador anónimo que ha cometido actos de humillación digital contra siete víctimas diferentes. Cada arco te obliga a enfrentar las consecuencias de tus acciones mientras intentas escapar de las "máscaras" que representan a tus víctimas.


---

## 🎭 CONCEPTO Y NARRATIVA

### Tema Central

El juego es un comentario social brutal sobre:
- **Ciberacoso y vigilancia digital**
- **Viralización de contenido humillante**
- **Deshumanización en redes sociales**
- **Pérdida de empatía digital**
- **Consecuencias reales de acciones virtuales**
- **Culpa, vergüenza y redención**

### Estructura Narrativa

Cada arco sigue un patrón de tres actos:

**ACTO 1: LA AMENAZA**
- Recibes un mensaje amenazante de una víctima
- Te obligan a ir a una ubicación específica
- Descubres que la víctima te está esperando con una máscara

**ACTO 2: LA PERSECUCIÓN**
- Debes recolectar 5 fragmentos de evidencia (pruebas de tu crimen)
- Un enemigo (la víctima enmascarada) te persigue
- Cada fragmento revela más sobre el daño que causaste

**ACTO 3: LA REVELACIÓN**
- Escapas con la evidencia
- Una cinemática muestra las consecuencias devastadoras de tus acciones
- La pregunta final: "¿Valió la pena?"

### Cinemática de Apertura (Primera Vez)

```
[PANTALLA NEGRA]

Tu teléfono vibra.
7 llamadas perdidas.
7 mensajes desconocidos.

"TE ENCONTRAMOS"
"RECUERDA QUÉ HICISTE"
"CADA UNO TENDRÁ SU TURNO"

[GLITCH]

No recuerdas qué hiciste.
Pero ELLOS sí.

SIETE VÍCTIMAS.
SIETE MÁSCARAS.
SIETE PECADOS.

[FADE TO BLACK]
```


---

## 🔥 LOS 7 PECADOS DIGITALES

### ARCO 1: GULA 🍽️ - "El Banquete de los Desechos"

**Víctima:** Mateo (19 años)  
**Pecado:** Compartir video humillante de alguien comiendo  
**Ubicación:** Almacén abandonado  
**Enemigo:** Sabueso de la Gula (Máscara de cerdo)  
**Duración:** 5-8 minutos

**Historia:**
Compartiste un video de Mateo comiendo desesperadamente de la basura. El video se volvió viral con 2.3 millones de vistas. Los comentarios fueron brutales: "Miren a este gordo comiendo basura", "Qué asco de persona". Mateo leyó cada comentario. Dejó de comer. Dejó de salir de su casa. Intentó suicidarse.

**Mecánica Única:** Sistema de Peso
- Cada evidencia recolectada te hace más lento (-10% velocidad)
- Con 5 evidencias puedes lanzar comida para distraer al enemigo
- Balance entre movilidad y poder de fuego

**Cinemática Pre-Arco:**
```
Abres los ojos. Oscuridad.
Tu teléfono vibra:
"Dirección: Almacén 7"
"Ven solo. O todos lo sabrán."

Algo se mueve en la oscuridad.
Algo hambriento.
Una máscara de cerdo emerge.

RUN.
```

**Cinemática Post-Arco:**
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

---

### ARCO 2: AVARICIA 💰 - "El Precio de un Click"

**Víctima:** Valeria (34 años)  
**Pecado:** Robar y difundir información financiera  
**Ubicación:** Banco Nacional - Bóveda C  
**Enemigo:** Banquero Avaro (Máscara de rata)  
**Duración:** 5-8 minutos

**Historia:**
Compartiste información privada de Valeria: número de cuenta, dirección, datos bancarios. Todo extraído de una foto inocente. La gente la doxxeó completamente. Perdió su casa, sus ahorros, sus hijos fueron acosados. Tú ganaste 15,632 likes.

**Mecánica Única:** Robo de Recursos
- La Rata roba tus evidencias cuando te atrapa
- Pierdes 10% de cordura por cada robo
- Cooldown de 5 segundos entre robos
- Cajas registradoras recuperan 50% de cordura

**Cinemática Pre-Arco:**
```
Llamada desconocida. Contestas.
"Hola, P-L-A-Y-E-R."

"¿Recuerdas lo que compartiste?"
[Cuelga]

Mensaje nuevo:
"Banco Nacional - Bóveda C"
"Recupera lo que robaste."

Una máscara de rata.
"Tú robaste mi vida.
Ahora robaré la tuya."
```

**Cinemática Post-Arco:**
```
Compartiste algo que no debías.
Número de cuenta: ████████
Dirección: █████████

Valeria lo perdió todo.
Su casa. Sus ahorros. Sus hijos.

Tú ganaste 15,632 likes.

¿Valió la pena?
```


---

### ARCO 3: ENVIDIA 💚 - "Reflejo en el Espejo"

**Víctima:** Lucía (28 años)  
**Pecado:** Humillación por apariencia física  
**Ubicación:** Gimnasio Atlas  
**Enemigo:** Camaleón Espejo (Máscara de camaleón)  
**Duración:** 5-8 minutos

**Historia:**
Comparaste fotos de Lucía: "Antes vs Después FAIL". Los comentarios fueron devastadores. Ella desarrolló anorexia severa, bajó a 38.5 kg, casi muere. Cada comparación era un golpe. Cada comentario, una herida. Ella cambió. Tú seguiste igual.

**Mecánica Única:** Espejo Adaptativo - SIN ESCONDITES
- El enemigo imita tus movimientos
- Se vuelve más rápido con cada evidencia (+15% velocidad)
- NO hay lugares para esconderse
- Puro movimiento y evasión

**Cinemática Pre-Arco:**
```
Mensaje directo de cuenta bloqueada:
"Hola. ¿Me recuerdas?"
[FOTO ADJUNTA: Antes/Después]

"Gimnasio Atlas. 3era Ave."
"Ven a verme."
"Tal vez ahora SOY suficiente para ti."

Una máscara de camaleón.
Se mueve exactamente como tú.
"¿Ahora me ves?"
```

**Cinemática Post-Arco:**
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

---

### ARCO 4: LUJURIA 🕷️ - "Red de Tentación"

**Víctima:** Adriana (25 años)  
**Pecado:** Sextorsión y chantaje  
**Ubicación:** Club nocturno abandonado  
**Enemigo:** Araña Depredadora (Máscara de araña)  
**Duración:** 5-8 minutos

**Historia:**
Obtuviste fotos íntimas de Adriana y las usaste para chantajearla. Cuando se negó, las compartiste. Su vida se destruyó: perdió su trabajo, su familia la rechazó, intentó suicidarse dos veces. Las fotos siguen circulando. Ella nunca podrá escapar.

**Mecánica Única:** Teletransportación + Redes
- La araña se teletransporta aleatoriamente cada 8 segundos
- Crea redes que ralentizan tu movimiento (-50%)
- 6 puntos de teletransporte fijos
- Debes predecir y evadir

**Mapa:** 2400x1600 (extendido a 5600x800 para más complejidad)

---

### ARCO 5: SOBERBIA 🦁 - "Arena del Poder"

**Víctima:** Carlos (32 años)  
**Pecado:** Fraude de influencer  
**Ubicación:** Estudio de grabación  
**Enemigo:** León Orgulloso (Máscara de león)  
**Duración:** 10-12 minutos (EL MÁS LARGO)

**Historia:**
Expusiste el fraude de Carlos como influencer: productos falsos, estafas, mentiras. Pero lo hiciste de forma cruel y humillante. Su carrera se destruyó, perdió todo, su familia lo abandonó. Él tenía razón en algunas cosas, pero tú lo convertiste en un monstruo.

**Mecánica Única:** Escalada de Poder
- **Fase 1 (0-2min):** León débil, velocidad x1
- **Fase 2 (2-4min):** León sube, velocidad x1.5
- **Fase 3 (4-6min):** León fuerte, velocidad x2
- **Fase 4 (6+min):** León IMPARABLE, velocidad x3
- 5 Tronos de Poder donde el león se fortalece
- ESTRATEGIA: ¡RUSH! Recolecta evidencia rápido

**Mapa:** 2400x1600 (extendido a 5600x800)


---

### ARCO 6: PEREZA 😴 - "Hospital de Gris"

**Víctima:** Miguel (45 años)  
**Pecado:** Negligencia médica expuesta cruelmente  
**Ubicación:** Hospital abandonado  
**Enemigo:** Babosa Durmiente (Máscara de perezoso)  
**Duración:** 8-10 minutos

**Historia:**
Miguel era un médico que cometió un error por agotamiento. Tú lo expusiste de la forma más cruel posible. Lo convertiste en un monstruo. Perdió su licencia, su familia, su vida. Se volvió adicto a las drogas para olvidar. El error fue real, pero tu crueldad fue peor.

**Mecánica Única:** Detección de Ruido
- El enemigo está DORMIDO pero vigilante
- **Correr (Sprint):** Ruido 100% → Enemigo DESPIERTA
- **Caminar (Walk):** Ruido 30% → Enemigo activo
- **Rastrear (Crawl):** Ruido 5% → Muy sigiloso
- **Esperar (Still):** Ruido 0% → Enemigo se ADORMECE

**Sistema de Sueño del Enemigo (0-100%):**
- >80% dormido: NO persigue
- Esperar lo sube
- Tu ruido lo baja rápido
- 10 charcos de lodo que ralentizan
- NO HAY ESCONDITES (puro sigilo)

**Mapa:** 2400x1600 (extendido a 5600x800)

---

### ARCO 7: IRA ⚡ - "Infierno Rojo"

**Víctima:** Víctor (38 años)  
**Pecado:** Exposición de violencia doméstica  
**Ubicación:** Casa en llamas  
**Enemigo:** Toro Furioso (Máscara de toro)  
**Duración:** 6-8 minutos

**Historia:**
Víctor era un abusador. Tú expusiste su violencia doméstica. Pero lo hiciste por likes, no por justicia. Convertiste el dolor de su familia en entretenimiento. Él fue a prisión, pero su familia quedó destrozada. Los hijos perdieron a ambos padres. Tú ganaste seguidores.

**Mecánica Única:** Persecución Imparable
- El toro NUNCA se rinde
- NO tiene patrulla: SIEMPRE viene hacia ti
- Más rápido que tú (1.5x velocidad)
- SOLO escondites detienen persecución
- Obstáculos lo ralentizan ligeramente

**Fases de Velocidad:**
- **Normal:** Velocidad 300
- **Te ve (200px):** Velocidad 450
- **Te persigue cerca:** Velocidad 600

**Peligros Ambientales:**
- 8 zonas de fuego y vapor
- Daño constante si tocas
- Screen shake intenso
- Drain rápido de sanidad

**Mapa:** 2400x1600 (extendido a 5600x800)

---

## 📊 COMPARATIVA DE ARCOS

| Arco | Víctima | Pecado | Mecánica Única | Duración | Dificultad |
|------|---------|--------|----------------|----------|------------|
| 1. Gula | Mateo | Humillación alimentaria | Sistema de Peso | 5-8 min | ⭐⭐ |
| 2. Avaricia | Valeria | Robo de datos | Robo de Recursos | 5-8 min | ⭐⭐⭐ |
| 3. Envidia | Lucía | Comparación cruel | Sin Escondites | 5-8 min | ⭐⭐⭐⭐ |
| 4. Lujuria | Adriana | Sextorsión | Teletransporte + Redes | 5-8 min | ⭐⭐⭐ |
| 5. Soberbia | Carlos | Fraude expuesto | Escalada de Poder | 10-12 min | ⭐⭐⭐⭐⭐ |
| 6. Pereza | Miguel | Negligencia médica | Detección de Ruido | 8-10 min | ⭐⭐⭐⭐ |
| 7. Ira | Víctor | Violencia doméstica | Persecución Imparable | 6-8 min | ⭐⭐⭐⭐ |

**Duración Total:** 35-56 minutos


---

## 🎮 FLUJO DEL JUEGO

### Progresión Completa del Usuario

```
INICIO
  ↓
1. SPLASH SCREEN (Logo + Carga)
  ↓
2. AUTH SCREEN (Login/Registro con Firebase)
  ↓
3. INTRO SCREEN (Cinemática perturbadora - Saltable)
  ↓
4. MENU SCREEN (Lobby Principal)
  ├─→ PLAY
  │    ↓
  │    5. ARC SELECTION SCREEN (Elegir 1 de 7 arcos)
  │    ↓
  │    6. ARC INTRO SCREEN (Cinemática pre-arco)
  │    ↓
  │    7. ITEM SELECTION SCREEN (Elegir loadout)
  │    ↓
  │    8. ARC GAME SCREEN (JUEGO PRINCIPAL)
  │    ↓
  │    9. VICTORY SCREEN / GAME OVER
  │    ↓
  │    10. ARC OUTRO SCREEN (Cinemática post-arco)
  │    ↓
  │    11. ARCHIVE SCREEN (Galería de evidencias)
  │    ↓
  │    [Si completaste 3 arcos → DEMO ENDING SCREEN]
  │    [Si completaste 7 arcos → TRUE ENDING SCREEN]
  │
  ├─→ STORE
  │    ↓
  │    12. STORE SCREEN
  │    ├─→ Featured (Destacados)
  │    ├─→ Items (Consumibles)
  │    ├─→ Skins (Apariencias)
  │    ├─→ Special (Limitados)
  │    └─→ Battle Pass
  │         ↓
  │         13. COINS PURCHASE SCREEN (Comprar monedas)
  │
  ├─→ ARCHIVE
  │    ↓
  │    14. ARCHIVE SCREEN (Ver fragmentos recolectados)
  │    ↓
  │    15. CASE FILE SCREEN (Expedientes completos)
  │
  ├─→ MULTIPLAYER
  │    ↓
  │    16. MULTIPLAYER LOBBY SCREEN
  │    ├─→ Crear Partida (Genera código)
  │    └─→ Unirse a Partida (Ingresa código)
  │         ↓
  │         17. ALGORITHM GAME SCREEN (Juego asimétrico)
  │         ↓
  │         18. MULTIPLAYER RESULT SCREEN
  │
  ├─→ ACHIEVEMENTS (Esquina inferior derecha)
  │    ↓
  │    19. ACHIEVEMENTS SCREEN (17 logros)
  │
  ├─→ LEADERBOARD (Esquina inferior derecha)
  │    ↓
  │    20. LEADERBOARD SCREEN (Top 100)
  │
  ├─→ SETTINGS (Esquina inferior izquierda)
  │    ↓
  │    21. SETTINGS SCREEN
  │    ├─→ Audio (Volumen, Vibración)
  │    ├─→ Gráficos (Calidad, Efectos)
  │    ├─→ Gameplay (Dificultad, Controles)
  │    ├─→ Privacidad
  │    ├─→ Cuenta
  │    └─→ Ver Estadísticas
  │         ↓
  │         22. STATS SCREEN (Progreso detallado)
  │
  └─→ EXIT (Guardar y Salir)
```


---

## 🕹️ MECÁNICAS DE JUEGO

### Gameplay Core (Arc Game Screen)

**Objetivo Principal:**
Recolectar 5 fragmentos de evidencia y llegar a la puerta de salida sin ser capturado.

### Controles

**PC/Desktop:**
- **W/↑** - Mover arriba
- **A/←** - Mover izquierda
- **S/↓** - Mover abajo
- **D/→** - Mover derecha
- **E / Click Derecho** - Usar item
- **ESPACIO** - Saltar/Interactuar
- **ESC** - Saltar cinemática / Pausar
- **M** - Abrir mapa (si disponible)

**Mobile/Táctil:**
- **Joystick izquierdo** - Movimiento (8 direcciones)
- **Botón derecho** - Usar item
- **Deslizar arriba** - Interactuar
- **Tap dos veces** - Sprint

### Sistema de Movimiento

**Velocidades:**
- **Caminar:** 200 px/s (base)
- **Correr:** 300 px/s (+50%)
- **Modificadores por arco:**
  - Gula: -10% por evidencia recolectada
  - Pereza: -40% velocidad constante
  - Otros: Velocidad normal

### Sistema de Cordura (Sanity)

**Rango:** 0.0 - 1.0 (0% - 100%)

**Pérdida de Cordura:**
- Enemigo cerca (< 200px): -0.05/segundo
- Enemigo muy cerca (< 100px): -0.1/segundo
- Ser atrapado: -0.3 instantáneo
- Mecánicas específicas por arco

**Recuperación de Cordura:**
- Esconderse: +0.02/segundo
- Alejarse del enemigo: +0.01/segundo
- Items especiales: +0.2 instantáneo

**Efectos Visuales por Nivel de Cordura:**
- **100-75%:** Normal
- **75-50%:** Viñeta leve, ligero glitch
- **50-25%:** Viñeta media, glitch frecuente, vibración
- **25-0%:** Viñeta intensa, glitch constante, screen shake
- **0%:** GAME OVER

### Sistema de Evidencias

**Cantidad:** 5 fragmentos por arco (35 total en el juego)

**Recolección:**
1. Caminar sobre el fragmento
2. Animación de recolección (0.5s)
3. Contador aumenta: X/5
4. Efecto visual: Pantalla se fractura más
5. Narrativa se desbloquea en Archive

**Progresión de Fractura:**
- Fragmento 1: 1 grieta
- Fragmento 2: 2-3 grietas
- Fragmento 3: Múltiples grietas
- Fragmento 4: Mayoría roto
- Fragmento 5: Casi completamente ilegible

### Sistema de Escondites

**Función:** Lugares donde el jugador puede ocultarse del enemigo

**Mecánica:**
- Presionar botón de acción cerca del escondite
- Jugador se vuelve invisible para el enemigo
- NO puedes moverte mientras estás escondido
- Opacidad reducida al 30%
- Salir: Presionar botón de acción nuevamente

**Cantidad por Arco:**
- Arcos 1-2: 6 escondites
- Arco 3: 0 escondites (mecánica única)
- Arcos 4-7: 5-6 escondites

**Limitaciones:**
- Algunos arcos drenan cordura mientras estás escondido
- Enemigos pueden "sospechar" si te escondes mucho

### Sistema de Items

**Tipos de Items:**

1. **Aturdidor** - Stun al enemigo por 2 segundos
2. **Invisibilidad** - 5 segundos sin ser detectado
3. **Boost de Velocidad** - +50% velocidad por 3 segundos
4. **Mapa Temporal** - Revela ubicación del enemigo por 3 segundos
5. **Escudo** - Absorbe 1 golpe
6. **Linterna** - Ilumina área (próximamente)
7. **Micrófono Scrambler** - Distorsiona audio del enemigo
8. **Camuflaje** - Se mezcla con el fondo (próximamente)

**Uso:**
- Seleccionar hasta 3 items antes de iniciar arco
- Usar con botón de acción (E o botón táctil)
- Cooldown de 5 segundos entre usos
- Cantidad limitada por partida


### Sistema de Enemigos (IA)

**Comportamientos Base:**

1. **Patrullaje (Patrol)**
   - Enemigo se mueve entre waypoints predefinidos
   - Velocidad: 150-200 px/s
   - Busca al jugador visualmente

2. **Persecución (Chase)**
   - Activado cuando detecta al jugador
   - Velocidad: 250-600 px/s (según arco)
   - Sigue al jugador directamente

3. **Búsqueda (Search)**
   - Activado cuando pierde de vista al jugador
   - Busca en última posición conocida
   - Duración: 5-10 segundos

4. **Ataque (Attack)**
   - Cuando alcanza al jugador
   - Daño: -30% cordura
   - Knockback: Empuja al jugador

**Enemigos Específicos:**

| Arco | Enemigo | Velocidad | Habilidad Especial |
|------|---------|-----------|-------------------|
| 1. Gula | Sabueso | 250 px/s | Devora evidencias |
| 2. Avaricia | Rata | 280 px/s | Roba recursos |
| 3. Envidia | Camaleón | 200-350 px/s | Imita movimientos |
| 4. Lujuria | Araña | 300 px/s | Teletransporte |
| 5. Soberbia | León | 200-600 px/s | Escalada de poder |
| 6. Pereza | Babosa | 150 px/s | Detección de ruido |
| 7. Ira | Toro | 300-600 px/s | Persecución imparable |

### Sistema de Colisiones

**Tipos de Colisiones:**

1. **Paredes (Walls)**
   - Bloques sólidos que detienen movimiento
   - Generados dinámicamente por arco
   - Hitbox: Rectángulo preciso

2. **Obstáculos**
   - Objetos que ralentizan pero no detienen
   - Ejemplo: Charcos, mesas, escombros
   - Reducción de velocidad: 30-50%

3. **Zonas de Peligro**
   - Áreas que drenan cordura
   - Ejemplo: Fuego, vapor, oscuridad
   - Daño: -0.05/segundo

**Detección:**
- Sistema de hitbox rectangular
- Rollback si colisión detectada
- Separación de ejes (X e Y independientes)

### Sistema de Victoria/Derrota

**Condiciones de Victoria:**
1. Recolectar 5/5 evidencias
2. Llegar a la puerta de salida
3. Interactuar con la puerta
4. → VICTORY SCREEN

**Condiciones de Derrota:**
1. Cordura llega a 0%
2. → GAME OVER SCREEN
3. Opciones: Reintentar / Volver al menú

**Estadísticas de Victoria:**
- Tiempo total
- Items usados
- Daño recibido
- Fragmentos recolectados (5/5)
- Puntuación (0-100)


---

## 🎨 PANTALLAS Y UI

### 1. Splash Screen
- Logo del juego
- Animación de carga
- Duración: 2-3 segundos

### 2. Auth Screen
- Login con email/contraseña
- Registro de nuevos usuarios
- Login con Google (opcional)
- Recuperación de contraseña
- Integración con Firebase Auth

### 3. Intro Screen (Primera Vez)
- Cinemática perturbadora
- Texto typewriter
- Notificaciones falsas
- Efecto glitch
- Botón "SALTAR [ESC]"
- Duración: 30-45 segundos

### 4. Menu Screen (Lobby Principal)
- Fondo de video oscuro (lobby.mp4)
- 6 botones principales:
  - **PLAY** - Entrar a los arcos
  - **STORE** - Tienda
  - **ARCHIVE** - Galería
  - **MULTIPLAYER** - Modo cooperativo
  - **SETTINGS** - Configuración
  - **EXIT** - Salir
- Botones secundarios (esquina inferior):
  - **Logros** (trofeo)
  - **Leaderboard** (clasificación)
- Audio ambiente (risas, sonidos oscuros)
- Notificaciones falsas del sistema

### 5. Arc Selection Screen
- Grid de 7 arcos
- Cada arco muestra:
  - Título (Gula, Avaricia, etc.)
  - Descripción breve
  - Progreso (0/5, 3/5, 5/5)
  - Estado (Bloqueado/Desbloqueado)
  - Icono representativo
- Animación de hover
- Botón "VOLVER"

### 6. Arc Intro Screen
- Fondo negro
- Texto typewriter (40-50ms por letra)
- Narrativa pre-arco
- Música tensa
- Botón "SALTAR [ESC]"
- Duración: 25-30 segundos

### 7. Item Selection Screen
- Grid de items disponibles
- Cada item muestra:
  - Icono
  - Nombre
  - Descripción
  - Rareza (común, raro, épico, legendario)
  - Costo en monedas (si no está comprado)
- Límite: Máximo 3 items
- Botón "CONFIRMAR"
- Botón "VOLVER"

### 8. Arc Game Screen (JUEGO PRINCIPAL)
- Vista top-down 2D
- Mapa: 2400x1600 (o extendido)
- HUD superior:
  - Barra de cordura (0-100%)
  - Contador de evidencias (X/5)
  - Timer (opcional)
- HUD inferior:
  - Virtual Joystick (mobile)
  - Botón de acción
  - Items equipados (3 slots)
- Botón de pausa (esquina superior derecha)
- Efectos visuales:
  - Viñeta (según cordura)
  - Glitch (según cordura)
  - Fracturas (según evidencias)

### 9. Pause Menu
- Fondo semi-transparente
- Opciones:
  - **REANUDAR**
  - **CONFIGURACIÓN**
  - **REINICIAR**
  - **VOLVER AL MENÚ**
- Estadísticas actuales:
  - Tiempo transcurrido
  - Evidencias: X/5
  - Cordura: X%

### 10. Victory Screen
- Animación de victoria
- Estadísticas finales:
  - Tiempo total
  - Items usados
  - Daño recibido
  - Fragmentos: 5/5
  - Puntuación: X/100
- Botón "CONTINUAR"

### 11. Game Over Screen
- Pantalla roja/oscura
- Mensaje de derrota (según arco)
- Flavor text
- Opciones:
  - **REINTENTAR**
  - **VOLVER AL MENÚ**

### 12. Arc Outro Screen
- Fondo negro
- Texto typewriter
- Cinemática post-arco
- Revelación de consecuencias
- Pregunta final: "¿Valió la pena?"
- Música triste/perturbadora
- Duración: 30-45 segundos
- Botón "CONTINUAR"

### 13. Archive Screen
- 7 pestañas (una por arco)
- Grid de 5 fragmentos por arco
- Estados:
  - **Bloqueado 🔒** - Silueta oscura, "???"
  - **Recolectado ✅** - Imagen visible, clickeable
- Filtros:
  - Todo
  - Capturas
  - Mensajes
  - Videos
  - Audio
- Indicador REC (esquina inferior derecha)
- Botón "VER EXPEDIENTE" (si arco completo)

### 14. Case File Screen
- Expediente completo del arco
- 5 documentos narrativos
- Navegación entre documentos
- Scroll vertical
- Botón "VOLVER"
- Efecto VHS
- Música ambiente tensa


### 15. Store Screen
- 5 categorías:
  - **Featured** (Destacados)
  - **Items** (Consumibles)
  - **Skins** (Apariencias)
  - **Special** (Limitados)
  - **Battle Pass**
- Grid de productos
- Cada producto muestra:
  - Imagen/Preview
  - Nombre
  - Descripción
  - Precio en monedas
  - Botón "COMPRAR" / "EQUIPAR"
- Contador de monedas (esquina superior)
- Botón "COMPRAR MONEDAS"

### 16. Coins Purchase Screen
- Paquetes de monedas:
  - 100 monedas - $0.99
  - 500 monedas - $4.99
  - 1,000 monedas - $8.99
  - 2,500 monedas - $19.99
- Integración con Stripe
- Métodos de pago
- Bonificaciones por primera compra
- Botón "VOLVER"

### 17. Multiplayer Lobby Screen
- Opciones:
  - **CREAR PARTIDA** - Genera código de 6 caracteres
  - **UNIRSE A PARTIDA** - Ingresa código
- Lista de jugadores en espera
- Botón "LISTO"
- Chat (opcional)
- Selección de rol:
  - Usuario (Víctima)
  - Algoritmo (Cazador)

### 18. Algorithm Game Screen
- Vista táctica/cenital para Algoritmo
- Mapa esquemático
- Señales de ruido del Usuario
- Panel de habilidades:
  - Ping de la Muerte
  - Glitch Visual
  - Lag Spike
  - Notificación Fantasma
  - Materializar Enemigo
- Contador de "Datos" (mana)
- Estado del Usuario (cordura, evidencias)

### 19. Multiplayer Result Screen
- Ganador/Perdedor
- Estadísticas de ambos jugadores
- Puntos ganados
- Botón "REVANCHA"
- Botón "VOLVER AL LOBBY"

### 20. Achievements Screen
- Lista de 17 logros
- Categorías:
  - Historia (5)
  - Colección (5)
  - Habilidad (3)
  - Especiales (4)
- Cada logro muestra:
  - Icono
  - Nombre
  - Descripción
  - Recompensa (monedas)
  - Estado (Bloqueado/Desbloqueado)
- Logros secretos (ocultos hasta desbloquear)
- Progreso total: X/17

### 21. Leaderboard Screen
- Top 100 jugadores globales
- Información por jugador:
  - Posición (#1, #2, etc.)
  - Avatar/Skin
  - Nombre de usuario
  - Puntuación total
  - Arcos completados
- Tu posición destacada
- Medallas para top 3 (🥇🥈🥉)
- Botón "ACTUALIZAR"
- Filtros (próximamente):
  - Global
  - Amigos
  - Regional

### 22. Settings Screen
- **Audio:**
  - Volumen Maestro (0-100%)
  - Volumen Música (0-100%)
  - Volumen SFX (0-100%)
  - Vibración (On/Off)
- **Gráficos:**
  - Calidad (Baja, Media, Alta)
  - Efectos Glitch (On/Off)
  - Efectos VHS (On/Off)
  - FPS Máximo (30/60)
- **Gameplay:**
  - Dificultad (Fácil, Normal, Difícil, Hardcore)
  - Controles (Táctiles, Teclado, Mando)
  - Subtítulos (On/Off)
  - Idioma (Español, Inglés, etc.)
- **Privacidad:**
  - Compartir datos (On/Off)
  - Notificaciones (On/Off)
- **Cuenta:**
  - Nombre de usuario
  - Email
  - Cambiar contraseña
  - Cerrar sesión
  - Eliminar cuenta
- Botón "VER ESTADÍSTICAS"

### 23. Stats Screen
- Resumen general:
  - Monedas totales
  - Fragmentos recolectados (X/35)
  - Arcos completados (X/7)
  - Tiempo total jugado
- Progreso por arco:
  - Barra de progreso (0-100%)
  - Fragmentos: X/5
  - Mejor tiempo
  - Muertes
- Inventario:
  - Items poseídos
  - Skins poseídas
  - Battle Pass (Sí/No)
- Botón "VOLVER"

### 24. Demo Ending Screen (Después de 3 arcos)
- Simulación de doxxeo
- Fases:
  1. Recapitulación
  2. Activación de cámara (falsa)
  3. Perfil generado
  4. Subida a redes (falsa)
  5. Transmisión EN VIVO (falsa)
  6. Comentarios crueles (falsos)
  7. Mensajes de víctimas
  8. Pausa incómoda
  9. REVELACIÓN - Era falso
  10. Reflexión final
  11. Cierre
- Duración: 2-3 minutos
- Efectos: Vibración, notificaciones falsas
- Propósito: Impacto emocional

### 25. True Ending Screen (Después de 7 arcos)
- Final narrativo completo
- Múltiples finales según decisiones
- Cinemática extendida
- Créditos
- Contenido no disponible en demo


---

## 🛒 TIENDA Y MONETIZACIÓN

### Sistema de Monedas

**Moneda Virtual:** Coins (Monedas)

**Formas de Obtener Monedas:**
1. Completar arcos (100-500 monedas/arco)
2. Desbloquear logros (50-500 monedas/logro)
3. Pase de batalla (recompensas progresivas)
4. Compra con dinero real

**Paquetes de Compra:**
- 100 monedas - $0.99 USD
- 500 monedas - $4.99 USD
- 1,000 monedas - $8.99 USD (Mejor precio)
- 2,500 monedas - $19.99 USD (MEGA OFERTA)

**Bonificaciones:**
- Primera compra: +20% monedas extra
- Compras recurrentes: +10% bonus

### Categorías de la Tienda

#### 1. ITEMS (Consumibles/Herramientas)
- Aturdidor - 50 monedas
- Invisibilidad - 75 monedas
- Boost de Velocidad - 60 monedas
- Mapa Temporal - 40 monedas
- Escudo - 100 monedas
- Linterna - 30 monedas (próximamente)
- Micrófono Scrambler - 80 monedas
- Camuflaje - 90 monedas (próximamente)

#### 2. SKINS (Apariencias del Jugador)

**Común (50-100 monedas):**
- Default - Gratis
- Usuario - Gratis
- Fantasma - Gratis

**Profesional (100-150 monedas):**
- Hacker - Hoodie, gafas VR
- Corporativo - Traje formal
- Agente - Ropa negra, estilo espía
- Periodista - Blazer, micrófono

**Alternativo (150-250 monedas):**
- Punk - Pelo verde, chaqueta de cuero
- Gótico - Ropa oscura, maquillaje
- Cyberpunk - Hoodie neon, accesorios tech
- Sombra - Negro puro, apenas visible

**Épico (250-500 monedas):**
- Deidad Digital - Aura brillante
- Ángel Caído - Alas oscuras, corona rota
- Demonio - Cuernos, aura roja
- Replicante - Aparición glitch
- Espectro - Fantasma translúcido

**Legendario (500+ monedas):**
- The Watcher - Ojo omnisciente
- Void - Agujero negro personificado
- Algoritmo Vivo - Código digital
- La Verdad - Forma imposible
- El Judas - Humano traidor

#### 3. BATTLE PASS
- **Precio:** $9.99 USD / 300 monedas
- **Niveles:** 50 niveles
- **Recompensas:**
  - Monedas (acumulativo)
  - Skins exclusivas
  - Items especiales
  - Emotes/Personalizaciones
  - Contenido narrativo

**Progresión:**
- Completar arcos: +500 XP
- Recolectar fragmentos: +100 XP
- Logros: +200 XP
- Multijugador: +150 XP/partida

#### 4. ESPECIAL (Limitados/Temporales)
- Skins de Halloween
- Skins de Navidad
- Bundles exclusivos
- Colaboraciones con artistas

### Integración de Pagos

**Plataformas:**
- Stripe (Web/Desktop)
- Google Play Billing (Android)
- App Store Billing (iOS)

**Seguridad:**
- Transacciones encriptadas
- Verificación de compra
- Recibos digitales
- Soporte de reembolso


---

## 👥 MULTIJUGADOR: "PROTOCOLO DE CONEXIÓN"

### Concepto: Usuario vs Algoritmo

**Tipo:** 1v1 Asimétrico de Terror Psicológico

**Premisa:** Un jugador es el Usuario (víctima) atrapado en el nivel. El otro es el Algoritmo (cazador), una entidad sin cuerpo que controla el entorno.

### Roles y Objetivos

#### JUGADOR 1: EL USUARIO (La Víctima)
- **Vista:** Tercera persona (igual que modo historia)
- **Objetivo:** Recolectar 3 "Llaves de Encriptación" y llegar al "Puerto de Salida"
- **Mecánicas:**
  - Sigilo: Moverse lento evita detección
  - VPN (Activa): Invisible al radar por 5 segundos
  - Antivirus (Pasiva): Reduce duración de efectos
- **Tensión:** No puedes ver al Algoritmo, solo sientes su presencia

#### JUGADOR 2: EL ALGORITMO (El Cazador)
- **Vista:** Cenital / Mapa Táctico
- **Objetivo:** Drenar la Cordura del Usuario a 0 o impedir escape
- **Limitación:** No ves al Usuario en tiempo real, solo señales de ruido
- **Recurso:** "Datos" (Mana) - Se recarga lentamente

### Habilidades del Algoritmo

| Habilidad | Coste | Efecto | Intensidad |
|-----------|-------|--------|------------|
| **PING DE LA MUERTE** | Bajo | Vibración real del teléfono | Alta |
| **GLITCH VISUAL** | Medio | Ciega parcialmente 3s | Media |
| **LAG SPIKE** | Medio | -50% velocidad por 4s | Media |
| **NOTIFICACIÓN FANTASMA** | Bajo | Sonido falso de enemigo | Baja |
| **MATERIALIZAR** | Alto | Invoca enemigo NPC | Muy Alta |

### Dinámica de Juego

**Loop de Juego:**
1. **Fase de Silencio:** Usuario se mueve sigilosamente
2. **Fase de Detección:** Usuario comete error (corre, toca objeto)
3. **Fase de Ataque:** Algoritmo lanza habilidades
4. **Fase de Pánico:** Usuario debe decidir: correr o esconderse

**Factor de Terror Real:**
- Vibración del teléfono (Ping de la Muerte)
- Flash de linterna (si es posible/seguro)
- Notificaciones falsas
- Rompe la cuarta pared

### Implementación Técnica

**Backend:** Firebase Realtime Database

**Estructura de Datos:**
```json
{
  "match_id_123": {
    "status": "active",
    "user_state": {
      "sanity": 0.8,
      "evidence_count": 1,
      "last_noise_position": {"x": 200, "y": 300}
    },
    "algorithm_actions": {
      "trigger_glitch": timestamp,
      "trigger_vibration": timestamp,
      "spawn_enemy_at": {"x": 500, "y": 500}
    }
  }
}
```

**Sincronización:**
- No se sincroniza posición exacta cada milisegundo
- Solo se sincronizan EVENTOS
- Reduce latencia y complejidad

### Expansión Futura: "El Juicio Final"

**Modo 2v1:**
- Dos Usuarios cooperativos
- Si uno muere, se convierte en "Fantasma Digital"
- Puede ayudar levemente o traicionar para revivir


---

## 🏆 LOGROS Y LEADERBOARD

### Sistema de Logros (17 Total)

#### Historia (5 logros)
- 👣 **Primeros Pasos** - Completa el tutorial - 50 monedas
- 🍔 **Gula Vencida** - Completa Arco 1 - 200 monedas
- 💰 **Avaricia Derrotada** - Completa Arco 2 - 250 monedas
- 👁️ **Envidia Superada** - Completa Arco 3 - 300 monedas
- 🏆 **Demo Completada** - Completa 3 arcos - 500 monedas

#### Colección (5 logros)
- 📄 **Primer Fragmento** - Recolecta tu primer fragmento - 50 monedas
- 📚 **Coleccionista Novato** - Recolecta 5 fragmentos - 100 monedas
- 📖 **Coleccionista Experto** - Recolecta 15 fragmentos - 300 monedas
- 🛒 **Primera Compra** - Compra tu primer item - 50 monedas
- 👔 **Fashionista** - Posee 3 skins diferentes - 150 monedas

#### Habilidad (3 logros)
- 🛡️ **Intocable** - Completa un arco sin ser atrapado - 200 monedas
- ⚡ **Velocista** - Completa Arco 1 en menos de 5 minutos - 250 monedas
- 🥷 **Maestro del Sigilo** - Usa escondites 50 veces - 150 monedas

#### Especiales (4 logros)
- 🧩 **Maestro de Puzzles** - Completa todos los expedientes - 400 monedas
- 💎 **Premium** - Compra el Battle Pass - 100 monedas
- 💸 **Millonario** - Acumula 10,000 monedas - 500 monedas [SECRETO]
- 🔗 **Conexión Establecida** - Juega una partida multijugador - 200 monedas

### Características del Sistema

- **Persistencia:** Firebase (`users/{uid}/progress/achievements`)
- **Verificación Automática:** Condiciones chequeadas en tiempo real
- **Recompensas Automáticas:** Monedas se otorgan al desbloquear
- **Notificaciones Flotantes:** Animadas al desbloquear
- **Logros Secretos:** Ocultos hasta desbloquear
- **Categorización:** Por tipo (Historia, Colección, etc.)

### Sistema de Leaderboard

**Ranking Global:** Top 100 jugadores

**Cálculo de Puntaje:**
```
Puntaje Total = 
  (Fragmentos × 100) +
  (Arcos completados × 500) +
  (Logros × 50) +
  (Monedas ÷ 10)
```

**Información Mostrada:**
- Posición (#1, #2, etc.)
- Avatar/Skin del jugador
- Nombre de usuario
- Puntuación total
- Arcos completados
- Medallas para top 3 (🥇🥈🥉)

**Características:**
- Actualización automática
- Botón de refresh manual
- Tu posición destacada
- Persistencia en Firestore (`leaderboard/{userId}`)

**Recompensas Semanales:**
- Top 1-10: Skin legendario exclusivo
- Top 11-50: Skin épico exclusivo
- Top 51-100: Skin raro exclusivo


---

## 🏗️ ARQUITECTURA TÉCNICA

### Stack Tecnológico

**Motor de Juego:** Flame (Flutter Game Engine)
- Framework: Flutter 3.x
- Lenguaje: Dart
- Plataformas: Android, iOS, Web, Desktop

**Backend:**
- Firebase Authentication (Auth)
- Cloud Firestore (Database)
- Firebase Realtime Database (Multiplayer)
- Firebase Storage (Assets)

**Pagos:**
- Stripe (Web/Desktop)
- Google Play Billing (Android)
- App Store Billing (iOS)

### Estructura del Proyecto

```
lib/
├── game/
│   ├── arcs/                    # 7 arcos del juego
│   │   ├── gluttony/           # Arco 1: Gula
│   │   ├── greed/              # Arco 2: Avaricia
│   │   ├── envy/               # Arco 3: Envidia
│   │   ├── lust/               # Arco 4: Lujuria
│   │   ├── pride/              # Arco 5: Soberbia
│   │   ├── sloth/              # Arco 6: Pereza
│   │   └── wrath/              # Arco 7: Ira
│   ├── core/
│   │   ├── base/               # BaseArcGame (clase base)
│   │   ├── components/         # Componentes reutilizables
│   │   ├── animation/          # Sistema de animación
│   │   ├── input/              # Input controller
│   │   ├── audio/              # Audio managers
│   │   ├── collision/          # Sistema de colisiones
│   │   ├── state/              # State management
│   │   └── systems/            # Sistemas (sanity, etc.)
│   └── ui/                     # UI del juego
│       ├── virtual_joystick.dart
│       ├── game_hud.dart
│       ├── pause_menu.dart
│       └── ...
├── screens/                    # Pantallas del juego
│   ├── menu_screen.dart
│   ├── arc_selection_screen.dart
│   ├── arc_game_screen.dart
│   ├── store_screen.dart
│   └── ...
├── data/
│   ├── models/                 # Modelos de datos
│   ├── providers/              # Providers (State)
│   └── repositories/           # Repositorios (Firebase)
├── services/                   # Servicios
│   ├── multiplayer_service.dart
│   ├── auth_service.dart
│   └── ...
└── main.dart                   # Punto de entrada
```

### Sistemas Principales

**1. BaseArcGame**
- Clase base para todos los arcos
- Maneja: Colisiones, Input, Sanity, Evidencias
- Extensible para mecánicas únicas

**2. Collision System**
- Detección de hitbox rectangular
- Rollback si colisión detectada
- Separación de ejes (X e Y)

**3. Sanity System**
- Rango: 0.0 - 1.0
- Drain/Recovery automático
- Efectos visuales según nivel

**4. Evidence System**
- 5 fragmentos por arco (35 total)
- Persistencia en Firebase
- Desbloqueo de narrativa

**5. Audio System**
- Audio manager por arco
- Background music
- Ambient sounds
- SFX

**6. State Management**
- Provider pattern
- Providers principales:
  - UserDataProvider
  - ArcProgressProvider
  - FragmentsProvider
  - AchievementsProvider
  - LeaderboardProvider
  - SettingsProvider

### Firebase Structure

```
users/
  {userId}/
    email: string
    displayName: string
    createdAt: timestamp
    progress/
      currentArc: string
      completedArcs: array
      totalPlayTime: number
      achievements/
        {achievementId}: boolean
    inventory/
      coins: number
      ownedItems: array
      equippedPlayerSkin: string
    fragments/
      {arcId}: array

leaderboard/
  {userId}/
    displayName: string
    score: number
    arcsCompleted: number
    totalFragments: number

matches/
  {matchId}/
    status: string
    players: object
    lastAction: object
```

### Performance

**Target FPS:**
- Desktop: 60 FPS
- Mobile: 30 FPS

**Optimizaciones:**
- Sprite batching
- Object pooling
- Lazy loading de assets
- Compresión de imágenes


---

## 📊 ESTADO DE DESARROLLO

### Completitud General

| Aspecto | Estado | Porcentaje |
|---------|--------|------------|
| **Narrativa** | ✅ Completa | 100% |
| **Gameplay** | ✅ Funcional | 100% |
| **Sistemas** | ✅ Implementado | 100% |
| **Enemigos** | ✅ Completo | 100% |
| **UI/UX** | ✅ Básico | 90% |
| **Audio** | ⚠️ Parcial | 60% |
| **Assets Visuales** | ⚠️ Incompleto | 43% |
| **Testing** | ❌ Pendiente | 0% |

### ✅ Completado

**Narrativa (100%):**
- 7 arcos completos con historias
- 35 fragmentos narrativos
- 7 expedientes completos (5 documentos cada uno)
- Cinemáticas intro/outro para todos los arcos

**Gameplay (100%):**
- 7 arcos jugables
- 7 mecánicas únicas implementadas
- Sistema de colisiones funcional
- Sistema de evidencias completo
- Sistema de cordura implementado
- Items y consumibles funcionales

**Enemigos (100%):**
- Arco 1: Sabueso de la Gula
- Arco 2: Rata Avara
- Arco 3: Camaleón Envidioso
- Arco 4: Araña Depredadora
- Arco 5: León Orgulloso
- Arco 6: Babosa Perezosa
- Arco 7: Toro Furioso

**Sistemas (100%):**
- Firebase Auth
- Firebase Firestore
- State Management (Provider)
- Multiplayer (Firebase Realtime)
- Achievements
- Leaderboard
- Store
- Battle Pass

**UI (90%):**
- 25 pantallas implementadas
- Navegación completa
- HUD de juego
- Menús y configuración

### ⚠️ Parcialmente Completado

**Audio (60%):**
- ✅ Background music
- ✅ Ambient sounds
- ✅ SFX básicos
- ❌ Narración de voces
- ❌ Música épica para cinemáticas
- ❌ Algunos efectos SFX

**Assets Visuales (43%):**
- ✅ Sprites de jugador (LPC)
- ✅ Sprites de enemigos (LPC)
- ✅ 3 imágenes de expedientes (Arcos 1-3)
- ❌ 4 imágenes de expedientes (Arcos 4-7)
- ❌ Algunos assets decorativos

### ❌ Pendiente

**Testing (0%):**
- ❌ No se ha jugado ningún arco completo
- ❌ No verificado: Colisiones funcionan
- ❌ No verificado: Enemigos se comportan bien
- ❌ No verificado: Evidencias se recolectan
- ❌ No verificado: Victory/Game Over funcionan
- ❌ No verificado: Performance (FPS)

### 🚨 Bloqueadores Críticos

**1. Testing En-Juego (CRÍTICO)**
- Necesita validación completa
- Jugar todos los 7 arcos
- Verificar que todo funciona

**2. Assets Faltantes (IMPORTANTE)**
- 4 imágenes de expedientes:
  - `assets/evidences/arc4_complete.jpg` (Lujuria)
  - `assets/evidences/arc5_complete.jpg` (Soberbia)
  - `assets/evidences/arc6_complete.jpg` (Pereza)
  - `assets/evidences/arc7_complete.jpg` (Ira)

**3. Performance (IMPORTANTE)**
- Verificar FPS en desktop (target: 60)
- Verificar FPS en mobile (target: 30)
- Optimizar si es necesario

### 📅 Roadmap

**Fase 1: Testing Crítico (1-2 horas)**
1. Compilar proyecto
2. Jugar Arco 1 completo
3. Jugar Arco 7 completo
4. Verificar CaseFileScreen
5. Revisar console para errores

**Fase 2: Assets Faltantes (30 min)**
1. Crear 4 imágenes placeholder
2. Volver a testear Arcos 4-7

**Fase 3: Testing Exhaustivo (2-3 horas)**
1. Jugar cada arco 1-7 hasta completion
2. Verificar todos los sistemas
3. Revisar expedientes
4. Verificar items y sanity

**Fase 4: Polish & Balance (1-2 horas)**
1. Ajustar velocidades
2. Ajustar dificultad
3. Verificar UX
4. Añadir audio faltante

**Fase 5: Performance (1 hora)**
1. Profiler en desktop
2. Profiler en mobile
3. Check memory leaks
4. Optimizar

**Fase 6: Release (TBD)**
1. Build para todas las plataformas
2. Testing final
3. Publicación


---

## 🧪 GUÍA DE TESTING

### Checklist de Testing Pre-Launch

#### Compilación y Ejecución
- [ ] Proyecto compila sin errores: `flutter run`
- [ ] No hay warnings críticos en console
- [ ] App se inicia correctamente
- [ ] Firebase se conecta correctamente

#### Testing de Arcos (Gameplay)

**Arco 1: Gula**
- [ ] Movimiento funciona (WASD/Joystick)
- [ ] Enemigo persigue al jugador
- [ ] 5 evidencias son recolectables
- [ ] Mecánica de peso funciona (lanzar comida)
- [ ] Escondites funcionan
- [ ] Cordura drena/recupera correctamente
- [ ] Puerta se abre al completar
- [ ] Victory screen aparece
- [ ] Outro cinemática funciona
- [ ] Expediente se abre en Archive

**Arco 2: Avaricia**
- [ ] Enemigo roba evidencias
- [ ] Sistema de puntos funciona
- [ ] Cajas registradoras recuperan cordura
- [ ] Resto de mecánicas básicas

**Arco 3: Envidia**
- [ ] NO hay escondites (mecánica única)
- [ ] Enemigo imita movimientos
- [ ] Velocidad aumenta con evidencias
- [ ] Resto de mecánicas básicas

**Arco 4: Lujuria**
- [ ] Araña se teletransporta
- [ ] Redes ralentizan movimiento
- [ ] 6 puntos de teletransporte funcionan
- [ ] Resto de mecánicas básicas

**Arco 5: Soberbia**
- [ ] León escala en poder
- [ ] Velocidad aumenta por fases
- [ ] Tronos de poder funcionan
- [ ] Duración extendida (10-12 min)
- [ ] Resto de mecánicas básicas

**Arco 6: Pereza**
- [ ] Sistema de ruido funciona
- [ ] Correr despierta enemigo
- [ ] Rastrear es sigiloso
- [ ] Charcos de lodo ralentizan
- [ ] NO hay escondites
- [ ] Resto de mecánicas básicas

**Arco 7: Ira**
- [ ] Toro persigue imparablemente
- [ ] Velocidad aumenta al detectar
- [ ] Peligros ambientales dañan
- [ ] Screen shake funciona
- [ ] Drain rápido de sanidad
- [ ] Resto de mecánicas básicas

#### Testing de Sistemas

**Sistema de Evidencias**
- [ ] Contador aumenta: X/5
- [ ] Pantalla se fractura progresivamente
- [ ] Narrativa se desbloquea en Archive
- [ ] Persistencia en Firebase

**Sistema de Cordura**
- [ ] Barra visual funciona
- [ ] Drain cerca del enemigo
- [ ] Recovery al alejarse/esconderse
- [ ] Efectos visuales según nivel
- [ ] Game Over a 0%

**Sistema de Colisiones**
- [ ] Paredes detienen movimiento
- [ ] Obstáculos ralentizan
- [ ] Zonas de peligro dañan
- [ ] Rollback funciona correctamente

**Sistema de Items**
- [ ] Items se pueden equipar (máx 3)
- [ ] Items se pueden usar en juego
- [ ] Cooldown funciona
- [ ] Efectos se aplican correctamente

#### Testing de UI

**Navegación**
- [ ] Todos los botones funcionan
- [ ] Transiciones son suaves
- [ ] No hay pantallas rotas
- [ ] Botón "Volver" funciona en todas las pantallas

**Archive Screen**
- [ ] 7 pestañas (una por arco)
- [ ] Fragmentos bloqueados/desbloqueados
- [ ] Click en fragmento abre detalle
- [ ] Botón "Ver Expediente" funciona

**Case File Screen**
- [ ] 5 documentos por expediente
- [ ] Navegación entre documentos
- [ ] Scroll funciona
- [ ] Imágenes se cargan (o placeholder)

**Store Screen**
- [ ] Productos se muestran correctamente
- [ ] Compra con monedas funciona
- [ ] Items se agregan al inventario
- [ ] Skins se pueden equipar

**Achievements Screen**
- [ ] 17 logros se muestran
- [ ] Estados correctos (bloqueado/desbloqueado)
- [ ] Notificaciones aparecen al desbloquear
- [ ] Recompensas se otorgan

**Leaderboard Screen**
- [ ] Top 100 se carga
- [ ] Tu posición se destaca
- [ ] Actualización funciona
- [ ] Medallas para top 3

#### Testing de Multiplayer

**Lobby**
- [ ] Crear partida genera código
- [ ] Unirse a partida funciona
- [ ] Lista de jugadores se actualiza
- [ ] Botón "Listo" funciona

**Gameplay**
- [ ] Usuario puede moverse
- [ ] Algoritmo ve señales de ruido
- [ ] Habilidades del Algoritmo funcionan
- [ ] Vibración funciona (Ping de la Muerte)
- [ ] Glitch visual funciona
- [ ] Sincronización en tiempo real

#### Testing de Performance

**Desktop**
- [ ] FPS >= 60 (target)
- [ ] No hay lag visible
- [ ] Memoria estable
- [ ] No hay memory leaks

**Mobile**
- [ ] FPS >= 30 (target)
- [ ] Controles táctiles responsivos
- [ ] Batería no drena excesivamente
- [ ] No hay crashes

#### Testing de Audio

- [ ] Background music se reproduce
- [ ] Ambient sounds funcionan
- [ ] SFX se reproducen correctamente
- [ ] Volumen se puede ajustar
- [ ] Mute funciona

#### Testing de Persistencia

- [ ] Progreso se guarda automáticamente
- [ ] Login/Logout funciona
- [ ] Datos se sincronizan con Firebase
- [ ] Cambio de dispositivo mantiene progreso

### Bugs Conocidos

**Ninguno reportado aún** (Pendiente de testing)

### Notas de Testing

**Prioridad Alta:**
1. Gameplay de los 7 arcos
2. Sistema de evidencias
3. Sistema de cordura
4. Colisiones

**Prioridad Media:**
5. UI/UX
6. Audio
7. Achievements
8. Leaderboard

**Prioridad Baja:**
9. Multiplayer
10. Store
11. Performance optimization


---

## 📝 RESUMEN EJECUTIVO

### ¿Qué es Condición: Humano?

Un juego narrativo de terror psicológico que te obliga a enfrentar las consecuencias devastadoras del acoso digital. No eres el héroe. Eres el perpetrador. Y ahora, tus siete víctimas quieren que entiendas el dolor que causaste.

### Características Clave

✅ **7 Arcos Narrativos Completos** - Cada uno con su propia historia devastadora  
✅ **7 Mecánicas Únicas** - Cada arco juega diferente  
✅ **35 Fragmentos Narrativos** - Evidencia de tus crímenes digitales  
✅ **7 Expedientes Completos** - Documentación del daño causado  
✅ **Multijugador Asimétrico** - Usuario vs Algoritmo  
✅ **17 Logros** - Con recompensas en monedas  
✅ **Leaderboard Global** - Compite con otros jugadores  
✅ **Tienda Completa** - Skins, items, Battle Pass  
✅ **Duración: 35-56 minutos** - Experiencia completa  

### Propósito del Juego

**Condición: Humano** no es entretenimiento vacío. Es una experiencia diseñada para generar reflexión sobre:

- La facilidad con la que deshumanizamos a otros en línea
- Las consecuencias reales de nuestras acciones virtuales
- La pérdida de empatía en la era digital
- El costo humano de la viralización
- La responsabilidad que tenemos con cada click, cada compartir, cada comentario

### Estado Actual

**Versión:** 1.0 (Completo)  
**Estado:** Listo para Testing  
**Plataformas:** Android, iOS, Web, Desktop  

**Completitud:**
- Narrativa: 100% ✅
- Gameplay: 100% ✅
- Sistemas: 100% ✅
- UI: 90% ✅
- Audio: 60% ⚠️
- Assets: 43% ⚠️
- Testing: 0% ❌

### Próximos Pasos

1. **Testing Crítico** - Jugar todos los arcos completos
2. **Assets Faltantes** - Crear 4 imágenes de expedientes
3. **Performance** - Optimizar FPS
4. **Polish** - Ajustar balance y UX
5. **Release** - Publicar en todas las plataformas

### Contacto y Créditos

**Proyecto:** Condición: Humano  
**Género:** Terror Psicológico / Aventura Narrativa  
**Motor:** Flame (Flutter)  
**Backend:** Firebase  
**Fecha:** Enero 2026  

---

## 📚 DOCUMENTOS RELACIONADOS

Para información más detallada, consulta estos documentos adicionales:

- `INFORMACION_COMPLETA_JUEGO.md` - Información general del juego
- `GUIA_JUEGO_COMPLETO.md` - Guía de los 7 mapas expandidos
- `ARCOS_GUIONES.md` - Guiones narrativos de cinemáticas
- `ESTRUCTURA_ARCOS.md` - Estructura de archivos por arco
- `EXPEDIENTES_COMPLETOS.md` - Todos los expedientes narrativos
- `EXPEDIENTES_ARCOS_4_5_6_7.md` - Expedientes de arcos 4-7
- `MULTIPLAYER_DESIGN.md` - Diseño del modo multijugador
- `STATS_ACHIEVEMENTS_LEADERBOARD.md` - Sistema de logros y clasificación
- `FIREBASE_DATABASE_DOCUMENTATION.md` - Documentación de Firebase
- `AUDITORIA_COMPLETA_JUEGO.md` - Auditoría del estado actual

---

## ⚠️ ADVERTENCIA DE CONTENIDO

**Condición: Humano** contiene temas maduros y perturbadores:

- Acoso digital y ciberbullying
- Trastornos alimenticios
- Ideación suicida
- Violencia doméstica
- Sextorsión y chantaje
- Negligencia médica
- Contenido psicológicamente intenso

**Clasificación Recomendada:** 17+ (Mature)

Este juego está diseñado para generar incomodidad y reflexión. No es apropiado para audiencias sensibles o menores de edad.

---

## 🎯 MENSAJE FINAL

"¿Cómo se siente ser observado?"  
"¿Cómo se siente saber que todos verán?"  
"¿Valió la pena?"

**Condición: Humano** te pregunta: ¿Qué tan humano eres realmente cuando nadie te está mirando?

---

**Fin del Documento Completo**

**Última Actualización:** 27 de Enero, 2026  
**Versión del Documento:** 1.0  
**Páginas:** ~50  
**Palabras:** ~15,000  

