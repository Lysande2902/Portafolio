import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';
import '../models/arc_progress.dart';
import '../models/player_inventory.dart';
import '../models/game_settings.dart';
import '../models/user_stats.dart';
import '../../core/utils/retry_strategy.dart';

/// Repository para gestionar operaciones CRUD de datos de usuario en Firestore
class UserRepository {
  final FirebaseFirestore _firestore;
  final RetryStrategy _retryStrategy;
  static const String _usersCollection = 'users';

  UserRepository({
    FirebaseFirestore? firestore,
    RetryStrategy? retryStrategy,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _retryStrategy = retryStrategy ?? RetryStrategy();

  /// Obtiene el documento de usuario desde Firestore
  /// Retorna null si el documento no existe
  Future<UserData?> getUser(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return UserData.fromFirestore(docSnapshot);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al obtener usuario');
    } catch (e) {
      throw Exception('Error inesperado al obtener usuario: $e');
    }
  }

  /// Crea un nuevo documento de usuario en Firestore
  /// Lanza excepción si el usuario ya existe
  Future<void> createUser(String userId, UserData initialData) async {
    try {
      await _retryStrategy.executeWithRetry(() async {
        final docRef = _firestore.collection(_usersCollection).doc(userId);
        
        // Verificar si el usuario ya existe
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          throw Exception('El usuario ya existe');
        }

        // Crear el documento con datos iniciales
        await docRef.set(initialData.toFirestore());
      });
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al crear usuario');
    } catch (e) {
      if (e.toString().contains('ya existe')) {
        rethrow;
      }
      throw Exception('Error inesperado al crear usuario: $e');
    }
  }

  /// Actualiza el documento completo de usuario
  Future<void> updateUser(String userId, dynamic data) async {
    try {
      if (data is UserData) {
        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .set(data.toFirestore(), SetOptions(merge: true));
      } else if (data is Map<String, dynamic>) {
        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .set(data, SetOptions(merge: true));
      } else {
        throw Exception('Invalid data type for updateUser');
      }
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al actualizar usuario');
    } catch (e) {
      throw Exception('Error inesperado al actualizar usuario: $e');
    }
  }

