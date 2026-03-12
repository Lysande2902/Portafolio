# Instrucciones para Configurar el Ícono de la App

## Cambios Realizados

Se ha configurado el ícono del juego (`assets/icon/logo_cond.png`) para reemplazar el ícono predeterminado de Flutter.

## Pasos para Aplicar el Ícono

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Generar los Íconos
```bash
flutter pub run flutter_launcher_icons
```

Este comando generará automáticamente los íconos para:
- ✅ Android (todos los tamaños)
- ✅ iOS (todos los tamaños)
- ✅ Adaptive icons para Android (con fondo negro)

### 3. Verificar los Cambios

Después de ejecutar el comando, verás que se generan archivos en:
- `android/app/src/main/res/` (múltiples carpetas mipmap)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 4. Reconstruir la App

```bash
flutter clean
flutter build apk  # Para Android
# o
flutter build ios  # Para iOS
```

## Configuración Aplicada

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/logo_cond.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/icon/logo_cond.png"
```

- **image_path**: Ruta al logo del juego
- **adaptive_icon_background**: Fondo negro para Android adaptive icons
- **adaptive_icon_foreground**: El logo como foreground

## Notas

- El ícono debe ser PNG de al menos 1024x1024 píxeles para mejores resultados
- Los íconos se generan automáticamente en todos los tamaños necesarios
- El fondo negro (#000000) se usa para los adaptive icons de Android
