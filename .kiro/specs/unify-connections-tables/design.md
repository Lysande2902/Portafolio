# Design Document: Unify Connections Tables

## Overview

Este documento describe el diseño técnico para unificar las dos tablas de conexiones (`connections` y `crews`) que actualmente coexisten en la aplicación Óolale Mobile, causando inconsistencias críticas en los datos y el comportamiento.

**Problema actual:**
- Dos tablas diferentes almacenan conexiones entre usuarios
- `connections` usa UUID, inglés para estados, y es usada por algunos componentes
- `crews` usa integer ID, español para estados, y es usada por otros componentes
- El código Flutter usa ambas tablas de forma inconsistente
- Resultado: datos duplicados, contadores incorrectos, confusión en el desarrollo

**Solución propuesta:**
- Usar `connections` como tabla unificada (UUID, inglés, mejor para Supabase)
- Migrar todos los datos de `crews` a `connections`
- Actualizar todo el código Flutter para usar solo `connections`
- Eliminar la tabla `crews` después de verificar la migración

## Architecture

### Database Layer

**Tabla Target (connections):**
```sql
CREATE TABLE connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  conectado_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  estatus TEXT CHECK (estatus IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Tabla Source (crews) - A eliminar:**
```sql
CREATE TABLE crews (
  id INTEGER PRIMARY KEY,
  perfil_id UUID REFERENCES profiles(id),
  target_id UUID REFERENCES profiles(id),
  estatus TEXT CHECK (estatus IN ('pendiente', 'activo', 'rechazado')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Application Layer

**Archivos Flutter afectados:**
1. `lib/screens/connections/connections_screen.dart` - Usa AMBAS tablas (inconsistencia crítica)
2. `lib/screens/connections/connection_requests_screen.dart` - Usa solo `connections`
3. `lib/screens/profile/public_profile_screen.dart` - Usa `connections` y elimina de ambas al bloquear
4. `lib/screens/discovery/discovery_screen.dart` - Usa `crews` para crear conexiones
5. `lib/screens/profile/profile_screen.dart` - Usa `crews` para contar seguidores
6. `lib/screens/profile/profile_detail_lists.dart` - Usa `crews` para listar seguidores

## Components and Interfaces

### 1. Migration Script Component

**Responsabilidad:** Migrar datos de `crews` a `connections` sin pérdida de información.

**Interface:**
```sql
-- Función principal de migración
CREATE OR REPLACE FUNCTION migrate_crews_to_connections()
RETURNS TABLE (
  migrated_count INTEGER,
  duplicate_count INTEGER,
  error_count INTEGER
) AS $$
DECLARE
  v_migrated INTEGER := 0;
  v_duplicates INTEGER := 0;
  v_errors INTEGER := 0;
BEGIN
  -- Lógica de migración
  RETURN QUERY SELECT v_migrated, v_duplicates, v_errors;
END;
$$ LANGUAGE plpgsql;
```

**Lógica de migración:**
1. Iterar sobre cada registro en `crews`
2. Verificar si ya existe en `connections` (mismo `usuario_id` y `conectado_id`)
3. Si no existe, insertar con mapeo de estados:
   - 'pendiente' → 'pending'
   - 'activo' → 'accepted'
   - 'rechazado' → 'rejected'
4. Si existe, incrementar contador de duplicados y omitir
5. Manejar errores y registrar en log

### 2. Analysis Script Component

**Responsabilidad:** Analizar datos existentes antes de la migración.

**Interface:**
```sql
CREATE OR REPLACE FUNCTION analyze_connections_data()
RETURNS TABLE (
  crews_total INTEGER,
  connections_total INTEGER,
  duplicates_count INTEGER,
  crews_unique INTEGER
) AS $$
-- Análisis de datos
$$ LANGUAGE plpgsql;
```

**Análisis incluye:**
- Total de registros en cada tabla
- Registros duplicados (existen en ambas tablas)
- Registros únicos en `crews` que deben migrarse
- Distribución de estados en cada tabla

### 3. Verification Script Component

**Responsabilidad:** Verificar integridad después de la migración.

**Interface:**
```sql
CREATE OR REPLACE FUNCTION verify_migration()
RETURNS TABLE (
  verification_passed BOOLEAN,
  total_connections INTEGER,
  orphaned_records INTEGER,
  duplicate_records INTEGER
) AS $$
-- Verificación de integridad
$$ LANGUAGE plpgsql;
```

**Verificaciones:**
- Todos los registros de `crews` existen en `connections`
- No hay registros huérfanos (usuarios inexistentes)
- No hay duplicados en `connections`
- Conteo total de conexiones únicas se mantiene

### 4. Flutter Code Update Component

**Responsabilidad:** Actualizar código Dart para usar solo `connections`.

**Cambios por archivo:**

**connections_screen.dart:**
```dart
// ANTES (línea 51-55):
final activeData = await _supabase
    .from('crews')
    .select('*, target:profiles!target_id(...)')
    .eq('perfil_id', myId)
    .eq('estatus', 'activo');

// DESPUÉS:
final activeData = await _supabase
    .from('connections')
    .select('*, target:profiles!connections_conectado_id_fkey(...)')
    .eq('usuario_id', myId)
    .eq('estatus', 'accepted');
```

**Mapeo de campos:**
- `crews.perfil_id` → `connections.usuario_id`
- `crews.target_id` → `connections.conectado_id`
- `crews.estatus = 'activo'` → `connections.estatus = 'accepted'`
- `crews.estatus = 'pendiente'` → `connections.estatus = 'pending'`
- `crews.estatus = 'rechazado'` → `connections.estatus = 'rejected'`
- `crews.id` (integer) → `connections.id` (UUID)

**discovery_screen.dart:**
```dart
// ANTES (línea 163-166):
final existing = await _supabase
    .from('crews')
    .select()
    .eq('perfil_id', myId)
    .eq('target_id', targetId);

// DESPUÉS:
final existing = await _supabase
    .from('connections')
    .select()
    .or('and(usuario_id.eq.$myId,conectado_id.eq.$targetId),and(usuario_id.eq.$targetId,conectado_id.eq.$myId)');
```

**profile_screen.dart y profile_detail_lists.dart:**
```dart
// ANTES:
final seguidoresData = await _supabase
    .from('crews')
    .select()
    .eq('target_id', widget.userId);

// DESPUÉS:
final seguidoresData = await _supabase
    .from('connections')
    .select()
    .eq('conectado_id', widget.userId)
    .eq('estatus', 'accepted');
```

### 5. Rollback Component

**Responsabilidad:** Restaurar estado anterior si la migración falla.

**Interface:**
```sql
CREATE OR REPLACE FUNCTION rollback_migration()
RETURNS BOOLEAN AS $$
-- Restaurar backups
$$ LANGUAGE plpgsql;
```

**Proceso de rollback:**
1. Restaurar tabla `connections` desde backup pre-migración
2. Restaurar tabla `crews` desde backup pre-migración
3. Revertir cambios en código Flutter (usando git)
4. Verificar que el sistema funciona como antes

## Data Models

### Connection Model (Unified)

```dart
class Connection {
  final String id;              // UUID
  final String usuarioId;       // UUID del usuario que envía solicitud
  final String conectadoId;     // UUID del usuario que recibe solicitud
  final ConnectionStatus estatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Connection({
    required this.id,
    required this.usuarioId,
    required this.conectadoId,
    required this.estatus,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      usuarioId: json['usuario_id'],
      conectadoId: json['conectado_id'],
      estatus: ConnectionStatus.fromString(json['estatus']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

enum ConnectionStatus {
  pending,
  accepted,
  rejected;
  
  static ConnectionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ConnectionStatus.pending;
      case 'accepted':
        return ConnectionStatus.accepted;
      case 'rejected':
        return ConnectionStatus.rejected;
      default:
        throw ArgumentError('Invalid connection status: $value');
    }
  }
  
  String toJson() {
    switch (this) {
      case ConnectionStatus.pending:
        return 'pending';
      case ConnectionStatus.accepted:
        return 'accepted';
      case ConnectionStatus.rejected:
        return 'rejected';
    }
  }
}
```

### State Mapping

**Mapeo de estados de crews a connections:**
```dart
Map<String, String> stateMapping = {
  'pendiente': 'pending',
  'activo': 'accepted',
  'rechazado': 'rejected',
};
```

## Correctness Properties

*Una propiedad es una característica o comportamiento que debe mantenerse verdadero en todas las ejecuciones válidas del sistema - esencialmente, una declaración formal sobre lo que el sistema debe hacer. Las propiedades sirven como puente entre especificaciones legibles por humanos y garantías de corrección verificables por máquina.*


### Property 1: Migration Completeness
*For any* record in the `crews` table before migration, after migration there must exist an equivalent record in the `connections` table with correctly mapped fields and state.

**Validates: Requirements 2.1, 5.1**

### Property 2: Migration Field Mapping
*For any* record migrated from `crews` to `connections`, the field mapping must be: `perfil_id` → `usuario_id`, `target_id` → `conectado_id`, and state mapping must be: 'pendiente' → 'pending', 'activo' → 'accepted', 'rechazado' → 'rejected'.

**Validates: Requirements 2.3, 2.4, 2.5, 2.6, 2.7**

### Property 3: Duplicate Preservation
*For any* record that exists in both `crews` and `connections` before migration (duplicate), the existing record in `connections` must remain unchanged after migration.

**Validates: Requirements 2.2**

### Property 4: Connection Request Creation
*For any* user sending a connection request to another user, the system must create a record in `connections` with `estatus = 'pending'` and the correct `usuario_id` and `conectado_id`.

**Validates: Requirements 4.1**

### Property 5: Connection State Transitions
*For any* connection request, when accepted the state must transition to 'accepted', and when rejected the state must transition to 'rejected' in the `connections` table.

**Validates: Requirements 4.2, 4.3**

### Property 6: Connection Filtering by State
*For any* query for connections by state (active or pending), the system must return only records from `connections` table that match the specified state ('accepted' for active, 'pending' for pending).

**Validates: Requirements 4.4, 4.5**

### Property 7: Counter Consistency
*For any* user viewing their pending requests, the count of pending requests must equal the length of the list of pending requests displayed.

**Validates: Requirements 4.6**

### Property 8: Block Removes Connection
*For any* user blocking another user, the system must delete any existing connection record between them from the `connections` table.

**Validates: Requirements 4.7**

### Property 9: Total Connections Invariant
*For any* migration execution, the total number of unique connections (unique pairs of users) before migration must equal the total number of unique connections after migration.

**Validates: Requirements 6.1**

### Property 10: State Preservation
*For any* connection with state 'accepted' or 'pending' before migration, the same connection must maintain the same state after migration.

**Validates: Requirements 6.2, 6.3**

### Property 11: Referential Integrity
*For any* connection record in `connections`, both `usuario_id` and `conectado_id` must reference existing users in the `profiles` table.

**Validates: Requirements 6.4**

### Property 12: Connection Uniqueness
*For any* pair of users (A, B), there must exist at most one connection record in `connections` (either A→B or B→A, but not both).

**Validates: Requirements 6.5**

### Property 13: Rollback Restoration
*For any* rollback execution after a failed migration, the state of both `connections` and `crews` tables must be identical to their state immediately before the migration started.

**Validates: Requirements 7.3**

### Property 14: Automatic Rollback on Failure
*For any* migration execution that encounters an error, the system must automatically trigger the rollback process.

**Validates: Requirements 7.5**

## Error Handling

### Migration Errors

**Error Types:**
1. **Duplicate Key Violation:** Intentar insertar un registro que ya existe en `connections`
   - **Handling:** Omitir inserción, incrementar contador de duplicados, continuar migración
   
2. **Foreign Key Violation:** Registro en `crews` referencia usuario inexistente
   - **Handling:** Registrar error, omitir registro, incrementar contador de errores, continuar migración
   
3. **Invalid State Value:** Estado en `crews` no es 'pendiente', 'activo', o 'rechazado'
   - **Handling:** Registrar error, omitir registro, incrementar contador de errores, continuar migración
   
4. **Database Connection Error:** Pérdida de conexión durante migración
   - **Handling:** Detener migración, ejecutar rollback automático, notificar error

### Flutter Code Errors

**Error Types:**
1. **Query Error:** Error al consultar `connections`
   - **Handling:** Mostrar mensaje de error al usuario, registrar en logs, no crashear app
   
2. **Insert Error:** Error al crear nueva conexión
   - **Handling:** Mostrar mensaje de error específico, no cambiar estado de UI
   
3. **Update Error:** Error al actualizar estado de conexión
   - **Handling:** Mostrar mensaje de error, recargar datos para reflejar estado real
   
4. **Delete Error:** Error al eliminar conexión
   - **Handling:** Mostrar mensaje de error, no cambiar estado de UI

### Rollback Errors

**Error Types:**
1. **Backup Not Found:** No existe backup para restaurar
   - **Handling:** Abortar rollback, notificar error crítico, mantener estado actual
   
2. **Restore Error:** Error al restaurar desde backup
   - **Handling:** Intentar restaurar tabla por tabla, registrar errores, notificar estado final

## Testing Strategy

### Dual Testing Approach

Este proyecto requiere tanto **unit tests** como **property-based tests** para garantizar corrección completa:

- **Unit tests:** Verifican ejemplos específicos, casos edge, y condiciones de error
- **Property tests:** Verifican propiedades universales a través de muchos inputs generados

Ambos tipos de tests son complementarios y necesarios para cobertura comprehensiva.

### Property-Based Testing

**Framework:** Para Dart/Flutter, usaremos el paquete `test` con generadores personalizados o `faker` para generar datos de prueba.

**Configuración:**
- Mínimo 100 iteraciones por property test
- Cada property test debe referenciar su propiedad del documento de diseño
- Tag format: `@Tags(['Feature: unify-connections-tables', 'Property N: {property_text}'])`

**Property Tests a Implementar:**

1. **Property 1 Test:** Generar conjunto aleatorio de registros en `crews`, ejecutar migración, verificar que todos existen en `connections`

2. **Property 2 Test:** Generar registros con diferentes estados en `crews`, verificar mapeo correcto de campos y estados después de migración

3. **Property 3 Test:** Generar registros duplicados en ambas tablas, verificar que los de `connections` no cambian

4. **Property 7 Test:** Generar conjunto aleatorio de conexiones pendientes, verificar que contador = length(lista)

5. **Property 9 Test:** Generar conjunto aleatorio de conexiones, contar únicos antes y después de migración, verificar igualdad

6. **Property 10 Test:** Generar conexiones con estados 'accepted' y 'pending', verificar que se preservan después de migración

7. **Property 11 Test:** Generar conexiones, verificar que todos los IDs referencian usuarios existentes

8. **Property 12 Test:** Generar múltiples conexiones, verificar que no hay duplicados (A→B y B→A)

### Unit Testing

**Unit Tests a Implementar:**

1. **Analysis Script Tests:**
   - Test que el análisis cuenta correctamente registros en cada tabla
   - Test que identifica duplicados correctamente
   - Test que identifica registros únicos correctamente
   - Test que genera reporte con formato correcto

2. **Migration Script Tests:**
   - Test migración de registro simple
   - Test manejo de duplicados
   - Test mapeo de cada estado específico
   - Test generación de logs
   - Test manejo de errores (foreign key violation, invalid state)

3. **Flutter Code Tests:**
   - Test que ConnectionsScreen carga solo de `connections`
   - Test que contador de pendientes usa `connections`
   - Test que crear conexión usa `connections`
   - Test que aceptar/rechazar actualiza `connections`
   - Test que bloquear elimina de `connections`

4. **Verification Tests:**
   - Test que verificación detecta registros faltantes
   - Test que verificación detecta duplicados
   - Test que verificación detecta registros huérfanos

5. **Rollback Tests:**
   - Test que rollback restaura estado anterior
   - Test que rollback se activa automáticamente en error
   - Test que rollback maneja backup faltante

### Integration Testing

**Escenarios de integración:**

1. **End-to-End Migration:**
   - Setup: Crear datos de prueba en ambas tablas
   - Execute: Ejecutar migración completa
   - Verify: Verificar integridad, funcionalidad Flutter, eliminar `crews`
   - Cleanup: Restaurar estado de prueba

2. **Flutter UI Flow:**
   - Test flujo completo: enviar solicitud → aceptar → mensajear
   - Test flujo completo: enviar solicitud → rechazar
   - Test flujo completo: conectar → bloquear
   - Verificar que todo usa solo `connections`

3. **Error Recovery:**
   - Simular error durante migración
   - Verificar que rollback se ejecuta
   - Verificar que sistema vuelve a estado funcional

### Manual Testing Checklist

Después de la migración, verificar manualmente:

- [ ] Contador de solicitudes pendientes coincide con lista
- [ ] Conexiones activas se muestran correctamente
- [ ] Enviar nueva solicitud funciona
- [ ] Aceptar solicitud funciona
- [ ] Rechazar solicitud funciona
- [ ] Bloquear usuario elimina conexión
- [ ] Mensajería requiere conexión aceptada
- [ ] No hay referencias a `crews` en código
- [ ] Tabla `crews` fue eliminada de Supabase

## Implementation Notes

### Migration Execution Order

1. **Pre-Migration:**
   - Crear backups de ambas tablas
   - Ejecutar análisis de datos
   - Revisar reporte de análisis
   - Confirmar con usuario antes de proceder

2. **Migration:**
   - Ejecutar script de migración
   - Monitorear logs en tiempo real
   - Verificar contadores (migrados, duplicados, errores)

3. **Post-Migration:**
   - Ejecutar script de verificación
   - Revisar resultados de verificación
   - Si todo OK, proceder con actualización de código
   - Si hay errores, ejecutar rollback

4. **Code Update:**
   - Actualizar archivos Flutter uno por uno
   - Ejecutar tests después de cada cambio
   - Verificar que app funciona correctamente

5. **Cleanup:**
   - Verificar que no hay referencias a `crews`
   - Crear backup final de `crews`
   - Eliminar tabla `crews`
   - Documentar cambios

### Database Indexes

Después de la migración, asegurar que existen estos índices en `connections`:

```sql
-- Índice para búsquedas por usuario_id
CREATE INDEX IF NOT EXISTS idx_connections_usuario_id 
ON connections(usuario_id);

-- Índice para búsquedas por conectado_id
CREATE INDEX IF NOT EXISTS idx_connections_conectado_id 
ON connections(conectado_id);

-- Índice para búsquedas por estado
CREATE INDEX IF NOT EXISTS idx_connections_estatus 
ON connections(estatus);

-- Índice compuesto para búsquedas comunes
CREATE INDEX IF NOT EXISTS idx_connections_usuario_estatus 
ON connections(usuario_id, estatus);

CREATE INDEX IF NOT EXISTS idx_connections_conectado_estatus 
ON connections(conectado_id, estatus);
```

### Performance Considerations

- La migración debe ejecutarse en una transacción para garantizar atomicidad
- Para tablas grandes (>10,000 registros), considerar migración por lotes
- Monitorear uso de memoria durante migración
- Considerar ejecutar migración en horario de bajo tráfico

### Security Considerations

- Backups deben almacenarse de forma segura
- Solo administradores deben poder ejecutar migración
- Logs no deben contener información sensible de usuarios
- Verificar permisos de Row Level Security en `connections` después de migración
