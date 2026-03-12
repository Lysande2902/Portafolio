# Guía de Configuración de Assets del Sistema de Rompecabezas

## Fecha
21 de noviembre de 2025

## Estructura de Carpetas

Debes crear las siguientes carpetas y colocar los archivos correspondientes:

```
assets/
├── evidences/              # Imágenes completas de evidencias
│   ├── arc1_complete.png   # Arco 1: Gula - Mateo
│   ├── arc2_complete.png   # Arco 2: Avaricia - Valeria
│   └── arc3_complete.png   # Arco 3: Envidia - Lucía
│
└── sounds/
    └── puzzle/             # Efectos de sonido del rompecabezas
        ├── pickup.mp3      # Levantar fragmento
        ├── snap.mp3        # Colocar correctamente
        ├── error.mp3       # Colocar incorrectamente
        ├── completion.mp3  # Completar puzzle
        ├── proximity.mp3   # Acercarse a posición correcta
        └── rotate.mp3      # Rotar fragmento
```

---

## 📋 Checklist de Instalación

### 1. Crear Carpetas

```bash
# Desde la raíz del proyecto
mkdir -p assets/evidences
mkdir -p assets/sounds/puzzle
```

### 2. Copiar Imágenes de Evidencias

Coloca tus 3 imágenes PNG en `assets/evidences/`:

- ✅ **arc1_complete.png** (600x400px) - Video viral de Mateo
- ✅ **arc2_complete.png** (600x400px) - Doxeo de Valeria  
- ✅ **arc3_complete.png** (600x400px) - Comparación de Lucía

**Comando (Windows)**:
```cmd
copy "ruta\a\tus\imagenes\arc1_complete.png" "assets\evidences\"
copy "ruta\a\tus\imagenes\arc2_complete.png" "assets\evidences\"
copy "ruta\a\tus\imagenes\arc3_complete.png" "assets\evidences\"
```

### 3. Copiar Efectos de Sonido

Coloca tus 6 archivos MP3 en `assets/sounds/puzzle/`:

- ✅ **pickup.mp3** (~0.3s) - Sonido al levantar fragmento
- ✅ **snap.mp3** (~0.5s) - Sonido al colocar correctamente
- ✅ **error.mp3** (~0.4s) - Sonido de error
- ✅ **completion.mp3** (~2.0s) - Sonido de victoria
- ✅ **proximity.mp3** (~0.3s) - Sonido de proximidad
- ✅ **rotate.mp3** (~0.2s) - Sonido de rotación

**Comando (Windows)**:
```cmd
copy "ruta\a\tus\sonidos\pickup.mp3" "assets\sounds\puzzle\"
copy "ruta\a\tus\sonidos\snap.mp3" "assets\sounds\puzzle\"
copy "ruta\a\tus\sonidos\error.mp3" "assets\sounds\puzzle\"
copy "ruta\a\tus\sonidos\completion.mp3" "assets\sounds\puzzle\"
copy "ruta\a\tus\sonidos\proximity.mp3" "assets\sounds\puzzle\"
copy "ruta\a\tus\sonidos\rotate.mp3" "assets\sounds\puzzle\"
```

### 4. Verificar Instalación

Ejecuta este comando para verificar que los archivos están en su lugar:

```bash
# Windows
dir assets\evidences
dir assets\sounds\puzzle

# Deberías ver:
# assets/evidences: 3 archivos PNG
# assets/sounds/puzzle: 6 archivos MP3
```

### 5. Actualizar Dependencias

```bash
flutter pub get
```

### 6. Probar

```bash
flutter run
```

---

## 🎨 Especificaciones de Imágenes

### Arco 1: Gula - Mateo
**Archivo**: `arc1_complete.png`
**Tamaño**: 600x400 píxeles
**Formato**: PNG con transparencia opcional
**Contenido**:
- Screenshot de video viral estilo TikTok/Instagram
- Mateo comiendo de contenedor de basura
- Contador de vistas: 2.3M
- Comentarios crueles visibles
- Interfaz de red social

### Arco 2: Avaricia - Valeria
**Archivo**: `arc2_complete.png`
**Tamaño**: 600x400 píxeles
**Formato**: PNG con transparencia opcional
**Contenido**:
- Foto de Valeria en banco
- Información personal expuesta (número cuenta, dirección)
- Datos de hijos visibles
- Contador: 89K likes
- Estilo: Collage de información doxxeada

