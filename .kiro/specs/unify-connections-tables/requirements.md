# Requirements Document

## Introduction

Este documento define los requisitos para unificar las dos tablas de conexiones (`connections` y `crews`) que actualmente existen en la aplicación Óolale Mobile, causando inconsistencias críticas en los datos y el comportamiento de la aplicación.

## Glossary

- **System**: El sistema de gestión de conexiones de Óolale Mobile
- **Connection**: Una relación entre dos usuarios (pendiente, aceptada o rechazada)
- **Source_Table**: La tabla `crews` que será migrada
- **Target_Table**: La tabla `connections` que será la tabla unificada final
- **Migration_Script**: Script SQL que migra datos de `crews` a `connections`
- **Flutter_Code**: Código Dart de la aplicación móvil
- **Supabase_Database**: Base de datos PostgreSQL en Supabase

## Requirements

### Requirement 1: Análisis de Datos Existentes

**User Story:** Como desarrollador, quiero analizar los datos existentes en ambas tablas, para entender qué datos deben migrarse y detectar posibles duplicados.

#### Acceptance Criteria

1. WHEN el análisis se ejecuta, THE System SHALL contar el número total de registros en la tabla `crews`
2. WHEN el análisis se ejecuta, THE System SHALL contar el número total de registros en la tabla `connections`
3. WHEN el análisis se ejecuta, THE System SHALL identificar registros duplicados que existen en ambas tablas
4. WHEN el análisis se ejecuta, THE System SHALL identificar registros únicos que solo existen en `crews`
5. WHEN el análisis se ejecuta, THE System SHALL generar un reporte con estadísticas de los datos encontrados

### Requirement 2: Migración de Datos

**User Story:** Como desarrollador, quiero migrar todos los datos de `crews` a `connections`, para consolidar la información en una sola tabla sin pérdida de datos.

#### Acceptance Criteria

1. WHEN la migración se ejecuta, THE Migration_Script SHALL copiar todos los registros únicos de `crews` a `connections`
2. WHEN la migración encuentra un registro duplicado, THE Migration_Script SHALL preservar el registro existente en `connections`
3. WHEN la migración copia un registro, THE Migration_Script SHALL mapear `perfil_id` a `usuario_id`
4. WHEN la migración copia un registro, THE Migration_Script SHALL mapear `target_id` a `conectado_id`
5. WHEN la migración copia un registro, THE Migration_Script SHALL mapear el estado 'pendiente' a 'pending'
6. WHEN la migración copia un registro, THE Migration_Script SHALL mapear el estado 'activo' a 'accepted'
7. WHEN la migración copia un registro, THE Migration_Script SHALL mapear el estado 'rechazado' a 'rejected'
8. WHEN la migración se completa, THE Migration_Script SHALL generar un log con el número de registros migrados
9. WHEN la migración se completa, THE Migration_Script SHALL generar un log con el número de registros duplicados omitidos

### Requirement 3: Actualización de Código Flutter

**User Story:** Como desarrollador, quiero actualizar todo el código Flutter para usar únicamente la tabla `connections`, para eliminar la inconsistencia en el acceso a datos.

#### Acceptance Criteria

1. WHEN se actualiza ConnectionsScreen, THE Flutter_Code SHALL usar únicamente la tabla `connections` para cargar conexiones activas
2. WHEN se actualiza ConnectionsScreen, THE Flutter_Code SHALL usar únicamente la tabla `connections` para cargar solicitudes pendientes
3. WHEN se actualiza ConnectionsScreen, THE Flutter_Code SHALL usar únicamente la tabla `connections` para contar solicitudes pendientes
4. WHEN se actualiza ConnectionRequestsScreen, THE Flutter_Code SHALL mantener el uso de la tabla `connections` sin cambios
5. WHEN se actualiza PublicProfileScreen, THE Flutter_Code SHALL mantener el uso de la tabla `connections` sin cambios
6. WHEN se buscan referencias a `crews`, THE System SHALL identificar todos los archivos que contienen referencias a la tabla `crews`
7. WHEN se actualizan referencias a `crews`, THE Flutter_Code SHALL reemplazar todas las referencias por `connections`

### Requirement 4: Validación de Funcionalidad

**User Story:** Como usuario, quiero que todas las funcionalidades de conexiones sigan funcionando correctamente después de la unificación, para no experimentar pérdida de funcionalidad.

#### Acceptance Criteria

1. WHEN un usuario envía una solicitud de conexión, THE System SHALL crear un registro en `connections` con estado 'pending'
2. WHEN un usuario acepta una solicitud, THE System SHALL actualizar el estado a 'accepted' en `connections`
3. WHEN un usuario rechaza una solicitud, THE System SHALL actualizar el estado a 'rejected' en `connections`
4. WHEN un usuario visualiza sus conexiones activas, THE System SHALL mostrar solo registros con estado 'accepted' de `connections`
5. WHEN un usuario visualiza solicitudes pendientes, THE System SHALL mostrar solo registros con estado 'pending' de `connections`
6. WHEN se cuenta el número de solicitudes pendientes, THE System SHALL retornar el mismo número que aparece en la lista de solicitudes
7. WHEN un usuario bloquea a otro usuario, THE System SHALL eliminar la conexión de la tabla `connections`

### Requirement 5: Eliminación de Tabla Obsoleta

**User Story:** Como desarrollador, quiero eliminar la tabla `crews` después de verificar que la migración fue exitosa, para mantener la base de datos limpia y evitar confusión futura.

#### Acceptance Criteria

1. WHEN se verifica la migración, THE System SHALL confirmar que todos los datos de `crews` existen en `connections`
2. WHEN se verifica el código, THE System SHALL confirmar que no existen referencias a `crews` en el código Flutter
3. WHEN se elimina la tabla, THE Supabase_Database SHALL ejecutar DROP TABLE `crews`
4. WHEN se elimina la tabla, THE System SHALL generar un backup de la tabla `crews` antes de eliminarla

### Requirement 6: Verificación de Integridad

**User Story:** Como desarrollador, quiero verificar la integridad de los datos después de la migración, para asegurar que no se perdió información crítica.

#### Acceptance Criteria

1. WHEN se ejecuta la verificación, THE System SHALL confirmar que el número total de conexiones únicas se mantiene
2. WHEN se ejecuta la verificación, THE System SHALL confirmar que todas las conexiones activas previas siguen activas
3. WHEN se ejecuta la verificación, THE System SHALL confirmar que todas las solicitudes pendientes previas siguen pendientes
4. WHEN se ejecuta la verificación, THE System SHALL confirmar que no existen registros huérfanos sin usuario válido
5. WHEN se ejecuta la verificación, THE System SHALL confirmar que no existen duplicados en `connections`

### Requirement 7: Rollback y Recuperación

**User Story:** Como desarrollador, quiero tener un plan de rollback en caso de que la migración falle, para poder restaurar el estado anterior sin pérdida de datos.

#### Acceptance Criteria

1. WHEN se crea el plan de rollback, THE System SHALL generar un backup completo de la tabla `connections` antes de la migración
2. WHEN se crea el plan de rollback, THE System SHALL generar un backup completo de la tabla `crews` antes de la migración
3. WHEN se ejecuta el rollback, THE System SHALL restaurar ambas tablas a su estado anterior
4. WHEN se ejecuta el rollback, THE System SHALL revertir los cambios en el código Flutter
5. IF la migración falla, THEN THE System SHALL ejecutar automáticamente el rollback
