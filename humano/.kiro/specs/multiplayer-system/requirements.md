# Requirements Document - Sistema Multijugador

## Introduction

El Sistema Multijugador permite a los jugadores de "Humano" jugar cooperativamente en los arcos del juego. Los jugadores pueden crear o unirse a salas de juego, sincronizar sus posiciones y acciones en tiempo real, y colaborar para recolectar evidencias y escapar del enemigo. El sistema utiliza Supabase Realtime para la sincronización de estado del juego.

## Glossary

- **MultiplayerSystem**: El sistema principal que gestiona la funcionalidad multijugador
- **GameRoom**: Una sala de juego donde múltiples jugadores pueden jugar juntos
- **RealtimeChannel**: Canal de Supabase Realtime para sincronización en tiempo real
- **PlayerState**: El estado de un jugador individual (posición, cordura, evidencias)
- **GameHost**: El jugador que crea la sala y tiene control sobre el inicio del juego
- **GameClient**: Un jugador que se une a una sala existente
- **SyncManager**: Componente que sincroniza el estado del juego entre jugadores

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero crear una sala de juego multijugador, para invitar a amigos a jugar conmigo.

#### Acceptance Criteria

1. WHEN the player selects "Crear Sala" in the menu, THE MultiplayerSystem SHALL create a new GameRoom with a unique room code
2. WHEN the GameRoom is created, THE MultiplayerSystem SHALL generate a 6-character alphanumeric room code
3. WHEN the GameRoom is created, THE MultiplayerSystem SHALL set the creator as the GameHost
4. WHEN the GameRoom is created, THE MultiplayerSystem SHALL display the room code to the host
5. WHEN the GameRoom is created, THE MultiplayerSystem SHALL initialize a RealtimeChannel for the room

### Requirement 2

**User Story:** Como jugador, quiero unirme a una sala de juego existente usando un código, para jugar con mis amigos.

#### Acceptance Criteria

1. WHEN the player selects "Unirse a Sala" in the menu, THE MultiplayerSystem SHALL display a room code input field
2. WHEN the player enters a valid room code, THE MultiplayerSystem SHALL connect to the corresponding GameRoom
3. WHEN the player enters an invalid room code, THE MultiplayerSystem SHALL display an error message "Sala no encontrada"
4. WHEN the player successfully joins a room, THE MultiplayerSystem SHALL add the player as a GameClient
5. WHEN the player joins a room, THE MultiplayerSystem SHALL notify all players in the room of the new player

### Requirement 3

**User Story:** Como host de la sala, quiero ver la lista de jugadores conectados, para saber quién está listo para jugar.

#### Acceptance Criteria

1. WHEN players join the GameRoom, THE MultiplayerSystem SHALL display a list of connected players
2. WHILE in the lobby, THE MultiplayerSystem SHALL show each player's username and ready status
3. WHEN a player joins or leaves, THE MultiplayerSystem SHALL update the player list in real-time
4. WHILE in the lobby, THE MultiplayerSystem SHALL display the room code prominently
5. WHEN all players are ready, THE MultiplayerSystem SHALL enable the "Iniciar Juego" button for the host

### Requirement 4

**User Story:** Como jugador en la sala, quiero marcarme como listo, para indicar que estoy preparado para comenzar.

#### Acceptance Criteria

1. WHEN the player is in the lobby, THE MultiplayerSystem SHALL display a "Listo" toggle button
2. WHEN the player toggles ready status, THE MultiplayerSystem SHALL broadcast the status to all players
3. WHILE the player is ready, THE MultiplayerSystem SHALL display a checkmark next to the player's name
4. WHEN the player toggles ready off, THE MultiplayerSystem SHALL remove the checkmark
5. WHILE not all players are ready, THE MultiplayerSystem SHALL disable the "Iniciar Juego" button

### Requirement 5

**User Story:** Como host, quiero iniciar el juego cuando todos estén listos, para comenzar la partida multijugador.

#### Acceptance Criteria

1. WHEN all players are ready, THE MultiplayerSystem SHALL enable the "Iniciar Juego" button for the host
2. WHEN the host clicks "Iniciar Juego", THE MultiplayerSystem SHALL broadcast a game start event to all players
3. WHEN the game start event is received, THE MultiplayerSystem SHALL transition all players to the game screen
4. WHEN the game starts, THE MultiplayerSystem SHALL initialize the selected arc for all players
5. WHEN the game starts, THE MultiplayerSystem SHALL spawn all players at designated spawn points

### Requirement 6

**User Story:** Como jugador, quiero ver a otros jugadores en tiempo real durante el juego, para coordinar estrategias.

#### Acceptance Criteria

1. WHILE the game is running, THE SyncManager SHALL broadcast the player's position every 100 milliseconds
2. WHEN another player's position is received, THE SyncManager SHALL update the remote player's visual representation
3. WHILE the game is running, THE MultiplayerSystem SHALL render remote players as semi-transparent avatars
4. WHEN a remote player moves, THE SyncManager SHALL interpolate the movement for smooth animation
5. WHILE a remote player is visible, THE MultiplayerSystem SHALL display the player's username above their avatar

### Requirement 7

**User Story:** Como jugador, quiero que mi cordura y estado se sincronicen con otros jugadores, para que todos vean mi situación.

#### Acceptance Criteria

1. WHEN the player's sanity changes, THE SyncManager SHALL broadcast the new sanity value
2. WHEN the player collects evidence, THE SyncManager SHALL broadcast the collection event
3. WHEN the player hides, THE SyncManager SHALL broadcast the hiding state
4. WHEN a remote player's state is received, THE SyncManager SHALL update the remote player's visual indicators
5. WHILE a remote player has low sanity, THE MultiplayerSystem SHALL display a warning icon above their avatar

