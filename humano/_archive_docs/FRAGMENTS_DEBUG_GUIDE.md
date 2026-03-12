# 🔍 Guía de Depuración: Fragmentos no se Desbloquean

## 📋 Problema

Los fragmentos que recolectas en el juego no aparecen desbloqueados en la pantalla de ARCHIVO.

## ✅ Verificaciones Implementadas

### 1. FragmentsProvider está Registrado
- ✅ Verificado en `lib/main.dart` líneas 98-110
- ✅ Se registra como `ChangeNotifierProxyProvider<AuthProvider, FragmentsProvider>`
- ✅ Se carga automáticamente cuando hay usuario autenticado

### 2. Guardado de Fragmentos está Implementado
- ✅ Verificado en `lib/screens/arc_game_screen.dart` línea 699
- ✅ Se llama a `fragmentsProvider.unlockFragmentsForArcProgress()` al completar un arco
- ✅ Se guarda en Firebase en la ruta: `users/{userId}/progress/fragments`

### 3. Carga de Fragmentos está Implementada
- ✅ Verificado en `lib/screens/archive_screen.dart` línea 56
- ✅ Se llama a `fragmentsProvider.loadProgress()` al abrir la pantalla
- ✅ Se lee desde Firebase en la misma ruta

## 🔍 Pasos para Depurar

### Paso 1: Verificar que se Guardan los Fragmentos

1. Juega un arco y recolecta al menos 1 evidencia
2. Completa el arco
3. Busca en los logs:

```
═══════════════════════════════════
🔓 [SAVE PROGRESS] Guardando fragmentos
   Arc ID: arc_1_gula
   Evidencias recolectadas: 3
   FragmentsProvider hashCode: XXXXX
```

4. Verifica que aparezca:

```
✅ [SAVE PROGRESS] Fragmentos guardados
   Fragmentos actuales para arc_1_gula: {1, 2, 3}
   Total fragmentos: 3
═══════════════════════════════════
```

**Si NO aparece este log:**
- El método `_saveProgress()` no se está ejecutando
- Verifica que `onComplete` en `ArcVictoryCinematic` se esté llamando

**Si aparece pero los fragmentos están vacíos:**
- Hay un problema en `unlockFragmentsForArcProgress()`
- Revisa los logs de `FragmentsProvider`

### Paso 2: Verificar Firebase

1. Abre Firebase Console
2. Ve a Firestore Database
3. Navega a: `users/{tu_user_id}/progress/fragments`
4. Verifica que el documento exista y contenga:

```json
{
  "arc_1_gula": [1, 2, 3],
  "lastUpdated": "timestamp"
}
```

**Si el documento NO existe:**
- El guardado en Firebase está fallando
- Revisa los logs de `_saveToFirebase()` en `FragmentsProvider`
- Verifica las reglas de Firebase (deben permitir escritura en subcollections)

**Si el documento existe pero está vacío:**
- El método `unlockFragment()` no está agregando los fragmentos
- Revisa los logs detallados en `FragmentsProvider`

### Paso 3: Verificar que se Cargan los Fragmentos

1. Abre la pantalla de ARCHIVO
2. Busca en los logs:

```
═══════════════════════════════════
🔄 [FragmentsProvider] Iniciando carga de progreso...
   Provider hashCode: XXXXX
   Usuario ID: XXXXX
   Ruta: users/XXXXX/progress/fragments
   Documento existe: true
```

3. Verifica que aparezca:

```
📦 [FragmentsProvider] Datos recibidos de Firebase:
   Raw data: {arc_1_gula: [1, 2, 3], lastUpdated: ...}
   ✓ arc_1_gula: {1, 2, 3}
✅ Progreso de fragmentos cargado desde Firebase
   Total fragmentos: 3
═══════════════════════════════════
```

**Si NO aparece este log:**
- `loadProgress()` no se está llamando
- Verifica que el `WidgetsBinding.instance.addPostFrameCallback` en `archive_screen.dart` se ejecute

