# Guía de Logs para Diagnosticar Game Attachment Error

## Logs Agregados

Se han agregado logs detallados en **TODOS** los puntos críticos del ciclo de vida del juego:

### 📍 BaseArcGame (Clase Base)
- `onLoad()` - Cuando el juego se carga
- `onMount()` - Cuando el juego se monta en el árbol de componentes
- `onRemove()` - Cuando el juego se elimina
- `initializeGame()` - Cuando se inicializa el juego

### 📍 Arcos Específicos (Gluttony, Greed, Envy)
- `setupScene()` - Configuración de la escena
- `setupPlayer()` - Configuración del jugador
- `setupEnemy()` - Configuración del enemigo
- `setupCollectibles()` - Configuración de coleccionables

### 📍 Componentes
- `PlayerComponent.onLoad()` - Carga del componente jugador
- `EnemyComponent.onLoad()` - Carga del componente enemigo

### 📍 Screen (ArcGameScreen)
- `initState()` - Creación del juego
- `didChangeDependencies()` - Setup de providers
- `dispose()` - Limpieza
- `build()` - Renderizado

## Secuencia Normal de Logs

Cuando entras a un arco, deberías ver esta secuencia:

```
═══════════════════════════════════
🎮 [INIT] Initializing ArcGameScreen for arc_1_gula
🎮 [INIT] Creating game instance
✅ [INIT] Game created: 123456789
🔑 [INIT] GameWidget key created: 987654321
═══════════════════════════════════

🔄 [DID_CHANGE_DEPS] Called - setting up providers
✅ [DID_CHANGE_DEPS] Providers setup complete

🔄 [BUILD] build() called - game: 123456789, _isDisposing: false
✅ [BUILD] Rendering game screen with game: 123456789

🔄 [LIFECYCLE] onLoad() called
   Game hashCode: 123456789
   Already initialized: false
   Has been attached: false
🎮 [LIFECYCLE] Initializing game for first time

🎮 [GLUTTONY] setupScene() called
   Game hashCode: 123456789
✅ [GLUTTONY] Scene setup complete

🎮 [GLUTTONY] setupPlayer() called
   Game hashCode: 123456789
🔧 [GLUTTONY-PLAYER] onLoad() called
✅ [GLUTTONY-PLAYER] Player component loaded
✅ [GLUTTONY] Player setup complete

🎮 [GLUTTONY] setupEnemy() called
   Game hashCode: 123456789
🔧 [GLUTTONY-ENEMY] onLoad() called
✅ [GLUTTONY-ENEMY] Enemy component loaded
✅ [GLUTTONY] Enemy setup complete

🎮 [GLUTTONY] setupCollectibles() called
   Game hashCode: 123456789
✅ [GLUTTONY] Collectibles setup complete (5 evidences, exit door, hiding spots)

✅ [LIFECYCLE] onLoad() completed successfully

✅ [LIFECYCLE] Game mounted for first time
   Game hashCode: 123456789
```

## ⚠️ Señales de Problema

### 1. Re-Mount Inesperado
```
⚠️ [LIFECYCLE] WARNING: Game is being mounted again!
   This might indicate a re-attachment issue
   Game hashCode: 123456789
```
**Causa**: El juego se está montando múltiples veces
**Solución**: Verificar que no haya hot reload activo, hacer restart completo

### 2. onLoad() Llamado Múltiples Veces
```
🔄 [LIFECYCLE] onLoad() called
   Game hashCode: 123456789
   Already initialized: true  ← ⚠️ PROBLEMA
   Has been attached: true    ← ⚠️ PROBLEMA
⚠️ [LIFECYCLE] Game already initialized, skipping
```
**Causa**: El juego se está reinicializando
**Solución**: Verificar que el GameWidget no se esté recreando

### 3. Mismo HashCode en Múltiples Instancias
```
🎮 [INIT] Game created: 123456789
...
🎮 [INIT] Game created: 123456789  ← ⚠️ MISMO HASHCODE
```
**Causa**: Se está reutilizando la misma instancia del juego
**Solución**: Verificar que se cree una nueva instancia cada vez

### 4. Build Llamado Durante Disposing
```
🔄 [BUILD] build() called - game: 123456789, _isDisposing: true  ← ⚠️ PROBLEMA
⏳ [BUILD] Showing loading screen
```
**Causa**: El widget se está reconstruyendo durante la eliminación
**Solución**: Verificar el ciclo de vida del widget

## Cómo Usar Esta Guía

### Paso 1: Ejecutar la App
```bash
cd humano
flutter run
```

### Paso 2: Navegar a un Arco
1. Abre la app
2. Selecciona un arco (Gluttony, Greed o Envy)
3. Observa la consola

### Paso 3: Copiar los Logs
Copia TODOS los logs desde que presionas el arco hasta que aparece el error.

### Paso 4: Buscar Patrones
Busca en los logs:
- ⚠️ Warnings
- ❌ Errores
- Secuencias anormales (como múltiples onLoad)
- HashCodes duplicados

### Paso 5: Comparar con la Secuencia Normal
Compara tus logs con la "Secuencia Normal" de arriba.

## Ejemplo de Análisis

Si ves esto:
```
🔄 [LIFECYCLE] onLoad() called
   Game hashCode: 123456789
   Already initialized: false
   Has been attached: false
✅ [LIFECYCLE] Game mounted for first time
   Game hashCode: 123456789

🔄 [LIFECYCLE] onLoad() called  ← ⚠️ SEGUNDA VEZ
   Game hashCode: 123456789
   Already initialized: true
   Has been attached: true
⚠️ [LIFECYCLE] WARNING: Game is being mounted again!
```

**Diagnóstico**: El juego se está montando dos veces
**Causa Probable**: Hot reload o rebuild del widget
**Solución**: Restart completo de la app

## Próximos Pasos

1. Ejecuta la app
2. Entra a cada arco (Gluttony, Greed, Envy)
3. Copia los logs completos
4. Compártelos para análisis detallado

Los logs ahora te dirán EXACTAMENTE qué está pasando y dónde está el problema.