### Requirement 8

**User Story:** Como jugador, quiero que las evidencias se sincronicen entre todos, para que no se dupliquen las recolecciones.

#### Acceptance Criteria

1. WHEN any player collects an evidence item, THE SyncManager SHALL broadcast the collection to all players
2. WHEN an evidence collection event is received, THE MultiplayerSystem SHALL remove the evidence from all players' games
3. WHEN an evidence is collected, THE MultiplayerSystem SHALL increment the shared evidence counter
4. WHILE the game is running, THE MultiplayerSystem SHALL display the total evidence collected by all players
5. WHEN all evidence is collected, THE MultiplayerSystem SHALL unlock the exit door for all players

### Requirement 9

**User Story:** Como jugador, quiero que el enemigo se sincronice entre todos, para que todos vean la misma amenaza.

#### Acceptance Criteria

1. WHEN the host's game is running, THE SyncManager SHALL broadcast the enemy's position every 100 milliseconds
2. WHEN the host's game is running, THE SyncManager SHALL broadcast the enemy's state (patrol, chase, waiting)
3. WHEN enemy data is received by clients, THE SyncManager SHALL update the enemy's position and state
4. WHILE the enemy is chasing, THE SyncManager SHALL prioritize the closest player as the target
5. WHEN the enemy catches any player, THE SyncManager SHALL broadcast the event to all players

### Requirement 10

**User Story:** Como jugador, quiero que el juego termine cuando todos los jugadores completen el objetivo o mueran, para una experiencia cooperativa completa.

#### Acceptance Criteria

1. WHEN any player reaches the exit door, THE MultiplayerSystem SHALL wait for all players to reach the exit
2. WHEN all players reach the exit, THE MultiplayerSystem SHALL trigger the victory screen for all players
3. WHEN any player dies, THE MultiplayerSystem SHALL mark the player as dead but continue the game
4. WHEN all players are dead, THE MultiplayerSystem SHALL trigger the game over screen for all players
5. WHEN the game ends, THE MultiplayerSystem SHALL award coins and progress to all players who survived

### Requirement 11

**User Story:** Como jugador, quiero poder salir de una sala multijugador, para volver al menú principal.

#### Acceptance Criteria

1. WHEN the player clicks "Salir" in the lobby, THE MultiplayerSystem SHALL disconnect from the GameRoom
2. WHEN the player disconnects, THE MultiplayerSystem SHALL notify all remaining players
3. WHEN the host disconnects, THE MultiplayerSystem SHALL migrate host status to another player
4. WHEN the last player leaves, THE MultiplayerSystem SHALL close the GameRoom
5. WHEN the player disconnects during gameplay, THE MultiplayerSystem SHALL remove the player's avatar from other players' games

### Requirement 12

**User Story:** Como jugador, quiero que el sistema maneje desconexiones inesperadas, para que el juego no se rompa si alguien pierde conexión.

#### Acceptance Criteria

1. WHEN a player loses connection, THE MultiplayerSystem SHALL detect the disconnection within 5 seconds
2. WHEN a disconnection is detected, THE MultiplayerSystem SHALL notify all remaining players
3. WHEN a player disconnects during gameplay, THE MultiplayerSystem SHALL remove their avatar after 10 seconds
4. WHEN the host disconnects, THE MultiplayerSystem SHALL automatically migrate host to the next player
5. WHEN a player reconnects within 30 seconds, THE MultiplayerSystem SHALL restore their state and rejoin the game

### Requirement 13

**User Story:** Como jugador, quiero que el sistema tenga límites de jugadores, para mantener el rendimiento y la jugabilidad.

#### Acceptance Criteria

1. WHEN creating a GameRoom, THE MultiplayerSystem SHALL set a maximum of 4 players per room
2. WHEN a room has 4 players, THE MultiplayerSystem SHALL prevent additional players from joining
3. WHEN a player tries to join a full room, THE MultiplayerSystem SHALL display an error message "Sala llena"
4. WHILE the game is running, THE MultiplayerSystem SHALL maintain 60 FPS with up to 4 players
5. WHEN the room is full, THE MultiplayerSystem SHALL hide the room from public listings

### Requirement 14

**User Story:** Como jugador, quiero ver indicadores de latencia, para saber si mi conexión es buena.

#### Acceptance Criteria

1. WHILE connected to a GameRoom, THE MultiplayerSystem SHALL measure round-trip latency every 2 seconds
2. WHEN latency is below 100ms, THE MultiplayerSystem SHALL display a green connection indicator
3. WHEN latency is between 100-300ms, THE MultiplayerSystem SHALL display a yellow connection indicator
4. WHEN latency is above 300ms, THE MultiplayerSystem SHALL display a red connection indicator
5. WHEN latency exceeds 1000ms, THE MultiplayerSystem SHALL display a "Conexión inestable" warning

### Requirement 15

**User Story:** Como desarrollador, quiero que el sistema multijugador se integre con Supabase, para aprovechar la infraestructura existente.

#### Acceptance Criteria

1. WHEN the MultiplayerSystem initializes, THE MultiplayerSystem SHALL use Supabase Realtime for communication
2. WHEN creating a GameRoom, THE MultiplayerSystem SHALL store room data in the Supabase database
3. WHEN players join, THE MultiplayerSystem SHALL authenticate using existing Supabase auth
4. WHEN the game ends, THE MultiplayerSystem SHALL save multiplayer stats to the player's profile
5. WHEN broadcasting state, THE MultiplayerSystem SHALL use Supabase Realtime channels for low-latency communication
