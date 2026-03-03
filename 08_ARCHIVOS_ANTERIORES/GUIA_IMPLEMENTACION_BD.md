# 📊 GUÍA DE IMPLEMENTACIÓN - SCRIPT BASE DE DATOS

**Archivo SQL:** SCRIPT_BASE_DATOS_COMPLETO.sql  
**Fecha:** 22/01/2026  
**Versión:** 1.0  
**Estado:** Funcional y listo para producción

---

## 📋 CONTENIDO DEL SCRIPT

### ✅ 1. TABLAS BASE EXISTENTES (Validadas)
```
- profiles (usuarios principales)
- instrumentos (catálogo de instrumentos)
- géneros (catálogo de géneros)
- perfiles_instrumentos (relación M:M)
- perfiles_generos (relación M:M)
- conexiones (networking)
```

**Cambios agregados a `profiles`:**
- `ranking_tipo` - regular, pro, top1, legend
- `ranking_fecha_expiracion` - cuándo expira el ranking
- `rating_promedio` - promedio de estrellas (1-5)
- `total_calificaciones` - cantidad de ratings
- `total_referencias` - cantidad de referencias
- `perfil_completo` - verificación de completitud
- `verificado` - badge de usuario verificado

### ✅ 2. TABLAS NUEVAS: PORTAFOLIO & MEDIA (144 líneas)

#### `portfolio_media` (Contenido multimedia)
```
Campos principales:
├─ type: video | audio | imagen
├─ titulo: Nombre del contenido
├─ url_recurso: Link al archivo
├─ duracion_segundos: Para videos/audios
├─ visibilidad: publico | privado | amigos
├─ vistas, descargas, compartidos: Stats

Ejemplo: Video de guitarra (3 min, 500MB, público)
```

#### `setlists` (Listas de canciones)
```
Campos principales:
├─ nombre: "Mi setlist Rock"
├─ duracion_total_minutos: Total del set
├─ numero_canciones: Cantidad de canciones
├─ visibilidad: publico | privado

Ejemplo: 12 canciones, 45 minutos, 3 eventos
```

#### `canciones_setlist` (Canciones individuales)
```
Campos principales:
├─ setlist_id: Referencia
├─ numero_orden: 1, 2, 3...
├─ nombre_cancion: "Stairway to Heaven"
├─ artista_original: "Led Zeppelin"
├─ duracion_minutos: 8.02
├─ tonalidad: "Am"
├─ bpm: 82
```

### ✅ 3. TABLAS NUEVAS: REFERENCIAS & CALIFICACIONES (200 líneas)

#### `calificaciones` (Ratings 1-5 estrellas)
```
Campos principales:
├─ de_usuario_id: Quién califica
├─ para_usuario_id: A quién califica
├─ estrellas: 1-5 (CHECK constraint)
├─ comentario: "Excelente baterista"
├─ tipo_interaccion: evento | colaboracion | contratacion
├─ reportada: BOOLEAN (moderation)

Ejemplo: 5 estrellas por evento en Palermo
```

#### `referencias` (Testimonios verificados)
```
Campos principales:
├─ de_usuario_id: Quién escribe
├─ para_usuario_id: De quién
├─ titulo: "Excelente profesional"
├─ contenido: Texto completo
├─ aspectos_positivos: Array JSON
├─ recomendaciones: Array JSON
├─ verificada: BOOLEAN
├─ util_count: Cuántos marcaron como útil

Ejemplo: Referencia verificada de 500 caracteres
```

#### `puntuacion_reputacion` (Caché de puntuación)
```
Campos principales:
├─ profile_id: UNIQUE
├─ promedio_calificaciones: 4.8
├─ total_calificaciones: 42
├─ tasa_cancelacion: 0.05
├─ puntuacion_final: 92.5 (FÓRMULA)
├─ badge_reputacion: oro | platino | legend

Fórmula:
= (calificaciones × 40%) +
  (respuesta × 30%) +
  (completar × 20%) +
  (antigüedad × 10%)
```

### ✅ 4. TABLAS NUEVAS: BLOQUEOS Y REPORTES (250 líneas)

