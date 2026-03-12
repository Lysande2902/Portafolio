# 📖 INFORMACIÓN COMPLETA DEL JUEGO - HUMANO

## 🎮 DESCRIPCIÓN GENERAL

**HUMANO** es un juego narrativo de suspenso y acoso digital donde el jugador vive historias perturbadoras bajo vigilancia constante. El juego explora temas de culpa, vergüenza digital y las consecuencias de viralizar contenido. El jugador controla a una persona anónima que comete actos de humillación digital contra otros, pero gradualmente descubre el costo emocional y existencial de sus acciones.

**Tipo:** Juego narrativo indie - Aventura de puzzle + sigilo  
**Plataformas:** Android, iOS, Web  
**Estado:** Demo completa con 3 arcos jugables

---

## 📚 LA HISTORIA

### Concepto Central
El juego cuenta una historia brutal sobre el "doxxing", acoso digital y la viralización de contenido humillante. Cada arco representa un "pecado digital" que el jugador comete, con consecuencias devastadoras para las víctimas.

### Los 7 Pecados (Arcos)
El juego completo consistirá de 7 arcos basados en los 7 pecados capitales:

1. **🍽️ GULA** - Compartir videos humillantes de alguien comiendo
2. **💰 AVARICIA** - Robar información financiera y difundir datos bancarios
3. **💚 ENVIDIA** - Humillar a alguien por no ser lo suficientemente "bonito/musculoso"
4. **😤 IRA** - (Futuro)
5. **🧎 PEREZA** - (Futuro)
6. **😈 LUJURIA** - (Futuro)
7. **🙏 SOBERBIA** - (Futuro)

### Narrativa de la Demo (3 Arcos)

#### ARCO 1: GULA 🍽️
**Cinemática Pre-Arco:**
```
"Abres los ojos. Oscuridad.
Tu teléfono vibra:
'Dirección: Almacén 7'
'Ven solo. O todos lo sabrán.'

Algo se mueve en la oscuridad.
Algo hambriento.
Una máscara de cerdo emerge.

RUN."
```

**Mecánica:** Recolectar 5 fragmentos de puzzle mientras escapas de un enemigo disfrazado de cerdo  
**Efecto Visual:** Cada fragmento recolectado fractura la pantalla más

**Cinemática Post-Arco:**
```
"Compartiste el video.
'MIREN A ESTE GORDO COMIENDO BASURA'

2.3 millones de vistas
847,392 likes

Mateo leyó los comentarios.
Todos los comentarios.

Ya no sale de su casa.
Ya no come.

¿Valió la pena?"
```

---

#### ARCO 2: AVARICIA 💰
**Cinemática Pre-Arco:**
```
"Llamada desconocida. Contestas.
'Hola, P-L-A-Y-E-R.'

'¿Recuerdas lo que compartiste?'
[Cuelga]

Mensaje nuevo:
'Banco Nacional - Bóveda C'
'Recupera lo que robaste.'

Una máscara de rata.
'Tú robaste mi vida.
Ahora robaré la tuya.'"
```

**Mecánica:** Sigilo + recolección en un banco digital  
**Enemigo:** Rata (más inteligente que el cerdo)

**Cinemática Post-Arco:**
```
"Compartiste algo que no debías.
Número de cuenta: ████████
Dirección: █████████

Valeria lo perdió todo.
Su casa. Sus ahorros. Sus hijos.

Tú ganaste 15,632 likes.

¿Valió la pena?"
```

---

#### ARCO 3: ENVIDIA 💚 (FINAL DE LA DEMO)
**Cinemática Pre-Arco:**
```
"Mensaje directo de cuenta bloqueada:
'Hola. ¿Me recuerdas?'
[FOTO ADJUNTA: Antes/Después]

'Gimnasio Atlas. 3era Ave.'
'Ven a verme.'
'Tal vez ahora SOY suficiente para ti.'

Una máscara de camaleón.
Se mueve exactamente como tú.
'¿Ahora me ves?'"
```

**Mecánica:** Combate + puzzle + sigilo simultáneamente  
**Enemigo:** Camaleón (se camufla, se replica)

**Cinemática Post-Arco:**
```
"Comparaste.
Humillaste.
Repetiste.

Cada comentario era un golpe.
Cada comparación, una herida.

Ella cambió.
Tú seguiste igual.

¿Valió la pena?"
```

