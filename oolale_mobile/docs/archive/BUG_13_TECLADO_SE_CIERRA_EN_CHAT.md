# 🐛 BUG #13: Teclado se Cierra al Recibir Mensajes en Tiempo Real

## 📅 Fecha: Día 14 - Testing y Correcciones

---

## 🔴 **PROBLEMA REPORTADO**

### Descripción:
Cuando dos usuarios conversan en el chat:
1. Usuario A está escribiendo un mensaje (teclado abierto)
2. Usuario B envía un mensaje
3. Usuario A recibe el mensaje en tiempo real
4. **El teclado de Usuario A se cierra automáticamente** 😱

### Impacto:
- ❌ Interrumpe la experiencia de escritura
- ❌ El usuario tiene que tocar el TextField de nuevo para seguir escribiendo
- ❌ Frustrante en conversaciones activas
- ❌ Hace que el chat se sienta "roto"

---

## 🔍 **CAUSA RAÍZ**

### Análisis técnico:

```dart
// ANTES (CÓDIGO CON BUG):
await _realtimeService.subscribeToConversation(
  myId,
  widget.userId,
  (newMessage) {
    final message = Message.fromJson(newMessage);
    if (mounted) {
      if (!_messageIds.contains(message.id)) {
        setState(() {  // ⚠️ PROBLEMA AQUÍ
          _messageIds.add(message.id);
          _messages.add(message);
          _scrollToBottom();
        });
        // ...
      }
    }
  },
);
```

### ¿Por qué se cierra el teclado?

1. **Llega un mensaje nuevo** → Se ejecuta el callback
2. **Se llama `setState()`** → Flutter reconstruye el widget
3. **El TextField se reconstruye** → Pierde el foco
4. **El FocusNode pierde la referencia** → El teclado se cierra
5. **Usuario frustrado** 😤

---

## ✅ **SOLUCIÓN IMPLEMENTADA**

### Estrategia:
**Preservar el foco del TextField antes y después del `setState()`**

### Código corregido:

```dart
// DESPUÉS (CÓDIGO CORREGIDO):
await _realtimeService.subscribeToConversation(
  myId,
  widget.userId,
  (newMessage) {
    final message = Message.fromJson(newMessage);
    if (mounted) {
      if (!_messageIds.contains(message.id)) {
        // 1️⃣ Guardar el estado del foco ANTES de setState
        final hadFocus = _messageFocusNode.hasFocus;
        
        setState(() {
          _messageIds.add(message.id);
          _messages.add(message);
          _scrollToBottom();
        });
        
        // 2️⃣ Restaurar el foco DESPUÉS de setState si lo tenía
        if (hadFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_messageFocusNode.hasFocus) {
              _messageFocusNode.requestFocus();
            }
          });
        }
        
        // Mark as read if from other user
        if (message.senderId == widget.userId) {
          _realtimeService.markMessageAsRead(message.id.toString());
        }
      }
    }
  },
);
```

---

## 🔧 **CÓMO FUNCIONA LA SOLUCIÓN**

### Paso a paso:

1. **Antes del `setState()`:**
   ```dart
   final hadFocus = _messageFocusNode.hasFocus;
   ```
   - Guardamos si el TextField tenía el foco
   - `true` = usuario estaba escribiendo
   - `false` = usuario no estaba escribiendo

2. **Durante el `setState()`:**
   ```dart
   setState(() {
     _messageIds.add(message.id);
     _messages.add(message);
     _scrollToBottom();
   });
   ```
   - Se actualiza la lista de mensajes
   - Flutter reconstruye el widget
   - El TextField pierde el foco temporalmente

3. **Después del `setState()`:**
   ```dart
   if (hadFocus) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted && !_messageFocusNode.hasFocus) {
         _messageFocusNode.requestFocus();
       }
     });
   }
   ```
   - Si el usuario estaba escribiendo (`hadFocus == true`)
   - Esperamos a que termine el rebuild (`addPostFrameCallback`)
   - Restauramos el foco del TextField
   - El teclado permanece abierto ✅

---

## 🎯 **CASOS DE USO**

### Caso 1: Usuario escribiendo cuando llega mensaje
```
Usuario A: [Escribiendo: "Hola, ¿cómo est..."]
Usuario B: [Envía: "¡Hola!"]
Usuario A: [Recibe mensaje]
✅ RESULTADO: Teclado permanece abierto, puede seguir escribiendo
```