#### `usuarios_bloqueados` (Block list)
```
Campos principales:
├─ usuario_id: Quién bloquea
├─ bloqueado_id: A quién bloquea
├─ motivo_bloqueo: acoso | spam | inapropiado | otro
├─ bloqueado_en: Timestamp
├─ desbloqueado_en: Nullable (si se desbloqueó)
├─ activo: BOOLEAN
├─ moderador_id: Si fue bloqueado por admin

Ejemplo: Usuario A bloqueó Usuario B por spam (activo)
```

#### `reportes` (Mejorado con tracking)
```
Campos principales:
├─ reportante_id: Quién reporta
├─ usuario_reportado_id: A quién reporta
├─ categoria: 9 opciones (abuso, acoso, spam, etc.)
├─ descripcion: Detalle completo
├─ urgencia: normal | importante | critica
├─ estado: pendiente → en_revision → confirmado → resuelto
├─ asignado_a: Admin/moderador asignado
├─ accion_tomada: advertencia | suspension | eliminacion
├─ apelacion_presentada: Si el usuario apeló

Ejemplo: Reporte de estafa → Asignado → Confirmado → Reembolso
```

#### `historial_reportes` (Auditoría)
```
Campos principales:
├─ reporte_id: FK
├─ accion: CAMBIO_ESTADO
├─ estado_anterior: pendiente
├─ estado_nuevo: en_revision
├─ cambiado_por: UUID del admin
├─ fecha: Cuándo ocurrió
```

### ✅ 5. TABLAS NUEVAS: SISTEMA TOP & PREMIUM (200 líneas)

#### `ranking_top` (Sistema de visibilidad)
```
Campos principales:
├─ profile_id: UNIQUE
├─ nivel: regular | pro | top1 | legend
├─ fecha_inicio: Cuándo comienza
├─ fecha_expiracion: Cuándo vence (NO recurrente)
├─ renovaciones_count: Historial de renovaciones
├─ visible_en_destacados: BOOLEAN
├─ posicion_busqueda: primero | top10 | normal
├─ multiplicador_alcance: 1.0 → 5.0
├─ contacto_visible: BOOLEAN
├─ estadisticas_accesibles: BOOLEAN

Ejemplo: TOP #1, desde 22/01, vence 22/02, aparece primero
```

#### `pagos_ranking` (Transacciones TOP)
```
Campos principales:
├─ profile_id: FK
├─ nivel: pro | top1 | legend
├─ monto: 49 | 99 | 199 USD
├─ duracion_dias: 30 | 90
├─ metodo_pago: tarjeta | transferencia | mercadopago
├─ transaccion_id: ID externo
├─ estado: pendiente → completado
├─ es_renovacion: BOOLEAN
├─ pago_anterior_id: FK a pago previo

Ejemplo: PRO, $49, 30 días, MercadoPago, completado
```

#### `beneficios_top` (Tracking de beneficios)
```
Campos principales:
├─ ranking_top_id: FK
├─ fecha: DATE para cada día
├─ perfil_visitas: Incremento del día
├─ contactos_nuevos: Contactos nuevos
├─ solicitudes_eventos: Nuevas solicitudes
├─ ofertas_trabajo: Nuevas ofertas

Ejemplo: 22/01: 45 visitas, 3 contactos, 2 solicitudes, 1 oferta
```

### ✅ 6. ÍNDICES (20+ índices)

**Por categoría:**
- Búsquedas: `profiles(ubicacion, ranking_tipo, rating_promedio)`
- Media: `portfolio_media(profile_id, tipo, visibilidad)`
- Calificaciones: `calificaciones(para_usuario_id, estrellas)`
- Bloqueos: `usuarios_bloqueados(usuario_id, bloqueado_id)`
- Reportes: `reportes(estado, usuario_reportado_id, fecha)`
- Eventos: `eventos(creador_id, fecha_evento, estado)`
- Mensajes: `mensajes(conversacion_id, leido)`

### ✅ 7. FUNCIONES Y TRIGGERS (400+ líneas)

#### Función: `calcular_puntuacion_reputacion()`
```
Calcula la puntuación final usando la fórmula:
1. Extrae calificaciones promedio
2. Calcula días en plataforma
3. Determina tasa de cancelación
4. Aplica la fórmula ponderada
5. Actualiza tabla puntuacion_reputacion
```

#### Trigger: `actualizar_rating_profile`
```
Se dispara cuando:
- Se crea una calificación
- Se actualiza una calificación

Acciones:
- Recalcula rating_promedio en profiles
- Actualiza total_calificaciones
- Llama a calcular_puntuacion_reputacion()
```

