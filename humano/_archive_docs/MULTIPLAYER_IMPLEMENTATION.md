# 🎮 SISTEMA MULTIJUGADOR - IMPLEMENTACIÓN COMPLETA

## 📋 RESUMEN

El modo multijugador de HUMANO es un modo asimétrico 1v1 donde:
- **ALGORITMO** (Host): Persigue y ataca al jugador con habilidades especiales
- **SUJETO** (Guest): Intenta escapar recolectando evidencia y evitando ser atrapado

---

## 🏗️ ARQUITECTURA

### **Flujo de Partida:**

```
1. ALGORITMO crea partida → Genera matchId
2. SUJETO se une con matchId → Partida comienza
3. Sincronización en tiempo real vía Firestore
4. Victoria/Derrota → Partida termina
```

### **Estructura de Datos (Firestore):**

```javascript
matches/{matchId} {
  // Metadata
  hostId: string,           // UID del Algoritmo
  guestId: string,          // UID del Sujeto
  arcId: string,            // Arco seleccionado
  status: 'waiting' | 'active' | 'finished',
  
  // Timestamps
  createdAt: Timestamp,
  startedAt: Timestamp,
  finishedAt: Timestamp,
  
  // Estado del Sujeto
  userState: {
    sanity: number,         // 0.0 - 1.0
    evidenceCount: number,  // 0 - 5
    isAlive: boolean,
    position: {x: number, y: number},
    lastUpdate: Timestamp,
    caughtAt: Timestamp,
  },
  
  // Comunicación
  lastSignal: {
    type: string,           // 'noise', 'movement', etc.
    data: object,
    timestamp: Timestamp,
  },
  
  lastAction: {
    type: string,           // 'ping', 'glitch', 'lag'
    params: object,
    timestamp: Timestamp,
  },
  
  // Resultado
  winner: 'algorithm' | 'user',
  endReason: string,
}
```

---

## ⚔️ MECÁNICAS DE JUEGO

### **ALGORITMO (Host):**

**Objetivo:** Atrapar al Sujeto antes de que escape

**Habilidades:**
1. **SONDA** (20 energía)
   - Envía vibración al dispositivo del Sujeto
   - Revela posición aproximada
   - Cooldown: Ninguno

2. **GLITCH** (40 energía)
   - Distorsiona la pantalla del Sujeto
   - Efecto de aberración cromática
   - Duración: 1.5s

3. **LAG** (60 energía)
   - Congela temporalmente el input del Sujeto
   - Pantalla oscurecida
   - Duración: 1.5s

**Energía:**
- Máximo: 100
- Regeneración: +2 cada 0.5s
- Se consume al usar habilidades

**Interfaz:**
- Radar con señales de ruido
- Barra de energía
- Estado del Sujeto (cordura, evidencia)
- Panel de habilidades

---

### **SUJETO (Guest):**

**Objetivo:** Recolectar 5 evidencias y escapar

**Mecánicas:**
- Movimiento normal del arco
- Recolección de evidencia
- Sistema de sigilo
- Esconderse en spots

**Efectos de Ataques:**
- **SONDA**: Vibración + indicador visual
- **GLITCH**: Distorsión de pantalla + scanlines
- **LAG**: Congelamiento temporal + icono de reloj

**Señales Enviadas:**
- Movimiento rápido
- Recolectar evidencia
- Ser detectado por enemigo
- Usar items

---

## 🔄 SINCRONIZACIÓN EN TIEMPO REAL

### **Del SUJETO al ALGORITMO:**

```dart
// Actualizar estado cada frame importante
multiplayerService.updateUserState(matchId, {
  'sanity': currentSanity,
  'evidenceCount': evidenceCollected,
  'isAlive': !isGameOver,
});

// Enviar señal de ruido
multiplayerService.sendSignal(matchId, 'noise', {
  'x': playerX,
  'y': playerY,
  'intensity': noiseLevel,
});
```

### **Del ALGORITMO al SUJETO:**

```dart
// Ejecutar habilidad
multiplayerService.performAction(matchId, 'glitch', {});

// Escuchar en el lado del Sujeto
StreamBuilder<DocumentSnapshot>(
  stream: multiplayerService.matchStream(matchId),
  builder: (context, snapshot) {
    final lastAction = snapshot.data?['lastAction'];
    if (lastAction != null) {
      _applyAlgorithmAttack(lastAction['type']);
    }
  },
);
```

---

## 🎯 CONDICIONES DE VICTORIA

### **ALGORITMO GANA:**
1. Sujeto es atrapado por el enemigo
2. Cordura del Sujeto llega a 0
3. Sujeto se desconecta

### **SUJETO GANA:**
1. Recolecta 5 evidencias y escapa
2. Algoritmo se desconecta

---

## 📁 ARCHIVOS IMPLEMENTADOS