### Caso 2: Usuario no escribiendo cuando llega mensaje
```
Usuario A: [Leyendo mensajes, teclado cerrado]
Usuario B: [Envía: "¿Estás ahí?"]
Usuario A: [Recibe mensaje]
✅ RESULTADO: Teclado permanece cerrado (comportamiento correcto)
```

### Caso 3: Conversación activa (múltiples mensajes)
```
Usuario A: [Escribiendo: "Sí, aquí est..."]
Usuario B: [Envía: "Perfecto"]
Usuario A: [Recibe mensaje, sigue escribiendo]
Usuario B: [Envía: "¿A qué hora?"]
Usuario A: [Recibe mensaje, sigue escribiendo]
✅ RESULTADO: Teclado nunca se cierra, experiencia fluida
```

---

## 🧪 **TESTING**

### Escenarios probados:

1. ✅ **Dos usuarios escribiendo simultáneamente**
   - Ambos teclados permanecen abiertos
   - Los mensajes llegan en tiempo real
   - No hay interrupciones

2. ✅ **Usuario escribiendo, otro envía mensaje**
   - El teclado del que escribe NO se cierra
   - El mensaje se muestra correctamente
   - El foco se mantiene

3. ✅ **Usuario leyendo, otro envía mensaje**
   - El teclado permanece cerrado (correcto)
   - El mensaje se muestra correctamente
   - No hay cambios inesperados

4. ✅ **Múltiples mensajes en ráfaga**
   - El teclado permanece estable
   - Todos los mensajes se muestran
   - No hay parpadeos ni cierres

---

## 📊 **IMPACTO DE LA CORRECCIÓN**

### Antes:
- ❌ Teclado se cierra cada vez que llega un mensaje
- ❌ Usuario tiene que tocar el TextField de nuevo
- ❌ Experiencia frustrante
- ❌ Conversaciones lentas e interrumpidas

### Después:
- ✅ Teclado permanece abierto mientras escribes
- ✅ Conversaciones fluidas y naturales
- ✅ Experiencia similar a WhatsApp/Telegram
- ✅ Usuarios satisfechos

---

## 🔍 **DETALLES TÉCNICOS**

### ¿Por qué usar `addPostFrameCallback`?

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  // Este código se ejecuta DESPUÉS de que Flutter termine de reconstruir
  _messageFocusNode.requestFocus();
});
```

**Razón:**
- `setState()` es **síncrono** pero el rebuild es **asíncrono**
- Si llamamos `requestFocus()` inmediatamente, el widget aún no está listo
- `addPostFrameCallback` espera a que el frame termine de renderizarse
- Entonces podemos restaurar el foco de forma segura

### ¿Por qué verificar `mounted`?

```dart
if (mounted && !_messageFocusNode.hasFocus) {
  _messageFocusNode.requestFocus();
}
```

**Razón:**
- El callback puede ejecutarse después de que el widget se desmonte
- Verificamos `mounted` para evitar errores
- Verificamos `!_messageFocusNode.hasFocus` para no forzar el foco si ya lo tiene

---

## 📝 **ARCHIVOS MODIFICADOS**

1. `lib/screens/messages/chat_screen.dart`
   - Líneas 257-280 (método `_setupRealtime`)
   - Agregada lógica de preservación de foco

---

## ✨ **RESULTADO FINAL**

El chat ahora funciona como se espera:
- ✅ Conversaciones fluidas sin interrupciones
- ✅ Teclado permanece abierto mientras escribes
- ✅ Experiencia similar a apps de mensajería profesionales
- ✅ Bug crítico resuelto

**¡Los usuarios ahora pueden conversar sin frustraciones!** 🎉

---

## 🚀 **PRÓXIMOS PASOS**

Posibles mejoras adicionales:
1. Agregar indicador visual cuando el otro usuario está escribiendo
2. Implementar "scroll to bottom" automático solo si el usuario está al final
3. Agregar haptic feedback al enviar mensajes
4. Implementar "mark as read" más inteligente

---

## 📌 **NOTAS**

- ✅ Código compila sin errores
- ⚠️ Solo warnings menores (deprecated withOpacity)
- ✅ Funcionalidad probada y verificada
- ✅ No afecta otras partes del código
