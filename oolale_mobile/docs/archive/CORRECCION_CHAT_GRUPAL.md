# 🔧 Corrección: Chat Grupal de Eventos

## ❌ Error Encontrado

```
ERROR: 42703: column participantes_evento.status does not exist
```

## 🔍 Causa

La tabla `participantes_evento` usa la columna **`confirmed`** (boolean), NO `status` (text).

### Estructura Real:
```sql
CREATE TABLE participantes_evento (
  id BIGINT PRIMARY KEY,
  event_id BIGINT REFERENCES eventos(id),
  user_id UUID REFERENCES perfiles(id),
  role TEXT,
  confirmed BOOLEAN DEFAULT false,  -- ✅ Esta es la columna correcta
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## ✅ Corrección Aplicada

### 1. **Script SQL** (`SETUP_EVENT_GROUP_CHAT.sql`)

**Antes:**
```sql
AND participantes_evento.status = 'accepted'
```

**Después:**
```sql
AND participantes_evento.confirmed = true
```

### 2. **Código Dart** (`event_group_chat_screen.dart`)

**Antes:**
```dart
.eq('status', 'accepted')
```

**Después:**
```dart
.eq('confirmed', true)
```

## 📋 Archivos Corregidos

1. ✅ `SETUP_EVENT_GROUP_CHAT.sql` - Políticas RLS actualizadas
2. ✅ `lib/screens/events/event_group_chat_screen.dart` - Query corregida

## 🚀 Próximo Paso

**Ejecutar el script SQL corregido en Supabase:**

1. Abrir Supabase Dashboard
2. Ir a SQL Editor
3. Copiar y ejecutar `SETUP_EVENT_GROUP_CHAT.sql`
4. Verificar que se crea la tabla sin errores

## ✅ Ahora Debería Funcionar

El script SQL ahora usa la columna correcta (`confirmed = true`) para verificar que los participantes están confirmados en el evento.
