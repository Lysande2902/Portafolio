# 🧹 TAREAS DE LIMPIEZA DE CÓDIGO

**Objetivo:** Eliminar referencias a sistemas que ya no usaremos

---

## ✅ ARCHIVOS YA ELIMINADOS

- ✅ `lib/screens/stats_screen.dart`
- ✅ `lib/screens/achievements_screen.dart`
- ✅ `lib/providers/achievements_provider.dart`
- ✅ `lib/data/models/achievement.dart`
- ✅ `lib/widgets/achievement_notification.dart`
- ✅ `lib/utils/progress_tracker.dart`
- ✅ `STATS_ACHIEVEMENTS_LEADERBOARD.md`
- ✅ `PLAN_SIMPLIFICACION_1_MES.md`

---

## 📝 ARCHIVOS QUE NECESITAS MODIFICAR

### 1. `lib/main.dart` ✅ COMPLETADO
**Acción:** Eliminar AchievementsProvider

**Eliminado:**
- Import de `achievements_provider.dart`
- ChangeNotifierProxyProvider de AchievementsProvider

---

### 2. `lib/screens/menu_screen.dart` ✅ COMPLETADO
**Acción:** Eliminar botón de Achievements

**Eliminado:**
- Import de `achievements_screen.dart`
- Import de `achievements_provider.dart`
- Botón de Achievements (esquina inferior derecha)
- Callback de achievements en `_ensureUserDataInitialized`

---

### 3. `lib/screens/settings_screen.dart` ✅ COMPLETADO
**Acción:** Eliminar botón "Ver Estadísticas"

**Eliminado:**
- Import de `stats_screen.dart`
- Botón "Ver estadísticas" en sección CUENTA
- Método `_showStats()`

---

### 4. `lib/data/providers/arc_data_provider.dart` ✅ COMPLETADO
**Acción:** Actualizar a 4 arcos fusionados

**Actualizado:**
```dart
final List<Arc> allArcs = [
  'arc_1_consumo_codicia',  // Gula + Avaricia
  'arc_2_envidia_lujuria',  // Envidia + Lujuria
  'arc_3_soberbia_pereza',  // Soberbia + Pereza
  'arc_4_ira',              // Ira (final)
];
```

**Contenido de arcos actualizado:**
- Arco 1: 10 fragmentos (5 Mateo + 5 Valeria)
- Arco 2: 10 fragmentos (5 Lucía + 5 Adriana)
- Arco 3: 10 fragmentos (5 Carlos + 5 Miguel)
- Arco 4: 5 fragmentos (Víctor solo)

---

### 5. `lib/screens/arc_selection_screen.dart` ✅ AUTO-ACTUALIZADO
**Acción:** Mostrar solo 4 arcos

**Estado:** Funciona automáticamente con arc_data_provider actualizado

---

### 6. `lib/data/providers/store_data_provider.dart` ⏳ PENDIENTE
**Acción:** Eliminar skins épicas y legendarias

**Buscar skins con precio > 150 y comentarlas:**
```dart
// Skins Épicas (250-500 monedas) - ELIMINADAS
// StoreItem(
//   id: 'skin_epic_1',
//   name: 'Deidad Digital',
//   price: 250,
//   ...
// ),

// Skins Legendarias (500+ monedas) - ELIMINADAS
// StoreItem(
//   id: 'skin_legendary_1',
//   name: 'The Watcher',
//   price: 500,
//   ...
// ),
```

**Mantener solo:**
- Skins gratis (0 monedas): Default, Usuario, Fantasma
- Skins comunes (50-75 monedas): Hacker, Corporativo, Agente, Periodista
- Skins profesionales (100-150 monedas): Punk, Gótico, Cyberpunk, Sombra

---

### 7. `lib/screens/store_screen.dart`
**Acción:** Eliminar tab de Battle Pass

**Buscar y comentar/eliminar:**
```dart
// Tab de Battle Pass
// Tab(text: 'Battle Pass')
```

**Y su contenido:**
```dart
// Widget de Battle Pass
// BattlePassWidget()
```

---

### 8. `lib/screens/arc_outro_screen.dart`
**Acción:** Verificar que después de 5 arcos vaya a Ending

**Buscar lógica que verifica arcos completados:**
```dart
// Si completedArcs.length == 5
// Navegar a EndingScreen (no DemoEndingScreen)
```

---

### 9. Crear `lib/screens/ending_screen.dart` ✅ COMPLETADO
**Acción:** Crear pantalla de final simple

**Estado:** Archivo creado con secuencia de texto animada y botón para volver al menú

---

## 🎯 PRIORIDAD DE TAREAS

### 🔴 CRÍTICO (COMPLETADO)
1. ✅ Eliminar archivos (YA HECHO)
2. ✅ Modificar `main.dart` (eliminar AchievementsProvider)
3. ✅ Modificar `menu_screen.dart` (eliminar botón achievements)
4. ✅ Modificar `arc_data_provider.dart` (4 arcos fusionados)
5. ✅ Modificar `settings_screen.dart` (eliminar botón stats)
6. ✅ Crear `ending_screen.dart` (pantalla de final)

### 🟡 IMPORTANTE (PENDIENTE)
7. ⏳ Modificar `store_data_provider.dart` (eliminar skins épicas/legendarias)
8. ⏳ Modificar `store_screen.dart` (eliminar Battle Pass)
9. ⏳ Crear archivos de arcos fusionados (4 nuevos arcos)
10. ⏳ Crear 4 imágenes de expedientes fusionados

### 🟢 DESEABLE (Si hay tiempo)
11. ⏳ Limpiar imports no usados
12. ⏳ Verificar que no hay referencias rotas
13. ⏳ Compilar y verificar que no hay errores

---

## 🧪 TESTING DESPUÉS DE LIMPIEZA

**Verificar que:**
- [ ] El juego compila sin errores
- [ ] No hay imports rotos
- [ ] Menu screen no tiene botones rotos
- [ ] Arc selection muestra solo 5 arcos
- [ ] Store muestra solo skins básicas
- [ ] No hay referencias a achievements/stats

---

## 📋 CHECKLIST RÁPIDO

```
ELIMINACIÓN DE CÓDIGO:
- [✅] Archivos de achievements eliminados
- [✅] Archivos de stats eliminados
- [✅] Documentación innecesaria eliminada
- [✅] main.dart limpio
- [✅] menu_screen.dart limpio
- [✅] settings_screen.dart limpio
- [✅] arc_data_provider.dart actualizado (4 arcos fusionados)
- [ ] store_data_provider.dart actualizado (skins básicas)
- [ ] store_screen.dart limpio (sin Battle Pass)
- [✅] ending_screen.dart creado

ARCOS FUSIONADOS:
- [ ] Crear lib/game/arcs/consumo_codicia/
- [ ] Crear lib/game/arcs/envidia_lujuria/
- [ ] Crear lib/game/arcs/soberbia_pereza/
- [ ] Crear lib/game/arcs/ira/
- [ ] Crear 4 imágenes de expedientes

COMPILACIÓN:
- [ ] flutter clean
- [ ] flutter pub get
- [ ] flutter run (sin errores)

TESTING BÁSICO:
- [ ] Menú principal funciona
- [ ] Arc selection muestra 4 arcos
- [ ] Store funciona
- [ ] No crashes al navegar
```

---

**SIGUIENTE PASO:** Modificar los archivos listados arriba

**¿Quieres que te ayude a modificar algún archivo específico?**

