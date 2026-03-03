# 📖 Explicación de Funcionalidades - Oolale Mobile

## 🎵 1. PANTALLA DE EXPLORAR MÚSICOS (Discovery Screen)

### 📊 **ESTADÍSTICAS**
Actualmente **NO hay estadísticas visibles** en esta pantalla. La pantalla se enfoca en mostrar directamente los resultados de músicos y bandas disponibles.

---

### 🔍 **BÚSQUEDA**

#### Cómo funciona:
- **Barra de búsqueda** en la parte superior con ícono de lupa
- **Búsqueda en tiempo real**: Cada vez que escribes, se ejecuta automáticamente
- **Campo de búsqueda**: "Músico, banda o instrumento..."

#### Qué busca:
- **Nombre artístico** del músico o banda (búsqueda parcial con `ILIKE`)
- Ejemplo: Si escribes "Leo", encontrará "Leo Fender", "Leonardo", etc.

#### Características especiales:
- **Excluye usuarios bloqueados**: No aparecen músicos que tú bloqueaste o que te bloquearon
- **No te muestra a ti mismo**: Tu propio perfil no aparece en los resultados
- **Paginación automática**: Carga 20 resultados a la vez
- **Scroll infinito**: Al llegar al final de la lista, carga automáticamente más resultados

---

### 🎛️ **FILTROS**

#### Filtros básicos (chips horizontales):

1. **"Todos"** (`todos`)
   - Muestra todos los músicos y bandas sin restricción
   - Filtro por defecto al abrir la pantalla

2. **"Mejor Valorados"** (`top_rated`) ⭐ **NUEVO**
   - Muestra músicos ordenados por su promedio de calificación (de mayor a menor)
   - Los músicos con mejor ranking aparecen primero
   - **Requisito mínimo**: Solo aparecen músicos con al menos **5 calificaciones**
   - Esto garantiza que el ranking sea confiable y no manipulable
   - Usa las columnas `promedio_calificacion` y `total_calificaciones` de la tabla `perfiles`

3. **"Open To Work"** (`open_to_work`)
   - Muestra solo músicos que marcaron su perfil como disponibles para trabajar
   - Filtra por columna `open_to_work = true`

#### Cómo se aplican:
- **Un solo filtro activo a la vez**: Al seleccionar uno, se desactiva el anterior
- **Combinable con búsqueda**: Puedes buscar "Guitarra" + filtro "Open To Work"
- **Recarga automática**: Al cambiar filtro, se reinicia la búsqueda desde página 0

---

### 🔧 **FILTROS AVANZADOS** (Modal)

Se abre al tocar el **ícono de filtro** (`filter_list`) en la barra de búsqueda.

#### Filtros disponibles:

1. **Instrumentos** (Selección múltiple)
   - Guitarra, Bajo, Batería, Teclado, Voz, Saxofón, Trompeta, Violín
   - Puedes seleccionar varios instrumentos a la vez
   - **Nota**: Actualmente en desarrollo (TODO en el código)

2. **Géneros Musicales** (Selección múltiple)
   - Rock, Jazz, Blues, Pop, Metal, Funk, Reggae, Clásica
   - Puedes seleccionar varios géneros a la vez
   - **Nota**: Actualmente en desarrollo (TODO en el código)

3. **Ubicación** (Selección única)
   - CDMX, Guadalajara, Monterrey, Puebla, Querétaro, Tijuana
   - Solo puedes seleccionar una ubicación
   - Filtra por columna `ubicacion_base`

#### Botones del modal:
- **"Limpiar"**: Resetea todos los filtros avanzados
- **"Aplicar Filtros"**: Cierra el modal y ejecuta la búsqueda con los filtros seleccionados

---

### 📋 **VISUALIZACIÓN DE RESULTADOS**

#### Formato:
- **Grid de 2 columnas** con tarjetas de músicos
- **Animación**: Cada tarjeta aparece con efecto `FadeInUp` escalonado

#### Información mostrada en cada tarjeta:
- **Avatar circular** con inicial del nombre
- **Borde de color** según nivel de badge (Pro/Maestro tienen gradiente)
- **Nombre artístico**
- **Instrumento principal** (en mayúsculas)
- **Ubicación base** con ícono de ubicación
- **Botón "Conectar"** para enviar solicitud de conexión

#### Funcionalidad del botón "Conectar":
1. Verifica que no haya bloqueo mutuo
2. Verifica que no exista ya una conexión
3. Crea una solicitud de conexión con `estatus = 'pending'`
4. Envía una notificación al músico objetivo
5. Muestra mensaje de confirmación

---

