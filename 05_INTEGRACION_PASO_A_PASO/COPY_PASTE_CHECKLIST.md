# 📋 CHECKLIST DE COPIA-PASTE - QUÉ COPIAR Y DÓNDE

**Objetivo:** Saber exactamente dónde pegar cada archivo en tu proyecto  
**Tiempo:** 5 minutos  
**Resultado:** Todo integrado

---

## 📱 ESTRUCTURA TÍPICA DE PROYECTO FLUTTER

```
mi_app/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── portfolio/           ← AQUÍ VA EL CÓDIGO NEW
│   │   ├── ratings/             ← AQUÍ VA EL CÓDIGO NEW
│   │   ├── home_screen.dart
│   │   └── profile_screen.dart
│   ├── models/
│   ├── services/
│   ├── widgets/
│   └── utils/
├── assets/
├── pubspec.yaml                 ← EDITAR
├── android/
├── ios/
└── web/
```

---

## ✅ PASO 1: CREAR CARPETAS

```bash
# Terminal / PowerShell
cd ruta/a/tu/proyecto/mi_app

# Crear carpetas
mkdir -p lib/screens/portfolio
mkdir -p lib/screens/ratings
mkdir -p lib/services
```

---

## ✅ PASO 2: COPIAR CÓDIGO FLUTTER

### Archivo 1: portfolio_screen.dart

```
ORIGEN:  c:\Users\acer\3Warner\portfolio_screen.dart
DESTINO: lib/screens/portfolio/portfolio_screen.dart

CÓMO: 
1. Abre: c:\Users\acer\3Warner\portfolio_screen.dart
2. Copia: TODO el contenido (Ctrl+A, Ctrl+C)
3. Crea: lib/screens/portfolio/portfolio_screen.dart
4. Pega: Contenido (Ctrl+V)
```

### Archivo 2: upload_media_screen.dart

```
ORIGEN:  c:\Users\acer\3Warner\upload_media_screen.dart
DESTINO: lib/screens/portfolio/upload_media_screen.dart

CÓMO:
1. Abre: c:\Users\acer\3Warner\upload_media_screen.dart
2. Copia: TODO el contenido
3. Crea: lib/screens/portfolio/upload_media_screen.dart
4. Pega: Contenido
```

### Archivo 3: ratings_screen.dart

```
ORIGEN:  c:\Users\acer\3Warner\ratings_screen.dart
DESTINO: lib/screens/ratings/ratings_screen.dart

CÓMO:
1. Abre: c:\Users\acer\3Warner\ratings_screen.dart
2. Copia: TODO el contenido
3. Crea: lib/screens/ratings/ratings_screen.dart
4. Pega: Contenido
```

---

## ✅ PASO 3: ACTUALIZAR pubspec.yaml

```yaml
# Abre: pubspec.yaml

# Busca: dependencies:
dependencies:
  flutter:
    sdk: flutter

  # AÑADE ESTAS LÍNEAS:
  supabase_flutter: ^1.11.0
  image_picker: ^0.8.7
  video_player: ^2.7.0
  just_audio: ^0.9.34
  flutter_staggered_grid_view: ^0.6.2
  http: ^0.13.5

# El resto del archivo déjalo igual
```

---

## ✅ PASO 4: INSTALAR DEPENDENCIAS

```bash
# Terminal / PowerShell en carpeta del proyecto
flutter pub get

# Si hay errores:
flutter pub cache clean
flutter pub get
```

---

## ✅ PASO 5: VERIFICAR COMPILACIÓN

```bash
# Compilar sin errores
flutter analyze

# Debería mostrar: No issues found!
```

---

## ✅ PASO 6: AÑADIR IMPORTS EN TU PROFILE SCREEN

```dart
// lib/screens/profile/profile_screen.dart (TU ARCHIVO)

// Añade al inicio:
import 'package:mi_app/screens/portfolio/portfolio_screen.dart';
import 'package:mi_app/screens/portfolio/upload_media_screen.dart';
import 'package:mi_app/screens/ratings/ratings_screen.dart';

// En tu widget de perfil, añade botones:
ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PortfolioScreen(userId: userId),
      ),
    );
  },
  child: const Text('Ver Portfolio'),
),

ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RatingsScreen(
          userId: userId,
          isOwnProfile: true,
        ),
      ),
    );
  },
  child: const Text('Ver Calificaciones'),
),
```

---

## ✅ PASO 7: CONFIGURACIÓN NECESARIA

### lib/main.dart - Verificar Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://your-supabase-url.supabase.co',
    anonKey: 'your-supabase-anon-key',
  );

  runApp(const MyApp());
}
```

### AndroidManifest.xml - Permisos (Android)

```xml
<!-- android/app/src/main/AndroidManifest.xml -->

<!-- Añade dentro de <manifest>: -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### Info.plist - Permisos (iOS)

```xml
<!-- ios/Runner/Info.plist -->

<!-- Añade dentro de <dict>: -->
<key>NSPhotoLibraryUsageDescription</key>
<string>La app necesita acceso a tu galería para subir fotos</string>

<key>NSCameraUsageDescription</key>
<string>La app necesita acceso a tu cámara para capturar fotos</string>

<key>NSMicrophoneUsageDescription</key>
<string>La app necesita acceso al micrófono para grabar audio</string>
```

---

## 🔌 CÓDIGO BACKEND

