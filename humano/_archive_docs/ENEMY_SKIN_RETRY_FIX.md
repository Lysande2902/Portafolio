# ✅ Fix: Enemigo Incorrecto al Reiniciar Arcos 2 y 3

## 🎯 Problema

Cuando reinicias el juego en los arcos 2 y 3 (después de perder), aparece el enemigo de Gula (Arco 1) en lugar del enemigo correcto de ese arco.

**Causa:** Al reiniciar el juego con el botón "Retry", se creaba una nueva instancia del juego pero no se configuraban los skins del jugador y del enemigo.

---

## 🔧 Solución Implementada

### Modificado: `lib/screens/arc_game_screen.dart`

#### Método `onRetry` en `_buildGameOverScreen()`:

**ANTES:**
```dart
onRetry: () async {
  if (mounted) {
    setState(() {
      // Create new game instance
      game = _createGameInstance();
      
      // Reconnect callbacks for the new game instance
      if (game is BaseArcGame) {
        // ... callbacks ...
      }
    });
  }
},
```

**DESPUÉS:**
```dart
onRetry: () async {
  if (mounted) {
    setState(() {
      // Create new game instance
      game = _createGameInstance();
      
      // Setup providers and inventory for the new game
      game.buildContext = context;
      final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
      game.setFragmentsProvider(fragmentsProvider);
      _loadInventory(); // CRITICAL: Load skins and items
      
      // Reconnect callbacks for the new game instance
      if (game is BaseArcGame) {
        // ... callbacks ...
      }
    });
  }
},
```

---

## 🎮 Qué Hace el Fix

### 1. **Configura el Contexto del Juego**
```dart
game.buildContext = context;
```
Establece el contexto de Flutter para que el juego pueda acceder a providers.

### 2. **Configura el FragmentsProvider**
```dart
final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
game.setFragmentsProvider(fragmentsProvider);
```
Conecta el provider de fragmentos para que el juego pueda desbloquear fragmentos.

### 3. **Carga el Inventario (CRÍTICO)**
```dart
_loadInventory(); // CRITICAL: Load skins and items
```
Este método hace lo siguiente:
- Carga el skin del jugador equipado
- **Carga el skin del enemigo equipado para el arco actual**
- Carga los items consumibles seleccionados
- Configura si el jugador tiene cuenta alternativa

---

## 📋 Cómo Funciona `_loadInventory()`

```dart
void _loadInventory() {
  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
  final inventory = storeProvider.inventory;

  // Configurar skin del jugador
  game.setPlayerSkin(inventory.equippedPlayerSkin);
  
  // Configurar skin del enemigo según el arco
  String? arcKey;
  if (widget.arcId == 'arc_1_gula') {
    arcKey = 'arc1';
  } else if (widget.arcId == 'arc_2_greed') {
    arcKey = 'arc2';
  } else if (widget.arcId == 'arc_3_envy') {
    arcKey = 'arc3';
  }
  
  if (arcKey != null) {
    final enemySkin = inventory.equippedSinSkins[arcKey];
    game.setEnemySkin(enemySkin); // ← ESTO ES LO QUE FALTABA
  }
  
  // Configurar items y consumibles
  // ...
}
```

---

## 🧪 Testing

### Para Probar el Fix:

1. **Arco 2 (Greed):**
   - Inicia el Arco 2
   - Deja que el enemigo te atrape (pierde el juego)
   - Haz clic en "Retry"
   - **Verifica:** El enemigo debe ser el Banquero (Greed), no el Chef (Gluttony)

2. **Arco 3 (Envy):**
   - Inicia el Arco 3
   - Deja que el enemigo te atrape (pierde el juego)
   - Haz clic en "Retry"
   - **Verifica:** El enemigo debe ser el Influencer (Envy), no el Chef (Gluttony)

3. **Arco 1 (Gluttony):**
   - Inicia el Arco 1
   - Deja que el enemigo te atrape
   - Haz clic en "Retry"
   - **Verifica:** El enemigo debe seguir siendo el Chef (Gluttony)

---

## 🎨 Skins de Enemigos por Arco

| Arco | Enemigo | Skin por Defecto |
|------|---------|------------------|
| Arco 1 - Gula | Chef | `default` |
| Arco 2 - Avaricia | Banquero | `default` |
| Arco 3 - Envidia | Influencer | `default` |
| Arco 4 - Lujuria | (Futuro) | `default` |
| Arco 5 - Soberbia | (Futuro) | `default` |
| Arco 6 - Pereza | (Futuro) | `default` |
| Arco 7 - Ira | (Futuro) | `default` |

---

## 📊 Flujo Completo de Reinicio

```
1. Usuario pierde el juego
2. Se muestra GameOverScreen
3. Usuario hace clic en "Retry"
4. onRetry() se ejecuta:
   a. Crea nueva instancia del juego (_createGameInstance)
   b. Configura buildContext
   c. Configura FragmentsProvider
   d. Llama a _loadInventory():
      - Carga skin del jugador
      - Carga skin del enemigo (según arcId)
      - Carga items consumibles
   e. Reconecta callbacks (noise, evidence, state)
5. setState() reconstruye la UI
6. GameWidget se recrea con la nueva instancia
7. El juego se reinicia con los skins correctos
```

---

## ✅ Estado Actual

- ✅ Enemigo correcto en Arco 1 al reiniciar
- ✅ Enemigo correcto en Arco 2 al reiniciar
- ✅ Enemigo correcto en Arco 3 al reiniciar
- ✅ Skins del jugador se mantienen al reiniciar
- ✅ Items consumibles se mantienen al reiniciar
- ✅ Fragmentos provider configurado correctamente

---

## 🔍 Notas Adicionales

### Por Qué Funcionaba en el Primer Intento

En el primer intento (cuando inicias el arco por primera vez), el método `didChangeDependencies()` se llama automáticamente y ejecuta `_loadInventory()`:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  if (_isInitialized && !_isDisposing) {
    game.buildContext = context;
    final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
    game.setFragmentsProvider(fragmentsProvider);
    _loadInventory(); // ← Se llama aquí
  }
}
```

### Por Qué No Funcionaba al Reiniciar

Al reiniciar con "Retry", `didChangeDependencies()` no se vuelve a llamar porque el widget ya está montado. Por eso necesitábamos llamar explícitamente a `_loadInventory()` en el callback `onRetry`.

---

## 🎉 Resultado

Ahora cuando reinicias cualquier arco, el enemigo correcto aparecerá con el skin correcto. El problema estaba en que no se estaba configurando el inventario (incluyendo los skins) al crear la nueva instancia del juego.