### 🔄 **REFRESH (Actualizar)**
- **Pull to refresh**: Desliza hacia abajo para recargar
- Reinicia la paginación y vuelve a cargar desde el inicio

---

## 🎪 2. PANTALLA DE EVENTOS (Events Screen)

### 📊 **ESTADÍSTICAS**
Actualmente **NO hay estadísticas visibles** en esta pantalla. La pantalla se enfoca en mostrar la lista de eventos.

---

### 🔍 **BÚSQUEDA**

#### Cómo funciona:
- **Barra de búsqueda** con ícono de lupa
- **Búsqueda en tiempo real**: Se ejecuta al escribir (`onChanged`)
- **Campo de búsqueda**: "Buscar eventos, lugares, ciudades..."

#### Qué busca (búsqueda amplia con `OR`):
1. **Título del evento** (`titulo_bolo`)
2. **Nombre del lugar** (`lugar_nombre`)
3. **Ciudad** (`lugar_ciudad`)

Ejemplo: Si escribes "Rock", encontrará:
- Eventos con "Rock" en el título
- Lugares llamados "Rock Bar"
- Eventos en ciudades como "Rockville"

#### Características especiales:
- **Excluye eventos de usuarios bloqueados**: No aparecen eventos organizados por usuarios que bloqueaste o te bloquearon
- **Paginación**: Carga 20 eventos a la vez
- **Scroll infinito**: Solo en vista "Próximos" (`upcoming`)
- **Botón de limpiar**: Aparece una "X" cuando hay texto para borrar rápidamente

---

### 🎛️ **FILTROS**

#### 1. **Filtros de Categoría de Tiempo** (Chips horizontales)

Estos son los chips que aparecen debajo de la barra de búsqueda:

- **"Próximos"** (`upcoming`) - **Por defecto**
  - Eventos con `fecha_gig >= hoy`
  - Ordenados por fecha ascendente
  - Tiene scroll infinito

- **"Hoy"** (`today`)
  - Eventos con `fecha_gig = hoy`
  - Solo eventos del día actual

- **"Esta Semana"** (`week`)
  - Eventos entre `hoy` y `hoy + 7 días`

- **"Este Mes"** (`month`)
  - Eventos entre `hoy` y `hoy + 1 mes`

- **"Pasados"** (`past`)
  - Eventos con `fecha_gig < hoy`
  - Muestra eventos que ya ocurrieron
  - **NO tiene scroll infinito**

#### 2. **Filtros Avanzados** (Modal de filtros)

Se abre al tocar el ícono de **"tune"** (ajustes) en el header.

##### **Ordenamiento** (`_sortBy`):
- **"Fecha"** (`date`) - Por defecto
  - Ordena por `fecha_gig` ascendente
  
- **"Popularidad"** (`popularity`)
  - Ordena por `created_at` descendente (más recientes primero)

##### **Rango de Fechas** (Actualmente en el código pero NO visible en UI):
El código tiene soporte para:
- `_startDate`: Fecha de inicio
- `_endDate`: Fecha de fin
- **Nota**: Los botones de fecha están en el código pero comentados/no visibles

#### 3. **Botón "Limpiar todos"**
- Aparece en el modal de filtros
- Resetea todos los filtros:
  - `_startDate = null`
  - `_endDate = null`
  - `_selectedView = 'upcoming'`
- Recarga los eventos desde cero

---

### 📋 **VISUALIZACIÓN DE RESULTADOS**

#### Formato:
- **Lista vertical** de tarjetas de eventos
- **Animación**: Cada tarjeta aparece con efecto `FadeInUp` escalonado (20ms de delay entre cada una)

#### Información mostrada en cada tarjeta:

**Lado izquierdo**:
- **Imagen del flyer** (si existe) con overlay de fecha
- **O fecha grande** en un contenedor de color si no hay imagen
  - Día en número grande
  - Mes en texto corto (ENE, FEB, MAR, etc.)

**Lado derecho**:
- **Título del evento** (en negrita)
- **Tipo de evento** (chip pequeño: CONCIERTO, JAM SESSION, etc.)
- **Ubicación** con ícono de pin
- **Hora** con ícono de reloj
- **Flecha** para indicar que es clickeable

#### Colores especiales:
- **Eventos de HOY**: Borde y elementos en **rojo**
- **Eventos PASADOS**: Elementos en **gris**
- **Eventos PRÓXIMOS**: Elementos en **color primario** (amarillo/verde)

---

### 🔄 **REFRESH (Actualizar)**
- **Pull to refresh**: Desliza hacia abajo para recargar
- Reinicia la paginación y vuelve a cargar desde el inicio
- Funciona en todas las vistas

---

