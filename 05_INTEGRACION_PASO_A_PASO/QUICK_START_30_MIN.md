# ⚡ QUICK START - INTEGRACIÓN EN 30 MINUTOS

**Objetivo:** Tener código compilando con Portfolio y Ratings en 30 minutos  
**Nivel:** Intermediate Flutter Developer  
**Prerrequisitos:** Flutter 3.0+, Supabase account, Visual Studio Code

---

## 🟢 PASO 1: PREPARAR ESTRUCTURA (5 minutos)

```bash
# 1. Crear carpetas si no existen
mkdir -p lib/screens/portfolio
mkdir -p lib/screens/ratings
mkdir -p lib/services

# 2. Verificar pubspec.yaml tiene:
flutter pub add supabase_flutter
flutter pub add image_picker
flutter pub add video_player
flutter pub add just_audio
flutter pub add flutter_staggered_grid_view
flutter pub add http

# 3. Descargar archivos generados
# - portfolio_screen.dart → lib/screens/portfolio/
# - upload_media_screen.dart → lib/screens/portfolio/
# - ratings_screen.dart → lib/screens/ratings/
```

---

## 🔵 PASO 2: COPIAR CÓDIGO FLUTTER (10 minutos)

### Portfolio Screen
```bash
# En lib/screens/portfolio/portfolio_screen.dart
# Copiar contenido completo de: portfolio_screen.dart

# Archivos necesarios en la misma carpeta:
# - upload_media_screen.dart
# - media_card.dart (incluido en portfolio_screen.dart)
```

**Imports automáticos que Flutter añadirá:**
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
```

### Ratings Screen
```bash
# En lib/screens/ratings/ratings_screen.dart
# Copiar contenido completo de: ratings_screen.dart

# Todo está incluido en 1 archivo:
# - RatingsScreen (pantalla principal)
# - LeaveRatingScreen (formulario)
# - Models (Calificacion, Reputacion, etc)
```

---

## 🟡 PASO 3: INTEGRAR EN MAIN APP (5 minutos)

### Opción A: Add botones en profile screen

```dart
// lib/screens/profile/profile_screen.dart (TU CÓDIGO)

import 'package:tuapp/screens/portfolio/portfolio_screen.dart';
import 'package:tuapp/screens/ratings/ratings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tu código existente...
            
            // NUEVO: Botones para Portfolio y Ratings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Opción B: Add tabs en tabBar

```dart
// Si usas TabBar, añade tabs:
TabBar(
  tabs: [
    const Tab(icon: Icon(Icons.person), text: 'Perfil'),
    const Tab(icon: Icon(Icons.collections), text: 'Portfolio'),
    const Tab(icon: Icon(Icons.star), text: 'Calificaciones'),
  ],
)

// En TabBarView:
TabBarView(
  children: [
    YourProfileWidget(),
    PortfolioScreen(userId: userId),
    RatingsScreen(userId: userId),
  ],
)
```

---

## 🟣 PASO 4: VERIFICAR COMPILACIÓN (5 minutos)

```bash
# 1. Limpiar proyecto
flutter clean

# 2. Obtener dependencias
flutter pub get

# 3. Verificar errores de import
flutter pub outdated

# 4. Compilar (verificar errores)
flutter pub global run pana lib/screens/portfolio/portfolio_screen.dart
flutter pub global run pana lib/screens/ratings/ratings_screen.dart

# 5. Run en emulator
flutter run
```

---

## 🟠 PASO 5: VERIFICAR EN DEVICE (5 minutos)

### Checklist

```
✅ App compila sin errores
✅ Portfolio screen abre
✅ Portfolio upload button funciona
✅ Ratings screen abre
✅ Star selector responde al tap
✅ No hay crashes
✅ UI se ve bien en dispositivo
```

### Test manual

```
1. Abre Portfolio
   → Debe mostrar grid vacío si no hay media
   → Botón "Subir" debe estar visible

2. Tap en Subir
   → Debe abrir dialog de selección
   → Poder seleccionar tipo (video/audio/imagen)

3. Abre Ratings
   → Debe mostrar "Sin calificaciones aún"
   → Botón "Dejar calificación" debe estar visible

4. Tap en "Dejar calificación"
   → Debe mostrar star selector
   → Poder seleccionar 1-5 estrellas
   → Poder escribir comentario

5. No hay crashes
   → Presiona back múltiples veces
   → Cambia de pantalla rápido
   → Verifica que no haya errores rojos
```

---

## 📋 CHECKLIST RÁPIDO (TODO EN 30 MIN)

- [ ] Minute 0-5: `flutter pub add` todas las dependencias
- [ ] Minute 5-10: Copiar `portfolio_screen.dart` → `lib/screens/portfolio/`
- [ ] Minute 10-15: Copiar `ratings_screen.dart` → `lib/screens/ratings/`
- [ ] Minute 15-20: Copiar `upload_media_screen.dart` → `lib/screens/portfolio/`
- [ ] Minute 20-25: Integrar botones en tu profile screen
- [ ] Minute 25-30: `flutter run` y verificar que compila