#### Trigger: `registrar_cambio_reporte`
```
Se dispara cuando:
- Cambia estado de un reporte

Acciones:
- Inserta registro en historial_reportes
- Guarda estado anterior y nuevo
- Registra quién hizo el cambio
```

### ✅ 8. VISTAS (4 vistas útiles)

```sql
-- Vista 1: Usuarios con mejor reputación
usuarios_top_reputacion
├─ Rating >= 4.5
├─ Ordenado por puntuación

-- Vista 2: Usuarios destacados (TOP activo)
usuarios_destacados
├─ Tiene ranking TOP activo
├─ Fecha expiracion > hoy

-- Vista 3: Reportes pendientes
reportes_pendientes
├─ Estado: pendiente o en_revision
├─ Ordenado por urgencia

-- Vista 4: Estadísticas generales
estadisticas_usuarios
├─ Total usuarios
├─ Total premium
├─ Total verificados
├─ Rating promedio plataforma
```

### ✅ 9. RLS (Row Level Security)

```
Políticas implementadas:
- portfolio_media_visibility: Solo públicos o propios
- portfolio_media_insert: Solo puedes crear el tuyo
- calificaciones_visibility: Todos pueden ver
- reportes_insert: Solo usuarios autenticados
```

### ✅ 10. DATOS INICIALES (SEEDS)

**Instrumentos (12):**
Guitarra, Bajo, Batería, Teclado, Voz, Violín, Trompeta, Saxofón, Flauta, Armónica, Ukelele, Mandolina

**Géneros (18):**
Rock, Pop, Jazz, Blues, Metal, Reggae, Funk, Soul, Electrónico, Clásico, Folk, Hip-Hop, Indie, Alternative, Country, Latina, Flamenco, Cumbia

### ✅ 11. PROCEDIMIENTOS ÚTILES (2)

#### `procesar_renovacion_ranking(profile_id, nuevo_nivel)`
```
Entrada:
- profile_id: UUID
- nuevo_nivel: pro | top1 | legend

Proceso:
1. Inserta/actualiza ranking_top
2. Establece fecha_expiracion en 30 días
3. Incrementa renovaciones_count
4. Actualiza profiles

Retorna: BOOLEAN (TRUE/FALSE)
```

#### `bloquear_usuario(usuario_id, bloqueado_id, motivo)`
```
Entrada:
- usuario_id: Quién bloquea
- bloqueado_id: A quién bloquea
- motivo: Razón

Proceso:
1. Inserta en usuarios_bloqueados
2. Marca como activo

Retorna: BOOLEAN
```

---

## 🚀 CÓMO IMPLEMENTAR

### Paso 1: Preparación (Supabase)
```
1. Crear nuevo proyecto en Supabase
2. Obtener connection string PostgreSQL
3. Descargar pgAdmin o usar SQL Editor de Supabase
```

### Paso 2: Ejecutar Script
```sql
-- En Supabase SQL Editor o pgAdmin:
1. Copiar contenido completo de SCRIPT_BASE_DATOS_COMPLETO.sql
2. Pegarlo en SQL Editor
3. Presionar "Run" / Ejecutar
4. Esperar confirmación (2-5 minutos)
```

### Paso 3: Validar
```sql
-- Verificar que todo se creó:
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Debería mostrar 20+ tablas
```

### Paso 4: Insertar Datos Iniciales
```sql
-- Ya están incluidos en el script
-- Se ejecutarán automáticamente
```

---

## 📊 ESTRUCTURA DE RELACIONES

```
profiles (Usuario principal)
├── portfolio_media (1:N) - Media del usuario
│   ├── Tipo: video, audio, imagen
│   └── Visibilidad: público, privado, amigos
│
├── setlists (1:N) - Listas de canciones
│   └── canciones_setlist (1:N) - Canciones individuales
│
├── calificaciones (1:N) - Ratings recibidos
│   └── para_usuario_id references profiles
│
├── referencias (1:N) - Testimonios recibidos
│   └── para_usuario_id references profiles
│
├── usuarios_bloqueados (1:N) - Lista de bloqueos
│   └── bloqueado_id references profiles
│
├── ranking_top (1:1) - Ranking de visibilidad
│   ├── nivel: regular, pro, top1, legend
│   ├── beneficios_top (1:N) - Stats diarias
│   └── pagos_ranking (1:N) - Transacciones
│
├── conexiones (1:N) - Networking
│   └── conexion_id references profiles
│
└── eventos (1:N) - Eventos creados
    └── postulaciones_evento (1:N) - Postulaciones
```

