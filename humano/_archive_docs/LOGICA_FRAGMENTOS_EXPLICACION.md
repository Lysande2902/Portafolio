# Lógica de Fragmentos: Cómo Es y Cómo Debería Ser

## Estructura del Juego

### Arcos Fusionados (3 arcos)
Cada arco fusionado combina 2 pecados capitales:

1. **Arco 1: Consumo y Codicia** (Gula + Avaricia)
   - 2 enemigos: Mateo (Cerdo) y Valeria (Rata)
   - 10 fragmentos totales
   - Checkpoint a los 5 fragmentos (cambio de enemigo)

2. **Arco 2: Envidia y Lujuria**
   - 2 enemigos: Lucía (Camaleón) y Adriana (Araña)
   - 10 fragmentos totales
   - Checkpoint a los 5 fragmentos

3. **Arco 3: Soberbia y Pereza**
   - 2 enemigos: Carlos (León) y Miguel (Babosa)
   - 10 fragmentos totales
   - Checkpoint a los 5 fragmentos

### Arco Final (1 arco)
4. **Arco 4: Ira**
   - 1 enemigo: Víctor (Toro)
   - 5 fragmentos totales
   - Sin checkpoint

**Total**: 35 fragmentos (30 + 5)

---

## Lógica Actual (CÓMO ES)

### 1. Durante el Juego (Gameplay)

```dart
// En consumo_codicia_arc_game.dart
void _checkEvidenceCollection() {
  for (final component in world.children) {
    if (component is EvidenceComponent && !component.isCollected) {
      final distance = (component.position - _player!.position).length;
      
      if (distance < 80) {  // Radio de recolección
        component.collect();
        evidenceCollected++;  // Contador local del juego
        
        debugPrint('📄 Evidence collected! Total: $evidenceCollected/10');
      }
    }
  }
}
```

**Qué hace**:
- Verifica distancia entre jugador y evidencia
- Si está a menos de 80 píxeles, la recoge
- Incrementa contador local `evidenceCollected`
- Este contador es TEMPORAL (solo durante la partida)

### 2. Al Ganar el Arco (Victory)

```dart
// En arc_game_screen.dart (cuando el jugador gana)
void _onVictory() async {
  // Guardar fragmentos en Firebase
  final fragmentsProvider = Provider.of<FragmentsProvider>(context);
  
  await fragmentsProvider.unlockFragmentsForArcProgress(
    'arc_1_consumo_codicia',  // ID del arco
    game.evidenceCollected,    // Cuántos fragmentos recolectó (0-10)
  );
}
```

**Qué hace**:
- Toma el contador local `evidenceCollected` (ej: 7 fragmentos)
- Llama a `unlockFragmentsForArcProgress()` con ese número
- Guarda en Firebase los fragmentos desbloqueados

### 3. En FragmentsProvider

```dart
Future<void> unlockFragmentsForArcProgress(String arcId, int fragmentsCollected) async {
  // Determinar máximo según el arco
  int maxFragments = 10;  // Arcos fusionados
  if (arcId == 'arc_4_ira') {
    maxFragments = 5;  // Arco final
  }
  
  // Desbloquear fragmentos progresivamente
  for (int i = 1; i <= fragmentsCollected && i <= maxFragments; i++) {
    if (!isFragmentUnlocked(arcId, i)) {
      await unlockFragment(arcId, i);  // Guarda en Firebase
    }
  }
}
```

**Qué hace**:
- Si recolectaste 7 fragmentos, desbloquea fragmentos 1, 2, 3, 4, 5, 6, 7
- Los guarda en Firebase
- Los fragmentos desbloqueados son PERMANENTES

### 4. En el Archivo de Expedientes

```dart
// En archive_screen.dart
Widget buildFragmentCard(int fragmentNumber) {
  final isUnlocked = fragmentsProvider.isFragmentUnlocked(
    'arc_1_consumo_codicia',
    fragmentNumber,
  );
  
  if (isUnlocked) {
    // Muestra el contenido del fragmento
    return Text('Contenido del fragmento $fragmentNumber');
  } else {
    // Muestra "Bloqueado"
    return Text('🔒 Fragmento bloqueado');
  }
}
```

**Qué hace**:
- Verifica qué fragmentos están desbloqueados en Firebase
- Muestra el contenido de los fragmentos desbloqueados
- Muestra "🔒" para los fragmentos bloqueados

---

## Lógica Correcta (CÓMO DEBERÍA SER)

### Escenario 1: Primera Vez Jugando el Arco

**Jugador recolecta 7 de 10 fragmentos y gana**:

1. Durante el juego: `evidenceCollected = 7`
2. Al ganar: Se guardan fragmentos 1-7 en Firebase
3. En Expedientes: Se muestran fragmentos 1-7, fragmentos 8-10 bloqueados
4. **Resultado**: ✅ Correcto

### Escenario 2: Rejugando el Arco

**Jugador ya tiene fragmentos 1-7, rejuega y recolecta 9 fragmentos**:

1. Durante el juego: `evidenceCollected = 9`
2. Al ganar: Se guardan fragmentos 1-9 en Firebase
   - Fragmentos 1-7 ya estaban desbloqueados (se saltan)
   - Fragmentos 8-9 se desbloquean (nuevos)
