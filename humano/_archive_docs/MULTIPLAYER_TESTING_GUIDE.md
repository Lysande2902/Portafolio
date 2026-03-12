# 🎮 GUÍA DE TESTING MULTIJUGADOR

## 📋 REQUISITOS PREVIOS

### **Hardware Necesario:**
- ✅ 2 dispositivos Android/iOS
- ✅ Conexión a Internet estable
- ✅ Ambos dispositivos con la app instalada
- ✅ Ambos dispositivos con cuentas diferentes

### **Software:**
- ✅ Firebase configurado
- ✅ Firestore rules actualizadas
- ✅ Autenticación funcionando

---

## 🚀 PREPARACIÓN

### **Paso 1: Verificar Firebase**

Asegúrate de que las reglas de Firestore estén actualizadas:

```javascript
// firestore.rules
match /matches/{matchId} {
  allow read, create: if request.auth != null;
  allow update: if request.auth != null;
}
```

### **Paso 2: Compilar la App**

```bash
# Para Android
flutter build apk --release

# Para iOS
flutter build ios --release
```

### **Paso 3: Instalar en Ambos Dispositivos**

- Dispositivo A (ALGORITMO): Instalar APK/IPA
- Dispositivo B (SUJETO): Instalar APK/IPA

---

## 🎯 PLAN DE TESTING

### **TEST 1: Creación y Unión de Partida**

**Objetivo:** Verificar que el matchmaking funciona

**Dispositivo A (ALGORITMO):**
1. Abrir app
2. Login con cuenta A
3. Ir a MULTIPLAYER
4. Seleccionar "ALGORITMO"
5. Elegir arco (ej: Gula)
6. **Anotar el código de partida** (matchId)
7. Esperar en lobby

**Dispositivo B (SUJETO):**
1. Abrir app
2. Login con cuenta B
3. Ir a MULTIPLAYER
4. Seleccionar "SUJETO"
5. Ingresar código de partida
6. Presionar "UNIRSE"

**Resultado Esperado:**
- ✅ Partida se crea con matchId único
- ✅ Sujeto se une exitosamente
- ✅ Ambos dispositivos navegan a sus pantallas respectivas
- ✅ Estado cambia de 'waiting' a 'active'

**Verificación en Firebase:**
```
matches/{matchId}:
  - hostId: "uid_dispositivo_A"
  - guestId: "uid_dispositivo_B"
  - status: "active"
  - arcId: "arc_1_gula"
```

---

### **TEST 2: Sincronización de Estado**

**Objetivo:** Verificar que el estado del Sujeto se sincroniza

**Dispositivo B (SUJETO):**
1. Mover al jugador
2. Recolectar evidencia
3. Esconderse

**Dispositivo A (ALGORITMO):**
1. Observar HUD del Sujeto
2. Verificar que se actualiza:
   - Cordura
   - Evidencia recolectada
   - Estado (vivo/muerto)

**Resultado Esperado:**
- ✅ Cordura se actualiza en tiempo real
- ✅ Contador de evidencia se actualiza
- ✅ Estado se refleja correctamente

**Verificación en Firebase:**
```
matches/{matchId}/userState:
  - sanity: 0.0-1.0 (actualizado)
  - evidenceCount: 0-5 (actualizado)
  - isAlive: true/false
  - position: {x, y}
```

---

### **TEST 3: Señales de Ruido**

**Objetivo:** Verificar que el radar detecta movimiento

**Dispositivo B (SUJETO):**
1. Moverse por el mapa
2. Hacer ruido (no esconderse)

**Dispositivo A (ALGORITMO):**
1. Observar el radar
2. Verificar que aparecen señales rojas

**Resultado Esperado:**
- ✅ Radar muestra señales cuando el Sujeto se mueve
- ✅ Señales desaparecen después de 2 segundos
- ✅ No hay señales cuando el Sujeto está escondido

**Verificación en Firebase:**
```
matches/{matchId}/lastSignal:
  - type: "noise"
  - data: {x, y}
  - timestamp: (reciente)
```

---

### **TEST 4: Habilidades del Algoritmo**

**Objetivo:** Verificar que los ataques funcionan

**Dispositivo A (ALGORITMO):**
1. Usar SONDA (20 energía)
2. Esperar recarga
3. Usar GLITCH (40 energía)
4. Esperar recarga
5. Usar LAG (60 energía)

**Dispositivo B (SUJETO):**
1. Sentir vibración (SONDA)
2. Ver distorsión visual (GLITCH)
3. Experimentar congelamiento (LAG)

**Resultado Esperado:**
- ✅ SONDA: Vibración + ondas visuales
- ✅ GLITCH: Aberración cromática + scanlines
- ✅ LAG: Pantalla oscura + icono de reloj
- ✅ Energía se consume y regenera correctamente

**Verificación en Firebase:**
```
matches/{matchId}/lastAction:
  - type: "ping" | "glitch" | "lag"
  - params: {}
  - timestamp: (reciente)
```

---

### **TEST 5: Victoria del Sujeto**

**Objetivo:** Verificar condición de victoria

**Dispositivo B (SUJETO):**
1. Recolectar 5 evidencias
2. Llegar a la puerta de salida
3. Escapar

**Ambos Dispositivos:**
1. Verificar pantalla de resultados
2. Verificar que muestra "SUJETO GANÓ"

