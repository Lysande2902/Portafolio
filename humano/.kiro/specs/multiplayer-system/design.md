# Design Document - Sistema Multijugador

## Overview

El Sistema Multijugador permite a los jugadores de "Humano" jugar cooperativamente en los arcos del juego usando Supabase Realtime para sincronización en tiempo real. El sistema soporta hasta 4 jugadores por sala, con sincronización de posiciones, estados, evidencias y enemigos.

**Objetivos de diseño:**
- Implementar sistema de salas con códigos de 6 caracteres
- Sincronizar estado del juego en tiempo real usando Supabase Realtime
- Soportar hasta 4 jugadores simultáneos
- Mantener 60 FPS con múltiples jugadores
- Manejar desconexiones y reconexiones gracefully
- Integrar con arquitectura existente de arcos

**Tecnologías:**
- Flutter 3.x
- Supabase Realtime (WebSocket)
- Supabase Database (PostgreSQL)
- Existing Flame game architecture

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Multiplayer Screens                       │
│  ├─ MultiplayerMenuScreen (create/join)                    │
│  ├─ LobbyScreen (waiting room)                             │
│  └─ MultiplayerGameScreen (gameplay)                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              MultiplayerProvider (State)                    │
│  ├─ Room management                                         │
│  ├─ Player list                                             │
│  └─ Connection status                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              MultiplayerService (Logic)                     │
│  ├─ Room creation/joining                                   │
│  ├─ Realtime channel management                             │
│  └─ State synchronization                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Supabase Realtime                              │
│  ├─ WebSocket connection                                    │
│  ├─ Channel broadcasting                                    │
│  └─ Presence tracking                                       │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── multiplayer/
│   ├── services/
│   │   ├── multiplayer_service.dart        # Core multiplayer logic
│   │   ├── sync_manager.dart               # State synchronization
│   │   └── room_manager.dart               # Room CRUD operations
│   ├── providers/
│   │   └── multiplayer_provider.dart       # State management
│   ├── models/
│   │   ├── game_room.dart                  # Room data model
│   │   ├── player_state.dart               # Player state model
│   │   └── sync_message.dart               # Sync message types
│   └── screens/
│       ├── multiplayer_menu_screen.dart    # Create/join menu
│       ├── lobby_screen.dart               # Waiting room
│       └── multiplayer_game_screen.dart    # Gameplay wrapper
├── game/
│   └── arcs/
│       └── [existing arcs]/
│           └── components/
│               └── remote_player_component.dart  # Remote player avatar
└── data/
    └── repositories/
        └── multiplayer_repository.dart     # Supabase integration
```

## Components and Interfaces

### 1. MultiplayerService

Core service that manages multiplayer functionality.

```dart
class MultiplayerService {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  String? _currentRoomId;
  
  // Create a new game room
  Future<GameRoom> createRoom({
    required String hostId,
    required String arcId,
  }) async {
    final roomCode = _generateRoomCode();
    final room = GameRoom(
      id: uuid.v4(),
      code: roomCode,
      hostId: hostId,
      arcId: arcId,
      players: [hostId],
      maxPlayers: 4,
      status: RoomStatus.waiting,
      createdAt: DateTime.now(),
    );
    
    await _supabase.from('game_rooms').insert(room.toJson());
    await _joinChannel(room.id);
    
    return room;
  }
  
  // Join existing room
  Future<GameRoom> joinRoom(String roomCode, String playerId) async {
    final room = await _findRoomByCode(roomCode);
    
    if (room == null) {
      throw RoomNotFoundException();
    }
    
    if (room.players.length >= room.maxPlayers) {
      throw RoomFullException();
    }
    
    await _supabase.from('game_rooms')
      .update({'players': [...room.players, playerId]})
      .eq('id', room.id);
    
    await _joinChannel(room.id);
    
    return room;
  }
  
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (_) => chars[Random().nextInt(chars.length)]).join();
  }
}
```

### 2. SyncManager

Manages real-time state synchronization between players.

```dart
class SyncManager {
  final RealtimeChannel channel;
  final String playerId;
  
