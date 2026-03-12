# Requirements Document

## Introduction

Este documento define los requisitos para el sistema de base de datos multi-usuario que gestiona toda la persistencia de datos individuales por usuario. El sistema debe manejar el progreso de arcos, inventario, estadísticas, configuraciones y evidencias de manera independiente para cada usuario autenticado, garantizando que cada jugador tenga su propio flujo y progreso único en el juego.

## Glossary

- **User Database System**: Sistema de persistencia de datos que gestiona toda la información individual de cada usuario en Firestore
- **User Document**: Documento principal en Firestore que contiene toda la información de un usuario específico
- **Arc Progress**: Progreso individual de un usuario en cada arco del juego (estado, porcentaje, evidencias)
- **Player Inventory**: Inventario del jugador incluyendo monedas, items comprados, battle pass y nivel
- **User Stats**: Estadísticas globales del usuario (tiempo de juego, arcos completados, intentos)
- **Game Settings**: Configuraciones personalizadas del usuario (volumen, efectos visuales)
- **Evidence Collection**: Colección de evidencias recolectadas por el usuario en cada arco
- **Firestore**: Base de datos NoSQL de Firebase utilizada para almacenar datos de usuarios
- **Real-time Sync**: Sincronización en tiempo real entre la base de datos y la aplicación
- **User Session**: Sesión activa de un usuario autenticado en la aplicación

## Requirements

### Requirement 1

**User Story:** Como usuario autenticado, quiero que mi progreso se guarde automáticamente en la nube, para que pueda continuar mi juego desde cualquier dispositivo.

#### Acceptance Criteria

1. WHEN un usuario se autentica exitosamente THEN el sistema SHALL crear o recuperar su documento de usuario en Firestore
2. WHEN un usuario inicia sesión por primera vez THEN el sistema SHALL inicializar su documento con valores por defecto (5000 monedas, 0 arcos completados, configuraciones predeterminadas)
3. WHEN un usuario realiza cambios en su progreso THEN el sistema SHALL sincronizar automáticamente los cambios con Firestore
4. WHEN un usuario cierra sesión THEN el sistema SHALL mantener todos sus datos persistidos en Firestore
5. WHEN un usuario inicia sesión desde otro dispositivo THEN el sistema SHALL cargar su progreso más reciente desde Firestore

### Requirement 2

**User Story:** Como usuario, quiero que mi progreso en cada arco se guarde individualmente, para que el sistema recuerde qué arcos he completado y cuáles están en progreso.

#### Acceptance Criteria

1. WHEN un usuario inicia un arco THEN el sistema SHALL crear o actualizar el registro de progreso para ese arco con estado "inProgress"
2. WHEN un usuario recolecta una evidencia THEN el sistema SHALL agregar el ID de la evidencia a la lista de evidencias recolectadas del arco
3. WHEN un usuario completa un arco THEN el sistema SHALL actualizar el estado del arco a "completed" y actualizar el contador de arcos completados
4. WHEN un usuario abandona un arco THEN el sistema SHALL guardar el porcentaje de progreso actual y la fecha de última jugada
5. WHEN un usuario consulta su progreso THEN el sistema SHALL retornar el estado actualizado de todos los arcos desde Firestore

### Requirement 3

**User Story:** Como usuario, quiero que mi inventario y monedas se sincronicen correctamente, para que mis compras y recompensas se reflejen en todos mis dispositivos.

#### Acceptance Criteria

1. WHEN un usuario compra un item en la tienda THEN el sistema SHALL deducir las monedas del inventario y agregar el item a la lista de items poseídos
2. WHEN un usuario recibe monedas como recompensa THEN el sistema SHALL incrementar el balance de monedas en Firestore inmediatamente
3. WHEN un usuario compra el battle pass THEN el sistema SHALL actualizar el campo hasBattlePass a true y establecer el nivel inicial
4. WHEN un usuario equipa un item THEN el sistema SHALL actualizar el estado de equipamiento del item en Firestore
5. WHEN ocurre un error en una transacción THEN el sistema SHALL revertir los cambios locales y mantener la consistencia con Firestore

### Requirement 4

**User Story:** Como usuario, quiero que mis configuraciones de juego se guarden, para que mis preferencias de volumen y efectos visuales persistan entre sesiones.

#### Acceptance Criteria

1. WHEN un usuario ajusta el volumen de música THEN el sistema SHALL actualizar el valor de musicVolume en Firestore
2. WHEN un usuario ajusta el volumen de efectos de sonido THEN el sistema SHALL actualizar el valor de sfxVolume en Firestore
3. WHEN un usuario activa o desactiva efectos VHS THEN el sistema SHALL actualizar el campo vhsEffectsEnabled en Firestore
4. WHEN un usuario activa o desactiva efectos de glitch THEN el sistema SHALL actualizar el campo glitchEffectsEnabled en Firestore
5. WHEN un usuario inicia sesión THEN el sistema SHALL cargar sus configuraciones guardadas y aplicarlas a la aplicación

### Requirement 5

**User Story:** Como usuario, quiero que mis estadísticas de juego se actualicen automáticamente, para que pueda ver mi tiempo total de juego y logros acumulados.