---

## ⚠️ ERRORES COMUNES Y SOLUCIONES

### Error 1: "Cannot find package"
```dart
// ❌ Error: import error
import 'package:portfolio_screen.dart';

// ✅ Solución:
import 'package:tuapp/screens/portfolio/portfolio_screen.dart';
// Reemplaza 'tuapp' con el nombre de tu proyecto
```

### Error 2: "RenderBox was not laid out"
```dart
// Causa: Grid sin dimensiones
// ✅ Solución: Envolver en Expanded/SizedBox
Expanded(
  child: MasonryGridView.count(
    crossAxisCount: 2,
    // ...
  ),
)
```

### Error 3: "Null safety error"
```dart
// ❌ Error: null checking
data['field']

// ✅ Solución:
data['field'] ?? 'default'
```

### Error 4: "image_picker not finding picker"
```bash
# Solución: Permisos en AndroidManifest.xml (Android)
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

# Info.plist (iOS)
<key>NSPhotoLibraryUsageDescription</key>
<string>App necesita acceso a tu galería</string>
```

---

## 🔧 CONFIGURACIÓN NECESARIA

### lib/main.dart - Asegúrate que tengas

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://your-supabase-url.supabase.co',
    anonKey: 'your-anon-key',
  );

  runApp(const MyApp());
}
```

### .env file (si usas flutter_dotenv)

```env
SUPABASE_URL=https://your-supabase-url.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
```

---

## 📱 RESPONSIVE DESIGN

Los componentes están diseñados para:
- ✅ Mobile portrait (375 width)
- ✅ Mobile landscape
- ✅ Tablet (600+ width)
- ✅ Dark theme (aplicación por defecto)

**Para cambiar colores:**

```dart
// En portfolio_screen.dart y ratings_screen.dart
// Busca: Colors.deepOrangeAccent

// Reemplaza con tu color:
Colors.blueAccent
Colors.purpleAccent
Colors.tealAccent
// etc
```

---

## 🚀 NEXT STEPS - DESPUÉS DE COMPILAR

### Si todo funciona ✅

1. **Backend integration** (siguiente paso)
   - Copiar endpoints de `ENDPOINTS_FASE_1_2.js`
   - Configurar API calls en app

2. **Supabase Storage**
   - Crear bucket 'media'
   - Configurar RLS policies
   - Set CORS headers

3. **Testing**
   - Usar device real
   - Probar upload de video
   - Probar calificaciones

### Si hay errores ❌

1. Verifica que todas las dependencias estén instaladas: `flutter pub get`
2. Limpia proyecto: `flutter clean`
3. Revisa que nombres de paquete sean correctos en imports
4. Verifica que Supabase está inicializado en main.dart

---

## 📞 TROUBLESHOOTING

| Problema | Solución |
|----------|----------|
| "Failed to load dynamic library" | Ejecutar `flutter pub get` nuevamente |
| "Unhandled Exception: PlatformException" | Verificar permisos en manifest/plist |
| UI lenta | Usar `const` en widgets que no cambian |
| Upload lento | Reducir tamaño video o usar compresión |
| Crash al abrir gallery | Revisar permisos de acceso |

---

## ✅ VALIDACIÓN FINAL

Cuando todo funcione:

```
✅ App compila: flutter run ejecuta sin error
✅ Portfolio: Pantalla abre, botones responden
✅ Upload: Dialog sale cuando taps "Subir"
✅ Ratings: Pantalla abre, star selector funciona
✅ No crashes: App es estable
✅ UI bonita: Se ve profesional en device
✅ Performance: No freezes o lags
```

**Si todo esto está ✅ = LISTO para siguiente fase**

---

## 📊 TIMELINE REALISTA

```
Si tienes experiencia con Flutter:
├─ Setup (pubspec, carpetas)       → 5 min
├─ Copiar código                    → 10 min
├─ Integración                      → 10 min
├─ Fix errores menores              → 10 min
└─ Verificación en device           → 5 min
   TOTAL: 40 minutos ✅

Si NO tienes experiencia:
├─ Setup                            → 15 min
├─ Copiar y entender código         → 20 min
├─ Integración                      → 20 min
├─ Fix errores                      → 20 min
└─ Testing                          → 10 min
   TOTAL: 85 minutos ⏳
```

---

## 🎯 OBJETIVO FINAL

En 30 minutos deberías tener:

```
✅ Portfolio Screen compilando
✅ Upload Screen compilando  
✅ Ratings Screen compilando
✅ Navegación entre pantallas
✅ UI visible en device
✅ Ready para conectar backend
```

**Luego:** Implementar backend + API calls = Next 2-3 horas

---

**¿Necesitas más detalles de algún paso específico? Responder en próxima sesión.**

---

*Quick Start Guide - Óolale Mobile*  
*Última actualización: 22/01/2026*
