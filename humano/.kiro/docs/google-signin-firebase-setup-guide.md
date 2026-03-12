# Guía de Configuración de Firebase para Google Sign-In

## 🎯 Objetivo
Configurar Firebase Console para habilitar Google Sign-In en tu aplicación Flutter.

---

## 📋 Información Necesaria

### SHA-1 y SHA-256 (Ya obtenidos) ✅
```
SHA-1:   B4:E5:CA:B3:57:77:BD:9F:B7:43:87:23:60:57:AA:00:C7:E0:FB:2C
SHA-256: 41:4A:3B:8B:0E:87:96:14:62:1A:9D:01:42:DC:BC:83:3B:71:59:A0:81:5F:CD:96:76:C6:6C:C9:D1:BE:72:3F
```

---

## 🔥 Paso 1: Habilitar Google Sign-In en Firebase

1. **Ir a Firebase Console**:
   - Abrir: https://console.firebase.google.com/
   - Seleccionar tu proyecto

2. **Ir a Authentication**:
   - En el menú lateral izquierdo → Click "Authentication"
   - Si es la primera vez, click "Get started"

3. **Habilitar Google Sign-In**:
   - Click en la pestaña "Sign-in method"
   - Buscar "Google" en la lista de proveedores
   - Click en "Google"
   - Toggle "Enable" → ON
   - Agregar un "Project support email" (tu email)
   - Click "Save"

**✅ Resultado**: Google Sign-In ahora está habilitado

---

## 🔑 Paso 2: Agregar SHA-1 y SHA-256

1. **Ir a Project Settings**:
   - Click en el ícono de engranaje ⚙️ (arriba izquierda)
   - Click "Project settings"

2. **Seleccionar tu app Android**:
   - Scroll down hasta "Your apps"
   - Click en tu app Android (debería tener el ícono de Android)

3. **Agregar SHA-1**:
   - Scroll down hasta "SHA certificate fingerprints"
   - Click "Add fingerprint"
   - Pegar: `B4:E5:CA:B3:57:77:BD:9F:B7:43:87:23:60:57:AA:00:C7:E0:FB:2C`
   - Presionar Enter o click fuera del campo

4. **Agregar SHA-256**:
   - Click "Add fingerprint" nuevamente
   - Pegar: `41:4A:3B:8B:0E:87:96:14:62:1A:9D:01:42:DC:BC:83:3B:71:59:A0:81:5F:CD:96:76:C6:6C:C9:D1:BE:72:3F`
   - Presionar Enter o click fuera del campo

**✅ Resultado**: Los fingerprints están agregados

---

## 📥 Paso 3: Descargar google-services.json Actualizado

1. **En la misma página de Project Settings**:
   - Scroll hasta tu app Android
   - Click en "google-services.json" (botón de descarga)
   - Guardar el archivo

2. **Reemplazar el archivo en tu proyecto**:
   - Ir a: `C:\Users\acer\Caso2\humano\android\app\`
   - Reemplazar el archivo `google-services.json` existente con el nuevo

**✅ Resultado**: Configuración actualizada en tu proyecto

---

## 🧪 Paso 4: Probar la Implementación

1. **Limpiar y reconstruir**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Ejecutar la app**:
   ```bash
   flutter run
   ```

3. **Probar Google Sign-In**:
   - Abrir la app
   - Click en el botón "[ GOOGLE ]"
   - Debería abrir el selector de cuenta de Google
   - Seleccionar una cuenta
   - Debería autenticarse y navegar a MenuScreen

---

## ✅ Checklist de Configuración

- [ ] Google Sign-In habilitado en Firebase Console
- [ ] SHA-1 agregado en Firebase Console
- [ ] SHA-256 agregado en Firebase Console
- [ ] google-services.json descargado
- [ ] google-services.json reemplazado en `android/app/`
- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] App probada en dispositivo/emulador

---

## 🐛 Troubleshooting

### Error: "PlatformException(sign_in_failed)"

**Causa**: SHA-1/SHA-256 no agregados o google-services.json no actualizado

**Solución**:
1. Verificar que los fingerprints estén en Firebase Console
2. Descargar nuevo google-services.json
3. Reemplazar en `android/app/google-services.json`
4. `flutter clean && flutter run`

### Error: "Google Sign-In not configured"

**Causa**: No habilitado en Firebase Console

**Solución**:
1. Firebase Console → Authentication → Sign-in method
2. Enable Google
3. Agregar support email
4. Save

### Botón no responde

**Causa**: Configuración incompleta

**Solución**:
1. Verificar logs en consola
2. Verificar que todos los pasos anteriores estén completos
3. Reiniciar la app

---

## 📱 Información del Keystore

**Debug Keystore** (usado para desarrollo):
```
Location: C:\Users\acer\.android\debug.keystore
Alias: androiddebugkey
Password: android
```

**Certificado**:
```
Owner: C=US, O=Android, CN=Android Debug
Valid from: Tue Oct 14 19:06:42 CST 2025
Valid until: Thu Oct 07 19:06:42 CST 2055
```

---

## 🔗 Enlaces Útiles

- [Firebase Console](https://console.firebase.google.com/)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)

---

## 📝 Notas Importantes

1. **Debug vs Release**: Los SHA-1/SHA-256 mostrados son del keystore de DEBUG. Para producción, necesitarás generar y agregar los fingerprints del keystore de RELEASE.

2. **Múltiples Keystores**: Puedes agregar múltiples fingerprints en Firebase (debug, release, diferentes máquinas de desarrollo).

3. **Actualización Automática**: Una vez agregados los fingerprints, Firebase actualiza la configuración automáticamente. Solo necesitas descargar el nuevo google-services.json.

4. **Tiempo de Propagación**: Los cambios en Firebase Console pueden tardar unos minutos en propagarse. Si no funciona inmediatamente, espera 5-10 minutos.

---

## 🎉 ¡Listo!

Una vez completados todos los pasos, tu aplicación estará lista para usar Google Sign-In.

Los usuarios podrán:
- ✅ Click en "[ GOOGLE ]"
- ✅ Seleccionar su cuenta de Google
- ✅ Autenticarse sin crear contraseña
- ✅ Acceder al juego inmediatamente

**¡El sistema está listo para producción!** 🚀