#### Acceptance Criteria

1. WHEN un usuario completa una sesión de juego THEN el sistema SHALL incrementar el tiempo total de juego en minutos
2. WHEN un usuario completa un arco THEN el sistema SHALL incrementar el contador de arcos completados
3. WHEN un usuario intenta un arco THEN el sistema SHALL incrementar el contador de intentos totales
4. WHEN un usuario consulta sus estadísticas THEN el sistema SHALL retornar los valores actualizados desde Firestore
5. WHEN se crea una cuenta nueva THEN el sistema SHALL inicializar las estadísticas con valores en cero y la fecha de creación actual

### Requirement 6

**User Story:** Como desarrollador, quiero que el sistema maneje errores de red y conflictos de sincronización, para que la experiencia del usuario sea robusta incluso con conexión inestable.

#### Acceptance Criteria

1. WHEN ocurre un error de red durante una escritura THEN el sistema SHALL reintentar la operación automáticamente hasta 3 veces
2. WHEN falla la conexión a Firestore THEN el sistema SHALL notificar al usuario y mantener los datos locales hasta que se restablezca la conexión
3. WHEN se detecta un conflicto de datos THEN el sistema SHALL priorizar los datos más recientes basándose en timestamps
4. WHEN se restaura la conexión THEN el sistema SHALL sincronizar automáticamente todos los cambios pendientes
5. WHEN ocurre un error crítico de base de datos THEN el sistema SHALL registrar el error y mostrar un mensaje apropiado al usuario

### Requirement 7

**User Story:** Como desarrollador, quiero que el sistema use listeners en tiempo real para cambios críticos, para que la UI se actualice automáticamente cuando cambien los datos del usuario.

#### Acceptance Criteria

1. WHEN se inicializa el provider de usuario THEN el sistema SHALL establecer un listener en tiempo real al documento del usuario
2. WHEN cambian las monedas del usuario en Firestore THEN el sistema SHALL actualizar automáticamente la UI sin requerir refresh manual
3. WHEN cambia el progreso de un arco en Firestore THEN el sistema SHALL notificar a los listeners y actualizar la UI correspondiente
4. WHEN el usuario cierra sesión THEN el sistema SHALL cancelar todos los listeners activos para liberar recursos
5. WHEN se detecta un cambio en el documento del usuario THEN el sistema SHALL actualizar el estado local y notificar a todos los widgets suscritos

### Requirement 8

**User Story:** Como usuario, quiero que mis evidencias recolectadas se guarden por arco, para que el sistema recuerde qué evidencias he encontrado en cada historia.

#### Acceptance Criteria

1. WHEN un usuario recolecta una evidencia durante el gameplay THEN el sistema SHALL agregar el ID de la evidencia a la lista del arco correspondiente
2. WHEN un usuario consulta las evidencias de un arco THEN el sistema SHALL retornar la lista completa de IDs de evidencias recolectadas
3. WHEN un usuario completa un arco THEN el sistema SHALL mantener la lista de evidencias recolectadas para referencia futura
4. WHEN un usuario reinicia un arco THEN el sistema SHALL preservar las evidencias previamente recolectadas
5. WHEN un usuario visualiza el archivo THEN el sistema SHALL mostrar todas las evidencias recolectadas de todos los arcos

### Requirement 9

**User Story:** Como desarrollador, quiero una estructura de datos clara y escalable en Firestore, para que sea fácil agregar nuevas funcionalidades y mantener el código.

#### Acceptance Criteria

1. WHEN se diseña la estructura de Firestore THEN el sistema SHALL usar una colección "users" con documentos identificados por userId
2. WHEN se almacenan datos de arcos THEN el sistema SHALL usar un mapa "arcProgress" con claves de arcId dentro del documento de usuario
3. WHEN se almacenan configuraciones THEN el sistema SHALL usar un objeto anidado "settings" dentro del documento de usuario
4. WHEN se almacenan estadísticas THEN el sistema SHALL usar un objeto anidado "stats" dentro del documento de usuario
5. WHEN se almacena el inventario THEN el sistema SHALL usar un objeto anidado "inventory" dentro del documento de usuario

### Requirement 10

**User Story:** Como desarrollador, quiero repositorios y providers específicos para cada dominio de datos, para que el código esté organizado y sea fácil de mantener.

#### Acceptance Criteria

1. WHEN se implementa la persistencia de usuario THEN el sistema SHALL crear un UserRepository que maneje todas las operaciones CRUD del documento de usuario
2. WHEN se implementa la lógica de negocio THEN el sistema SHALL crear un UserDataProvider que use el UserRepository y notifique cambios
3. WHEN se necesita acceder a datos de usuario THEN el sistema SHALL usar el UserDataProvider en lugar de acceder directamente a Firestore
4. WHEN se agregan nuevas funcionalidades THEN el sistema SHALL extender los repositorios y providers existentes manteniendo la separación de responsabilidades
5. WHEN se escriben pruebas THEN el sistema SHALL permitir inyectar mocks de repositorios para facilitar el testing