  /// Verifica si un documento de usuario existe
  Future<bool> userExists(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      return docSnapshot.exists;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al verificar usuario');
    } catch (e) {
      throw Exception('Error inesperado al verificar usuario: $e');
    }
  }

  /// Elimina el documento de usuario (útil para testing)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al eliminar usuario');
    } catch (e) {
      throw Exception('Error inesperado al eliminar usuario: $e');
    }
  }

  /// Actualiza el progreso de un arco específico
  /// Si el arco no existe, lo inicializa
  Future<void> updateArcProgress(
    String userId,
    String arcId,
    ArcProgress progress,
  ) async {
    try {
      // Usar dot notation para actualizar solo el arco específico
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set({
        'arcProgress.$arcId': progress.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al actualizar progreso de arco');
    } catch (e) {
      throw Exception('Error inesperado al actualizar progreso de arco: $e');
    }
  }

  /// Agrega una evidencia a la lista de evidencias recolectadas de un arco
  Future<void> addEvidenceToArc(
    String userId,
    String arcId,
    String evidenceId,
  ) async {
    try {
      // Usar arrayUnion para agregar sin duplicados
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set({
        'arcProgress.$arcId.evidencesCollected': FieldValue.arrayUnion([evidenceId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al agregar evidencia');
    } catch (e) {
      throw Exception('Error inesperado al agregar evidencia: $e');
    }
  }

  /// Obtiene el progreso de un arco específico
  Future<ArcProgress?> getArcProgress(String userId, String arcId) async {
    try {
      final userData = await getUser(userId);
      if (userData == null) return null;
      
      return userData.arcProgress[arcId];
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al obtener progreso de arco');
    } catch (e) {
      throw Exception('Error inesperado al obtener progreso de arco: $e');
    }
  }

  /// Obtiene todos los arcos en progreso de un usuario
  Future<Map<String, ArcProgress>> getAllArcProgress(String userId) async {
    try {
      final userData = await getUser(userId);
      if (userData == null) return {};
      
      return userData.arcProgress;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al obtener arcos');
    } catch (e) {
      throw Exception('Error inesperado al obtener arcos: $e');
    }
  }

  /// Actualiza el inventario completo del usuario
  Future<void> updateInventory(String userId, PlayerInventory inventory) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set({
        'inventory': inventory.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al actualizar inventario');
    } catch (e) {
      throw Exception('Error inesperado al actualizar inventario: $e');
    }
  }

  /// Realiza una compra de item como transacción atómica
  /// Retorna true si la compra fue exitosa, false si no hay fondos suficientes
  Future<bool> purchaseItem(String userId, String itemId, int price) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        // Leer el documento actual
        final docRef = _firestore.collection(_usersCollection).doc(userId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Usuario no encontrado');
        }

        final userData = UserData.fromFirestore(snapshot);

        // Verificar fondos suficientes
        if (userData.inventory.coins < price) {
          return false; // Fondos insuficientes
        }

        // Verificar si ya posee el item
        if (userData.inventory.ownedItems.contains(itemId)) {
          throw Exception('El usuario ya posee este item');
        }

        // Detectar si es el Battle Pass
        final isBattlePass = itemId == 'battle_pass';

        // Calcular nuevo inventario
        final newInventory = userData.inventory.copyWith(
          coins: userData.inventory.coins - price,
          ownedItems: {...userData.inventory.ownedItems, itemId},
          hasBattlePass: isBattlePass ? true : userData.inventory.hasBattlePass,
        );

        // Actualizar en la transacción
        transaction.set(
          docRef,
          {
            'inventory': newInventory.toJson(),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        return true; // Compra exitosa
      });
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al comprar item');
    } catch (e) {
      if (e.toString().contains('ya posee')) {
        rethrow;
      }
      throw Exception('Error inesperado al comprar item: $e');
    }
  }

  /// Agrega monedas al balance del usuario
  Future<void> addCoins(String userId, int amount) async {
    try {
      final userData = await getUser(userId);
      if (userData == null) {
        throw Exception('Usuario no encontrado');
      }

      final newInventory = userData.inventory.copyWith(
        coins: userData.inventory.coins + amount,
      );

      await updateInventory(userId, newInventory);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al agregar monedas');
    } catch (e) {
      throw Exception('Error inesperado al agregar monedas: $e');
    }
  }

  /// Equipa un item (actualiza el estado de equipamiento)
  Future<void> equipItem(String userId, String itemId, bool equipped) async {
    try {
      // Nota: Esta implementación asume que el estado de equipamiento
      // se maneja en una estructura separada o en los metadatos del item
      // Por ahora, solo verificamos que el usuario posea el item
      final userData = await getUser(userId);
      if (userData == null) {
        throw Exception('Usuario no encontrado');
      }

      if (!userData.inventory.ownedItems.contains(itemId)) {
        throw Exception('El usuario no posee este item');
      }

      // Aquí se podría agregar lógica adicional para manejar el estado de equipamiento
      // Por ejemplo, guardar en un campo separado 'equippedItems'
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al equipar item');
    } catch (e) {
      throw Exception('Error inesperado al equipar item: $e');
    }
  }

  /// Actualiza las configuraciones del juego
  Future<void> updateSettings(String userId, GameSettings settings) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set({
        'settings': settings.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al actualizar configuraciones');
    } catch (e) {
      throw Exception('Error inesperado al actualizar configuraciones: $e');
    }
  }

  /// Actualiza las estadísticas del usuario
  Future<void> updateStats(String userId, UserStats stats) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set({
        'stats': stats.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al actualizar estadísticas');
    } catch (e) {
      throw Exception('Error inesperado al actualizar estadísticas: $e');
    }
  }

  /// Incrementa el tiempo de juego del usuario
  Future<void> incrementPlayTime(String userId, int minutes) async {
    try {
      final userData = await getUser(userId);
      if (userData == null) {
        throw Exception('Usuario no encontrado');
      }

      final updatedStats = userData.stats.copyWith(
        totalPlayTimeMinutes: userData.stats.totalPlayTimeMinutes + minutes,
      );

      await updateStats(userId, updatedStats);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al incrementar tiempo de juego');
    } catch (e) {
      throw Exception('Error inesperado al incrementar tiempo de juego: $e');
    }
  }

  /// Incrementa el contador de intentos
  Future<void> incrementAttempts(String userId) async {
    try {
      final userData = await getUser(userId);
      if (userData == null) {
        throw Exception('Usuario no encontrado');
      }

      final updatedStats = userData.stats.copyWith(
        totalAttempts: userData.stats.totalAttempts + 1,
      );

      await updateStats(userId, updatedStats);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al incrementar intentos');
    } catch (e) {
      throw Exception('Error inesperado al incrementar intentos: $e');
    }
  }

  /// Incrementa el contador de arcos completados
  Future<void> incrementArcsCompleted(String userId) async {
    try {
      final userData = await getUser(userId);
      if (userData == null) {
        throw Exception('Usuario no encontrado');
      }

      final updatedStats = userData.stats.copyWith(
        arcsCompleted: userData.stats.arcsCompleted + 1,
      );

      await updateStats(userId, updatedStats);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al incrementar arcos completados');
    } catch (e) {
      throw Exception('Error inesperado al incrementar arcos completados: $e');
    }
  }

  /// Observa cambios en tiempo real del documento de usuario
  /// Retorna un Stream que emite UserData cada vez que el documento cambia
  Stream<UserData?> watchUser(String userId) {
    try {
      return _firestore
          .collection(_usersCollection)
          .doc(userId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        return UserData.fromFirestore(snapshot);
      }).handleError((error) {
        if (error is FirebaseException) {
          throw _handleFirebaseException(error, 'Error en listener de usuario');
        }
        throw Exception('Error inesperado en listener: $error');
      });
    } catch (e) {
      throw Exception('Error al crear listener: $e');
    }
  }

  /// Obtiene todas las evidencias recolectadas de todos los arcos
  Future<Map<String, List<String>>> getAllEvidences(String userId) async {
    try {
      final userData = await getUser(userId);
      if (userData == null) return {};

      final allEvidences = <String, List<String>>{};
      userData.arcProgress.forEach((arcId, progress) {
        allEvidences[arcId] = progress.evidencesCollected;
      });

      return allEvidences;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al obtener evidencias');
    } catch (e) {
      throw Exception('Error inesperado al obtener evidencias: $e');
    }
  }

  /// Reinicia un arco preservando las evidencias recolectadas
  Future<void> restartArc(String userId, String arcId) async {
    try {
      final currentProgress = await getArcProgress(userId, arcId);
      if (currentProgress == null) {
        throw Exception('Arco no encontrado');
      }

      // Reiniciar pero preservar evidencias
      final restartedProgress = ArcProgress(
        arcId: arcId,
        status: ArcStatus.notStarted,
        progressPercent: 0.0,
        lastPlayed: null,
        attemptsCount: currentProgress.attemptsCount + 1,
        evidencesCollected: currentProgress.evidencesCollected, // Preservar evidencias
      );

      await updateArcProgress(userId, arcId, restartedProgress);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'Error al reiniciar arco');
    } catch (e) {
      throw Exception('Error inesperado al reiniciar arco: $e');
    }
  }

  /// Maneja excepciones de Firebase y las convierte en mensajes legibles
  Exception _handleFirebaseException(FirebaseException e, String context) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('$context: Permiso denegado');
      case 'unavailable':
        return Exception('$context: Servicio no disponible');
      case 'deadline-exceeded':
        return Exception('$context: Tiempo de espera excedido');
      case 'not-found':
        return Exception('$context: Documento no encontrado');
      case 'already-exists':
        return Exception('$context: El documento ya existe');
      case 'resource-exhausted':
        return Exception('$context: Recursos agotados');
      case 'cancelled':
        return Exception('$context: Operación cancelada');
      case 'data-loss':
        return Exception('$context: Pérdida de datos');
      case 'unauthenticated':
        return Exception('$context: Usuario no autenticado');
      default:
        return Exception('$context: ${e.message ?? "Error desconocido"}');
    }
  }

  /// Guarda las decisiones del prólogo
  Future<void> savePlayerDecisions(
    String userId,
    int indiferenceScore,
    int justificationScore,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'player_decisions': {
          'indiference_score': indiferenceScore,
          'justification_score': justificationScore,
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving player decisions: $e');
      rethrow;
    }
  }

  /// Obtiene las decisiones del prólogo
  Future<Map<String, dynamic>?> getPlayerDecisions(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      
      final data = doc.data();
      return data?['player_decisions'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting player decisions: $e');
      return null;
    }
  }

  /// Resetea el progreso para permitir ver otro final
  /// MANTIENE: inventory (monedas, items), purchases, battle_pass
  /// RESETEA: arc_progress, player_decisions, unlocked_ending, stats (para que vuelva a mostrar prólogo)
  Future<void> resetProgressForNewEnding(String userId) async {
    try {
      print('🔄 [REPOSITORY] Reseteando progreso para nuevo final...');
      
      // Resetear en Firestore
      await _firestore.collection('users').doc(userId).set({
        'arcProgress': {},  // Resetear progreso de arcos (nota: era arc_progress, ahora arcProgress)
        'indiferenceScore': 0,  // Resetear decisiones
        'justificationScore': 0,
        'unlockedEnding': null,  // Permitir desbloquear otro final
        'endingUnlockedAt': null,
        'stats': {  // Resetear stats para que vuelva a mostrar prólogo/intro
          'userId': userId,
          'totalPlayTime': 0,
          'gamesCompleted': 0,
          'totalDeaths': 0,
          'enemiesDefeated': 0,
          'itemsCollected': 0,
          'puzzlesSolved': 0,
          'secretsFound': 0,
          'achievementsUnlocked': [],
          'lastPlayed': FieldValue.serverTimestamp(),
        },
        'lastUpdated': FieldValue.serverTimestamp(),
        'reset_timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Resetear fragmentos en la subcolección
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('fragments')
          .delete();

      print('✅ [REPOSITORY] Progreso reseteado exitosamente');
    } catch (e) {
      print('❌ [REPOSITORY] Error reseteando progreso: $e');
      rethrow;
    }
  }
}
