# 🎯 SOLUCIÓN FINAL: Error Aparece Desde la Primera Vez

## 🚨 PROBLEMA REAL

Si el error **"A game instance can only be attached to one widget at a time"** aparece **incluso la primera vez** que entras al arco, entonces el problema NO es de reutilización.

El problema es que **algo está creando múltiples GameWidgets o múltiples instancias del juego**.

---

## 🔍 CAUSAS POSIBLES

### 1. Hot Reload Corrupto
- Flutter mantiene estado antiguo en memoria
- El juego anterior no se limpió correctamente
- **Solución**: Hot Restart completo

### 2. Múltiples Builds Durante Inicialización
- `build()` se llama múltiples veces durante la inicialización
- Cada llamada crea un nuevo GameWidget
- **Solución**: Guardar el GameWidget en una variable

### 3. Navegación Rápida
- Usuario navega muy rápido (entra/sale/entra)
- El dispose() no termina antes del nuevo initState()
- **Solución**: Agregar delays y flags

---

## ✅ SOLUCIÓN COMPLETA

### Paso 1: Limpiar Estado Corrupto

```bash
# En terminal:
flutter clean
flutter pub get
```

### Paso 2: Modificar arc_game_screen.dart

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  late dynamic game;
  Widget? _gameWidget; // Nullable para control explícito
  bool _isDisposing = false;
  bool _isInitialized = false;
  
  Map<String, int> availableItems = {};
  bool showPauseMenu = false;
  String? _activeFeedbackItem;
  bool _throwMode = false;
  String? _throwMessage;
  
  final InGameHintManager _hintManager = InGameHintManager();
  ArcHint? _currentHint;
  double _gameStartTime = 0.0;
  int _lastEvidenceCount = 0;
  bool _wasNearEnemy = false;

  @override
  void initState() {
    super.initState();
    
    print('🎮 [INIT] Creating game for ${widget.arcId}');
    
    // Crear juego
    switch (widget.arcId) {
      case 'arc_1_gula':
        game = GluttonyArcGame();
        break;
      case 'arc_2_greed':
        game = GreedArcGame();
        break;
      case 'arc_3_envy':
        game = EnvyArcGame();
        break;
      case 'arc_4_lust':
        game = LustArcGame();
        break;
      case 'arc_5_pride':
        game = PrideArcGame();
        break;
      case 'arc_6_sloth':
        game = SlothArcGame();
        break;
      case 'arc_7_wrath':
        game = WrathArcGame();
        break;
      default:
        game = GluttonyArcGame();
    }
    
    print('✅ [INIT] Game created: ${game.hashCode}');
    _isInitialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Solo crear GameWidget UNA VEZ
    if (_gameWidget == null && !_isDisposing) {
      print('🎮 [BUILD] Creating GameWidget for first time');
      _gameWidget = GameWidget(
        key: ValueKey('game_${widget.arcId}_${game.hashCode}'),
        game: game,
      );
      
      // Setup providers
      game.buildContext = context;
      final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
      game.setFragmentsProvider(fragmentsProvider);
      _loadInventory();
    }
  }

  @override
  void dispose() {
    print('🗑️ [DISPOSE] Starting disposal for ${widget.arcId}');
    _isDisposing = true;
    
    try {
      if (game != null) {
        print('⏸️ [DISPOSE] Pausing game engine');
        game.pauseEngine();
        
        // Dar tiempo para que Flame procese
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            print('🧹 [DISPOSE] Calling game.onRemove()');
            game.onRemove();
          } catch (e) {
            print('⚠️ [DISPOSE] Error in onRemove: $e');
          }
        });
      }
    } catch (e) {
      print('⚠️ [DISPOSE] Error disposing game: $e');
    }
    
    _gameWidget = null;
    _isInitialized = false;
    
    super.dispose();
    print('✅ [DISPOSE] Disposal complete');
  }

  @override
  Widget build(BuildContext context) {
    // Si estamos disposing, mostrar pantalla negra
    if (_isDisposing || _gameWidget == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _gameWidget!, // Usar el widget guardado
          
          // ... resto del UI sin cambios ...
          
          if (_throwMode)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  if (!game.isGameOver && !game.isVictory) {
                    _handleThrowTap(details.localPosition);
                  }
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),

          _buildGameHUD(),
          _buildThrowButton(),

          // ... resto del Stack ...
        ],
      ),
    );
  }
  
  // ... resto de métodos sin cambios ...
}
```

---

## 🔑 PUNTOS CLAVE

### 1. Crear GameWidget en didChangeDependencies()
- Se llama DESPUÉS de initState()
- Tiene acceso al context
- Solo se llama una vez (con el check `_gameWidget == null`)

### 2. Usar Variable Nullable
- `Widget? _gameWidget` permite control explícito
- Podemos verificar si ya existe antes de crear
- Podemos hacer null en dispose()

### 3. Flag _isDisposing
- Previene crear GameWidget durante dispose()
- Muestra loading screen si estamos limpiando

### 4. Delay en onRemove()
- Da tiempo a Flame para procesar el pause
- Evita race conditions

---

## 🧪 TESTING

### Paso 1: Limpiar Completamente
```bash
flutter clean
flutter pub get
```

### Paso 2: Hot Restart (NO Hot Reload)
- CTRL+SHIFT+F5 (Windows/Linux)
- CMD+SHIFT+F5 (Mac)

### Paso 3: Probar Flujo
1. Abrir app
2. Entrar a un arco
3. **NO debería haber error**
4. Salir del arco
5. Entrar de nuevo
6. **NO debería haber error**

---

## 🎯 SI AÚN PERSISTE EL ERROR

Si después de aplicar TODO esto el error persiste, entonces el problema está en **Flame Engine** o en alguna **dependencia externa**.

### Opción 1: Actualizar Flame
```yaml
# pubspec.yaml
dependencies:
  flame: ^1.18.0  # Última versión estable