3. En Expedientes: Se muestran fragmentos 1-9, fragmento 10 bloqueado
4. **Resultado**: ✅ Correcto

### Escenario 3: Completando el Arco

**Jugador ya tiene fragmentos 1-9, rejuega y recolecta los 10**:

1. Durante el juego: `evidenceCollected = 10`
2. Al ganar: Se guardan fragmentos 1-10 en Firebase
   - Fragmentos 1-9 ya estaban desbloqueados (se saltan)
   - Fragmento 10 se desbloquea (nuevo)
3. En Expedientes: Se muestran los 10 fragmentos completos
4. **Resultado**: ✅ Correcto - Arco 100% completo

---

## Diferencia Entre Contador Local y Fragmentos Guardados

### Contador Local (`evidenceCollected`)
- **Dónde**: En el juego (memoria RAM)
- **Duración**: Solo durante la partida actual
- **Propósito**: Saber cuántos fragmentos llevas en esta partida
- **Ejemplo**: "Has recolectado 7/10 fragmentos"

### Fragmentos Guardados (Firebase)
- **Dónde**: En la base de datos (persistente)
- **Duración**: Permanente (entre partidas)
- **Propósito**: Recordar qué fragmentos has desbloqueado en total
- **Ejemplo**: "Tienes desbloqueados los fragmentos 1, 2, 3, 4, 5, 6, 7"

---

## Flujo Completo de un Fragmento

```
1. GAMEPLAY
   ┌─────────────────────────────────────┐
   │ Jugador se acerca a evidencia      │
   │ Distance < 80px                     │
   │ evidenceCollected++                 │
   │ "📄 Evidence collected! Total: 7/10"│
   └─────────────────────────────────────┘
                    ↓
2. VICTORIA
   ┌─────────────────────────────────────┐
   │ Jugador llega a la puerta de salida│
   │ onVictory() se ejecuta              │
   │ unlockFragmentsForArcProgress(7)    │
   └─────────────────────────────────────┘
                    ↓
3. GUARDADO
   ┌─────────────────────────────────────┐
   │ FragmentsProvider                   │
   │ for (i = 1; i <= 7; i++)           │
   │   unlockFragment('arc_1', i)        │
   │   → Guarda en Firebase              │
   └─────────────────────────────────────┘
                    ↓
4. EXPEDIENTES
   ┌─────────────────────────────────────┐
   │ ArchiveScreen                       │
   │ isFragmentUnlocked('arc_1', 1) ✅   │
   │ isFragmentUnlocked('arc_1', 2) ✅   │
   │ ...                                 │
   │ isFragmentUnlocked('arc_1', 7) ✅   │
   │ isFragmentUnlocked('arc_1', 8) ❌   │
   │ isFragmentUnlocked('arc_1', 9) ❌   │
   │ isFragmentUnlocked('arc_1', 10) ❌  │
   └─────────────────────────────────────┘
```

---

## IDs de Arcos

### IDs Correctos (Arcos Fusionados)
```dart
'arc_1_consumo_codicia'  // Arco 1: Consumo y Codicia (10 fragmentos)
'arc_2_envidia_lujuria'  // Arco 2: Envidia y Lujuria (10 fragmentos)
'arc_3_soberbia_pereza'  // Arco 3: Soberbia y Pereza (10 fragmentos)
'arc_4_ira'              // Arco 4: Ira (5 fragmentos)
```

### IDs Antiguos (Compatibilidad)
```dart
'arc_1_gula'      // Arco individual (5 fragmentos) - OBSOLETO
'arc_2_greed'     // Arco individual (5 fragmentos) - OBSOLETO
'arc_3_envy'      // Arco individual (5 fragmentos) - OBSOLETO
// etc.
```

---

## Verificación de la Lógica

### ✅ Correcto
```dart
// Arco fusionado con 10 fragmentos
unlockFragmentsForArcProgress('arc_1_consumo_codicia', 7);
// Resultado: Desbloquea fragmentos 1-7

// Arco final con 5 fragmentos
unlockFragmentsForArcProgress('arc_4_ira', 5);
// Resultado: Desbloquea fragmentos 1-5
```

### ❌ Incorrecto (Antes del Fix)
```dart
// Arco fusionado pero límite de 5
unlockFragmentsForArcProgress('arc_1_consumo_codicia', 7);
// Resultado: Solo desbloqueaba fragmentos 1-5 (MALO)
// Fragmentos 6-10 se perdían
```

---

## Resumen

### Cómo Es Ahora (Después del Fix)
1. ✅ Arcos fusionados soportan 10 fragmentos
2. ✅ Arco final soporta 5 fragmentos
3. ✅ Contador muestra "X/10" o "X/5" correctamente
4. ✅ Fragmentos se guardan progresivamente en Firebase
5. ✅ Expedientes muestran fragmentos desbloqueados

### Cómo Era Antes (Problema)
1. ❌ Todos los arcos limitados a 5 fragmentos
2. ❌ Contador mostraba "X/5" en arcos fusionados
3. ❌ Fragmentos 6-10 no se guardaban
4. ❌ Imposible completar arcos fusionados al 100%

---

**Autor**: Kiro AI  
**Fecha**: 28 de enero de 2025  