---

## 🎬 FLUJO DEL JUEGO (PROGRESIÓN)

### 1️⃣ **INTRO SCREEN** (Entrada Perturbadora)
- Pantalla inicial con audio de risas de fondo
- Notificaciones falsas aparecen (menciones, fotos etiquetadas, visualizaciones)
- Efecto glitch y distorsión visual
- Texto typewriter que revela la premisa del juego
- Elige un usuario para comenzar
- **Propósito:** Establecer la atmósfera incómoda del juego

---

### 2️⃣ **AUTH SCREEN** (Autenticación)
- Inicio de sesión con Firebase
- Registro de nuevos usuarios
- Mantiene persistencia del progreso
- **Propósito:** Sincronización multijugador y progreso

---

### 3️⃣ **MENU SCREEN** (Lobby Principal)
- Fondo de video oscuro (lobby.mp4)
- 6 opciones principales:
  - **PLAY** - Entrar a los arcos
  - **STORE** - Tienda de items/skins
  - **ARCHIVE** - Galería de evidencias
  - **MULTIPLAYER** - Modo cooperativo/versus
  - **SETTINGS** - Configuración
  - **EXIT** - Salir del juego
- Audio ambiente (risas, sonidos oscuros)
- Notificaciones falsas del sistema
- **Propósito:** Hub central del juego

---

### 4️⃣ **ARC SELECTION SCREEN** (Seleccionar Arco)
- Mostrar 7 arcos narrativos (3 jugables en demo)
- Cada arco tiene:
  - Título (Gula, Avaricia, Envidia, etc.)
  - Descripción narrativa
  - Progreso (no iniciado, en progreso, completado)
  - Icono representativo
  - Estado de bloqueo/desbloqueo
- Animación de revelación para arcos futuros (Season 2)
- **Propósito:** Seleccionar qué historia jugar

---

### 5️⃣ **ARC INTRO SCREEN** (Cinemática Pre-Arco)
- Fondo negro con texto typewriter
- Dialoga la narrativa y motivación del arco
- Presenta la amenaza (la máscara del enemigo)
- Botón "SALTAR [ESC]" para usuarios impacientes
- Duraciones: 30-45 segundos
- **Propósito:** Inmersión narrativa

---

### 6️⃣ **ITEM SELECTION SCREEN** (Elegir Loadout)
- Mostrar 5-8 items disponibles en el inventario
- Cada item tiene:
  - Icono y nombre
  - Descripción (velocidad, defensa, visión, etc.)
  - Rareza (común, raro, épico, legendario)
  - Costo en monedas (si hay que comprar)
- Límite: Máximo 3 items por misión
- Botón "CONFIRMAR" para iniciar el juego
- **Propósito:** Customización táctica

---

### 7️⃣ **ARC GAME SCREEN** (JUEGO PRINCIPAL)
**Objetivo:** Recolectar 5 fragmentos de puzzle sin ser capturado

**Mecánicas Core:**
- **Movimiento:** WASD o flechas
- **Sigilo:** Acercarse a ciertas áreas para ocultarse (opacidad al 30%)
- **Items:** Usar items con E o click derecho
  - Aturdidor (stun enemy 2 segundos)
  - Invisibilidad (5 segundos sin ser visto)
  - Boost de velocidad
  - Mapa temporal (revela enemigo 3 segundos)
- **Recolección:** Caminar sobre el fragmento para recolectarlo
- **Pantalla Fracturada:** Al recolectar cada fragmento, la pantalla se fractura más
  - Fragmento 1: 1 grieta
  - Fragmento 2: 2-3 grietas
  - Fragmento 3: Múltiples grietas
  - Fragmento 4: Mayoría roto
  - Fragmento 5: Casi completamente ilegible (MÁXIMO)

**Enemigos (por arco):**
- **Arco 1 (Gula):** Cerdo - Velocidad: Media, Rango de detección: Medio
- **Arco 2 (Avaricia):** Rata - Velocidad: Media-Alta, Inteligencia de ruta mejorada
- **Arco 3 (Envidia):** Camaleón - Velocidad: Alta, Se camufla con el fondo, Clona posición del jugador

**Estado del Jugador:**
- **Salud:** El jugador NO tiene salud (1 golpe = captura)
- **Cordura:** Disminuye cuando el enemigo está cerca (visualmente por distorsión de pantalla)
- **Energía:** Se consume al correr, se regenera al estar quieto