### **Servicios:**
- ✅ `lib/services/multiplayer_service.dart` - Servicio de Firestore

### **Pantallas:**
- ✅ `lib/screens/multiplayer_lobby_screen.dart` - Lobby de espera
- ✅ `lib/screens/algorithm_game_screen.dart` - Vista del Algoritmo

### **Widgets:**
- ✅ `lib/widgets/algorithm_attack_effects.dart` - Efectos visuales de ataques

### **Pendientes:**
- ⏳ Integración con `ArcGameScreen` para modo multijugador
- ⏳ Pantalla de resultados multijugador
- ⏳ Sistema de recompensas multijugador

---

## 🔧 INTEGRACIÓN CON ArcGameScreen

### **Cambios Necesarios:**

1. **Detectar modo multijugador:**
```dart
final bool isMultiplayer;
final String? matchId;

ArcGameScreen({
  required this.arcId,
  this.isMultiplayer = false,
  this.matchId,
});
```

2. **Escuchar ataques del Algoritmo:**
```dart
StreamBuilder<DocumentSnapshot>(
  stream: _multiplayerService.matchStream(matchId!),
  builder: (context, snapshot) {
    final lastAction = snapshot.data?['lastAction'];
    // Aplicar efectos
  },
);
```

3. **Enviar señales de ruido:**
```dart
// Cuando el jugador hace ruido
if (isMultiplayer) {
  _multiplayerService.sendSignal(matchId!, 'noise', {
    'x': playerPosition.x,
    'y': playerPosition.y,
  });
}
```

4. **Actualizar estado:**
```dart
// Cada frame o evento importante
if (isMultiplayer) {
  _multiplayerService.updateUserState(matchId!, {
    'sanity': currentSanity,
    'evidenceCount': evidenceCollected,
    'isAlive': !isGameOver,
  });
}
```

---

## 🎨 EFECTOS VISUALES IMPLEMENTADOS

### **PING Effect:**
- Ondas concéntricas rojas
- Vibración suave (300ms)
- Duración: 1.5s

### **GLITCH Effect:**
- Aberración cromática (rojo/cyan)
- Scanlines horizontales
- Vibración intermitente (3x 50ms)
- Duración: 1.5s

### **LAG Effect:**
- Overlay oscuro
- Icono de reloj de arena
- Vibración fuerte (500ms)
- Congelamiento de input
- Duración: 1.5s

---

## 🔐 REGLAS DE FIRESTORE

```javascript
// Ya implementadas en firestore.rules
match /matches/{matchId} {
  allow read, create: if request.auth != null;
  allow update: if request.auth != null;
}
```

---

## 🚀 PRÓXIMOS PASOS

### **Fase 1: Integración Básica** ✅
- [x] MultiplayerService completo
- [x] AlgorithmGameScreen funcional
- [x] Efectos visuales de ataques
- [x] Reglas de Firestore

### **Fase 2: Integración con ArcGameScreen** ⏳
- [ ] Agregar parámetros de multijugador
- [ ] Escuchar ataques del Algoritmo
- [ ] Enviar señales de ruido
- [ ] Actualizar estado en tiempo real
- [ ] Aplicar efectos visuales

### **Fase 3: Victoria/Derrota** ⏳
- [ ] Detectar condiciones de victoria
- [ ] Pantalla de resultados
- [ ] Recompensas multijugador
- [ ] Logro "Conexión Establecida"

### **Fase 4: Balance y Pulido** ⏳
- [ ] Ajustar costos de energía
- [ ] Balancear duración de efectos
- [ ] Optimizar sincronización
- [ ] Testing con 2 dispositivos

---

## 🎮 CÓMO JUGAR

### **Como ALGORITMO:**
1. Ir a Menú → MULTIPLAYER
2. Seleccionar "ALGORITMO"
3. Elegir arco
4. Compartir código de partida
5. Esperar a que el Sujeto se una
6. Usar habilidades para atrapar al Sujeto

### **Como SUJETO:**
1. Ir a Menú → MULTIPLAYER
2. Seleccionar "SUJETO"
3. Ingresar código de partida
4. Jugar el arco normalmente
5. Evitar ataques del Algoritmo
6. Recolectar evidencia y escapar

---

## 📊 MÉTRICAS Y BALANCE

### **Energía del Algoritmo:**
- SONDA: 20 (spam-able)
- GLITCH: 40 (moderado)
- LAG: 60 (poderoso)
- Regeneración: +2/0.5s = +4/s

**Tiempo para habilidades:**
- SONDA: 5s desde 0
- GLITCH: 10s desde 0
- LAG: 15s desde 0

### **Duración de Efectos:**
- Todos: 1.5s
- Cooldown implícito por costo de energía

---

**Fecha de implementación:** 2025-12-04
**Estado:** ⏳ EN PROGRESO (Fase 1 completada)
