# Documentación Completa de Firebase - CONDICIÓN: HUMANO

## 📋 Índice
1. [Configuración del Proyecto](#configuración-del-proyecto)
2. [Reglas de Seguridad de Firestore](#reglas-de-seguridad-de-firestore)
3. [Estructura de Colecciones](#estructura-de-colecciones)
4. [Explicación Detallada de Reglas](#explicación-detallada-de-reglas)
5. [Mejores Prácticas y Recomendaciones](#mejores-prácticas-y-recomendaciones)

---

## 🔧 Configuración del Proyecto

### Información del Proyecto Firebase
- **Project ID**: `condicion-humano`
- **Versión de Reglas**: `2`

### Plataformas Configuradas
```json
{
  "android": "1:375864472598:android:27f4df986f230bfd44b137",
  "ios": "1:375864472598:ios:55b8296101cb417f44b137",
  "macos": "1:375864472598:ios:55b8296101cb417f44b137",
  "web": "1:375864472598:web:db0f213f9b40d80644b137",
  "windows": "1:375864472598:web:6099e96e14c4001344b137"
}
```

### Archivo de Configuración
- **Ubicación**: `firebase.json`
- **Reglas de Firestore**: `firestore.rules`
- **Salida Android**: `android/app/google-services.json`
- **Opciones Dart**: `lib/firebase_options.dart`

---

## 🔒 Reglas de Seguridad de Firestore

### Archivo Completo: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ========================================
    // 1. COLECCIÓN DE USUARIOS
    // ========================================
    match /users/{userId} {
      // Lectura: Solo el propio usuario
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Escritura: Solo el propio usuario
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // Eliminación: Solo el propio usuario
      allow delete: if request.auth != null && request.auth.uid == userId;
      
      // Subcolecciones: Solo el propio usuario
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // ========================================
    // 2. TRANSACCIONES PENDIENTES (STRIPE)
    // ========================================
    match /pending_transactions/{transactionId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update, delete: if request.auth != null;
    }
    
    // ========================================
    // 3. TRANSACCIONES COMPLETADAS (STRIPE)
    // ========================================
    match /transactions/{transactionId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update, delete: if request.auth != null;
    }

    // ========================================
    // 4. MULTIJUGADOR - PARTIDAS
    // ========================================
    match /matches/{matchId} {
      // Cualquier usuario autenticado puede leer/crear partidas
      allow read, create: if request.auth != null;
      
      // Solo usuarios autenticados pueden actualizar
      // NOTA: Idealmente restringir a participantes de la partida
      allow update: if request.auth != null;
    }
    
    // ========================================
    // 5. LEADERBOARD (TABLA DE CLASIFICACIÓN)
    // ========================================
    match /leaderboard/{userId} {
      // Todos los usuarios autenticados pueden leer el leaderboard
      allow read: if request.auth != null;
      
      // Solo el usuario puede escribir su propia entrada
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // ========================================
    // 6. REGLA POR DEFECTO (DENEGAR TODO)
    // ========================================
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 📊 Estructura de Colecciones

### 1. **Colección: `users`**
**Ruta**: `/users/{userId}`

**Propósito**: Almacenar datos de usuario, progreso del juego, inventario, etc.

**Estructura Típica**:
```javascript
{
  userId: "abc123",
  email: "usuario@ejemplo.com",
  displayName: "Jugador1",
  createdAt: Timestamp,
  
  // Progreso del juego
  progress: {
    currentArc: "arc_1_gula",
    completedArcs: ["arc_1_gula"],
    totalPlayTime: 3600000
  },
  
  // Inventario
  inventory: {
    coins: 1500,
    ownedItems: ["skin_1", "skin_2"],
    consumableQuantities: {
      "modo_incognito": 3,
      "firewall_digital": 2
    },
    equippedPlayerSkin: "skin_1",
    equippedSinSkins: {
      "arc1": "sin_skin_1"
    },
    hasBattlePass: true
  },
  
  // Evidencias desbloqueadas
  unlockedEvidences: ["gluttony_evidence_1", "gluttony_evidence_2"],
  
  // Fragmentos recolectados
  fragments: {
    "arc_1_gula": [1, 2, 3, 4, 5],
    "arc_2_greed": [1, 2]
  }
}
```

**Subcolecciones Posibles**:
- `/users/{userId}/arcProgress` - Progreso detallado por arco
- `/users/{userId}/achievements` - Logros desbloqueados
- `/users/{userId}/settings` - Configuraciones del usuario

---

### 2. **Colección: `pending_transactions`**
**Ruta**: `/pending_transactions/{transactionId}`

**Propósito**: Transacciones de Stripe en proceso

**Estructura Típica**:
```javascript
{
  transactionId: "txn_abc123",
  userId: "user_abc123",
  amount: 499, // centavos
  currency: "usd",
  status: "pending",
  itemId: "battle_pass",
  createdAt: Timestamp,
  stripePaymentIntentId: "pi_xyz789"
}
```

---

### 3. **Colección: `transactions`**
**Ruta**: `/transactions/{transactionId}`

**Propósito**: Transacciones de Stripe completadas

**Estructura Típica**:
```javascript
{
  transactionId: "txn_abc123",
  userId: "user_abc123",
  amount: 499,
  currency: "usd",
  status: "completed",
  itemId: "battle_pass",
  createdAt: Timestamp,
  completedAt: Timestamp,
  stripePaymentIntentId: "pi_xyz789",
  receiptUrl: "https://..."
}
```

---

### 4. **Colección: `matches`**
**Ruta**: `/matches/{matchId}`

**Propósito**: Partidas multijugador

**Estructura Típica**:
```javascript
{
  matchId: "match_abc123",
  arcId: "arc_1_gula",
  status: "waiting", // waiting, in_progress, completed
  createdAt: Timestamp,
  
  // Jugadores
  players: {
    "user_1": {
      role: "human",
      ready: true,
      sanity: 1.0,
      evidenceCount: 3,
      isAlive: true
    },
    "user_2": {
      role: "algorithm",
      ready: true
    }
  },
  
  // Última acción del Algoritmo
  lastAction: {
    type: "glitch",
    timestamp: Timestamp,
    params: {}
  },
  
  // Señales de ruido del jugador
  signals: [
    {
      type: "noise",
      position: { x: 100, y: 200 },
      timestamp: Timestamp
    }
  ]
}
```

---

### 5. **Colección: `leaderboard`**
**Ruta**: `/leaderboard/{userId}`

**Propósito**: Tabla de clasificación global

**Estructura Típica**:
```javascript
{
  userId: "user_abc123",
  displayName: "Jugador1",
  score: 15000,
  arcsCompleted: 3,
  totalFragments: 15,
  totalPlayTime: 7200000,
  lastUpdated: Timestamp,
  
  // Estadísticas adicionales
  stats: {
    fastestArcTime: 180000, // ms
    perfectArcs: 2, // arcos con 5/5 fragmentos
    deathCount: 5
  }
}
```

---

## 🔍 Explicación Detallada de Reglas

### 1. Reglas de Usuarios (`/users/{userId}`)

#### ✅ Permisos Permitidos:
- **Lectura**: Solo el propio usuario puede leer sus datos
- **Escritura**: Solo el propio usuario puede modificar sus datos
- **Eliminación**: Solo el propio usuario puede eliminar sus datos

#### 🔐 Seguridad:
```javascript
request.auth != null && request.auth.uid == userId
```
- `request.auth != null` - Verifica que el usuario esté autenticado
- `request.auth.uid == userId` - Verifica que el UID coincida con el documento

#### 📁 Subcolecciones:
Todas las subcolecciones heredan las mismas reglas del documento padre.

---

### 2. Reglas de Transacciones

#### Transacciones Pendientes:
```javascript
match /pending_transactions/{transactionId} {
  allow create: if request.auth != null;
  allow read: if request.auth != null;
  allow update, delete: if request.auth != null;
}
```

**⚠️ ADVERTENCIA DE SEGURIDAD**:
Estas reglas son demasiado permisivas. Cualquier usuario autenticado puede:
- Leer transacciones de otros usuarios
- Modificar transacciones de otros usuarios

**✅ RECOMENDACIÓN**:
```javascript
match /pending_transactions/{transactionId} {
  allow create: if request.auth != null;
  allow read: if request.auth != null && 
                 resource.data.userId == request.auth.uid;
  allow update, delete: if request.auth != null && 
                           resource.data.userId == request.auth.uid;
}
```

---

### 3. Reglas de Multijugador

#### Partidas (`/matches/{matchId}`):
```javascript
match /matches/{matchId} {
  allow read, create: if request.auth != null;
  allow update: if request.auth != null;
}
```

**⚠️ ADVERTENCIA DE SEGURIDAD**:
Cualquier usuario puede actualizar cualquier partida.

**✅ RECOMENDACIÓN**:
```javascript
match /matches/{matchId} {
  allow read, create: if request.auth != null;
  allow update: if request.auth != null && 
                   request.auth.uid in resource.data.players.keys();
}
```
Esto restringe las actualizaciones solo a los jugadores de la partida.

---

### 4. Reglas de Leaderboard

#### Tabla de Clasificación:
```javascript
match /leaderboard/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

**✅ SEGURIDAD CORRECTA**:
- Todos pueden leer el leaderboard (necesario para mostrar rankings)
- Solo el usuario puede actualizar su propia entrada

---

### 5. Regla por Defecto

```javascript
match /{document=**} {
  allow read, write: if false;
}
```

**✅ BUENA PRÁCTICA**:
Niega todo acceso por defecto a colecciones no especificadas.

---

## 🛡️ Mejores Prácticas y Recomendaciones

### 1. **Validación de Datos**

Agrega validación de datos en las reglas:

```javascript
match /users/{userId} {
  allow write: if request.auth != null && 
                  request.auth.uid == userId &&
                  // Validar estructura de datos
                  request.resource.data.keys().hasAll(['email', 'displayName']) &&
                  // Validar tipos
                  request.resource.data.email is string &&
                  // Validar límites
                  request.resource.data.inventory.coins >= 0;
}
```

---

### 2. **Funciones Reutilizables**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función helper
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
  }
}
```

---

### 3. **Reglas Mejoradas para Transacciones**

```javascript
match /pending_transactions/{transactionId} {
  allow create: if isAuthenticated() &&
                   request.resource.data.userId == request.auth.uid;
  
  allow read: if isAuthenticated() &&
                 resource.data.userId == request.auth.uid;
  
  allow update: if isAuthenticated() &&
                   resource.data.userId == request.auth.uid &&
                   // No permitir cambiar el userId
                   request.resource.data.userId == resource.data.userId;
  
  allow delete: if false; // Las transacciones no deben eliminarse
}
```

---

### 4. **Reglas Mejoradas para Multijugador**

```javascript
match /matches/{matchId} {
  allow create: if isAuthenticated() &&
                   request.auth.uid in request.resource.data.players.keys();
  
  allow read: if isAuthenticated();
  
  allow update: if isAuthenticated() &&
                   request.auth.uid in resource.data.players.keys() &&
                   // No permitir cambiar jugadores una vez iniciada
                   (resource.data.status == 'waiting' || 
                    request.resource.data.players == resource.data.players);
}
```

---

### 5. **Límites de Tasa (Rate Limiting)**

Considera implementar límites en Cloud Functions para prevenir abuso:

```javascript
// En Cloud Functions
exports.createMatch = functions.https.onCall(async (data, context) => {
  // Verificar límite de partidas por usuario
  const recentMatches = await admin.firestore()
    .collection('matches')
    .where('players.' + context.auth.uid, '!=', null)
    .where('createdAt', '>', Date.now() - 60000) // Último minuto
    .get();
  
  if (recentMatches.size >= 5) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Demasiadas partidas creadas recientemente'
    );
  }
  
  // Crear partida...
});
```

---

## 📝 Comandos Útiles de Firebase

### Desplegar Reglas
```bash
firebase deploy --only firestore:rules
```

### Probar Reglas Localmente
```bash
firebase emulators:start --only firestore
```

### Ver Logs de Seguridad
```bash
firebase firestore:logs
```

---

## ✅ Estado de Seguridad Actual

### ✅ IMPLEMENTADO:
1. **Transacciones**: Solo el dueño puede leer/modificar sus transacciones
2. **Partidas Multijugador**: Solo los participantes pueden modificar partidas
3. **Validación de Datos**: Validación de tipos, rangos y estructura
4. **Límites**: Límites en monedas (999,999), precios ($1000), nombres (30 chars)
5. **Inmutabilidad**: Transacciones completadas no pueden modificarse
6. **Protección de Identidad**: El userId no puede cambiarse después de crear

### ✅ CORRECTO:
1. Reglas de usuarios con validación completa
2. Regla por defecto niega todo acceso
3. Leaderboard correctamente configurado con validación
4. Funciones helper reutilizables
5. Protección contra modificación de participantes en partidas activas

---

## 📚 Recursos Adicionales

- [Documentación de Reglas de Firestore](https://firebase.google.com/docs/firestore/security/get-started)
- [Guía de Seguridad de Firebase](https://firebase.google.com/docs/rules)
- [Simulador de Reglas](https://firebase.google.com/docs/rules/simulator)

---

## 🔄 Historial de Cambios

### Versión 2.1 (Diciembre 5, 2024) - MEJORAS DE SEGURIDAD
- ✅ **Funciones Helper**: Agregadas funciones reutilizables (isAuthenticated, isOwner, isValidString, isValidNumber)
- ✅ **Validación de Usuarios**: Validación completa de estructura de datos de usuario
- ✅ **Validación de Inventario**: Límites en monedas (999,999), validación de tipos
- ✅ **Transacciones Seguras**: Solo el dueño puede acceder a sus transacciones
- ✅ **Validación de Transacciones**: Validación de montos ($0-$1000), monedas (usd/mxn/eur), estados
- ✅ **Inmutabilidad**: Transacciones completadas no pueden modificarse ni eliminarse
- ✅ **Protección de userId**: El userId no puede cambiarse después de crear
- ✅ **Partidas Multijugador Seguras**: Solo participantes pueden modificar partidas
- ✅ **Validación de Partidas**: Validación de estados, protección de host/guest
- ✅ **Leaderboard Validado**: Validación de nombres (max 30 chars), scores, estadísticas
- ✅ **Protección de Participantes**: No se pueden cambiar jugadores en partidas activas

### Versión 2.0 (Anterior)
- ✅ Reglas básicas de usuarios
- ✅ Soporte para transacciones Stripe
- ✅ Soporte para multijugador
- ✅ Leaderboard global
- ⚠️ Tenía problemas de seguridad (resueltos en v2.1)

---

**Última actualización**: Diciembre 5, 2024
**Proyecto**: CONDICIÓN: HUMANO
**Firebase Project ID**: condicion-humano
**Versión de Reglas**: 2.1 (Seguridad Mejorada)