**Fin del Arco:**
- ✅ **VICTORIA:** Recolectar los 5 fragmentos y llegar a la salida
- ❌ **DERROTA:** Ser capturado por el enemigo → Pantalla de Game Over → Reintentar

**Propósito:** Gameplay principal - mezcla sigilo, recolección y supervivencia

---

### 8️⃣ **VICTORY SCREEN** (Pantalla de Victoria)
- Mostrar estadísticas:
  - Tiempo total
  - Items usados
  - Daño recibido
  - Fragmentos recolectados (5/5)
- Botón para ir al siguiente paso
- **Propósito:** Transición narrativa

---

### 9️⃣ **ARC OUTRO SCREEN** (Cinemática Post-Arco)
- Texto typewriter revelando el destino de la víctima
- La pregunta existencial: "¿Valió la pena?"
- Efectos visuales que muestran las consecuencias
- Audio triste/perturbador
- **Propósito:** Reflexión moral

---

### 🔟 **ARCHIVE SCREEN** (Galería de Evidencias)
- Después de completar cada arco, acceso a la galería
- **Organización por Arco:**
  - Tab para cada arco (7 pestañas)
  - Solo muestra fragmentos del arco completado
- **Grid de Fragmentos:**
  - Mostrar 5 fragmentos por arco
  - Fragmentos recolectados: imagen visible
  - Fragmentos no recolectados: bloqueados con icono de candado
- **Filtros Disponibles:**
  - Todo
  - Capturas de pantalla
  - Mensajes
  - Videos
  - Audio
- **Detalles del Fragmento:**
  - Al hacer click: Vista ampliada del fragmento
  - Mostrar narrative snippet (texto que acompaña el puzzle)
  - Información: Dónde, cuándo, quién
  - Botón de compartir (falso - solo para UI)
- **Indicador REC:** Esquina inferior derecha parpadea como grabación
- **Propósito:** Exploración narrativa + recompensa visual

---

### 1️⃣1️⃣ **DEMO ENDING SCREEN** (Final Extremadamente Incómodo)
**SOLO después de completar los 3 arcos**

**Fases del Demo Ending:**

**Fase 1-2: Recapitulación Normal**
```
"Has completado 3 arcos"
"Escapaste de las máscaras"
"Procesando datos... Un momento."
```

**Fase 3: Simulación de Activación de Cámara** [VIBRACIÓN]
```
"Activando cámara frontal..."
"Captura guardada."
"Analizando expresión facial..."
```

**Fase 4: Perfil Generado** [VIBRACIÓN CONTINUA]
```
PERFIL GENERADO
Usuario: P-L-A-Y-E-R
Dispositivo: [TU DISPOSITIVO REAL]
Ubicación: [TU CIUDAD]
Hora local: [HORA REAL]
Arcos completados: 3/7
Tiempo jugado: [CALCULADO]
```

**Fase 5: Simulación de Subida a Redes** [VIBRACIÓN CON NOTIFICACIONES]
```
"Conectando a servidor..."
"Subiendo captura de pantalla..."
"Publicando en Reddit..." [VIBRACIÓN]
"Publicando en Twitter..." [VIBRACIÓN]
"Compartiendo en Discord..." [VIBRACIÓN]

[Notificaciones falsas emergentes]
```

**Fase 6: Simulación de Transmisión EN VIVO**
```
[Contador rojo]
EN VIVO: 237
[Sube: 237 → 584 → 1,247 → 2,389...]

[VIBRACIÓN CON CADA INCREMENTO]
```

**Fase 7: Comentarios Crueles Simulados** [VIBRACIÓN C/U]
```
[Nuevos comentarios cada 2 segundos]

"JAJAJA quién es este payaso"
"Qué patético, jugando jueguitos"
"Captura guardada para siempre lol"
"Compartido en mi grupo 😂"
"Este wey de verdad pensó que escapaba"
"Ya sé dónde vive este"
"Qué perdedor"
```

**Fase 8: Mensajes de Víctimas** [INDICADOR DE ESCRITURA]
```
[Escribe...]  [3 segundos de pausa incómoda]

«Ahora tú eres el monstruo»
- Mateo [VIBRACIÓN]

[Escribe...]

«¿Cómo se siente ser observado?»
- Valeria [VIBRACIÓN]

[Escribe...]

«Te vemos. Te juzgamos. Te compartimos.»
- Lucía [VIBRACIÓN]
```

