# GUÍA DE VERIFICACIÓN DE MEJORAS

**Fecha**: 28 de enero de 2025  
**Problema**: Las mejoras no se muestran en la aplicación

---

## 🔍 DIAGNÓSTICO

### Posibles Causas

1. **Hot Reload no suficiente** - Cambios en lógica de juego requieren restart
2. **Caché de Flutter** - Archivos antiguos en caché
3. **Instancia de juego antigua** - Juego creado antes de los cambios
4. **Imports faltantes** - Archivos nuevos no importados correctamente

---

## ✅ SOLUCIONES PASO A PASO

### Solución 1: Hot Restart (Más Rápido)

```bash
# En la terminal donde corre la app:
# Presiona 'R' (mayúscula) para Hot Restart
R
```

O desde VS Code:
- `Ctrl+Shift+F5` (Windows/Linux)
- `Cmd+Shift+F5` (Mac)

---

### Solución 2: Limpiar y Recompilar (Recomendado)

```bash
# 1. Detener la aplicación
# 2. Limpiar caché
flutter clean

# 3. Obtener dependencias
flutter pub get

# 4. Recompilar y ejecutar
flutter run
```

---

### Solución 3: Verificar Imports

Verifica que estos imports estén en `arc_game_screen.dart`:

```dart
import 'package:humano/game/ui/tension_effects_overlay.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
```

---

## 🧪 VERIFICACIÓN DE CAMBIOS

### 1. Verificar Pausa

**Cómo probar**:
1. Inicia el juego (Arco 1)
2. Presiona el botón de pausa
3. Observa al enemigo

**Resultado esperado**:
- ✅ Enemigo se detiene completamente
- ✅ Animación del enemigo se congela
- ✅ Jugador no puede moverse

**Si falla**:
- El enemigo sigue moviéndose → Hot restart no funcionó

---

### 2. Verificar Colisiones

**Cómo probar**:
1. Inicia el juego
2. Observa al enemigo patrullar
3. Mira si atraviesa obstáculos (cajas)

**Resultado esperado**:
- ✅ Enemigo rodea obstáculos
- ✅ Enemigo no traspasa paredes
- ✅ Enemigo navega correctamente

**Si falla**:
- Enemigo traspasa obstáculos → Código no se aplicó

---

### 3. Verificar Efectos Visuales

**Cómo probar**:
1. Inicia el juego
2. Deja que la cordura baje (<50%)
3. Observa los bordes de la pantalla

**Resultado esperado**:
- ✅ Bordes más oscuros (vignette)
- ✅ Líneas de escaneo visibles
- ✅ Efecto glitch ocasional
- ✅ Borde rojo cuando enemigo está cerca

**Si falla**:
- No se ven efectos → Import faltante o hot restart necesario

---

### 4. Verificar Botón de Esconderse

**Cómo probar**:
1. Inicia el juego
2. Acércate a un escondite (área semi-transparente)
3. Busca el botón morado

**Resultado esperado**:
- ✅ Botón morado aparece
- ✅ Al presionar, jugador se vuelve semi-transparente
- ✅ Enemigo no detecta al jugador escondido

**Si falla**:
- Botón no aparece → Verificar que estás en arco fusionado

---

## 🔧 COMANDOS DE DIAGNÓSTICO

### Verificar que los archivos existen

```bash
# Verificar archivo de efectos de tensión
ls lib/game/ui/tension_effects_overlay.dart

# Verificar cambios en enemigos
git diff lib/game/arcs/gluttony/components/enemy_component.dart
git diff lib/game/arcs/greed/components/banker_enemy.dart
```

### Verificar compilación

```bash
# Compilar sin ejecutar
flutter build apk --debug

# Si hay errores, verlos aquí
flutter analyze
```

---

## 📱 PASOS ESPECÍFICOS POR PLATAFORMA

### Android

```bash
# 1. Detener app
# 2. Limpiar
flutter clean

# 3. Recompilar
flutter build apk --debug

# 4. Instalar y ejecutar
flutter run
```

### iOS

```bash
# 1. Detener app
# 2. Limpiar
flutter clean

# 3. Limpiar pods
cd ios
pod deintegrate
pod install
cd ..

# 4. Recompilar
flutter run
```

### Web

```bash
# 1. Detener app
# 2. Limpiar
flutter clean

# 3. Recompilar
flutter run -d chrome
```

