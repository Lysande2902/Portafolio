# Requirements Document

## Introduction

Este documento especifica los requisitos para solucionar el problema crítico donde los expedientes (fragmentos de evidencia) recolectados durante el gameplay NO se guardan en la base de datos Firebase ni aparecen en la sección ARCHIVOS. El sistema actual tiene una dependencia frágil en `BuildContext` que puede ser `null` durante la recolección de evidencia.

## Glossary

- **Expediente**: Documento narrativo que se desbloquea progresivamente mediante la recolección de fragmentos
- **Fragmento**: Pieza individual de evidencia que desbloquea una página del expediente (5 fragmentos por arco)
- **FragmentsProvider**: Provider de Flutter que maneja el estado y persistencia de fragmentos en Firebase
- **PuzzleIntegrationHelper**: Clase helper que integra la recolección de fragmentos con los providers
- **BuildContext**: Contexto de Flutter necesario para acceder a providers mediante `Provider.of<T>(context)`
- **Evidence Collection**: Evento del juego cuando el jugador recoge un fragmento durante el gameplay
- **Firebase Firestore**: Base de datos donde se persisten los fragmentos en `users/{userId}/progress/fragments`

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero que los fragmentos que recolecto durante el juego se guarden inmediatamente en la base de datos, para que no pierda mi progreso si salgo del juego.

#### Acceptance Criteria

1. WHEN el jugador recolecta un fragmento durante el gameplay THEN el sistema SHALL guardar el fragmento en Firebase inmediatamente
2. WHEN se guarda un fragmento THEN el sistema SHALL actualizar la colección `users/{userId}/progress/fragments` en Firestore
3. WHEN se guarda un fragmento THEN el sistema SHALL registrar el arcId y el número de fragmento correctamente
4. WHEN el guardado falla THEN el sistema SHALL registrar el error sin crashear el juego
5. WHEN el jugador no está autenticado THEN el sistema SHALL manejar el caso gracefully sin intentar guardar

### Requirement 2

**User Story:** Como jugador, quiero ver los fragmentos que recolecté en la sección ARCHIVOS inmediatamente después de recolectarlos, para poder leer el contenido narrativo sin esperar a completar el arco.

#### Acceptance Criteria

1. WHEN el jugador recolecta un fragmento THEN el fragmento SHALL aparecer desbloqueado en la pantalla ARCHIVOS
2. WHEN el jugador abre ARCHIVOS THEN el sistema SHALL cargar los fragmentos desde Firebase
3. WHEN se muestra un fragmento desbloqueado THEN el sistema SHALL mostrar su contenido narrativo completo
4. WHEN el jugador hace clic en un fragmento desbloqueado THEN el sistema SHALL abrir el expediente correspondiente
5. WHEN el sistema carga fragmentos THEN el sistema SHALL sincronizar el estado local con Firebase

### Requirement 3

**User Story:** Como desarrollador, quiero que el sistema de guardado de fragmentos NO dependa de `BuildContext` del juego, para evitar errores cuando el contexto es `null` o inválido.

#### Acceptance Criteria

1. WHEN se recolecta un fragmento THEN el sistema SHALL guardar sin requerir `BuildContext` del juego
2. WHEN se inicializa el juego THEN el sistema SHALL configurar una referencia directa al `FragmentsProvider`
3. WHEN se llama al método de guardado THEN el sistema SHALL usar la referencia directa al provider
4. WHEN el provider no está disponible THEN el sistema SHALL registrar un error sin crashear
5. WHEN se resetea el juego THEN el sistema SHALL mantener la referencia al provider válida

### Requirement 4

**User Story:** Como desarrollador, quiero que el sistema valide que los fragmentos se guardaron correctamente, para poder detectar y debuggear problemas de persistencia.

#### Acceptance Criteria

1. WHEN se guarda un fragmento THEN el sistema SHALL registrar logs detallados del proceso
2. WHEN el guardado es exitoso THEN el sistema SHALL confirmar con un log de éxito
3. WHEN el guardado falla THEN el sistema SHALL registrar el error con stack trace
4. WHEN se recolecta evidencia THEN el sistema SHALL validar que userId existe antes de guardar
5. WHEN se completa el guardado THEN el sistema SHALL verificar que el fragmento existe en Firebase

### Requirement 5

**User Story:** Como jugador, quiero que el sistema maneje correctamente los IDs de arcos, para que los fragmentos se asocien al arco correcto independientemente del formato del ID.

#### Acceptance Criteria

1. WHEN se recolecta un fragmento THEN el sistema SHALL normalizar el arcId al formato estándar
2. WHEN el arcId es 'gluttony' THEN el sistema SHALL convertirlo a 'arc_1_gula'
3. WHEN el arcId es 'greed' THEN el sistema SHALL convertirlo a 'arc_2_greed'
4. WHEN el arcId es 'envy' THEN el sistema SHALL convertirlo a 'arc_3_envy'
5. WHEN el arcId ya está en formato estándar THEN el sistema SHALL usarlo sin modificación