**Fase 9: Pausa Incómoda**
```
[5 segundos de silencio absoluto]
.
[800ms]
.
[800ms]
.
```

**Fase 10: REVELACIÓN - ERA FALSO**
```
"Relájate."
"Nada de esto fue real."
"Tu cámara no se activó."
"Nadie te está viendo."
"No fuiste compartido."

"Pero sentiste algo, ¿verdad?"
```

**Fase 11: Reflexión Final**
```
"Miedo."
"Esa sensación en el estómago."
"Esa urgencia de cerrar la app."
"Esa paranoia de revisar tu teléfono."

"Eso sintieron ellos."
"Cada. Maldito. Día."
"Por meses."
"Por años."

"Porque TÚ diste click."
```

**Fase 12: Cierre**
```
"DEMO COMPLETA"
"Esto fue solo el inicio."
"4 máscaras más."
"4 lecciones más."
"¿Estás preparado?"
```

→ **Volver al menú principal**

**Propósito:** Impacto emocional y reflexión sobre las consecuencias

---

### 1️⃣2️⃣ **ENDING SCREEN / TRUE ENDING SCREEN** (Finales Completos)
- Solo desbloqueado si se completan todos los 7 arcos
- Múltiples finales basados en decisiones
- Contenido no disponible en la demo
- **Propósito:** Final narrativo completo

---

## 🛍️ TIENDA (STORE SCREEN)

### Categorías de Items

#### 1. **DESTACADO (Featured)**
- Items nuevos/promocionados
- Ofertas especiales
- Skins limitados
- Pase de batalla

#### 2. **ITEMS (Consumibles/Herramientas)**
- **Aturdidor** - Stun al enemigo por 2 segundos
- **Invisibilidad** - 5 segundos sin ser detectado
- **Boost de Velocidad** - +50% velocidad por 3 segundos
- **Mapa Temporal** - Revela ubicación del enemigo por 3 segundos
- **Escudo** - Absorbe 1 golpe (¡nueva vida!)
- **Linterna** - Ilumina área (próximamente)
- **Micrófono Scrambler** - Distorsiona audio del enemigo
- **Camuflaje** - Se mezcla con el fondo (próximamente)

**Sistema de Monedas:**
- Cada item tiene un costo en monedas virtuales
- Las monedas se obtienen:
  - Completando arcos (100-500 monedas/arco)
  - Logros y desafíos
  - Compra con dinero real
  - Pase de batalla

#### 3. **SKINS (Apariencias Personalizadas)**
- **Skin de Jugador:**
  - Ropa variada (esmoquin, punk, hacker, formal, etc.)
  - Distintos colores
  - Accesorios (gafas, sombreros, máscaras)
  - Rarezas: Común, Raro, Épico, Legendario
- **Precio:** 50-500 monedas según rareza

#### 4. **ESPECIAL (Limited/Seasonal)**
- Skins limitados por tiempo
- Bundles exclusivos
- Colabs con artistas/comunidad
- Precio: Variable

#### 5. **PASE DE BATALLA (Battle Pass)**
- **Sistema de Progresión:**
  - Gratuito: 10 niveles básicos
  - Premium (Pase Pagado): 50 niveles con recompensas
- **Recompensas:**
  - Monedas
  - Skins exclusivas
  - Items especiales
  - Emotes/Personalizaciones
  - Contenido narrativo desbloqueado
- **Precio:** $9.99 USD / 300 monedas

---

## 💳 CARRITO DE COMPRA (COINS PURCHASE SCREEN)

### Monedas Disponibles
- **100 Monedas** - $0.99
- **500 Monedas** - $4.99
- **1,000 Monedas** - $8.99 (Mejor precio)
- **2,500 Monedas** - $19.99 (MEGA OFERTA)

### Método de Pago
- Integración con Stripe
- Google Play Billing (Android)
- App Store Billing (iOS)
- Compras recurrentes disponibles

### Bonificaciones
- Primer compra: +20% monedas extra
- Compras recurrentes: +10% bonus
- Promociones semanales: +25% en ciertos horarios

---

## 👥 PERSONAJES / SKINS