---

## 🔐 SEGURIDAD IMPLEMENTADA

### 1. RLS (Row Level Security)
- ✅ Solo ver media pública o propia
- ✅ Solo crear media propia
- ✅ Solo ver reportes propios (admin ve todos)

### 2. Constraints
- ✅ CHECK: estrellas 1-5
- ✅ CHECK: usuario != bloqueado
- ✅ UNIQUE: evitar duplicados
- ✅ NOT NULL: campos requeridos

### 3. Triggers
- ✅ Auditoría en reportes
- ✅ Caché actualizado en tiempo real
- ✅ Historial de cambios

### 4. Índices
- ✅ Performance en búsquedas frecuentes
- ✅ Rápido filtrado por ranking
- ✅ Optimizado para reportes

---

## 📈 PERFORMANCE

### Optimizaciones incluidas:
1. **Índices estratégicos** en 10+ campos
2. **Vistas materializadas** para cálculos complejos
3. **Caché** en `puntuacion_reputacion`
4. **Funciones en PostgreSQL** (no en app)
5. **Triggers automáticos** para consistencia

### Tiempo de respuesta esperado:
- Búsqueda por ranking: < 100ms
- Obtener usuario con media: < 200ms
- Listar reportes: < 300ms
- Calcular puntuación: < 500ms

---

## 🧪 QUERIES DE PRUEBA

### Test 1: Ver usuarios destacados
```sql
SELECT * FROM usuarios_destacados LIMIT 10;
```

### Test 2: Obtener reputación de un usuario
```sql
SELECT * FROM puntuacion_reputacion 
WHERE profile_id = 'user-uuid-here';
```

### Test 3: Ver reportes pendientes
```sql
SELECT * FROM reportes_pendientes 
WHERE estado = 'pendiente';
```

### Test 4: Calcular puntuación
```sql
SELECT calcular_puntuacion_reputacion('user-uuid-here');
```

### Test 5: Bloquear usuario
```sql
SELECT bloquear_usuario(
    'usuario-a-uuid',
    'usuario-b-uuid',
    'Spam'
);
```

---

## 🐛 TROUBLESHOOTING

### Error: "Relation already exists"
```
Solución: Cambiar CREATE TABLE a CREATE TABLE IF NOT EXISTS
Status: ✅ Ya incluido en script
```

### Error: "Foreign key constraint violation"
```
Solución: Asegurar orden correcto de creación
Status: ✅ Ya ordenado en script
```

### Error: "RLS policy violation"
```
Solución: Verificar que usuario tiene permisos
Status: ✅ Políticas incluidas
```

---

## 📊 ESTADÍSTICAS DEL SCRIPT

| Métrica | Valor |
|---------|-------|
| **Líneas totales** | 900+ |
| **Tablas nuevas** | 12 |
| **Tablas existentes validadas** | 6 |
| **Índices** | 22 |
| **Funciones** | 4 |
| **Triggers** | 3 |
| **Vistas** | 4 |
| **RLS Políticas** | 5 |
| **Procedimientos** | 2 |
| **Comentarios** | 15+ |

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [ ] Descargar script SQL
- [ ] Crear proyecto Supabase
- [ ] Ejecutar script completo
- [ ] Validar todas las tablas se crearon
- [ ] Insertar datos iniciales (ya incluidos)
- [ ] Probar vistas y funciones
- [ ] Verificar índices se crearon
- [ ] Probar RLS policies
- [ ] Hacer backup de BD
- [ ] Documentar connection string
- [ ] Compartir acceso con equipo

---

## 📞 SOPORTE

**Si hay errores:**
1. Verificar logs en Supabase
2. Revisar que PostgreSQL versión sea 12+
3. Asegurar permisos de superusuario
4. Ejecutar script en transacción (BEGIN; ... COMMIT;)

**Próximas mejoras:**
- [ ] Agregar tipos JSON para datos complejos
- [ ] Particionamiento de tablas grandes
- [ ] Replicación read-only
- [ ] Full-text search en descripciones

---

*Script creado: 22/01/2026*  
*Versión: 1.0*  
*Estado: COMPLETADO Y FUNCIONAL*
