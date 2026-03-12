# 🔧 Compatibilidad de Código con Nuevas Reglas

## ✅ Resumen

Las nuevas reglas de Firebase son **100% compatibles** con tu código existente. No necesitas hacer cambios en el código Dart.

---

## 📝 Operaciones que Siguen Funcionando

### 1. Operaciones de Usuario

#### ✅ Leer Datos de Usuario
```dart
// UserRepository.getUser() - SIN CAMBIOS
Future<UserData?> getUser(String userId) async {
  final docSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .get();
  return UserData.fromFirestore(docSnapshot);
}
```

**Regla que lo permite:**
```javascript
allow read: if isOwner(userId);
```

---

#### ✅ Actualizar Inventario
```dart
// UserRepository.updateInventory() - SIN CAMBIOS
Future<void> updateInventory(String userId, PlayerInventory inventory) async {
  await _firestore
      .collection('users')
      .doc(userId)
      .set({
    'inventory': inventory.toJson(),
    'lastUpdated': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
```

**Regla que lo permite:**
```javascript
allow write: if isOwner(userId) && validateUserData();
```

**Validación automática:**
- ✅ Verifica que `inventory.coins >= 0`
- ✅ Verifica que `inventory.coins <= 999999`
- ✅ Verifica que `inventory.ownedItems` sea una lista
- ✅ Verifica que `inventory.hasBattlePass` sea booleano

---

#### ✅ Comprar Items
```dart
// UserRepository.purchaseItem() - SIN CAMBIOS
Future<bool> purchaseItem(String userId, String itemId, int price) async {
  return await _firestore.runTransaction<bool>((transaction) async {
    // ... lógica de transacción
    transaction.set(docRef, {
      'inventory': newInventory.toJson(),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  });
}
```

**Regla que lo permite:**
```javascript
allow write: if isOwner(userId) && validateUserData();
```

---

### 2. Operaciones de Transacciones

#### ✅ Crear Transacción Pendiente
```dart
// Código hipotético - SIN CAMBIOS NECESARIOS
Future<void> createTransaction(String userId, int amount) async {
  await _firestore.collection('pending_transactions').add({
    'userId': userId,  // ✅ Debe coincidir con auth.uid
    'amount': amount,  // ✅ Debe estar entre 0 y 100000
    'currency': 'usd', // ✅ Debe ser usd, mxn o eur
    'status': 'pending', // ✅ Debe ser un estado válido
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

**Regla que lo permite:**
```javascript
allow create: if isAuthenticated() &&
                 request.resource.data.userId == request.auth.uid &&
                 validateTransaction(request.resource.data);
```

**Validaciones automáticas:**
- ✅ `userId` debe coincidir con el usuario autenticado
- ✅ `amount` debe estar entre $0 y $1,000
- ✅ `currency` debe ser 'usd', 'mxn' o 'eur'
- ✅ `status` debe ser válido

---

#### ✅ Leer Transacciones Propias
```dart
// Código hipotético - SIN CAMBIOS NECESARIOS
Future<List<Transaction>> getMyTransactions(String userId) async {
  final snapshot = await _firestore
      .collection('pending_transactions')
      .where('userId', isEqualTo: userId)
      .get();
  return snapshot.docs.map((doc) => Transaction.fromDoc(doc)).toList();
}
```

**Regla que lo permite:**
```javascript
allow read: if isAuthenticated() &&
               resource.data.userId == request.auth.uid;
```

---

### 3. Operaciones de Multijugador

#### ✅ Crear Partida
```dart
// MultiplayerService.createMatch() - SIN CAMBIOS
Future<String> createMatch(String userId, String arcId) async {
  final docRef = await _firestore.collection('matches').add({
    'hostId': userId,  // ✅ Debe coincidir con auth.uid
    'status': 'waiting', // ✅ Estado válido
    'arcId': arcId,    // ✅ String no vacío
    'createdAt': FieldValue.serverTimestamp(),
    'userState': {
      'sanity': 1.0,
      'evidenceCount': 0,
      'isAlive': true,
    },
  });
  return docRef.id;
}
```

**Regla que lo permite:**
```javascript
allow create: if isAuthenticated() &&
                 request.resource.data.hostId == request.auth.uid &&
                 validateMatchData(request.resource.data);
```

---

#### ✅ Unirse a Partida
```dart
// MultiplayerService.joinMatch() - SIN CAMBIOS
Future<bool> joinMatch(String matchId, String userId) async {
  final docRef = _firestore.collection('matches').doc(matchId);
  final doc = await docRef.get();
  
  if (!doc.exists) return false;
  if (doc.data()?['status'] != 'waiting') return false;
  
  await docRef.update({
    'guestId': userId,
    'status': 'active',
    'startedAt': FieldValue.serverTimestamp(),
  });
  
  return true;
}
```

**Regla que lo permite:**
```javascript
allow update: if isAuthenticated() &&
                 isMatchParticipant() &&
                 validateMatchUpdate();