### Categorías de Skins

#### **1. Skins Base (Gratuitos)**
- **Default** - Silueta gris neutra
- **Usuario** - Icono de usuario genérico
- **Fantasma** - Transparente azulado

#### **2. Skins Profesionales (50-100 monedas)**
- **Hacker** - Hoodie, gafas de realidad virtual
- **Corporativo** - Traje formal, corbata roja
- **Agente** - Ropa negra, estilo espía
- **Periodista** - Blazer, micrófono

#### **3. Skins Alternativos (100-250 monedas)**
- **Punk** - Pelo verde, chaqueta de cuero
- **Gótico** - Ropa oscura, maquillaje dramático
- **Cyberpunk** - Hoodie neon, accesorios tech
- **Fantasma Verdadero** - Completamente blanco/transparente
- **Sombra** - Negro puro, apenas visible

#### **4. Skins Épicos (250-500 monedas)**
- **Deidad Digital** - Aura brillante, efecto sobrenatural
- **Ángel Caído** - Alas oscuras, corona rota
- **Demonio** - Cuernos, aura roja, efectos de fuego
- **Replicante** - Aparición glitch/digital
- **Especro** - Fantasma translúcido con distorsión

#### **5. Skins Legendarios (500+ monedas)**
- **The Watcher** - Ojo todo viendo, aura omnisciente
- **Void** - Agujero negro personificado, absorbente de luz
- **Algoritmo Vivo** - Código digital hecho carne
- **La Verdad** - Forma imposible, mata la mente
- **El Judas** - Apariencia de humano traidor

#### **6. Skins Limitados (Temporales)**
- Halloween: Esqueleto, Momia, Vampiro
- Navidad: Duende rojo, Reno, Papa Noel oscuro
- Semana Santa: Ángel, Demonio, Penitente

---

## 📋 ARCHIVOS (ARCHIVE SYSTEM)

### Función General
Es una galería de "evidencias" digitales recolectadas durante el juego. Funciona como un museo perturbador de tus acciones.

### Estructura

#### **Por Arco (7 pestañas):**
1. **Gula** - 5 fragmentos sobre la víctima #1 (Mateo)
2. **Avaricia** - 5 fragmentos sobre la víctima #2 (Valeria)
3. **Envidia** - 5 fragmentos sobre la víctima #3 (Lucía)
4. **Ira** - Bloqueado (futuro)
5. **Pereza** - Bloqueado (futuro)
6. **Lujuria** - Bloqueado (futuro)
7. **Soberbia** - Bloqueado (futuro)

#### **Tipos de Contenido:**
- **Captura de Pantalla** - Imagen del acto de humillación
- **Mensaje** - Conversación de chat incriminadora
- **Video** - Clip de la acción
- **Audio** - Grabación de llamada/conversación
- **Documento** - Datos personales de la víctima

#### **Estados de Fragmento:**
- **Bloqueado 🔒** - No recolectado
  - Mostrar silueta oscura
  - Mostrar "???" como nombre
  - Tooltip: "Recolecta este fragmento para desbloquearlo"
  
- **Recolectado ✅** - Visible y clickeable
  - Mostrar imagen/contenido
  - Mostrar título
  - Reproducible si es audio/video
  - Clickable para vista completa

#### **Información de Fragmento:**
Al clickear:
- Imagen/Video/Audio completo
- Título descriptivo
- Descripción narrativa
- Fecha recolección
- Ubicación en el juego
- Botón para compartir (falsamente - solo UI)
- Botón cerrar (X)

#### **Filtros Disponibles:**
- **Todo** - Todos los fragmentos del arco
- **Capturas** - Solo screenshots
- **Mensajes** - Solo chats
- **Videos** - Solo videoclips
- **Audio** - Solo grabaciones

#### **Estadísticas de Archivo:**
- Fragmentos recolectados: X/5 (por arco)
- Progreso visual: Barra de progreso
- Porcentaje completado
- Tiempo total de reproducción de contenido

#### **Indicadores Visuales:**
- **Indicador REC** (esquina inferior derecha)
  - Parpadea rojo: "REC"
  - Pulsación: En tiempo real
  - Propósito: Recordar que "todo se está grabando"

#### **Efecto Visual de Fondo:**
- Video de lobby de fondo
- Overlay oscuro semi-transparente
- Efecto VHS (distorsión análoga)
- Glitch ocasional