```

### Opción 2: Workaround Temporal
```dart
// En arc_game_screen.dart, envolver GameWidget en try-catch
Widget _buildGameWidget() {
  try {
    return GameWidget(
      key: ValueKey('game_${widget.arcId}_${game.hashCode}'),
      game: game,
    );
  } catch (e) {
    print('⚠️ Error creating GameWidget: $e');
    // Forzar recreación del juego
    _recreateGame();
    return const SizedBox.shrink();
  }
}

void _recreateGame() {
  // Crear nuevo juego con nuevo hashCode
  switch (widget.arcId) {
    case 'arc_1_gula':
      game = GluttonyArcGame();
      break;
    // ... otros casos
  }
  _gameWidget = null;
  setState(() {}); // Forzar rebuild
}
```

### Opción 3: Reportar Bug a Flame
Si nada funciona, es un bug de Flame:
https://github.com/flame-engine/flame/issues

---

## 📊 DIAGNÓSTICO

Para entender mejor el problema, agrega estos prints:

```dart
@override
void initState() {
  super.initState();
  print('═══════════════════════════════════');
  print('🎮 [INIT] Arc: ${widget.arcId}');
  print('🎮 [INIT] Creating game...');
  
  game = _createGame();
  
  print('✅ [INIT] Game created');
  print('   Game hashCode: ${game.hashCode}');
  print('   Game type: ${game.runtimeType}');
  print('═══════════════════════════════════');
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  if (_gameWidget == null) {
    print('═══════════════════════════════════');
    print('🎮 [BUILD] Creating GameWidget...');
    print('   Game hashCode: ${game.hashCode}');
    
    _gameWidget = GameWidget(
      key: ValueKey('game_${widget.arcId}_${game.hashCode}'),
      game: game,
    );
    
    print('✅ [BUILD] GameWidget created');
    print('   Widget hashCode: ${_gameWidget.hashCode}');
    print('═══════════════════════════════════');
  }
}

@override
Widget build(BuildContext context) {
  print('🔄 [BUILD] build() called - _gameWidget: ${_gameWidget != null}');
  // ... resto del código
}
```

Esto te dirá **exactamente** cuándo se crea cada cosa y si hay duplicados.

---

## ✅ RESUMEN

1. **Limpiar**: `flutter clean`
2. **Modificar**: Crear GameWidget en `didChangeDependencies()`
3. **Guardar**: Usar `Widget? _gameWidget`
4. **Proteger**: Agregar flag `_isDisposing`
5. **Limpiar**: Implementar `dispose()` correctamente
6. **Probar**: Hot Restart completo

Si esto no funciona, el problema está fuera de tu control (Flame o Flutter).