### Node.js/Express - Copiar endpoints

```
ORIGEN:  c:\Users\acer\3Warner\ENDPOINTS_FASE_1_2.js
DESTINO: src/routes/portfolio-ratings-api.js

CÓMO:
1. Abre: ENDPOINTS_FASE_1_2.js
2. Copia: TODO el código de rutas
3. En tu proyecto, crea: src/routes/portfolio-ratings-api.js
4. Pega: Código

5. En src/app.js o index.js, añade:
   const portfolioRoutes = require('./routes/portfolio-ratings-api.js');
   app.use('/api', portfolioRoutes);
```

---

## 📚 DOCUMENTACIÓN - REFERENCIA

```
Copiar a tu proyecto (para referencia):
├── PLAN_IMPLEMENTACION_MEJORAS_OOLALE.md    (docs/)
├── INTEGRACION_MERCADO_PAGO_COMPLETA.md     (docs/)
├── ENDPOINTS_FASE_1_2.js                    (backend/)
├── PROJECT_STATUS.md                        (docs/)
└── QUICK_START_30_MIN.md                    (docs/)
```

---

## ✅ TEST FINAL

```bash
# 1. Terminal
flutter run

# 2. En la app:
- Navega a Portfolio
- Debe mostrar pantalla vacía + botón "Subir"
- Tap en "Subir" → debe abrir dialog
- Navega a Calificaciones
- Debe mostrar "Sin calificaciones" + botón
- Tap en botón → debe mostrar star selector

# 3. Resultado:
✅ Todo funciona = Integración exitosa
❌ Errores = Revisar imports y dependencias
```

---

## 📁 ARCHIVO-POR-ARCHIVO CHECKLIST

### Flutter Code

- [ ] Copié: `portfolio_screen.dart` → `lib/screens/portfolio/portfolio_screen.dart`
- [ ] Copié: `upload_media_screen.dart` → `lib/screens/portfolio/upload_media_screen.dart`
- [ ] Copié: `ratings_screen.dart` → `lib/screens/ratings/ratings_screen.dart`
- [ ] Traté imports correctamente (package:mi_app/screens/...)
- [ ] Ejecuté: `flutter pub get`
- [ ] Verificué: `flutter analyze` (sin errores)

### Dependencias

- [ ] Añadí a `pubspec.yaml`: supabase_flutter, image_picker, video_player, just_audio, flutter_staggered_grid_view, http
- [ ] Ejecuté: `flutter pub get`
- [ ] Verificué versiones compatibles

### Configuración

- [ ] Verificué Supabase inicializado en `main.dart`
- [ ] Añadí permisos Android (AndroidManifest.xml)
- [ ] Añadí permisos iOS (Info.plist)
- [ ] Configuré Supabase URL y anon key

### Backend

- [ ] Copié endpoints a `src/routes/`
- [ ] Integré rutas en `app.js`
- [ ] Configuré variables de entorno
- [ ] Testeé endpoints con Postman

### Testing

- [ ] `flutter run` compila sin errores
- [ ] Botones de Portfolio y Ratings visible
- [ ] Navegación funciona
- [ ] No hay crashes

---

## 🎯 SI ALGO NO FUNCIONA

### Error: "Could not resolve dependency"

```bash
# Solución:
flutter pub cache clean
flutter pub get
flutter clean
flutter run
```

### Error: "Cannot find package 'mi_app'"

```dart
// En los archivos .dart, reemplaza:
import 'package:mi_app/    ← Reemplaza 'mi_app' con tu package name

// Para saber tu package name:
// grep -r "io.flutter.embedding.android.FlutterActivity" android/app/src/main/
// android/app/src/main/AndroidManifest.xml, busca: android:package="com...."
```

### Error: "image_picker not working"

```
Android: Verificar permisos en AndroidManifest.xml
iOS: Verificar permisos en Info.plist
Emulator: Permitir acceso a galería en settings
```

### Error: "Supabase not initialized"

```dart
// Asegurar en main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  ← IMPORTANTE
  await Supabase.initialize(url: '...', anonKey: '...');
  runApp(const MyApp());
}
```

---

## 📞 CONTACTO SI NECESITAS AYUDA

1. **Error de compilación?**
   → Lee: QUICK_START_30_MIN.md (Sección: Errores Comunes)

2. **Cómo funcionan los componentes?**
   → Lee comentarios en: portfolio_screen.dart / ratings_screen.dart

3. **Cómo integrar backend?**
   → Lee: ENDPOINTS_FASE_1_2.js (comentarios al inicio)

4. **Cómo se guarda la data?**
   → Lee: PLAN_IMPLEMENTACION_MEJORAS_OOLALE.md (Sección: Queries SQL)

---

## ✨ DESPUÉS DE INTEGRACIÓN EXITOSA

1. **Backend integration**
   - Copiar endpoints
   - Configurar API calls

2. **Supabase Storage**
   - Crear bucket 'media'
   - Configurar RLS

3. **Testing**
   - QA en device real
   - Testing de upload

4. **Deployment**
   - Push a staging
   - QA testing
   - Deploy a producción

---

**Tiempo estimado:** 30 minutos (si todo va bien)  
**Complejidad:** Intermediate  
**Resultado:** App con Portfolio y Ratings funcionales

---

*Guía de Copy-Paste - Óolale Mobile Project*  
*Última actualización: 22/01/2026*