**Resultado Esperado:**
- ✅ Partida termina cuando Sujeto escapa
- ✅ Ambos ven pantalla de resultados
- ✅ Razón: "user_escaped"

**Verificación en Firebase:**
```
matches/{matchId}:
  - status: "finished"
  - winner: "user"
  - endReason: "user_escaped"
  - finishedAt: (timestamp)
```

---

### **TEST 6: Victoria del Algoritmo**

**Objetivo:** Verificar condición de derrota

**Dispositivo A (ALGORITMO):**
1. Usar habilidades para reducir cordura
2. Esperar a que el Sujeto sea atrapado

**Dispositivo B (SUJETO):**
1. Dejar que el enemigo atrape
2. O dejar que la cordura llegue a 0

**Ambos Dispositivos:**
1. Verificar pantalla de resultados
2. Verificar que muestra "ALGORITMO GANÓ"

**Resultado Esperado:**
- ✅ Partida termina cuando Sujeto muere
- ✅ Ambos ven pantalla de resultados
- ✅ Razón: "user_caught" o "sanity_depleted"

**Verificación en Firebase:**
```
matches/{matchId}:
  - status: "finished"
  - winner: "algorithm"
  - endReason: "user_caught" | "sanity_depleted"
  - finishedAt: (timestamp)
```

---

### **TEST 7: Desconexión**

**Objetivo:** Verificar manejo de desconexiones

**Escenario A: Algoritmo se desconecta**
1. Dispositivo A: Cerrar app
2. Dispositivo B: Verificar que detecta desconexión

**Escenario B: Sujeto se desconecta**
1. Dispositivo B: Cerrar app
2. Dispositivo A: Verificar que detecta desconexión

**Resultado Esperado:**
- ✅ Partida termina automáticamente
- ✅ Mensaje de "Oponente desconectado"
- ✅ Victoria para el jugador que quedó

---

## 📊 CHECKLIST DE TESTING

### **Funcionalidad Básica:**
- [ ] Crear partida como Algoritmo
- [ ] Unirse como Sujeto con código
- [ ] Ambos entran a sus pantallas respectivas
- [ ] Partida inicia correctamente

### **Sincronización:**
- [ ] Estado del Sujeto se actualiza en tiempo real
- [ ] Cordura se refleja correctamente
- [ ] Evidencia recolectada se sincroniza
- [ ] Posición se actualiza

### **Señales:**
- [ ] Radar muestra señales de ruido
- [ ] Señales desaparecen después de tiempo
- [ ] No hay señales cuando está escondido

### **Habilidades:**
- [ ] SONDA funciona (vibración + visual)
- [ ] GLITCH funciona (distorsión)
- [ ] LAG funciona (congelamiento)
- [ ] Energía se consume y regenera

### **Victoria/Derrota:**
- [ ] Sujeto puede ganar escapando
- [ ] Algoritmo puede ganar atrapando
- [ ] Pantallas de resultado se muestran
- [ ] Razones correctas

### **Edge Cases:**
- [ ] Desconexión del Algoritmo
- [ ] Desconexión del Sujeto
- [ ] Reintentar después de partida
- [ ] Múltiples partidas consecutivas

---

## 🐛 BUGS COMUNES Y SOLUCIONES

### **Bug: "No se puede unir a la partida"**
**Causa:** Partida ya iniciada o código incorrecto
**Solución:** Verificar que el código sea correcto y la partida esté en estado 'waiting'

### **Bug: "Estado no se sincroniza"**
**Causa:** Problemas de red o reglas de Firestore
**Solución:** Verificar conexión a Internet y reglas de Firebase

### **Bug: "Habilidades no se ven"**
**Causa:** Timestamp muy antiguo
**Solución:** Verificar que el timestamp sea reciente (< 2 segundos)

### **Bug: "Partida no termina"**
**Causa:** Condiciones de victoria no se detectan
**Solución:** Verificar lógica en `_checkVictoryCondition()` y `_checkGameOverConditions()`

---

## 📝 NOTAS DE TESTING

### **Latencia:**
- Latencia esperada: < 500ms
- Si > 1s: Verificar conexión a Internet
- Firebase tiene latencia inherente

### **Firestore Limits:**
- Lecturas: 50,000/día (gratis)
- Escrituras: 20,000/día (gratis)
- Suficiente para testing

### **Recomendaciones:**
1. Usar WiFi estable en ambos dispositivos
2. Cerrar otras apps para mejor rendimiento
3. Limpiar caché de Firebase entre tests
4. Documentar cualquier bug encontrado

---

## ✅ CRITERIOS DE ÉXITO

El multijugador está listo si:
- ✅ 10/10 tests pasan exitosamente
- ✅ Latencia < 1 segundo
- ✅ Sin crashes durante 5 partidas
- ✅ Sincronización funciona 100%
- ✅ Habilidades funcionan correctamente

---

## 🎯 PRÓXIMOS PASOS DESPUÉS DE TESTING

Si todo funciona:
1. ✅ Documentar resultados
2. ✅ Ajustar balance si es necesario
3. ✅ Optimizar sincronización
4. ✅ Agregar más feedback visual
5. ✅ Implementar chat (opcional)

Si hay problemas:
1. 🐛 Documentar bugs encontrados
2. 🔧 Priorizar fixes
3. 🧪 Re-testear después de fixes

---

**Fecha:** 2025-12-05
**Versión:** 1.0
**Estado:** Listo para Testing