---

## 🎯 LOGROS (ACHIEVEMENTS SYSTEM)

### Categorías de Logros

#### **1. Narrativos (Historia)**
- **"Primer Pecado"** - Completa Arco 1: Gula
- **"Ladrón"** - Completa Arco 2: Avaricia
- **"Celoso"** - Completa Arco 3: Envidia
- **"Pecador Completado"** - Completa todos los 7 arcos
- **"Sin Piedad"** - Completa 3 arcos sin morir una sola vez

#### **2. de Gameplay**
- **"Speedrunner"** - Completa un arco en menos de 3 minutos
- **"Item Master"** - Usa todos los tipos de items en una misión
- **"Fantasma"** - Completa un arco sin ser detectado
- **"Recolector"** - Recolecta todos los fragmentos de un arco
- **"Invencible"** - Completa un arco sin usar items

#### **3. Desafío**
- **"Hardcore"** - Completa Arco 3 en dificultad máxima
- **"Perfeccionista"** - Completa un arco con puntuación perfecta (100%)
- **"Sin Retorno"** - Nunca repites un arco después de completarlo

#### **4. Multijugador**
- **"Conexión"** - Juega una partida multijugador
- **"Campeón"** - Gana 10 partidas multijugador
- **"Algoritmo Maestro"** - Usa todas las habilidades del algoritmo

#### **5. Sociales**
- **"Compartidor"** - Comparte tu progreso 5 veces
- **"Influencer"** - Invita a 3 amigos a jugar
- **"Leyenda Comunitaria"** - Aparece en el top 10 del leaderboard

#### **6. Secretos/Easter Eggs**
- **"¿Qué eres?"** - Descubre el código secreto en intro
- **"La Verdad"** - Obtén el ending verdadero
- **"Observador"** - Descubre todos los mensajes ocultos
- **"El Despertar"** - Completa la misión secreta

### Sistema de Recompensas
- Cada logro desbloqueado: +10-50 monedas
- Algunos logros desbloquean contenido especial
- Mostrar notificación en pantalla cuando se desbloquea
- Historial de logros desbloqueados

---

## 🏆 LEADERBOARD (CLASIFICACIÓN)

### Métricas de Ranking
1. **Puntuación General** - Suma de puntos de todos los arcos
2. **Arcos Completados** - Número de arcos terminados
3. **Tiempo Más Rápido** - Speedrun de mejor tiempo
4. **Fragmentos Recolectados** - Total de fragmentos obtenidos
5. **Logros Desbloqueados** - Cantidad de achievements

### Información del Leaderboard
- Top 100 jugadores globales
- Filtro por región (próximo)
- Filtro por amigos
- Actualización en tiempo real
- Tu posición destacada

### Información de Jugador
- Avatar (skin actual)
- Nombre de usuario
- Posición
- Puntuación
- Insignia de rango (Novato, Intermedio, Experto, Maestro)
- País/Región
- Opción de agregar como amigo

### Recompensas de Leaderboard
- Top 1-10: Skin legendario exclusivo
- Top 11-50: Skin épico exclusivo
- Top 51-100: Skin raro exclusivo
- Actualización semanal

---

## ⚙️ CONFIGURACIÓN (SETTINGS)

### Audio
- **Volumen Maestro** (0-100%)
- **Volumen Música** (0-100%)
- **Volumen Efectos de Sonido** (0-100%)
- **Volumen Voces** (0-100%)
- **Toggle:** Vibración del teléfono
- **Toggle:** Notificaciones de sonido

### Gráficos
- **Calidad Visual** (Baja, Media, Alta)
- **Resolución** (Auto, 720p, 1080p, 4K)
- **Toggle:** Efectos de Glitch
- **Toggle:** Efectos VHS
- **Toggle:** Partículas visuales
- **FPS Máximo:** Limitar a 60 FPS (ahorra batería)

### Gameplay
- **Dificultad** (Fácil, Normal, Difícil, Hardcore)
- **Sensibilidad de Cámara** (Baja, Media, Alta)
- **Controles** (Táctiles, Teclado, Mando)
- **Mapa en Pantalla** (On/Off)
- **Subtítulos** (On/Off)
- **Idioma** (Español, Inglés, Portugués, etc.)

