# Implementation Plan - Sistema Multijugador

- [ ] 1. Create database schema in Supabase
  - Create `game_rooms` table with columns: id, code, host_id, arc_id, players, ready_status, max_players, status, created_at, updated_at
  - Create `multiplayer_stats` table with columns: id, room_id, player_id, arc_id, evidence_collected, time_survived, completed, coins_earned, created_at
  - Add indexes on room_code and room_status
  - Set up Row Level Security policies for both tables
  - _Requirements: 15.2_

- [ ] 2. Create multiplayer data models
  - Create `lib/multiplayer/models/game_room.dart` with GameRoom class
  - Create `lib/multiplayer/models/player_state.dart` with PlayerState class
  - Create `lib/multiplayer/models/sync_message.dart` with SyncMessage and SyncMessageType enum
  - Add toJson() and fromJson() methods for all models
  - Define RoomStatus enum (waiting, playing, finished, closed)
  - _Requirements: 1.1, 6.1, 7.1_

- [ ] 3. Implement MultiplayerRepository for Supabase integration
  - Create `lib/data/repositories/multiplayer_repository.dart`
  - Implement createRoom() method to insert room into database
  - Implement findRoomByCode() method to query room by code
  - Implement updateRoomPlayers() method to add/remove players
  - Implement updateReadyStatus() method to update player ready state
  - Implement saveMultiplayerStats() method to save game results
  - _Requirements: 15.1, 15.2, 15.4_

- [ ] 4. Implement RoomManager service
  - Create `lib/multiplayer/services/room_manager.dart`
  - Implement generateRoomCode() to create 6-character alphanumeric codes
  - Implement createRoom() to create new GameRoom with unique code
  - Implement joinRoom() to add player to existing room
  - Implement leaveRoom() to remove player from room
  - Add validation for room capacity (max 4 players)
  - Add error handling for RoomNotFoundException and RoomFullException
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 13.1, 13.2, 13.3_

- [ ] 5. Implement MultiplayerService for Realtime integration
  - Create `lib/multiplayer/services/multiplayer_service.dart`
  - Implement _joinChannel() to connect to Supabase Realtime channel
  - Implement _leaveChannel() to disconnect from channel
  - Implement broadcastMessage() to send messages to channel
  - Implement listenForMessages() to receive messages from channel
  - Add presence tracking for connected players
  - Add disconnection detection with 5-second timeout
  - _Requirements: 15.1, 15.5, 12.1_

- [ ] 6. Implement SyncManager for state synchronization
  - Create `lib/multiplayer/services/sync_manager.dart`
  - Implement broadcastPosition() to send player position every 100ms
  - Implement broadcastState() to send player state (sanity, hidden, evidence)
  - Implement broadcastEvidenceCollection() to sync evidence pickups
  - Implement broadcastEnemyUpdate() for host to sync enemy position/state
  - Implement listenForUpdates() to receive and process sync messages
  - Add message batching to reduce network traffic
  - Add timestamp to all messages for ordering
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 7.1, 7.2, 7.3, 7.4, 9.1, 9.2_

- [ ] 7. Implement MultiplayerProvider for state management
  - Create `lib/multiplayer/providers/multiplayer_provider.dart`
  - Add properties: currentRoom, players, readyStatus, isHost, connectionStatus
  - Implement createRoom() method
  - Implement joinRoom() method
  - Implement leaveRoom() method
  - Implement toggleReady() method
  - Implement startGame() method (host only)
  - Add listeners for room updates
  - Notify UI on state changes
  - _Requirements: 1.1, 1.4, 2.4, 3.1, 3.2, 3.3, 4.1, 4.2, 5.1, 5.2_

- [ ] 8. Create MultiplayerMenuScreen
  - Create `lib/multiplayer/screens/multiplayer_menu_screen.dart`
  - Add "Crear Sala" button that calls createRoom()
  - Add "Unirse a Sala" button that shows join dialog
  - Add "Volver" button to return to main menu
  - Style with game theme
  - _Requirements: 1.1, 2.1_

- [ ] 9. Create JoinRoomDialog
  - Create join room dialog widget
  - Add text field for 6-character room code input
  - Add validation for code format
  - Add "Unirse" button that calls joinRoom()
  - Display error message if room not found or full
  - _Requirements: 2.1, 2.2, 2.3, 13.3_

- [ ] 10. Create LobbyScreen
  - Create `lib/multiplayer/screens/lobby_screen.dart`
  - Display room code prominently at top
  - Show list of connected players with usernames
  - Show ready status (checkmark) for each player
  - Show "Host" badge for room creator
  - Add "Listo" toggle button for non-host players
  - Add "Iniciar Juego" button for host (enabled when all ready)
  - Update player list in real-time when players join/leave
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1_