### Arco 3: Envidia - Lucía
**Archivo**: `arc3_complete.png`
**Tamaño**: 600x400 píxeles
**Formato**: PNG con transparencia opcional
**Contenido**:
- Comparación "Antes vs Después"
- Foto joven vs foto actual
- Comentarios de odio
- Contador: 156K shares
- Estilo: Meme de comparación cruel

---

## 🔊 Especificaciones de Sonidos

### pickup.mp3
- **Duración**: ~0.3 segundos
- **Tipo**: Pop suave, swoosh ligero
- **Volumen en código**: 50%
- **Cuándo se usa**: Al levantar un fragmento

### snap.mp3
- **Duración**: ~0.5 segundos
- **Tipo**: Click firme, snap mecánico
- **Volumen en código**: 70%
- **Cuándo se usa**: Al colocar fragmento correctamente

### error.mp3
- **Duración**: ~0.4 segundos
- **Tipo**: Buzz corto, boop negativo
- **Volumen en código**: 60%
- **Cuándo se usa**: Al colocar fragmento incorrectamente

### completion.mp3
- **Duración**: ~2.0 segundos
- **Tipo**: Fanfarria, acordes ascendentes, "Ta-da!"
- **Volumen en código**: 80%
- **Cuándo se usa**: Al completar el puzzle

### proximity.mp3
- **Duración**: ~0.3 segundos
- **Tipo**: Ding suave, tono corto
- **Volumen en código**: 30%
- **Cuándo se usa**: Al acercarse a posición correcta

### rotate.mp3
- **Duración**: ~0.2 segundos
- **Tipo**: Swish corto, click de rotación
- **Volumen en código**: 40%
- **Cuándo se usa**: Al rotar un fragmento

---

## ✅ Verificación Final

Después de copiar todos los archivos, verifica que:

1. ✅ Existen 3 archivos PNG en `assets/evidences/`
2. ✅ Existen 6 archivos MP3 en `assets/sounds/puzzle/`
3. ✅ Los nombres de archivo coinciden exactamente (case-sensitive)
4. ✅ `pubspec.yaml` incluye las rutas de assets
5. ✅ Ejecutaste `flutter pub get`

---

## 🐛 Troubleshooting

### Problema: "Unable to load asset"

**Solución**:
1. Verifica que los nombres de archivo sean exactos
2. Ejecuta `flutter clean`
3. Ejecuta `flutter pub get`
4. Vuelve a ejecutar la app

### Problema: "File not found"

**Solución**:
1. Verifica la ruta completa: `assets/evidences/arc1_complete.png`
2. Asegúrate de que no haya espacios en los nombres
3. Verifica que las extensiones sean correctas (.png, .mp3)

### Problema: Sonidos no se reproducen

**Solución**:
1. Verifica que los archivos MP3 sean válidos
2. Prueba con volumen del dispositivo al máximo
3. Verifica permisos de audio en el dispositivo

---

## 📝 Notas Adicionales

### Optimización de Imágenes

Si las imágenes son muy pesadas, puedes optimizarlas:

```bash
# Usando ImageMagick (opcional)
magick convert arc1_complete.png -quality 85 -resize 600x400 arc1_complete.png
```

### Optimización de Sonidos

Si los sonidos son muy pesados, puedes optimizarlos:

```bash
# Usando FFmpeg (opcional)
ffmpeg -i pickup.mp3 -b:a 128k -ar 44100 pickup_optimized.mp3
```

### Formato Alternativo

Si tienes problemas con MP3, puedes usar OGG:

1. Convierte los archivos a OGG
2. Cambia las extensiones en `sound_manager.dart`
3. Actualiza las rutas en el código

---

## 🎯 Estado Actual

- ✅ Código implementado
- ✅ Dependencias instaladas
- ✅ `pubspec.yaml` actualizado
- ⏳ **PENDIENTE**: Copiar archivos de assets
- ⏳ **PENDIENTE**: Probar en dispositivo

Una vez que copies los archivos, el sistema de rompecabezas estará **100% funcional**.