### Privacidad
- **Compartir Datos Anónimos** (On/Off)
- **Permite Notificaciones** (On/Off)
- **Permite Localización** (On/Off)
- **Datos de Juego** (Descargar/Eliminar)

### Cuenta
- **Nombre de Usuario**
- **Email**
- **Cambiar Contraseña**
- **Cerrar Sesión**
- **Eliminar Cuenta**

### Info
- **Versión del Juego** (v1.0.0, etc.)
- **Desarrollador** - Créditos
- **Política de Privacidad**
- **Términos de Servicio**
- **Contacto/Soporte**

---

## 👾 MULTIJUGADOR (MULTIPLAYER)

### Modo: "El Algoritmo"
Juego asimétrico donde:
- **Jugador 1:** Vive el arco (objetivo: recolectar fragmentos)
- **Jugador 2:** Controla "El Algoritmo" (objetivo: capturar al jugador)

### Habilidades del Algoritmo
1. **Vigilancia** - Revelar posición del enemigo temporalmente
2. **Replicación** - Crear clones de sí mismo
3. **Distorsión** - Confundir visión del jugador
4. **Bloqueo** - Crear paredes digitales
5. **Sincronización** - Moverse al mismo tiempo que el jugador

### Sistema de Ranking
- Puntos por captura
- Puntos por defensa
- Puntos por tiempo
- Sumar para leaderboard global

### Códigos de Partida
- Generar código único de 6 caracteres
- Compartir código para que otro jugador se una
- Sistema de espera y "Listo"

---

## 🎬 CINEMÁTICAS

### Sistema de Cinemáticas
1. **Intro Screen** - Narrativa inicial perturbadora
2. **Arc Intro** - Texto typewriter pre-arco
3. **Arc Outro** - Texto typewriter post-arco
4. **Demo Ending** - Simulación de doxxeo
5. **True Ending** (7 arcos) - Final verdadero

### Efectos Visuales Cinemáticos
- **Typewriter Effect** - Texto escrito lentamente (40-50ms por letra)
- **Glitch Effect** - Distorsión digital aleatoria
- **VHS Effect** - Líneas horizontales y aberración cromática
- **Fade In/Out** - Transiciones suaves
- **Vibración** - Haptic feedback en momentos clave

### Audio Cinemático
- **Música ambiental** - Sonidos ominosos de fondo
- **Notificaciones** - Sonidos de teléfono/alerta
- **Voces en off** - (Futuro: Narración en audio)
- **Silencio estratégico** - Pausas incómodas

---

## 💾 PERSISTENCIA Y PROGRESO

### Guardado Automático
- Progreso se sincroniza con Firebase
- Automático después de cada acción importante
- Sincronización en la nube

### Progreso Rastreado
- Arcos completados (3/7)
- Fragmentos recolectados (por arco)
- Logros desbloqueados
- Monedas gastaas/disponibles
- Skins poseídas
- Leaderboard ranking

### Recuperación de Datos
- Si cambias dispositivo, tus datos se mantienen
- Login con Firebase
- Restauración automática

---

## 🌐 FLUJO COMPLETO DEL USUARIO

```
INICIO
  ↓
Auth Screen (Login/Registro)
  ↓
Intro Screen (Narrativa incómoda) [Saltable]
  ↓
Menu Screen
  ├─→ PLAY
  │    ↓
  │    Arc Selection Screen
  │    ↓
  │    Arc Intro Screen (Cinemática)
  │    ↓
  │    Item Selection Screen
  │    ↓
  │    Arc Game Screen (JUEGO)
  │    ↓
  │    Victory/Game Over
  │    ↓
  │    Arc Outro Screen (Cinemática)
  │    ↓
  │    Archive Screen (Galería)
  │    ↓
  │    [Si es Arco 3 → Demo Ending Screen]
  │
  ├─→ STORE
  │    ↓
  │    Store Screen
  │    ├─→ Featured
  │    ├─→ Items
  │    ├─→ Skins
  │    ├─→ Special
  │    └─→ Battle Pass
  │         [Click Compra → Coins Purchase Screen]
  │
  ├─→ ARCHIVE
  │    ↓
  │    Archive Screen
  │    [Ver fragmentos recolectados]
  │
  ├─→ MULTIPLAYER
  │    ↓
  │    Multiplayer Lobby Screen
  │    ├─→ Crear Partida (Genera código)
  │    └─→ Unirse a Partida (Ingresa código)
  │         ↓
  │         Algorithm Game Screen
  │
  ├─→ SETTINGS
  │    ↓
  │    Settings Screen
  │    [Ajustes de audio, gráficos, privacidad]
  │
  └─→ EXIT
       ↓
       Guardar y Salir

ACHIEVEMENTS
  [Se desbloquean durante el juego]

LEADERBOARD
  [Actualiza en tiempo real]
```