### Windows/Desktop

```bash
# 1. Detener app
# 2. Limpiar
flutter clean

# 3. Recompilar
flutter run -d windows
```

---

## 🐛 PROBLEMAS COMUNES

### Problema 1: "No se ve ningún cambio"

**Causa**: Hot reload no suficiente  
**Solución**: Hot restart (R mayúscula) o `flutter clean`

### Problema 2: "Error de import"

**Causa**: Archivo nuevo no encontrado  
**Solución**: 
```bash
flutter pub get
flutter clean
flutter run
```

### Problema 3: "Enemigo sigue traspasando"

**Causa**: Instancia de juego antigua en memoria  
**Solución**: Cerrar app completamente y reiniciar

### Problema 4: "No se ven efectos visuales"

**Causa**: Import faltante o overlay no agregado  
**Solución**: Verificar que `TensionEffectsOverlay` está en `arc_game_screen.dart`

---

## ✅ CHECKLIST DE VERIFICACIÓN

Marca cada item después de verificarlo:

### Antes de Probar
- [ ] Ejecuté `flutter clean`
- [ ] Ejecuté `flutter pub get`
- [ ] Cerré la app completamente
- [ ] Reinicié la app con `flutter run`

### Durante la Prueba
- [ ] Probé pausar el juego
- [ ] Observé al enemigo patrullar
- [ ] Dejé que la cordura bajara
- [ ] Busqué el botón de esconderse

### Resultados
- [ ] Pausa funciona (enemigo se detiene)
- [ ] Colisiones funcionan (enemigo no traspasa)
- [ ] Efectos visuales se ven (vignette, glitch)
- [ ] Botón de esconderse aparece

---

## 📊 TABLA DE DIAGNÓSTICO

| Síntoma | Causa Probable | Solución |
|---------|----------------|----------|
| Enemigo sigue moviéndose al pausar | Hot reload insuficiente | Hot restart (R) |
| Enemigo traspasa obstáculos | Código no aplicado | `flutter clean` + `flutter run` |
| No se ven efectos visuales | Import faltante | Verificar imports |
| Botón esconderse no aparece | Arco incorrecto | Verificar que es arco fusionado |
| App no compila | Error de sintaxis | `flutter analyze` |

---

## 🔍 VERIFICACIÓN MANUAL DE CÓDIGO

### Verificar que el código está en el archivo

```bash
# Buscar la verificación de pausa en enemy_component.dart
grep -n "isPaused" lib/game/arcs/gluttony/components/enemy_component.dart

# Buscar la función _wouldCollide
grep -n "_wouldCollide" lib/game/arcs/gluttony/components/enemy_component.dart

# Buscar TensionEffectsOverlay en arc_game_screen.dart
grep -n "TensionEffectsOverlay" lib/screens/arc_game_screen.dart
```

**Resultado esperado**:
- Debe mostrar números de línea donde aparece el código
- Si no muestra nada, el código no está en el archivo

---

## 💡 SOLUCIÓN DEFINITIVA

Si nada funciona, ejecuta estos comandos en orden:

```bash
# 1. Detener la app completamente
# Ctrl+C en la terminal

# 2. Limpiar TODO
flutter clean
rm -rf build/
rm -rf .dart_tool/

# 3. Obtener dependencias
flutter pub get

# 4. Recompilar desde cero
flutter run --no-hot

# 5. Si aún no funciona, reiniciar el dispositivo/emulador
```

---

## 📞 INFORMACIÓN DE DEBUG

Si los cambios siguen sin aparecer, proporciona esta información:

```bash
# Versión de Flutter
flutter --version

# Dispositivo/Plataforma
flutter devices

# Logs de la app
flutter logs

# Estado de git (para ver si los cambios están guardados)
git status
git diff
```

---

## ✅ CONFIRMACIÓN FINAL

Después de aplicar las soluciones, deberías ver:

1. **Pausa**: Enemigo completamente detenido
2. **Colisiones**: Enemigo navegando alrededor de obstáculos
3. **Efectos**: Vignette oscuro, líneas de escaneo, glitch
4. **Esconderse**: Botón morado visible cerca de escondites

Si ves todo esto, ¡las mejoras están funcionando! ✅

---

**Última actualización**: 28 de enero de 2025