- [ ] 11. Implement RemotePlayerComponent
  - Create `lib/game/arcs/[base]/components/remote_player_component.dart`
  - Extend PositionComponent from Flame
  - Add properties: playerId, username, targetPosition, sanity, isHidden
  - Implement updateFromSync() to update state from sync messages
  - Implement position interpolation for smooth movement
  - Render semi-transparent avatar (blue, 70% opacity)
  - Render username text above avatar
  - Render low sanity warning icon when sanity < 30%
  - Adjust opacity when player is hidden (30%)
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.4, 7.5_

- [ ] 12. Integrate multiplayer with BaseArcGame
  - Modify BaseArcGame to support multiplayer mode
  - Add isMultiplayer flag and syncManager property
  - Add remotePlayers map to track RemotePlayerComponent instances
  - Broadcast local player position every 100ms when in multiplayer
  - Broadcast local player state changes (sanity, hidden, evidence)
  - Listen for remote player updates and create/update RemotePlayerComponent
  - Remove remote player components when players disconnect
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 11.2_

- [ ] 13. Implement shared evidence collection
  - Modify EvidenceComponent to broadcast collection in multiplayer
  - When evidence collected, send broadcastEvidenceCollection()
  - Listen for evidence collection events from other players
  - Remove evidence from all players' games when collected by anyone
  - Update shared evidence counter for all players
  - Unlock exit door for all players when all evidence collected
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 14. Implement enemy synchronization (host authority)
  - Modify enemy AI to only run on host's game
  - Host broadcasts enemy position every 100ms
  - Host broadcasts enemy state (patrol, chase, waiting)
  - Clients receive enemy updates and render enemy position
  - Clients disable local enemy AI
  - Host determines which player enemy is targeting (closest)
  - Broadcast enemy collision events to all players
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 15. Implement multiplayer game end conditions
  - Track which players have reached exit door
  - Wait for all living players to reach exit before victory
  - Mark players as dead when they die, but continue game
  - Trigger game over for all when all players are dead
  - Award coins and progress to all players who survived
  - Save multiplayer stats to database for all players
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 16. Implement disconnection handling
  - Detect player disconnection within 5 seconds
  - Notify remaining players when someone disconnects
  - Remove player avatar after 10 seconds of disconnection
  - Implement host migration when host disconnects
  - Allow reconnection within 30 seconds
  - Restore player state on reconnection
  - Close room when last player leaves
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 17. Implement latency monitoring
  - Measure round-trip latency every 2 seconds using ping/pong
  - Display connection indicator in game HUD
  - Green indicator for < 100ms latency
  - Yellow indicator for 100-300ms latency
  - Red indicator for > 300ms latency
  - Display "Conexión inestable" warning when latency > 1000ms
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 18. Create MultiplayerGameScreen wrapper
  - Create `lib/multiplayer/screens/multiplayer_game_screen.dart`
  - Wrap BaseArcGame with multiplayer context
  - Pass SyncManager to game instance
  - Handle game start synchronization
  - Handle navigation back to lobby on disconnect
  - _Requirements: 5.3, 5.4_

- [ ] 19. Add multiplayer option to main menu
  - Add "Multijugador" button to main menu
  - Navigate to MultiplayerMenuScreen on click
  - Add multiplayer icon/badge
  - _Requirements: 1.1, 2.1_

- [ ]* 20. Implement network optimization
  - Add message batching for position updates
  - Implement delta compression for position data
  - Add priority system for message types
  - Optimize RemotePlayerComponent rendering
  - Add component pooling for remote players
  - _Requirements: 6.1, 13.4_

- [ ]* 21. Test multiplayer with 2 players
  - Test room creation and joining
  - Test ready status synchronization
  - Test game start for both players
  - Test position synchronization
  - Test evidence collection sync
  - Test enemy synchronization
  - Test game end conditions
  - Verify 60 FPS performance
  - _Requirements: 1.1, 2.1, 5.1, 6.1, 8.1, 9.1, 10.1_

- [ ]* 22. Test multiplayer with 4 players
  - Test with maximum player count
  - Verify room full error when 5th player tries to join
  - Test position sync with 4 players
  - Test evidence collection with 4 players
  - Test disconnection with 4 players
  - Test host migration with 4 players
  - Verify 60 FPS performance with 4 players
  - _Requirements: 13.1, 13.2, 13.3, 13.4_

- [ ]* 23. Test disconnection and reconnection scenarios
  - Test player disconnect during lobby
  - Test player disconnect during gameplay
  - Test host disconnect and migration
  - Test reconnection within 30 seconds
  - Test reconnection after 30 seconds (should fail)
  - Test room closure when all players leave
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ]* 24. Test latency and network conditions
  - Test with good connection (< 100ms)
  - Test with medium connection (100-300ms)
  - Test with poor connection (> 300ms)
  - Test with unstable connection (packet loss)
  - Verify latency indicator displays correctly
  - Verify game remains playable at 300ms latency
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_