---

## 📊 ESTADÍSTICAS DE LA DEMO

- **3 Arcos Jugables:** Gula, Avaricia, Envidia
- **15 Fragmentos Totales:** 5 por arco
- **Múltiples Skins:** Base, Profesional, Alternativo, Épico, Legendario
- **10+ Items Disponibles:** Aturdidor, Invisibilidad, etc.
- **20+ Logros:** Narrativos, Gameplay, Desafío, Multijugador
- **Sistema Completo de Progresión**
- **Cinemáticas Perturbadoras:** 3 Intros + 3 Outros + 1 Demo Ending
- **Final Impactante:** Simulación de doxxeo incómoda

---

## 🎮 CONTROLES

### PC/Desktop
- **W/↑** - Mover arriba
- **A/←** - Mover izquierda
- **S/↓** - Mover abajo
- **D/→** - Mover derecha
- **E / Click Derecho** - Usar item
- **ESPACIO** - Saltar/Interactuar
- **ESC** - Saltar cinemática / Pausar
- **M** - Abrir mapa

### Mobile/Táctil
- **Joystick izquierdo** - Movimiento (8 direcciones)
- **Botón derecho** - Usar item
- **Deslizar arriba** - Interactuar
- **Tap dos veces** - Sprintar

### Mando (Futuro)
- **Stick izquierdo** - Movimiento
- **A** - Usar item
- **B** - Saltar
- **Y** - Interactuar
- **Start** - Pausar

---

## 🌟 CARACTERÍSTICAS ÚNICAS

1. **Narrativa Perturbadora:** Exploración profunda del acoso digital
2. **Finales Morales:** Cada arco termina con reflexión sobre consecuencias
3. **Juego Asimétrico:** Multijugador donde roles son completamente diferentes
4. **Progresión no Linear:** Completa arcos en cualquier orden
5. **Sistemas Profundos:** Logros, Leaderboards, Battle Pass
6. **Experiencia Inmersiva:** Audio, vibración, visual glitch para incomodidad
7. **Demo Ending Memorable:** Simulación de doxxeo que marca al jugador

---

## 📱 PLATAFORMAS

- ✅ Android (Compilado)
- ✅ iOS (Preparado)
- ✅ Web (Disponible)
- 🔄 Próximamente: Nintendo Switch, PlayStation, Xbox

---

## 💡 PROPÓSITO NARRATIVO

HUMANO es un comentario social sobre:
- **Ciberacoso y vigilancia digital**
- **Viralización de contenido humillante**
- **Deshumanización en redes sociales**
- **Empatía digital perdida**
- **Consecuencias reales de acciones virtuales**
- **Reflexión sobre culpa y redención**

El jugador no es un "héroe" sino un perpetrador que debe confrontar las consecuencias morales de sus acciones.

---

## ✅ ESTADO DE LA DEMO

**Completado al 100%:**
- ✅ 3 Arcos jugables con gameplay completo
- ✅ Sistema de fragmentos y puzzle
- ✅ Cinemáticas narrativas
- ✅ Tienda con compras reales (Stripe)
- ✅ Logros y leaderboard
- ✅ Multijugador asimétrico
- ✅ Archive con galería de evidencias
- ✅ Demo Ending perturbador
- ✅ Sistemas de progresión
- ✅ Autenticación con Firebase

**Próximamente (Post-Demo):**
- 🔄 4 Arcos adicionales (Ira, Pereza, Lujuria, Soberbia)
- 🔄 Sistema de relaciones
- 🔄 Finales verdaderos
- 🔄 Contenido multijugador expandido
- 🔄 Crossover con otras propiedades intelectuales

---

**¡La experiencia completa de HUMANO está lista para que la vivas!**

```
"¿Cómo se siente ser observado?"
"¿Cómo se siente saber que todos verán?"
"¿Valió la pena?"
```
