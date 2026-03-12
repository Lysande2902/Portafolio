# 🔥 Fix de Reglas de Firebase - Deployment Guide

## 📋 Problema Resuelto

Las reglas de Firestore eran demasiado estrictas y rechazaban actualizaciones parciales del documento de usuario. Esto causaba errores `PERMISSION_DENIED` cuando la app intentaba guardar:
- Progreso de arcos (`arcProgress`)
- Inventario (`inventory`)
- Estadísticas (`stats`)
- Configuraciones (`settings`)

## ✅ Solución Implementada

Se modificaron las reglas para:
1. **Separar validación de creación vs actualización**
   - `create`: Requiere campos completos (`userId`, `email`)
   - `update`: Permite actualizaciones parciales (merge)

2. **Validación flexible en actualizaciones**
   - Solo valida los campos que están siendo actualizados
   - No requiere que todos los campos estén presentes

## 🚀 Pasos para Desplegar

### 1. Verificar que tienes Firebase CLI instalado

```bash
firebase --version
```

Si no está instalado:
```bash
npm install -g firebase-tools
```

### 2. Login a Firebase (si no lo has hecho)

```bash
firebase login
```

### 3. Verificar el proyecto actual

```bash
firebase projects:list
```

Asegúrate de estar en el proyecto correcto. Si necesitas cambiar:
```bash
firebase use <project-id>
```

### 4. Desplegar SOLO las reglas de Firestore

```bash
firebase deploy --only firestore:rules
```

### 5. Verificar el despliegue

Después del despliegue, verás algo como:
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/tu-proyecto/overview
```

### 6. Probar en la app

1. Abre la app en tu dispositivo/emulador
2. Juega un arco completo
3. Verifica en los logs que NO aparezcan errores `PERMISSION_DENIED`
4. Verifica en Firebase Console que los datos se guardaron:
   - Ve a Firestore Database
   - Busca tu usuario en la colección `users`
   - Verifica que `arcProgress`, `inventory`, etc. se actualizaron

## 🔍 Verificación en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Firestore Database** → **Rules**
4. Verifica que las reglas nuevas estén activas
5. Revisa la pestaña **Usage** para ver si hay errores de permisos

## 📊 Cambios Específicos en las Reglas

### ANTES (Problema):
```javascript
allow write: if isOwner(userId) && validateUserData();

function validateUserData() {
  let data = request.resource.data;
  return data.keys().hasAll(['userId', 'email']) && // ❌ Requería TODOS los campos
         data.userId == userId &&
         isValidString(data.email);
}
```

### DESPUÉS (Solución):
```javascript
allow create: if isOwner(userId) && validateUserCreation();
allow update: if isOwner(userId) && validateUserUpdate();

function validateUserUpdate() {
  let data = request.resource.data;
  
  // Solo valida los campos que están siendo actualizados ✅
  let userIdValid = !data.keys().hasAny(['userId']) || data.userId == userId;
  let emailValid = !data.keys().hasAny(['email']) || isValidString(data.email);
  let inventoryValid = !data.keys().hasAny(['inventory']) || validateInventory(data.inventory);
  
  return userIdValid && emailValid && inventoryValid;
}
```

## 🧪 Testing

### Logs a buscar (ANTES del fix):
```
W/Firestore: Write failed at users/xxx: Status{code=PERMISSION_DENIED}
```

### Logs esperados (DESPUÉS del fix):
```
I/flutter: ✅ [UserDataProvider] Inventario guardado en Firebase
I/flutter: 📡 [UserDataProvider] Datos actualizados desde Firestore
```

## 🆘 Troubleshooting

### Error: "Permission denied"
- Verifica que las reglas se desplegaron correctamente
- Revisa en Firebase Console → Firestore → Rules
- Asegúrate de que el usuario está autenticado

### Error: "Firebase CLI not found"
```bash
npm install -g firebase-tools
firebase login
```

### Error: "No project active"
```bash
firebase use --add
# Selecciona tu proyecto de la lista
```

### Las reglas no se actualizan
1. Espera 1-2 minutos (puede tardar en propagarse)
2. Verifica en Firebase Console que las reglas nuevas estén activas
3. Cierra y vuelve a abrir la app

## 📝 Notas Importantes

- **Seguridad mantenida**: Las reglas siguen siendo seguras
  - Solo el dueño puede leer/escribir sus datos
  - Validación de tipos y límites sigue activa
  - No se permite acceso cross-user

- **Compatibilidad**: Las reglas son compatibles con el código existente
  - No requiere cambios en la app
  - Funciona con `SetOptions(merge: true)`

- **Rollback**: Si algo sale mal, puedes revertir desde Firebase Console
  - Ve a Firestore → Rules → History
  - Selecciona la versión anterior y restaura

## ✨ Resultado Esperado

Después del despliegue:
- ✅ El progreso de arcos se guarda correctamente
- ✅ Los fragmentos se desbloquean
- ✅ Los logros se registran
- ✅ El inventario se actualiza
- ✅ Las estadísticas se guardan
- ✅ No más errores `PERMISSION_DENIED` en los logs

---

**Fecha de fix**: 5 de diciembre de 2024
**Archivo modificado**: `firestore.rules`
**Comando de despliegue**: `firebase deploy --only firestore:rules`
