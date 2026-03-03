# 🐛 BUG #12: Estado "En Línea" Incorrecto en Chat

**Fecha**: 6 de Febrero, 2026  
**Prioridad**: 🔴 ALTA  
**Estado**: ✅ CORREGIDO

---

## 📋 Descripción del Problema

**Reporte del Usuario:**
> "En lo visual mi otro usuario no está conectado pero aparece conectado"

**Causa Raíz:**
- El indicador "En línea" en el chat mostraba el estado de la **conexión Realtime** (WebSocket), NO el estado real del usuario
- No se consultaba la columna `en_linea` de la tabla `perfiles`
- No había listener en tiempo real para actualizar el estado cuando el usuario se conecta/desconecta

---

## 🔍 Análisis Técnico

### Problema Original

El código mostraba "En línea" basándose en `_realtimeConnectionState`:

```dart
// ❌ INCORRECTO: Mostraba estado de WebSocket, no del usuario
switch (_realtimeConnectionState) {
  case RealtimeConnectionState.connected:
    text = 'En línea';  // Esto significa que TU WebSocket está conectado
    color = Colors.green;
    break;
  // ...
}
```

Esto significaba que:
- Si **TU** conexión Realtime estaba activa → mostraba "En línea"
- Pero NO verificaba si el **OTRO USUARIO** realmente estaba conectado

### Solución Implementada

Ahora consultamos y escuchamos el estado real del usuario desde la BD:

```dart
// ✅ CORRECTO: Consulta el estado real del usuario
final data = await _supabase
    .from('perfiles')
    .select('nombre_artistico, foto_perfil, en_linea, ultima_conexion')
    .eq('id', widget.userId)
    .single();

_userIsOnline = data['en_linea'] ?? false;
_userLastSeen = DateTime.parse(data['ultima_conexion']);
```

---

## 🔧 Correcciones Aplicadas

### 1. **Nuevas Variables de Estado** ✅

```dart
// Agregadas en _ChatScreenState
bool _userIsOnline = false; // Estado real del usuario desde BD
DateTime? _userLastSeen; // Última conexión del usuario
StreamSubscription? _presenceSubscription; // Para escuchar cambios de presencia
```

---

### 2. **Consulta de Estado en _loadUserInfo()** ✅

```dart
// ANTES: Solo cargaba nombre y foto
final data = await _supabase
    .from('perfiles')
    .select('nombre_artistico, foto_perfil')
    .eq('id', widget.userId)
    .single();

// AHORA: También carga estado de presencia
final data = await _supabase
    .from('perfiles')
    .select('nombre_artistico, foto_perfil, en_linea, ultima_conexion')
    .eq('id', widget.userId)
    .single();

_userIsOnline = data['en_linea'] ?? false;
_userLastSeen = DateTime.parse(data['ultima_conexion']);
```

---

### 3. **Listener de Presencia en Tiempo Real** ✅

Nueva función `_setupPresenceListener()`:

```dart
void _setupPresenceListener() {
  _presenceSubscription = _supabase
      .channel('presence:${widget.userId}')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'perfiles',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: widget.userId,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          if (newRecord != null && mounted) {
            setState(() {
              _userIsOnline = newRecord['en_linea'] ?? false;
              _userLastSeen = DateTime.parse(newRecord['ultima_conexion']);
            });
            debugPrint('🔄 Estado actualizado: ${_userIsOnline ? "En línea" : "Desconectado"}');
          }
        },
      )
      .subscribe();
}
```

**Características:**
- ✅ Escucha cambios en la tabla `perfiles` para el usuario específico
- ✅ Se actualiza automáticamente cuando el usuario se conecta/desconecta
- ✅ Actualiza el estado en tiempo real sin recargar la pantalla

---

### 4. **Indicador Visual Mejorado** ✅

```dart
Widget _buildConnectionIndicator() {
  // Mostrar estado real del usuario desde la BD
  if (_userIsOnline) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'En línea',
          style: GoogleFonts.outfit(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  } else if (_userLastSeen != null) {
    // Mostrar última vez visto
    final now = DateTime.now();
    final difference = now.difference(_userLastSeen!);
    
    String lastSeenText;
    if (difference.inMinutes < 1) {
      lastSeenText = 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      lastSeenText = 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      lastSeenText = 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      lastSeenText = 'Hace ${difference.inDays} d';
    } else {
      lastSeenText = 'Hace tiempo';
    }
    
    return Text(lastSeenText, style: ...);
  }
  
  return const SizedBox.shrink();
}
```

**Características:**
- ✅ Muestra punto verde + "En línea" si el usuario está conectado
- ✅ Muestra "Hace X min/h/d" si el usuario está desconectado
- ✅ Formato amigable y fácil de entender

---

### 5. **Limpieza de Recursos** ✅

```dart
@override
void dispose() {
  _realtimeService.dispose();
  _typingTimer?.cancel();
  _typingSubscription?.cancel();
  _connectionSubscription?.cancel();
  _presenceSubscription?.cancel(); // ✅ Cancelar suscripción de presencia
  _messageController.removeListener(_onTypingChanged);
  _messageController.dispose();
  _messageFocusNode.dispose();
  _scrollController.dispose();
  super.dispose();
}
```

---

## 📊 Flujo de Actualización

### Cuando Usuario 2 Abre la App:

1. **PresenceService.initialize()** se ejecuta en `main.dart`
2. Actualiza `perfiles.en_linea = true` para Usuario 2
3. **Listener en ChatScreen** detecta el cambio
4. Usuario 1 ve "En línea" con punto verde ✅

### Cuando Usuario 2 Cierra la App:

1. **AppLifecycleState.paused** se detecta en `main.dart`
2. **PresenceService.setOffline()** actualiza `perfiles.en_linea = false`
3. **Listener en ChatScreen** detecta el cambio
4. Usuario 1 ve "Hace un momento" ✅

---

## 🧪 Pruebas Recomendadas

1. **Verificar estado inicial:**
   - Usuario 1 abre chat con Usuario 2 (que está desconectado)
   - Debe mostrar "Hace X min/h/d"

2. **Verificar actualización en tiempo real:**
   - Usuario 2 abre la app
   - Usuario 1 debe ver cambiar a "En línea" con punto verde
   - Sin recargar la pantalla

3. **Verificar desconexión:**
   - Usuario 2 cierra la app
   - Usuario 1 debe ver cambiar a "Hace un momento"
   - Después de 1 minuto debe decir "Hace 1 min"

4. **Verificar múltiples chats:**
   - Abrir varios chats con diferentes usuarios
   - Cada uno debe mostrar su estado correcto

---

## 📁 Archivos Modificados

1. `oolale_mobile/lib/screens/messages/chat_screen.dart`

---

## ⚠️ Dependencias

Este fix requiere que el script SQL esté ejecutado:
- `oolale_mobile/FIX_SUPABASE_SIMPLE.sql`

El script crea:
- ✅ Columnas `en_linea` y `ultima_conexion` en tabla `perfiles`
- ✅ Sistema de presencia funcional

---

## ✅ Estado Final

- **Bug corregido**: ✅
- **Actualización en tiempo real**: ✅
- **Indicador visual mejorado**: ✅
- **Última vez visto**: ✅
- **Limpieza de recursos**: ✅

---

## 📝 Notas Adicionales

- El indicador ahora muestra el estado **REAL** del usuario, no el estado de la conexión WebSocket
- Se actualiza automáticamente sin necesidad de recargar
- Formato amigable para "última vez visto"
- Compatible con el sistema de presencia implementado en `PresenceService`
