# ⚡ Google Sign-In - Guía Rápida (1 Página)

## 🎯 Objetivo: Configurar Google Sign-In en 15 minutos

---

## 📋 Antes de Empezar

### Copia estos valores (los necesitarás):

```
SHA-1:   B4:E5:CA:B3:57:77:BD:9F:B7:43:87:23:60:57:AA:00:C7:E0:FB:2C
SHA-256: 41:4A:3B:8B:0E:87:96:14:62:1A:9D:01:42:DC:BC:83:3B:71:59:A0:81:5F:CD:96:76:C6:6C:C9:D1:BE:72:3F
```

---

## 🔥 PASO 1: Habilitar Google Sign-In (3 min)

1. Abre: https://console.firebase.google.com/
2. Selecciona tu proyecto
3. **Authentication** → **Sign-in method**
4. Click en **"Google"**
5. Toggle **"Enable"** → ON
6. Selecciona tu **email** en "Project support email"
7. Click **"Save"**

✅ **Resultado**: Google habilitado

---

## 🔑 PASO 2: Agregar SHA Fingerprints (3 min)

1. Click en **⚙️** (arriba izquierda) → **"Project settings"**
2. Scroll down → **"Your apps"** → Tu app Android
3. Scroll down → **"SHA certificate fingerprints"**
4. Click **"Add fingerprint"**
5. Pega: `B4:E5:CA:B3:57:77:BD:9F:B7:43:87:23:60:57:AA:00:C7:E0:FB:2C`
6. Presiona **Enter**
7. Click **"Add fingerprint"** nuevamente
8. Pega: `41:4A:3B:8B:0E:87:96:14:62:1A:9D:01:42:DC:BC:83:3B:71:59:A0:81:5F:CD:96:76:C6:6C:C9:D1:BE:72:3F`
9. Presiona **Enter**

✅ **Resultado**: Ambos SHA agregados

---

## 📥 PASO 3: Actualizar google-services.json (2 min)

1. En la misma página, click **"google-services.json"**
2. El archivo se descarga
3. Abre: `C:\Users\acer\Caso2\humano\android\app\`
4. **Elimina** el `google-services.json` viejo
5. **Copia** el nuevo archivo ahí

✅ **Resultado**: Archivo actualizado

---

## 🧹 PASO 4: Limpiar y Ejecutar (3 min)

Abre PowerShell y ejecuta:

```powershell
cd C:\Users\acer\Caso2\humano
flutter clean
flutter pub get
flutter run
```

✅ **Resultado**: App ejecutándose

---

## 🧪 PASO 5: Probar (1 min)

1. En la app, click **"[ GOOGLE ]"** (botón azul)
2. Selecciona tu cuenta de Google
3. Deberías ver el **MenuScreen**

✅ **Resultado**: ¡Funciona!

---

## 🐛 Si no funciona:

### Error: "sign_in_failed"
- Verifica que ambos SHA estén en Firebase
- Descarga nuevo google-services.json
- `flutter clean && flutter run`

### Botón no aparece
- `flutter clean && flutter pub get && flutter run`

### Selector no se abre
- Actualiza Google Play Services en tu dispositivo

---

## 📞 Más Ayuda

Para instrucciones detalladas:
👉 **GUIA-DETALLADA-FIREBASE-GOOGLE-SIGNIN.md**

---

## ✅ Checklist

- [ ] Google habilitado en Firebase
- [ ] SHA-1 agregado
- [ ] SHA-256 agregado
- [ ] google-services.json actualizado
- [ ] flutter clean ejecutado
- [ ] flutter pub get ejecutado
- [ ] App probada
- [ ] ✅ Funciona!

---

## 🎉 ¡Listo!

**Tiempo total**: 10-15 minutos

**¡El sistema está listo para producción!** 🚀

---

**Fecha**: 24 de noviembre de 2025 | **Versión**: 1.0.0