### ➕ **CREAR EVENTO**
- **Botón "+"** en el header (esquina superior derecha)
- Abre la pantalla `CreateEventScreen`
- Al crear un evento exitosamente, recarga la lista automáticamente

---

### 🚫 **SISTEMA DE BLOQUEO**

Ambas pantallas implementan el **mismo sistema de bloqueo bidireccional**:

1. **Consulta inicial**: Al cargar, busca en `usuarios_bloqueados`:
   - Usuarios que TÚ bloqueaste (`usuario_id = tuId`)
   - Usuarios que TE bloquearon (`bloqueado_id = tuId`)

2. **Filtrado a nivel de BD**: 
   - Discovery: `id NOT IN (lista_bloqueados)`
   - Events: `organizador_id NOT IN (lista_bloqueados)`

3. **Protección adicional**: Filtrado en el cliente por si acaso

---

## ⭐ **SISTEMA DE RANKING Y CALIFICACIONES**

### Cómo funciona:

1. **Columnas en tabla `perfiles`**
   - `promedio_calificacion`: Promedio de todas las calificaciones recibidas
   - `total_calificaciones`: Número total de calificaciones recibidas
   - Se calculan desde la tabla `referencias` (columna `puntuacion`)

2. **Filtro "Mejor Valorados"**
   - Ordena los resultados por `promedio_calificacion DESC`
   - **Requisito mínimo**: Solo muestra músicos con al menos **5 calificaciones**
   - Los músicos con mejor ranking aparecen primero
   - Útil para encontrar músicos destacados y confiables

3. **¿Por qué un mínimo de 5 calificaciones?**
   - Evita que músicos con 1 o 2 calificaciones de 5 estrellas aparezcan primero
   - Garantiza que el ranking sea representativo y confiable
   - Incentiva a los músicos a conseguir más trabajos y calificaciones
   - Previene manipulación del sistema

4. **Ejemplo práctico:**
   - ❌ Músico con 2 calificaciones de 5⭐ (promedio 5.0) → **NO aparece** en "Mejor Valorados"
   - ✅ Músico con 10 calificaciones de 4.5⭐ (promedio 4.5) → **SÍ aparece** en "Mejor Valorados"
   - ✅ Músico con 50 calificaciones de 4.8⭐ (promedio 4.8) → **Aparece PRIMERO** (más confiable)

5. **Visualización**
   - Los badges (Pro, Maestro, Leyenda) se muestran con gradientes especiales
   - El borde del avatar tiene colores según el nivel

---

## 📝 RESUMEN COMPARATIVO

| Característica | Explorar Músicos | Eventos |
|----------------|------------------|---------|
| **Estadísticas** | ❌ No | ❌ No |
| **Búsqueda** | ✅ Nombre artístico | ✅ Título, lugar, ciudad |
| **Filtros básicos** | 3 chips (Todos, Mejor Valorados, Open to Work) | 5 chips (Próximos, Hoy, Semana, Mes, Pasados) |
| **Filtros avanzados** | ✅ Sí (Instrumentos, Géneros, Ubicación) | ✅ Sí (Ordenamiento) |
| **Ranking** | ✅ Filtro "Mejor Valorados" | ❌ No |
| **Paginación** | ✅ Scroll infinito | ✅ Solo en "Próximos" |
| **Visualización** | Grid 2 columnas | Lista vertical |
| **Bloqueo de usuarios** | ✅ Sí | ✅ Sí |
| **Refresh** | ✅ Pull to refresh | ✅ Pull to refresh |
| **Crear nuevo** | ❌ No | ✅ Botón "+" |

---

## 🎯 CONCLUSIÓN

Ambas pantallas tienen una estructura similar:
1. **Header** con título y acciones
2. **Barra de búsqueda** con búsqueda en tiempo real
3. **Filtros rápidos** (chips horizontales)
4. **Filtros avanzados** (modal)
5. **Lista de resultados** con paginación
6. **Sistema de bloqueo** para proteger la privacidad

### Mejoras implementadas:

✅ **Eliminados filtros obsoletos**: "Músicos" y "Bandas" ya no existen
✅ **Agregado sistema de ranking**: Filtro "Mejor Valorados" para destacar músicos con buenas calificaciones
✅ **Implementados filtros avanzados**: Modal con instrumentos, géneros y ubicación
✅ **Eliminados filtros de tipo de evento**: Ya no se filtran eventos por tipo (concierto, jam session, etc.)

**Ninguna de las dos pantallas muestra estadísticas actualmente**, pero el código está estructurado de forma que sería fácil agregar una sección de estadísticas en el futuro (por ejemplo, "X músicos encontrados", "X eventos esta semana", etc.).
