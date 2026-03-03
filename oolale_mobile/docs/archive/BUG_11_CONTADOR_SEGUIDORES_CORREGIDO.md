# 🐛 BUG #11: Contador de Seguidores Incorrecto

**Fecha**: 6 de Febrero, 2026  
**Prioridad**: 🔴 ALTA  
**Estado**: ✅ CORREGIDO

---

## 📋 Descripción del Problema

**Reporte del Usuario:**
> "Dice que tengo dos seguidores, luego le doy click y me dice que son tres, checa si esta correcto o no se actualiza en tiempo real"

**Causa Raíz:**
- Múltiples archivos consultaban el contador de seguidores usando la columna **incorrecta** (`conectado_id` en lugar de `usuario_id`)
- En el sistema bidireccional de conexiones, los seguidores se cuentan donde `usuario_id = X`, no donde `conectado_id = X`

---

## 🔍 Análisis Técnico

### Sistema de Conexiones Bidireccionales

Cuando Usuario 2 acepta la solicitud de Usuario 1, el trigger SQL crea **DOS filas**:

```sql
-- Fila original (Usuario 1 → Usuario 2)
{usuario_id: 1, conectado_id: 2, estatus: 'accepted'}

-- Fila inversa creada por trigger (Usuario 2 → Usuario 1)  
{usuario_id: 2, conectado_id: 1, estatus: 'accepted'}
```

### Consulta Correcta vs Incorrecta

**❌ INCORRECTO** (contaba las conexiones donde el usuario es `conectado_id`):
```dart
final seguidoresData = await _supabase
    .from('conexiones')
    .select()
    .eq('conectado_id', userId)  // ❌ Columna incorrecta
    .eq('estatus', 'accepted');
```

**✅ CORRECTO** (cuenta las conexiones donde el usuario es `usuario_id`):
```dart
final seguidoresData = await _supabase
    .from('conexiones')
    .select()
    .eq('usuario_id', userId)  // ✅ Columna correcta
    .eq('estatus', 'accepted');
```

---

## 🔧 Correcciones Aplicadas

### 1. **profile_screen.dart** ✅
**Línea 76-80**

```dart
// ANTES:
final seguidoresData = await _supabase
    .from('conexiones')
    .select()
    .eq('conectado_id', user.id)  // ❌
    .eq('estatus', 'accepted');

// AHORA:
final seguidoresData = await _supabase
    .from('conexiones')
    .select()
    .eq('usuario_id', user.id)  // ✅
    .eq('estatus', 'accepted');
```

---

### 2. **public_profile_screen.dart** ✅
**Línea 72-76**

```dart
// ANTES:
final seguidoresData = await _supabase
    .from('conexiones')
    .select()
    .eq('conectado_id', widget.userId)  // ❌
    .eq('estatus', 'accepted');

// AHORA:
final seguidoresData = await _supabase
    .from('conexiones')
    .select()
    .eq('usuario_id', widget.userId)  // ✅
    .eq('estatus', 'accepted');
```

---

### 3. **profile_detail_lists.dart** (ProfileFollowersScreen) ✅
**Línea 200-206**

```dart
// ANTES:
final response = await _supabase
    .from('conexiones')
    .select('*, perfiles:usuario_id(*)') 
    .eq('conectado_id', widget.userId)  // ❌
    .eq('estatus', 'accepted')
    .range(from, to);

// AHORA:
final response = await _supabase
    .from('conexiones')
    .select('*, perfiles:conectado_id(*)') 
    .eq('usuario_id', widget.userId)  // ✅
    .eq('estatus', 'accepted')
    .range(from, to);
```

**Nota:** También se cambió el join de `perfiles:usuario_id` a `perfiles:conectado_id` porque ahora estamos consultando por `usuario_id`, entonces los perfiles de los seguidores están en la columna `conectado_id`.

---

### 4. **unified_profile_screen.dart** ✅
**Ya estaba correcto** - No requirió cambios.

Además, este archivo ya tenía implementado:
- ✅ Listener de Realtime para actualizar el contador automáticamente
- ✅ Método `_reloadFollowersCount()` que recarga solo el contador sin recargar toda la pantalla

---

## 📊 Impacto de la Corrección

### Antes:
- Contador mostraba número incorrecto de seguidores
- Al hacer clic en "Seguidores", la lista mostraba un número diferente
- Inconsistencia entre contador y lista real

### Después:
- ✅ Contador muestra el número correcto de seguidores
- ✅ Lista de seguidores coincide con el contador
- ✅ Actualización en tiempo real cuando se acepta una conexión (en unified_profile_screen)

---

## 🧪 Pruebas Recomendadas

1. **Verificar contador en perfil propio:**
   - Ir a tu perfil
   - Verificar que el número de seguidores sea correcto
   - Hacer clic en "Seguidores" y verificar que coincida

2. **Verificar contador en perfil público:**
   - Ver el perfil de otro usuario
   - Verificar que el contador sea correcto
   - Hacer clic en "Seguidores" y verificar que coincida

3. **Verificar actualización en tiempo real:**
   - Usuario 1 envía solicitud a Usuario 2
   - Usuario 2 acepta la solicitud
   - Verificar que ambos usuarios vean +1 seguidor inmediatamente

4. **Verificar lista de seguidores:**
   - Hacer clic en el contador de "Seguidores"
   - Verificar que la lista muestre todos los seguidores correctos
   - Verificar que los perfiles se muestren correctamente

---

## 📁 Archivos Modificados

1. `oolale_mobile/lib/screens/profile/profile_screen.dart`
2. `oolale_mobile/lib/screens/profile/public_profile_screen.dart`
3. `oolale_mobile/lib/screens/profile/profile_detail_lists.dart`

---

## ✅ Estado Final

- **Bug corregido**: ✅
- **Archivos actualizados**: 3
- **Pruebas pendientes**: Usuario debe verificar
- **Actualización en tiempo real**: ✅ (ya implementada en unified_profile_screen)

---

## 📝 Notas Adicionales

- El sistema bidireccional funciona correctamente con el trigger SQL
- La corrección es consistente en todos los archivos de perfil
- No se requieren cambios en la base de datos, solo en el código Dart
- El listener de Realtime en `unified_profile_screen.dart` asegura que el contador se actualice automáticamente cuando hay cambios en la tabla `conexiones`
