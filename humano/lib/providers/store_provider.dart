import 'package:flutter/foundation.dart';
import '../data/models/store_item.dart';
import '../data/models/player_inventory.dart';
import 'user_data_provider.dart';

/// Provider de tienda que usa UserDataProvider como fuente de datos
class StoreProvider extends ChangeNotifier {
  final UserDataProvider _userDataProvider;
  
  String? _error;

  StoreProvider({required UserDataProvider userDataProvider})
      : _userDataProvider = userDataProvider {
    // Escuchar cambios en UserDataProvider
    _userDataProvider.addListener(_onUserDataChanged);
  }

  void _onUserDataChanged() {
    notifyListeners();
  }

  // Getters que leen directamente de UserDataProvider
  bool get isLoading => _userDataProvider.isLoading;
  String? get error => _error ?? _userDataProvider.errorMessage;
  PlayerInventory get inventory => _userDataProvider.inventory;
  int get coins => _userDataProvider.inventory.coins;

  /// Compra un item de la tienda
  /// [finalPrice] permite especificar un precio personalizado (ej: con descuento Battle Pass)
  Future<bool> purchaseItem(StoreItem item, {int? finalPrice}) async {
    _error = null;
    
    // Usar precio personalizado o precio del item
    final price = finalPrice ?? item.price;
    
    // Verificar que el usuario esté inicializado
    if (!_userDataProvider.isInitialized) {
      _error = 'Usuario no inicializado';
      notifyListeners();
      print('❌ Error: Usuario no inicializado');
      return false;
    }
    
    // Para consumibles, permitir compras múltiples
    final isConsumable = item.type == StoreItemType.consumable;
    
    // Verificar si ya posee el item (solo para no-consumibles)
    if (!isConsumable && _userDataProvider.inventory.ownsItem(item.id)) {
      _error = 'Ya posees este item';
      notifyListeners();
      return false;
    }

    // Verificar fondos suficientes
    if (!_userDataProvider.inventory.canAfford(price)) {
      _error = 'Monedas insuficientes';
      notifyListeners();
      print('❌ Fondos insuficientes: ${_userDataProvider.inventory.coins} < $price');
      return false;
    }

    try {
      print('🛒 Iniciando compra de: ${item.name} (${item.id})');
      print('💰 Monedas actuales: ${_userDataProvider.inventory.coins}');
      print('💵 Precio: $price${finalPrice != null ? ' (con descuento Battle Pass)' : ''}');
      
      if (isConsumable) {
        // Para consumibles: restar monedas y añadir cantidad
        final currentCoins = _userDataProvider.inventory.coins;
        final currentQuantity = _userDataProvider.inventory.getConsumableQuantity(item.id);
        
        print('📦 Cantidad actual de ${item.id}: $currentQuantity');
        
        final updatedQuantities = Map<String, int>.from(_userDataProvider.inventory.consumableQuantities);
        updatedQuantities[item.id] = currentQuantity + 1;
        
        final updatedInventory = _userDataProvider.inventory.copyWith(
          coins: currentCoins - price,
          consumableQuantities: updatedQuantities,
        );
        
        print('💾 Guardando inventario actualizado...');
        print('   - Nuevas monedas: ${updatedInventory.coins}');
        print('   - Nueva cantidad: ${updatedInventory.getConsumableQuantity(item.id)}');
        
        await _userDataProvider.updateInventory(updatedInventory);
        print('✅ Consumible comprado: ${item.id} (cantidad: ${currentQuantity + 1})');
      } else if (item.type == StoreItemType.bundle) {
        // Para bundles: entregar items y monedas del contenido
        print('🎁 Procesando bundle: ${item.name}');
        
        final currentCoins = _userDataProvider.inventory.coins;
        final updatedQuantities = Map<String, int>.from(_userDataProvider.inventory.consumableQuantities);
        
        // Añadir items del bundle
        if (item.bundleItems != null) {
          print('📦 Añadiendo items del bundle:');
          item.bundleItems!.forEach((itemId, quantity) {
            final currentQuantity = updatedQuantities[itemId] ?? 0;
            updatedQuantities[itemId] = currentQuantity + quantity;
            print('   - $itemId: $currentQuantity → ${currentQuantity + quantity}');
          });
        }
        
        // Calcular monedas finales (restar precio, añadir bonus)
        final bonusCoins = item.bundleCoins ?? 0;
        final finalCoins = currentCoins - price + bonusCoins;
        
        print('💰 Monedas: $currentCoins - $price + $bonusCoins = $finalCoins');
        
        // Marcar bundle como comprado
        final ownedItems = Set<String>.from(_userDataProvider.inventory.ownedItems);
        ownedItems.add(item.id);
        
        final updatedInventory = _userDataProvider.inventory.copyWith(
          coins: finalCoins,
          consumableQuantities: updatedQuantities,
          ownedItems: ownedItems,
        );
        
        await _userDataProvider.updateInventory(updatedInventory);
        print('✅ Bundle comprado y contenido entregado');
      } else {
        // Para no-consumibles: usar transacción atómica
        print('🔒 Usando transacción atómica para item permanente');
        final success = await _userDataProvider.purchaseItem(item.id, price);
        
        if (!success) {
          _error = _userDataProvider.errorMessage ?? 'Error al procesar la compra';
          notifyListeners();
          print('❌ Transacción falló: $_error');
          return false;
        }
        
        print('✅ Transacción exitosa');
        
        // Si es battle pass, actualizar el flag
        if (item.type == StoreItemType.battlePass) {
          print('🎫 Activando Battle Pass...');
          final updatedInventory = _userDataProvider.inventory.copyWith(
            hasBattlePass: true,
          );
          await _userDataProvider.updateInventory(updatedInventory);
          print('✅ Battle Pass activado');
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al comprar: $e';
      notifyListeners();
      return false;
    }
  }

  /// Agrega monedas al balance del usuario
  Future<void> addCoins(int amount) async {
    print('🪙 [StoreProvider] Añadiendo $amount monedas...');
    try {
      await _userDataProvider.addCoins(amount);
      print('✅ [StoreProvider] Monedas añadidas, notificando listeners...');
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar monedas: $e';
      print('❌ [StoreProvider] Error al añadir monedas: $e');
      notifyListeners();
    }
  }

  /// Verifica si el usuario puede pagar un precio
  bool canAfford(int price) {
    return _userDataProvider.inventory.canAfford(price);
  }

  /// Verifica si el usuario posee un item
  bool ownsItem(String itemId) {
    return _userDataProvider.inventory.ownsItem(itemId);
  }

  /// Limpia el error actual
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // ==================== EQUIPMENT SYSTEM ====================
  
  /// Equip a player skin
  Future<bool> equipPlayerSkin(String skinId) async {
    try {
      final success = await _userDataProvider.equipPlayerSkin(skinId);
      if (success) {
        notifyListeners();
      } else {
        _error = _userDataProvider.errorMessage;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error al equipar skin: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Equip a visual theme
  Future<bool> equipTheme(String themeId) async {
    try {
      final success = await _userDataProvider.equipTheme(themeId);
      if (success) {
        notifyListeners();
      } else {
        _error = _userDataProvider.errorMessage;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error al equipar tema: $e';
      notifyListeners();
      return false;
    }
  }

  /// Equip a background music track
  Future<bool> equipMusic(String musicId) async {
    try {
      final success = await _userDataProvider.equipMusic(musicId);
      if (success) {
        notifyListeners();
      } else {
        _error = _userDataProvider.errorMessage;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error al equipar música: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Equip a sin skin for a specific arc
  Future<bool> equipSinSkin(String arcId, String skinId) async {
    try {
      final success = await _userDataProvider.equipSinSkin(arcId, skinId);
      if (success) {
        notifyListeners();
      } else {
        _error = _userDataProvider.errorMessage;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error al equipar skin de pecado: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Use a consumable item
  Future<bool> useConsumable(String itemId) async {
    try {
      final success = await _userDataProvider.useConsumable(itemId);
      if (success) {
        notifyListeners();
      } else {
        _error = _userDataProvider.errorMessage;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Error al usar item: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _userDataProvider.removeListener(_onUserDataChanged);
    super.dispose();
  }
}
