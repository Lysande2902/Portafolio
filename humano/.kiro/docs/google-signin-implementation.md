# Implementación de Google Sign-In

## Fecha
21 de noviembre de 2025

## ✅ Dependencias Instaladas

Ya se agregó e instaló:
```yaml
google_sign_in: ^6.2.1
```

## ✅ Código Backend Actualizado

### 1. AuthRepository ✅
Ya se agregó el método `signInWithGoogle()`

### 2. FirebaseAuthRepository ✅
Ya se implementó la lógica completa de Google Sign-In

### 3. AuthProvider ✅
Ya se agregó el método `signInWithGoogle()`

---

## 📝 Código para Agregar al AuthScreen

### Paso 1: Agregar método en `_AuthScreenState`

Agrega este método después del método `_authenticate()`:

```dart
Future<void> _authenticateWithGoogle() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  debugPrint('🔐 Attempting Google Sign-In...');

  bool success = await authProvider.signInWithGoogle();

  debugPrint('🔐 Google Sign-In response: success=$success, error=${authProvider.errorMessage}');

  if (!success && authProvider.errorMessage != null) {
    _showErrorNotification(authProvider.errorMessage!);
    authProvider.clearError();
  } else if (success) {
    debugPrint('🔐 Google authentication successful! Navigating to MenuScreen...');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MenuScreen()),
      );
    }
  }
}
```

### Paso 2: Agregar botón de Google

Busca en `auth_screen.dart` donde está el `Wrap` con los botones (alrededor de la línea 550-600).

Encontrarás algo como:
```dart
Wrap(
  spacing: 15,
  runSpacing: 10,
  alignment: WrapAlignment.center,
  children: [
    ElevatedButton(
      onPressed: () {
        debugPrint('🔘 Button clicked!');
        _authenticate();
      },
      // ... resto del botón ACCEDER/REGISTRAR
    ),
    TextButton(
      onPressed: _switchAuthMode,
      // ... resto del botón de cambio de modo
    ),
  ],
),
```

**AGREGA** este botón de Google **DESPUÉS** del botón de ACCEDER/REGISTRAR y **ANTES** del TextButton:

```dart
// Botón de Google Sign-In
ElevatedButton.icon(
  onPressed: () {
    debugPrint('🔘 Google Sign-In button clicked!');
    _authenticateWithGoogle();
  },
  icon: Icon(
    Icons.g_mobiledata,
    color: Colors.white,
    size: 28,
  ),
  label: Text(
    '[ GOOGLE ]',
    style: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontFamily: 'monospace',
      letterSpacing: 2,
      fontWeight: FontWeight.bold,
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF4285F4), // Google Blue
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
      side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
    ),
    elevation: 0,
  ),
),
```

---

## 🔧 Configuración de Firebase (IMPORTANTE)

### Android

1. **Descarga el archivo `google-services.json` actualizado** desde Firebase Console:
   - Ve a Firebase Console → Tu proyecto
   - Project Settings → General
   - Scroll down hasta "Your apps"
   - Click en tu app Android
   - Click "Download google-services.json"

2. **Reemplaza** el archivo en:
   ```
   android/app/google-services.json
   ```

3. **Verifica** que el `build.gradle` tenga:
   ```gradle
   // android/build.gradle.kts
   dependencies {
       classpath("com.google.gms:google-services:4.4.0")
   }
   
   // android/app/build.gradle.kts
   plugins {
       id("com.google.gms.google-services")
   }
   ```

### iOS (Si aplica)

1. **Descarga el archivo `GoogleService-Info.plist`** desde Firebase Console

2. **Agrega** el archivo a:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

3. **Actualiza** `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

### Firebase Console

1. **Habilita Google Sign-In** en Firebase:
   - Firebase Console → Authentication
   - Sign-in method tab
   - Click en "Google"
   - Enable
   - Agrega tu email de soporte
   - Save

2. **Agrega SHA-1 y SHA-256** de tu app (Android):
   ```bash
   cd android
   ./gradlew signingReport
   ```
   
   Copia los SHA-1 y SHA-256 y agrégalos en:
   - Firebase Console → Project Settings → Your apps → Android app
   - Click "Add fingerprint"

---

## 🎨 Resultado Visual

El botón de Google aparecerá así:

```
┌─────────────────────────────────────────┐
│  [ ACCEDER ]  [ GOOGLE ]                │
│                                         │
│  > No estás registrado...               │
└─────────────────────────────────────────┘
```

Con estilo:
- Fondo azul de Google (#4285F4)
- Icono de Google (G)
- Texto blanco en monospace
- Borde sutil blanco

---

## 🧪 Pruebas

### 1. Compilar y Ejecutar
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Probar Google Sign-In
1. Click en botón "[ GOOGLE ]"
2. Selecciona cuenta de Google
3. Autoriza la app
4. Debe navegar a MenuScreen

### 3. Verificar Logs
```
🔐 Attempting Google Sign-In...
🔐 Google Sign-In response: success=true
🔐 Google authentication successful! Navigating to MenuScreen...
```

---

## 🐛 Troubleshooting

### Error: "PlatformException(sign_in_failed)"

**Causa**: SHA-1/SHA-256 no configurados o `google-services.json` desactualizado

**Solución**:
1. Genera SHA-1: `cd android && ./gradlew signingReport`
2. Agrega SHA-1 en Firebase Console
3. Descarga nuevo `google-services.json`
4. Reemplaza el archivo
5. `flutter clean && flutter run`

### Error: "ERROR_ABORTED_BY_USER"

**Causa**: Usuario canceló el sign-in

**Solución**: Normal, no es un error real

### Error: "Google Sign-In not configured"

**Causa**: Google Sign-In no habilitado en Firebase

**Solución**:
1. Firebase Console → Authentication → Sign-in method
2. Enable Google
3. Save

---

## ✅ Checklist de Implementación

### Código
- [x] Dependencia `google_sign_in` agregada
- [x] `AuthRepository` actualizado
- [x] `FirebaseAuthRepository` implementado
- [x] `AuthProvider` actualizado
- [ ] Método `_authenticateWithGoogle()` agregado a `AuthScreen`
- [ ] Botón de Google agregado al UI

### Configuración Firebase
- [ ] Google Sign-In habilitado en Firebase Console
- [ ] `google-services.json` actualizado (Android)
- [ ] SHA-1 y SHA-256 agregados (Android)
- [ ] `GoogleService-Info.plist` agregado (iOS, si aplica)

### Testing
- [ ] App compila sin errores
- [ ] Botón de Google visible
- [ ] Click en botón abre selector de cuenta
- [ ] Login exitoso navega a MenuScreen
- [ ] Logout funciona correctamente

---

## 📝 Notas Adicionales

### Modo de Autenticación

El botón de Google funciona en **ambos modos** (Login y SignUp):
- Si el usuario no existe, se crea automáticamente
- Si el usuario ya existe, inicia sesión
- No necesitas cambiar entre modos

### Seguridad

- Google Sign-In es más seguro que email/password
- No necesitas manejar contraseñas
- Google maneja la autenticación 2FA
- Token de acceso se renueva automáticamente

### UX

- El botón es prominente y fácil de identificar
- Color azul de Google es reconocible
- Proceso es más rápido que email/password
- Menos fricción para el usuario

---

## 🚀 Próximos Pasos

1. Agrega el método `_authenticateWithGoogle()` al `AuthScreen`
2. Agrega el botón de Google al UI
3. Configura Firebase Console
4. Actualiza `google-services.json`
5. Agrega SHA-1/SHA-256
6. Prueba en dispositivo real

**¡El sistema está listo para Google Sign-In!** 🎉
