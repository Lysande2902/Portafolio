import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_data.dart';
import '../data/models/arc_progress.dart';
import '../data/models/player_inventory.dart';
import '../data/models/game_settings.dart';
import '../data/models/user_stats.dart';

/// Provider que gestiona el estado completo del usuario autenticado
class UserDataProvider extends ChangeNotifier {
  final UserRepository _repository;

  UserData? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserData?>? _userSubscription;
  
  // Battle Pass passive timer system
  Timer? _battlePassTimer;
  int _accumulatedSeconds = 0;
  static const int _secondsPerLevel = 1800; // 30 minutes = 1800 seconds

  UserDataProvider({required UserRepository repository})
      : _repository = repository;

  // Getters
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _userData != null;

  PlayerInventory get inventory =>
      _userData?.inventory ?? PlayerInventory.empty();
  GameSettings get settings => _userData?.settings ?? GameSettings.defaults;
  UserStats get stats => _userData?.stats ?? UserStats.empty('');
  Map<String, ArcProgress> get arcProgress => _userData?.arcProgress ?? {};

  /// Inicializa el provider y establece el listener para un usuario
  Future<void> initialize(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Verificar si el usuario existe, si no, crearlo
      final exists = await _repository.userExists(userId);
      if (!exists) {
        final initialData = UserData.initial(userId);
        await _repository.createUser(userId, initialData);
      }

      // Establecer listener en tiempo real
      debugPrint('🔄 [UserDataProvider] Configurando listener para usuario: $userId');
      _userSubscription = _repository.watchUser(userId).listen(
        (userData) {
          debugPrint('📡 [UserDataProvider] Datos actualizados desde Firestore');
          debugPrint('   Monedas: ${userData?.inventory.coins ?? 0}');
          _userData = userData;
          _setLoading(false);
          notifyListeners();
          debugPrint('✅ [UserDataProvider] Listeners notificados');
        },
        onError: (error) {
          debugPrint('❌ [UserDataProvider] Error en listener: $error');
          _setError('Error al sincronizar datos: $error');
          _setLoading(false);
        },
      );
      debugPrint('✅ [UserDataProvider] Listener configurado exitosamente');
      
      // Start Battle Pass passive timer if user has active Battle Pass
      _startBattlePassTimer();
    } catch (e) {
      _setError('Error al inicializar usuario: $e');
      _setLoading(false);
    }
  }

  /// Actualiza el progreso de un arco
  Future<void> updateArcProgress(String arcId, ArcProgress progress) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      await _repository.updateArcProgress(_userData!.userId, arcId, progress);
      // El listener actualizará automáticamente el estado
    } catch (e) {
      _setError('Error al actualizar progreso de arco: $e');
    }
  }

  /// Agrega una evidencia a un arco
  Future<void> addEvidence(String arcId, String evidenceId) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      await _repository.addEvidenceToArc(
        _userData!.userId,
        arcId,
        evidenceId,
      );
      // El listener actualizará automáticamente el estado
    } catch (e) {
      _setError('Error al agregar evidencia: $e');
    }
  }

  /// Actualiza el inventario completo
  Future<void> updateInventory(PlayerInventory inventory) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      debugPrint('📦 [UserDataProvider] Actualizando inventario completo');
      debugPrint('   Monedas: ${inventory.coins}');
      debugPrint('   Items: ${inventory.ownedItems.length}');
      debugPrint('   Consumibles: ${inventory.consumableQuantities.length}');
      
      await _repository.updateInventory(_userData!.userId, inventory);
      
      debugPrint('✅ [UserDataProvider] Inventario guardado en Firebase');
      
      // Forzar actualización local inmediata
      debugPrint('🔄 Forzando actualización local del inventario...');
      _userData = _userData!.copyWith(inventory: inventory);
      notifyListeners();
      debugPrint('✅ UI actualizada inmediatamente');
      
      // El listener actualizará con los datos reales de Firebase después
    } catch (e) {
      debugPrint('❌ [UserDataProvider] Error al actualizar inventario: $e');
      _setError('Error al actualizar inventario: $e');
    }
  }

  /// Compra un item (transacción atómica)
  Future<bool> purchaseItem(String itemId, int price) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return false;
    }

    try {
      debugPrint('🛒 [UserDataProvider] Comprando item: $itemId por $price monedas');
      
      if (price == 0) {
        print('🎁 Item gratuito detectado, usando actualización simple...');
        final updatedInventory = inventory.copyWith(
          ownedItems: {...inventory.ownedItems, itemId},
        );
        await updateInventory(updatedInventory);
        return true;
      }

      bool success = false;
      try {
        success = await _repository.purchaseItem(
          _userData!.userId,
          itemId,
          price,
        );
      } catch (e) {
        // Si el servicio no está disponible (offline), intentamos una actualización simple
        // Esto permite que el cambio se encole localmente y se sincronice después.
        if (e.toString().contains('Servicio no disponible') || e.toString().contains('unavailable')) {
          debugPrint('⚠️ [UserDataProvider] Firebase Transaction no disponible (offline). Usando fallback local...');
          
          if (inventory.coins < price) {
            _setError('Fondos insuficientes');
            return false;
          }

          final updatedInventory = inventory.copyWith(
            coins: inventory.coins - price,
            ownedItems: {...inventory.ownedItems, itemId},
            hasBattlePass: itemId == 'battle_pass' ? true : inventory.hasBattlePass,
          );
          
          await updateInventory(updatedInventory);
          return true;
        } else {
          rethrow;
        }
      }

      if (!success) {
        debugPrint('❌ [UserDataProvider] Fondos insuficientes');
        _setError('Fondos insuficientes');
        return false;
      }

      debugPrint('✅ [UserDataProvider] Compra exitosa en Firebase');
      
      // Forzar actualización local inmediata
      debugPrint('🔄 Forzando actualización local del inventario...');
      
      // Detectar si es el Battle Pass
      final isBattlePass = itemId == 'battle_pass';
      
      final updatedInventory = _userData!.inventory.copyWith(
        coins: _userData!.inventory.coins - price,
        ownedItems: {..._userData!.inventory.ownedItems, itemId},
        hasBattlePass: isBattlePass ? true : _userData!.inventory.hasBattlePass,
      );
      _userData = _userData!.copyWith(inventory: updatedInventory);
      notifyListeners();
      debugPrint('✅ UI actualizada inmediatamente');
      debugPrint('   Nuevas monedas: ${_userData!.inventory.coins}');
      debugPrint('   Nuevos items: ${_userData!.inventory.ownedItems.length}');
      if (isBattlePass) {
        debugPrint('   🎖️ Battle Pass activado!');
        // Start the passive timer now that user has Battle Pass
        restartBattlePassTimer();
      }
      
      // El listener actualizará con los datos reales de Firebase después
      return true;
    } catch (e) {
      debugPrint('❌ [UserDataProvider] Error al comprar: $e');
      _setError('Error al comprar item: $e');
      return false;
    }
  }

  /// Agrega monedas al balance
  Future<void> addCoins(int amount) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      debugPrint('❌ Error al añadir monedas: Usuario no inicializado');
      debugPrint('   _userData es null');
      debugPrint('   isInitialized: $isInitialized');
      debugPrint('   _userSubscription: ${_userSubscription != null ? "activo" : "null"}');
      return;
    }

    try {
      debugPrint('💰 Añadiendo $amount monedas al usuario ${_userData!.userId}');
      debugPrint('   Balance actual: ${_userData!.inventory.coins}');
      
      await _repository.addCoins(_userData!.userId, amount);
      
      debugPrint('✅ Monedas añadidas exitosamente en Firebase');
      debugPrint('   Nuevo balance esperado: ${_userData!.inventory.coins + amount}');
      
      // Forzar actualización inmediata mientras el listener se sincroniza
      debugPrint('🔄 Forzando actualización local inmediata...');
      final updatedInventory = _userData!.inventory.copyWith(
        coins: _userData!.inventory.coins + amount,
      );
      _userData = _userData!.copyWith(inventory: updatedInventory);
      notifyListeners();
      debugPrint('✅ UI actualizada inmediatamente');
      
      // El listener actualizará con los datos reales de Firebase después
    } catch (e) {
      _setError('Error al agregar monedas: $e');
      debugPrint('❌ Error al añadir monedas: $e');
    }
  }

  /// Actualiza las configuraciones del juego
  Future<void> updateSettings(GameSettings settings) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      await _repository.updateSettings(_userData!.userId, settings);
      // El listener actualizará automáticamente el estado
    } catch (e) {
      _setError('Error al actualizar configuraciones: $e');
    }
  }

  /// Actualiza las estadísticas del usuario
  Future<void> updateStats(UserStats stats) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      await _repository.updateStats(_userData!.userId, stats);
      // El listener actualizará automáticamente el estado
    } catch (e) {
      _setError('Error al actualizar estadísticas: $e');
    }
  }

  /// Incrementa el tiempo de juego
  Future<void> incrementPlayTime(int minutes) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      await _repository.incrementPlayTime(_userData!.userId, minutes);
      // El listener actualizará automáticamente el estado
    } catch (e) {
      _setError('Error al incrementar tiempo de juego: $e');
    }
  }

  /// Incrementa el contador de intentos
  Future<void> incrementAttempts() async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      await _repository.incrementAttempts(_userData!.userId);
      // El listener actualizará automáticamente el estado
    } catch (e) {
      _setError('Error al incrementar intentos: $e');
    }
  }

  /// Incrementa el contador de arcos completados
  Future<void> incrementArcsCompleted() async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }

    try {
      await _repository.incrementArcsCompleted(_userData!.userId);
      // El listener actualizará automáticamente el estado
    } catch (e) {
      _setError('Error al incrementar arcos completados: $e');
    }
  }

  /// Limpia el error actual
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  // ==================== EQUIPMENT SYSTEM ====================
  
  /// Equip a player skin
  Future<bool> equipPlayerSkin(String skinId) async {
    print('🎨 [UserDataProvider] equipPlayerSkin llamado con: $skinId');
    
    if (_userData == null) {
      print('   ❌ userData es null');
      _setError('Usuario no inicializado');
      return false;
    }
    
    print('   Items poseídos: ${inventory.ownedItems.toList()}');
    print('   ¿Posee la skin? ${inventory.ownsItem(skinId)}');
    
    // Verify ownership
    if (!inventory.ownsItem(skinId) && skinId != 'skin_anonymous') {
      print('   ❌ No posee esta skin');
      _setError('No posees esta skin');
      return false;
    }
    
    try {
      final updatedInventory = inventory.copyWith(
        equippedPlayerSkin: skinId,
      );
      await updateInventory(updatedInventory);
      print('   ✅ Skin equipada: $skinId');
      return true;
    } catch (e) {
      print('   ❌ Error: $e');
      _setError('Error al equipar skin: $e');
      return false;
    }
  }
  
  /// Equip a visual theme
  Future<bool> equipTheme(String themeId) async {
    print('🎨 [UserDataProvider] equipTheme llamado con: $themeId');
    
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return false;
    }
    
    // Verify ownership (except for default theme)
    if (!inventory.ownsItem(themeId) && themeId != 'default') {
      _setError('No posees este tema');
      return false;
    }
    
    try {
      final updatedInventory = inventory.copyWith(
        equippedTheme: themeId,
      );
      await updateInventory(updatedInventory);
      print('   ✅ Tema equipado: $themeId');
      return true;
    } catch (e) {
      _setError('Error al equipar tema: $e');
      return false;
    }
  }
  
  /// Equip a background music track
  Future<bool> equipMusic(String musicId) async {
    print('🎵 [UserDataProvider] equipMusic llamado con: $musicId');
    
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return false;
    }
    
    // Verify ownership (except for free defaults)
    final freeMusics = ['music_reflections', 'music_excess'];
    if (!inventory.ownsItem(musicId) && !freeMusics.contains(musicId)) {
      _setError('No posees esta pista de música');
      return false;
    }
    
    try {
      final updatedInventory = inventory.copyWith(
        equippedMusic: musicId,
      );
      await updateInventory(updatedInventory);
      print('   ✅ Música equipada: $musicId');
      return true;
    } catch (e) {
      _setError('Error al equipar música: $e');
      return false;
    }
  }
  
  /// Equip a sin skin for a specific arc
  Future<bool> equipSinSkin(String arcId, String skinId) async {
    print('🎨 [UserDataProvider] equipSinSkin llamado con: arcId=$arcId, skinId=$skinId');
    
    if (_userData == null) {
      print('   ❌ userData es null');
      _setError('Usuario no inicializado');
      return false;
    }
    
    print('   Items poseídos: ${inventory.ownedItems.toList()}');
    print('   ¿Posee la skin? ${inventory.ownsItem(skinId)}');
    
    // Verify ownership
    if (!inventory.ownsItem(skinId)) {
      print('   ❌ No posee esta skin');
      _setError('No posees esta skin');
      return false;
    }
    
    try {
      final updatedSinSkins = Map<String, String?>.from(inventory.equippedSinSkins);
      updatedSinSkins[arcId] = skinId;
      
      final updatedInventory = inventory.copyWith(
        equippedSinSkins: updatedSinSkins,
      );
      await updateInventory(updatedInventory);
      print('   ✅ Skin de pecado equipada: $skinId para arco $arcId');
      return true;
    } catch (e) {
      print('   ❌ Error: $e');
      _setError('Error al equipar skin de pecado: $e');
      return false;
    }
  }
  
  /// Use a consumable item
  Future<bool> useConsumable(String itemId) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return false;
    }
    
    final currentQuantity = inventory.getConsumableQuantity(itemId);
    if (currentQuantity <= 0) {
      _setError('No tienes este item');
      return false;
    }
    
    try {
      final updatedQuantities = Map<String, int>.from(inventory.consumableQuantities);
      updatedQuantities[itemId] = currentQuantity - 1;
      
      final updatedInventory = inventory.copyWith(
        consumableQuantities: updatedQuantities,
      );
      await updateInventory(updatedInventory);
      print('✅ Item usado: $itemId (quedan: ${currentQuantity - 1})');
      return true;
    } catch (e) {
      _setError('Error al usar item: $e');
      return false;
    }
  }
  
  // ==================== ENDINGS SYSTEM ====================
  
  /// Unlock an ending for the user
  Future<void> unlockEnding(String endingId) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return;
    }
    
    try {
      print('🎬 [UserDataProvider] Desbloqueando final: $endingId');
      
      // Update in Firestore
      await _repository.updateUser(_userData!.userId, {
        'unlockedEnding': endingId,
      });
      
      // Update local state immediately
      _userData = _userData!.copyWith(unlockedEnding: endingId);
      notifyListeners();
      
      print('✅ Final desbloqueado: $endingId');
    } catch (e) {
      print('❌ Error al desbloquear final: $e');
      _setError('Error al desbloquear final: $e');
    }
  }
  
  /// Check if this is the first time the user is seeing any ending
  bool isFirstTimeSeeingEnding() {
    return _userData?.unlockedEnding == null;
  }
  
  /// Determine which ending to show based on player decisions
  String determineEnding() {
    // For now, return a default ending
    // This logic can be expanded based on player decisions/stats
    if (_userData?.unlockedEnding != null) {
      // If they've already seen an ending, show the other one
      return _userData!.unlockedEnding == 'spectator' ? 'accomplice' : 'spectator';
    }
    // Default to spectator for first ending
    return 'spectator';
  }
  
  // ==================== BATTLE PASS SYSTEM ====================
  
  /// Purchase the Battle Pass
  Future<bool> purchaseBattlePass(int price) async {
    if (_userData == null) {
      _setError('Usuario no inicializado');
      return false;
    }
    
    if (inventory.hasBattlePass) {
      _setError('Ya tienes el Battle Pass');
      return false;
    }
    
    if (!inventory.canAfford(price)) {
      _setError('Monedas insuficientes');
      return false;
    }
    
    try {
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      final updatedInventory = inventory.copyWith(
        coins: inventory.coins - price,
        hasBattlePass: true,
        battlePassExpiryDate: expiryDate,
      );
      
      await updateInventory(updatedInventory);
      print('🏆 Battle Pass comprado con éxito. Expira en: $expiryDate');
      
      // Start the passive timer now that user has Battle Pass
      restartBattlePassTimer();
      
      return true;
    } catch (e) {
      _setError('Error al comprar Battle Pass: $e');
      return false;
    }
  }
  
  /// Increments Battle Pass level (1 level per increment)
  /// New system: Only users with active Battle Pass can level up
  /// The level system is independent of arcs and minigames
  Future<void> incrementBattlePassLevel() async {
    if (_userData == null) return;
    
    // CRITICAL: Only users with active Battle Pass can level up
    if (!hasActiveBattlePass) {
      print('⚠️ No se puede subir de nivel sin Acceso Total activo');
      return;
    }
    
    // Max level 20 (as per updated system)
    if (inventory.battlePassLevel >= 20) {
      print('⚠️ Battle Pass ya está en nivel máximo (20)');
      return;
    }
    
    try {
      final updatedInventory = inventory.copyWith(
        battlePassLevel: inventory.battlePassLevel + 1,
      );
      await updateInventory(updatedInventory);
      print('📈 Battle Pass nivel subido: ${inventory.battlePassLevel + 1}');
    } catch (e) {
      print('❌ Error al subir nivel de Battle Pass: $e');
    }
  }
  
  /// Claims a reward for a specific level
  Future<bool> claimBattlePassReward(int level, int coinAmount) async {
    if (_userData == null || !inventory.hasBattlePass) return false;
    
    if (inventory.battlePassLevel < level) {
      _setError('Nivel insuficiente');
      return false;
    }
    
    if (inventory.claimedBattlePassRewards.contains(level)) {
      _setError('Recompensa ya reclamada');
      return false;
    }
    
    try {
      final updatedClaimed = List<int>.from(inventory.claimedBattlePassRewards);
      updatedClaimed.add(level);
      
      final updatedInventory = inventory.copyWith(
        coins: inventory.coins + coinAmount,
        claimedBattlePassRewards: updatedClaimed,
      );
      
      await updateInventory(updatedInventory);
      print('🎁 Recompensa de nivel $level reclamada: $coinAmount SEGS');
      return true;
    } catch (e) {
      _setError('Error al reclamar recompensa: $e');
      return false;
    }
  }
  
  /// Check if user has active battle pass benefits
  bool get hasActiveBattlePass {
    if (!inventory.hasBattlePass) return false;
    if (inventory.battlePassExpiryDate == null) return true; // Legacy
    return DateTime.now().isBefore(inventory.battlePassExpiryDate!);
  }
  
  // ==================== BATTLE PASS PASSIVE TIMER SYSTEM ====================
  
  /// Starts the passive timer that increments Battle Pass levels every 30 minutes
  void _startBattlePassTimer() {
    // Cancel existing timer if any
    _battlePassTimer?.cancel();
    
    // Only start timer if user has active Battle Pass and is not at max level
    if (!hasActiveBattlePass || inventory.battlePassLevel >= 20) {
      debugPrint('⏸️ [Battle Pass Timer] No iniciado (sin pase activo o nivel máximo)');
      return;
    }
    
    debugPrint('▶️ [Battle Pass Timer] Iniciando timer pasivo');
    debugPrint('   Nivel actual: ${inventory.battlePassLevel}');
    debugPrint('   Segundos por nivel: $_secondsPerLevel (30 minutos)');
    
    // Timer that ticks every second
    _battlePassTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Verify user still has active Battle Pass
      if (!hasActiveBattlePass) {
        debugPrint('⏸️ [Battle Pass Timer] Detenido (pase expirado)');
        timer.cancel();
        return;
      }
      
      // Verify not at max level
      if (inventory.battlePassLevel >= 20) {
        debugPrint('⏸️ [Battle Pass Timer] Detenido (nivel máximo alcanzado)');
        timer.cancel();
        return;
      }
      
      // Increment accumulated seconds
      _accumulatedSeconds++;
      
      // Check if we've reached 30 minutes (1800 seconds)
      if (_accumulatedSeconds >= _secondsPerLevel) {
        debugPrint('🎉 [Battle Pass Timer] ¡30 minutos completados! Subiendo nivel...');
        _accumulatedSeconds = 0; // Reset counter
        incrementBattlePassLevel(); // Level up!
      }
      
      // Debug log every 5 minutes
      if (_accumulatedSeconds % 300 == 0 && _accumulatedSeconds > 0) {
        final minutesElapsed = _accumulatedSeconds / 60;
        final minutesRemaining = (_secondsPerLevel - _accumulatedSeconds) / 60;
        debugPrint('⏱️ [Battle Pass Timer] Progreso: ${minutesElapsed.toStringAsFixed(0)} min / 30 min (faltan ${minutesRemaining.toStringAsFixed(0)} min)');
      }
    });
  }
  
  /// Stops the Battle Pass timer (called when user logs out or disposes)
  void _stopBattlePassTimer() {
    _battlePassTimer?.cancel();
    _battlePassTimer = null;
    _accumulatedSeconds = 0;
    debugPrint('⏹️ [Battle Pass Timer] Detenido');
  }
  
  /// Restarts the timer (useful when Battle Pass is purchased or renewed)
  void restartBattlePassTimer() {
    debugPrint('🔄 [Battle Pass Timer] Reiniciando timer');
    _stopBattlePassTimer();
    _startBattlePassTimer();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _stopBattlePassTimer();
    super.dispose();
  }
}