  // Broadcast player position
  void broadcastPosition(Vector2 position) {
    channel.send(
      type: RealtimeListenTypes.broadcast,
      event: 'player_move',
      payload: {
        'player_id': playerId,
        'x': position.x,
        'y': position.y,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Broadcast player state
  void broadcastState(PlayerState state) {
    channel.send(
      type: RealtimeListenTypes.broadcast,
      event: 'player_state',
      payload: {
        'player_id': playerId,
        'sanity': state.sanity,
        'is_hidden': state.isHidden,
        'evidence_collected': state.evidenceCollected,
      },
    );
  }
  
  // Broadcast evidence collection
  void broadcastEvidenceCollection(String evidenceId) {
    channel.send(
      type: RealtimeListenTypes.broadcast,
      event: 'evidence_collected',
      payload: {
        'player_id': playerId,
        'evidence_id': evidenceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
  
  // Listen for remote player updates
  void listenForUpdates(Function(Map<String, dynamic>) onUpdate) {
    channel.on(
      RealtimeListenTypes.broadcast,
      ChannelFilter(event: 'player_move'),
      (payload, [ref]) => onUpdate(payload),
    );
    
    channel.on(
      RealtimeListenTypes.broadcast,
      ChannelFilter(event: 'player_state'),
      (payload, [ref]) => onUpdate(payload),
    );
    
    channel.on(
      RealtimeListenTypes.broadcast,
      ChannelFilter(event: 'evidence_collected'),
      (payload, [ref]) => onUpdate(payload),
    );
  }
}
```

### 3. RemotePlayerComponent

Visual representation of remote players in the game.

```dart
class RemotePlayerComponent extends PositionComponent {
  final String playerId;
  final String username;
  
  Vector2 targetPosition;
  double sanity = 1.0;
  bool isHidden = false;
  
  RemotePlayerComponent({
    required this.playerId,
    required this.username,
    required Vector2 initialPosition,
  }) : targetPosition = initialPosition {
    position = initialPosition;
    size = Vector2(40, 60);
  }
  
  void updateFromSync(Map<String, dynamic> data) {
    if (data.containsKey('x') && data.containsKey('y')) {
      targetPosition = Vector2(data['x'], data['y']);
    }
    
    if (data.containsKey('sanity')) {
      sanity = data['sanity'];
    }
    
    if (data.containsKey('is_hidden')) {
      isHidden = data['is_hidden'];
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Interpolate position for smooth movement
    position = position.lerp(targetPosition, 0.3);
  }
  
  @override
  void render(Canvas canvas) {
    // Render semi-transparent avatar
    final paint = Paint()
      ..color = Colors.blue.withOpacity(isHidden ? 0.3 : 0.7);
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );
    
    // Render username above avatar
    final textPainter = TextPainter(
      text: TextSpan(
        text: username,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -20));
    
    // Render low sanity warning
    if (sanity < 0.3) {
      canvas.drawCircle(
        Offset(size.x / 2, -30),
        8,
        Paint()..color = Colors.red,
      );
    }
  }
}
```

## Data Models

### GameRoom

```dart
class GameRoom {
  final String id;
  final String code;
  final String hostId;
  final String arcId;
  final List<String> players;
  final Map<String, bool> readyStatus;
  final int maxPlayers;
  final RoomStatus status;
  final DateTime createdAt;
  
  GameRoom({
    required this.id,
    required this.code,
    required this.hostId,
    required this.arcId,
    required this.players,
    this.readyStatus = const {},
    this.maxPlayers = 4,
    required this.status,
    required this.createdAt,
  });
  
  bool get isFull => players.length >= maxPlayers;
  bool get allReady => players.every((p) => readyStatus[p] == true);
}

enum RoomStatus {
  waiting,   // In lobby
  playing,   // Game in progress
  finished,  // Game completed
  closed,    // Room closed
}
```

### PlayerState

```dart
class PlayerState {
  final String playerId;
  final Vector2 position;
  final double sanity;
  final bool isHidden;
  final int evidenceCollected;
  final bool isDead;
  final int timestamp;
  
  PlayerState({
    required this.playerId,
    required this.position,
    required this.sanity,
    required this.isHidden,
    required this.evidenceCollected,
    required this.isDead,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'player_id': playerId,
    'x': position.x,
    'y': position.y,
    'sanity': sanity,
    'is_hidden': isHidden,
    'evidence_collected': evidenceCollected,
    'is_dead': isDead,
    'timestamp': timestamp,
  };
  
  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
    playerId: json['player_id'],
    position: Vector2(json['x'], json['y']),
    sanity: json['sanity'],
    isHidden: json['is_hidden'],
    evidenceCollected: json['evidence_collected'],
    isDead: json['is_dead'],
    timestamp: json['timestamp'],
  );
}
```

### SyncMessage

```dart
enum SyncMessageType {
  playerMove,
  playerState,
  evidenceCollected,
  enemyUpdate,
  gameStart,
  gameEnd,
  playerDisconnect,
}

class SyncMessage {
  final SyncMessageType type;
  final String senderId;
  final Map<String, dynamic> data;
  final int timestamp;
  
  SyncMessage({
    required this.type,
    required this.senderId,
    required this.data,
    required this.timestamp,
  });
}
```

## Database Schema

### game_rooms table

```sql
CREATE TABLE game_rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(6) UNIQUE NOT NULL,
  host_id UUID REFERENCES auth.users(id) NOT NULL,
  arc_id VARCHAR(50) NOT NULL,
  players UUID[] NOT NULL DEFAULT '{}',
  ready_status JSONB DEFAULT '{}',
  max_players INTEGER DEFAULT 4,
  status VARCHAR(20) DEFAULT 'waiting',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_room_code ON game_rooms(code);
CREATE INDEX idx_room_status ON game_rooms(status);
```

### multiplayer_stats table

```sql
CREATE TABLE multiplayer_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES game_rooms(id),
  player_id UUID REFERENCES auth.users(id),
  arc_id VARCHAR(50) NOT NULL,
  evidence_collected INTEGER DEFAULT 0,
  time_survived INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT FALSE,
  coins_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Game Flow

### Lobby Flow

```
1. Host creates room
   ↓
2. Room code generated and displayed
   ↓
3. Other players join using code
   ↓
4. Players mark themselves as ready
   ↓
5. Host starts game when all ready
   ↓
6. All players transition to game screen
```

### Gameplay Synchronization

```
Every 100ms:
- Broadcast player position
- Broadcast player state (sanity, hidden)
- Host broadcasts enemy position/state

On events:
- Evidence collection → broadcast to all
- Player death → broadcast to all
- Game end → broadcast to all
```

### Disconnection Handling

```
Player disconnects:
1. Detect disconnection (5 second timeout)
2. Notify remaining players
3. Remove player avatar after 10 seconds
4. If host: migrate host to next player
5. If all players gone: close room

Player reconnects (within 30s):
1. Restore player state
2. Rejoin channel
3. Sync current game state
4. Re-add player avatar
```

## Performance Optimization

### Network Optimization

1. **Message Batching:**
   - Batch position updates every 100ms
   - Reduce message frequency for non-critical updates

2. **Delta Compression:**
   - Only send changed values
   - Use delta encoding for positions

3. **Interpolation:**
   - Client-side position interpolation
   - Smooth movement between updates

4. **Priority System:**
   - High priority: evidence collection, deaths
   - Medium priority: player positions
   - Low priority: cosmetic updates

### Game Performance

1. **Component Pooling:**
   - Reuse RemotePlayerComponent instances
   - Pool sync message objects

2. **Culling:**
   - Only render visible remote players
   - Disable updates for off-screen players

3. **Efficient Rendering:**
   - Simple avatars for remote players
   - Minimal particle effects

**Target Performance:**
- 60 FPS with 4 players
- < 100ms latency for local network
- < 300ms latency for internet play

## Integration with Existing Systems

### BaseArcGame Integration

```dart
class MultiplayerArcGame extends BaseArcGame {
  final SyncManager syncManager;
  final Map<String, RemotePlayerComponent> remotePlayers = {};
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Broadcast local player state
    if (_shouldBroadcast()) {
      syncManager.broadcastPosition(player.position);
      syncManager.broadcastState(PlayerState(
        playerId: currentUserId,
        position: player.position,
        sanity: sanitySystem.currentSanity,
        isHidden: player.isHidden,
        evidenceCollected: evidenceCollected,
        isDead: isGameOver,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    
    // Update remote players
    for (var remotePlayer in remotePlayers.values) {
      remotePlayer.update(dt);
    }
  }
  
  void onRemotePlayerUpdate(Map<String, dynamic> data) {
    final playerId = data['player_id'];
    
    if (!remotePlayers.containsKey(playerId)) {
      // Create new remote player
      remotePlayers[playerId] = RemotePlayerComponent(
        playerId: playerId,
        username: data['username'] ?? 'Player',
        initialPosition: Vector2(data['x'], data['y']),
      );
      add(remotePlayers[playerId]!);
    }
    
    // Update existing remote player
    remotePlayers[playerId]!.updateFromSync(data);
  }
}
```

## UI Screens

### MultiplayerMenuScreen

```dart
class MultiplayerMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Multijugador', style: TextStyle(fontSize: 32)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _createRoom(context),
              child: Text('Crear Sala'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showJoinDialog(context),
              child: Text('Unirse a Sala'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _createRoom(BuildContext context) async {
    final multiplayerProvider = context.read<MultiplayerProvider>();
    final room = await multiplayerProvider.createRoom(arcId: 'arc_1_gluttony');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LobbyScreen(room: room),
      ),
    );
  }
  
  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => JoinRoomDialog(),
    );
  }
}
```

### LobbyScreen

```dart
class LobbyScreen extends StatelessWidget {
  final GameRoom room;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sala: ${room.code}')),
      body: Column(
        children: [
          // Room code display
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Código de Sala', style: TextStyle(fontSize: 18)),
                Text(room.code, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Player list
          Expanded(
            child: Consumer<MultiplayerProvider>(
              builder: (context, provider, _) {
                return ListView.builder(
                  itemCount: provider.players.length,
                  itemBuilder: (context, index) {
                    final player = provider.players[index];
                    final isReady = provider.readyStatus[player.id] ?? false;
                    
                    return ListTile(
                      leading: Icon(
                        isReady ? Icons.check_circle : Icons.circle_outlined,
                        color: isReady ? Colors.green : Colors.grey,
                      ),
                      title: Text(player.username),
                      trailing: player.id == room.hostId
                        ? Chip(label: Text('Host'))
                        : null,
                    );
                  },
                );
              },
            ),
          ),
          
          // Ready button
          Padding(
            padding: EdgeInsets.all(20),
            child: Consumer<MultiplayerProvider>(
              builder: (context, provider, _) {
                final isHost = provider.isHost;
                final allReady = provider.allPlayersReady;
                
                if (isHost) {
                  return ElevatedButton(
                    onPressed: allReady ? () => _startGame(context) : null,
                    child: Text('Iniciar Juego'),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () => provider.toggleReady(),
                    child: Text(provider.isReady ? 'No Listo' : 'Listo'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _startGame(BuildContext context) {
    final provider = context.read<MultiplayerProvider>();
    provider.startGame();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MultiplayerGameScreen(room: room),
      ),
    );
  }
}
```

## Error Handling

### Common Error Scenarios

1. **Room Not Found:**
   ```dart
   try {
     await multiplayerService.joinRoom(code, playerId);
   } catch (e) {
     if (e is RoomNotFoundException) {
       showDialog(
         context: context,
         builder: (_) => AlertDialog(
           title: Text('Error'),
           content: Text('Sala no encontrada'),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: Text('OK'),
             ),
           ],
         ),
       );
     }
   }
   ```

2. **Room Full:**
   ```dart
   if (e is RoomFullException) {
     showSnackBar('La sala está llena (máximo 4 jugadores)');
   }
   ```

3. **Connection Lost:**
   ```dart
   void _handleDisconnection() {
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (_) => AlertDialog(
         title: Text('Conexión Perdida'),
         content: Text('Intentando reconectar...'),
       ),
     );
     
     _attemptReconnection();
   }
   ```

4. **Host Migration:**
   ```dart
   void _onHostDisconnect(String newHostId) {
     if (newHostId == currentUserId) {
       showSnackBar('Ahora eres el host de la sala');
     } else {
       showSnackBar('El host se desconectó. Nuevo host: $newHostName');
     }
   }
   ```

## Testing Strategy

### Unit Tests

1. **MultiplayerService:**
   - Test room creation
   - Test room joining
   - Test room code generation
   - Test player limit enforcement

2. **SyncManager:**
   - Test message broadcasting
   - Test message receiving
   - Test message parsing
   - Test timestamp handling

3. **RemotePlayerComponent:**
   - Test position interpolation
   - Test state updates
   - Test rendering

### Integration Tests

1. **Room Flow:**
   - Create room → join room → start game
   - Test with 2, 3, and 4 players
   - Test ready status synchronization

2. **Gameplay Sync:**
   - Test position synchronization
   - Test evidence collection sync
   - Test enemy synchronization
   - Test game end conditions

3. **Disconnection:**
   - Test player disconnect
   - Test host migration
   - Test reconnection

### Manual Testing Checklist

- [ ] Can create room and get code
- [ ] Can join room with code
- [ ] Room code validation works
- [ ] Player list updates in real-time
- [ ] Ready status syncs correctly
- [ ] Host can start game when all ready
- [ ] All players transition to game
- [ ] Player positions sync smoothly
- [ ] Evidence collection syncs
- [ ] Enemy position syncs (host authority)
- [ ] Sanity displays for remote players
- [ ] Game ends correctly for all players
- [ ] Disconnection is handled gracefully
- [ ] Host migration works
- [ ] Reconnection works within 30s
- [ ] Performance is 60 FPS with 4 players
- [ ] Latency indicator shows correctly

## Design Decisions and Rationale

### Why Supabase Realtime?

**Pros:**
- Already using Supabase for auth
- WebSocket-based, low latency
- Built-in presence tracking
- No additional backend needed
- Scales automatically

**Cons:**
- Vendor lock-in
- Limited to Supabase infrastructure

**Decision:** Use Supabase Realtime for consistency with existing stack and rapid development.

### Why 4 Player Limit?

**Rationale:**
- Maintains 60 FPS performance
- Keeps gameplay manageable
- Reduces network bandwidth
- Easier to coordinate strategies
- Standard for co-op games

### Why Host Authority for Enemy?

**Rationale:**
- Prevents desync issues
- Simpler implementation
- Host has authoritative game state
- Clients just render enemy position
- Reduces network messages

### Why 100ms Sync Rate?

**Rationale:**
- Balance between smoothness and bandwidth
- 10 updates per second is sufficient
- Client interpolation fills gaps
- Reduces server load
- Industry standard for real-time games

### Why 30s Reconnection Window?

**Rationale:**
- Handles brief network hiccups
- Long enough for mobile network switches
- Short enough to not block gameplay
- Prevents abandoned sessions

## Future Enhancements

### Post-MVP Improvements

1. **Voice Chat:**
   - Integrate WebRTC for voice
   - Push-to-talk functionality
   - Proximity-based voice

2. **Matchmaking:**
   - Public room listings
   - Skill-based matching
   - Quick play option

3. **Spectator Mode:**
   - Allow spectators to watch
   - Ghost mode for dead players

4. **Replay System:**
   - Record multiplayer sessions
   - Playback from any player's perspective

5. **Leaderboards:**
   - Multiplayer-specific leaderboards
   - Team completion times
   - Cooperative achievements

## Conclusion

El Sistema Multijugador añade una dimensión cooperativa al juego, permitiendo a los jugadores trabajar juntos para completar los arcos. La implementación usa Supabase Realtime para sincronización eficiente y se integra perfectamente con la arquitectura existente del juego.

**Key Strengths:**
- Integración con infraestructura existente
- Sincronización en tiempo real eficiente
- Manejo robusto de desconexiones
- Escalable hasta 4 jugadores
- Experiencia cooperativa fluida

**Implementation Priority:**
1. Database schema and Supabase setup (30 min)
2. MultiplayerService and room management (60 min)
3. SyncManager and message handling (45 min)
4. UI screens (lobby, menu) (60 min)
5. RemotePlayerComponent (30 min)
6. Integration with BaseArcGame (45 min)
7. Testing and bug fixes (60 min)

**Total estimated time: 5-6 hours**