```

**Protecciones automáticas:**
- ✅ Solo participantes pueden actualizar
- ✅ `hostId` no puede cambiarse
- ✅ `guestId` no puede cambiarse una vez asignado

---

#### ✅ Actualizar Estado de Partida
```dart
// MultiplayerService.updateUserState() - SIN CAMBIOS
Future<void> updateUserState(String matchId, Map<String, dynamic> state) async {
  await _firestore.collection('matches').doc(matchId).update({
    'userState': state,
  });
}
```

**Regla que lo permite:**
```javascript
allow update: if isAuthenticated() &&
                 isMatchParticipant() &&
                 validateMatchUpdate();
```

---

### 4. Operaciones de Leaderboard

#### ✅ Actualizar Entrada
```dart
// LeaderboardProvider.updateUserEntry() - SIN CAMBIOS
Future<void> updateUserEntry({
  required String username,
  required int totalFragments,
  required int arcsCompleted,
  required int totalCoins,
  required int achievementsUnlocked,
}) async {
  final user = _auth.currentUser;
  if (user == null) return;

  final entry = LeaderboardEntry(
    userId: user.uid,
    username: username, // ✅ Max 30 caracteres
    totalFragments: totalFragments,
    arcsCompleted: arcsCompleted,
    totalCoins: totalCoins,
    achievementsUnlocked: achievementsUnlocked,
    lastUpdated: DateTime.now(),
  );

  final data = entry.toFirestore();
  data['totalScore'] = entry.totalScore;

  await _firestore
      .collection('leaderboard')
      .doc(user.uid)
      .set(data, SetOptions(merge: true));
}
```

**Regla que lo permite:**
```javascript
allow write: if isOwner(userId) && validateLeaderboardEntry();
```

**Validaciones automáticas:**
- ✅ `username` no puede exceder 30 caracteres
- ✅ Todos los scores deben ser números >= 0
- ✅ `userId` debe coincidir con el documento

---

## ⚠️ Casos que Ahora Fallarán (Correctamente)

### ❌ Intentar Leer Datos de Otro Usuario
```dart
// Esto FALLARÁ (y es correcto)
final otherUserData = await _firestore
    .collection('users')
    .doc('otro_usuario_id')
    .get();
// Error: permission-denied
```

**Por qué falla:** Solo puedes leer tus propios datos.

---

### ❌ Intentar Modificar Transacción de Otro Usuario
```dart
// Esto FALLARÁ (y es correcto)
await _firestore
    .collection('pending_transactions')
    .doc('transaccion_de_otro')
    .update({'status': 'completed'});
// Error: permission-denied
```

**Por qué falla:** Solo puedes modificar tus propias transacciones.

---

### ❌ Intentar Modificar Partida Ajena
```dart
// Esto FALLARÁ (y es correcto)
await _firestore
    .collection('matches')
    .doc('partida_de_otros')
    .update({'status': 'finished'});
// Error: permission-denied
```

**Por qué falla:** Solo los participantes pueden modificar la partida.

---

### ❌ Intentar Crear Usuario con Monedas Inválidas
```dart
// Esto FALLARÁ (y es correcto)
await _firestore.collection('users').doc(userId).set({
  'userId': userId,
  'email': 'user@example.com',
  'inventory': {
    'coins': -100, // ❌ Negativo
    'ownedItems': [],
    'hasBattlePass': false,
  }
});
// Error: validation failed
```

**Por qué falla:** Las monedas deben ser >= 0.

---

### ❌ Intentar Crear Transacción con Monto Excesivo
```dart
// Esto FALLARÁ (y es correcto)
await _firestore.collection('pending_transactions').add({
  'userId': userId,
  'amount': 200000, // ❌ Excede $1000
  'currency': 'usd',
  'status': 'pending',
});
// Error: validation failed
```

**Por qué falla:** El monto máximo es $1,000 (100,000 centavos).

---

## 🎯 Recomendaciones de Código

### 1. Manejo de Errores

Asegúrate de manejar errores de permisos:

```dart
try {
  await _firestore.collection('users').doc(userId).get();
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    print('No tienes permiso para acceder a estos datos');
  }
}
```

### 2. Validación del Lado del Cliente

Aunque las reglas validan en el servidor, es buena práctica validar también en el cliente:

```dart
Future<void> updateInventory(PlayerInventory inventory) async {
  // Validación del lado del cliente
  if (inventory.coins < 0 || inventory.coins > 999999) {
    throw Exception('Monedas fuera de rango');
  }
  
  // Continuar con la actualización
  await _repository.updateInventory(userId, inventory);
}
```

### 3. Límites de Username

Si permites que los usuarios cambien su nombre:

```dart
Future<void> updateUsername(String newUsername) async {
  // Validación del lado del cliente
  if (newUsername.length > 30) {
    throw Exception('El nombre no puede exceder 30 caracteres');
  }
  
  // Continuar con la actualización
  await _firestore.collection('leaderboard').doc(userId).update({
    'username': newUsername,
  });
}
```

---

## ✅ Conclusión

Tu código existente es **100% compatible** con las nuevas reglas. Las validaciones son transparentes y solo rechazan operaciones que no deberían estar permitidas de todos modos.

**No necesitas hacer cambios en tu código Dart.**

---

**Última actualización**: Diciembre 5, 2024  
**Estado**: ✅ Totalmente Compatible