**Si aparece "Documento existe: false":**
- Los fragmentos nunca se guardaron en Firebase
- Vuelve al Paso 1

**Si aparece "Raw data: {}" (vacío):**
- El documento existe pero no tiene datos
- Problema en el guardado (Paso 1)

### Paso 4: Verificar la UI

1. Con los logs del Paso 3 confirmados, verifica la UI
2. Los fragmentos deberían aparecer desbloqueados
3. Busca en los logs:

```
🎬 [ENDING BUTTON DEBUG]
   Arc 1: 3/5 fragmentos - {1, 2, 3}
   Arc 1 completo: false
```

**Si los fragmentos aparecen en los logs pero NO en la UI:**
- Problema de renderizado
- Verifica que `Consumer<FragmentsProvider>` esté funcionando
- Verifica que `notifyListeners()` se esté llamando

## 🐛 Problemas Comunes

### Problema 1: Fragmentos se Guardan pero no se Cargan

**Síntoma:** Los logs muestran guardado exitoso, pero al cargar están vacíos

**Causa Probable:** Instancias diferentes de `FragmentsProvider`

**Solución:**
```dart
// Verifica que el hashCode sea el mismo
print('Provider al guardar: ${fragmentsProvider.hashCode}');
print('Provider al cargar: ${fragmentsProvider.hashCode}');
```

Si son diferentes, hay un problema con el registro del provider.

### Problema 2: Firebase Rechaza la Escritura

**Síntoma:** Error "permission-denied" en los logs

**Causa:** Reglas de Firebase muy restrictivas

**Solución:** Verifica que las reglas permitan escritura en subcollections:

```javascript
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
  
  // Subcolecciones
  match /{subcollection}/{document=**} {
    allow read, write: if request.auth.uid == userId;
  }
}
```

### Problema 3: Fragmentos se Duplican

**Síntoma:** Los fragmentos aparecen múltiples veces

**Causa:** `unlockFragment()` se llama múltiples veces

**Solución:** Ya está implementado con `Set<int>` que previene duplicados

### Problema 4: Fragmentos Desaparecen al Reiniciar

**Síntoma:** Los fragmentos están al completar, pero desaparecen al cerrar/abrir

**Causa:** No se está cargando desde Firebase al iniciar

**Solución:** Verifica que `loadProgress()` se llame en:
1. `archive_screen.dart` al abrir la pantalla
2. `main.dart` al autenticar el usuario

## 📊 Checklist de Depuración

- [ ] Logs de guardado aparecen correctamente
- [ ] Documento existe en Firebase Console
- [ ] Documento contiene los fragmentos correctos
- [ ] Logs de carga aparecen correctamente
- [ ] Fragmentos se cargan desde Firebase
- [ ] UI muestra los fragmentos desbloqueados
- [ ] Fragmentos persisten al reiniciar la app

## 🔧 Comandos Útiles

### Ver logs en tiempo real (Android)
```bash
flutter logs | grep -E "SAVE PROGRESS|FragmentsProvider|ARCHIVE"
```

### Ver logs en tiempo real (iOS)
```bash
flutter logs | grep -E "SAVE PROGRESS|FragmentsProvider|ARCHIVE"
```

### Limpiar datos de prueba en Firebase
```dart
// En Dart DevTools Console
await FirebaseFirestore.instance
  .collection('users')
  .doc('YOUR_USER_ID')
  .collection('progress')
  .doc('fragments')
  .delete();
```

## 📞 Siguiente Paso

Si después de seguir todos estos pasos el problema persiste:

1. Copia TODOS los logs relevantes
2. Verifica el estado en Firebase Console
3. Comparte los logs para análisis más profundo

---

**Última actualización**: Diciembre 5, 2024  
**Archivos modificados**:
- `lib/screens/arc_game_screen.dart` - Logs mejorados en guardado
- `lib/data/providers/fragments_provider.dart` - Logs mejorados en carga
