# 🎨 CÓMO COMPILAR LOS SPRITESHEETS

## 📋 RESUMEN

Tienes las animaciones en formato LPC (carpetas con frames individuales). Necesitas compilarlas en spritesheets PNG para usarlas en el juego.

---

## 🛠️ OPCIÓN 1: TexturePacker (RECOMENDADO)

### **Ventajas**:
- Interfaz gráfica fácil de usar
- Optimización automática
- Genera JSON con metadata
- Versión gratuita disponible

### **Pasos**:

1. **Descarga TexturePacker**:
   - Web: https://www.codeandweb.com/texturepacker
   - Versión gratuita: Suficiente para este proyecto

2. **Abre TexturePacker**

3. **Para cada skin**:
   ```
   a. Arrastra la carpeta completa (ej: player_skin_anonymous_lpc/)
   b. Configura:
      - Data Format: JSON (Hash)
      - Texture Format: PNG
      - Algorithm: Basic
      - Max Size: 2048x2048
      - Padding: 2
   c. Output:
      - Data file: player_skin_anonymous.json
      - Texture file: player_skin_anonymous.png
   d. Click "Publish sprite sheet"
   ```

4. **Repite para cada skin**:
   - player_skin_anonymous_lpc → player_skin_anonymous.png
   - player_skin_influencer_lpc → player_skin_influencer.png
   - player_skin_moderator_lpc → player_skin_moderator.png
   - player_skin_troll_lpc → player_skin_troll.png
   - player_skin_ghost_user_lpc → player_skin_ghost_user.png
   - sin_gluttony_porcelain_lpc → sin_gluttony_porcelain.png
   - sin_gluttony_glitch_lpc → sin_gluttony_glitch.png
   - sin_greed_porcelain_lpc → sin_greed_porcelain.png
   - sin_greed_glitch_lpc → sin_greed_glitch.png

5. **Mueve los archivos**:
   ```
   Skins de jugador → assets/store/skins/player/
   Skins de pecados → assets/store/skins/sins/
   ```

---

## 🛠️ OPCIÓN 2: Free Texture Packer (GRATIS ONLINE)

### **Ventajas**:
- No requiere instalación
- Completamente gratis
- Fácil de usar

### **Pasos**:

1. **Abre el sitio**:
   - URL: http://free-tex-packer.com/

2. **Para cada skin**:
   ```
   a. Click en "Add sprites"
   b. Selecciona TODOS los frames de la carpeta LPC
   c. Configura:
      - Texture name: player_skin_anonymous
      - Texture format: png
      - Max size: 2048x2048
      - Padding: 2
   d. Click "Export"
   e. Descarga el ZIP
   ```

3. **Extrae y organiza**:
   ```
   Descomprime el ZIP
   Renombra el PNG si es necesario
   Mueve a la carpeta correcta
   ```

---

## 🛠️ OPCIÓN 3: Leshy SpriteSheet Tool (GRATIS ONLINE)

### **Ventajas**:
- Muy simple
- No requiere registro
- Genera spritesheet básico

### **Pasos**:

1. **Abre el sitio**:
   - URL: https://www.leshylabs.com/apps/sstool/

2. **Para cada skin**:
   ```
   a. Arrastra todos los frames
   b. Ajusta el layout (Grid o Packed)
   c. Click "Save Spritesheet"
   d. Descarga el PNG
   ```

---

## 🛠️ OPCIÓN 4: Script Python (PARA DESARROLLADORES)

### **Ventajas**:
- Automatizable
- Procesa múltiples carpetas
- Personalizable

### **Script**:

```python
from PIL import Image
import os
import json

def compile_spritesheet(input_folder, output_name):
    # Obtener todos los PNG de la carpeta
    frames = []
    for file in sorted(os.listdir(input_folder)):
        if file.endswith('.png'):
            img = Image.open(os.path.join(input_folder, file))
            frames.append(img)
    
    if not frames:
        print(f"No frames found in {input_folder}")
        return
    
    # Calcular dimensiones del spritesheet
    frame_width = frames[0].width
    frame_height = frames[0].height
    cols = 8  # 8 frames por fila
    rows = (len(frames) + cols - 1) // cols
    
    # Crear spritesheet
    spritesheet = Image.new('RGBA', (frame_width * cols, frame_height * rows))
    
    # Pegar frames
    for i, frame in enumerate(frames):
        x = (i % cols) * frame_width
        y = (i // cols) * frame_height
        spritesheet.paste(frame, (x, y))
    
    # Guardar
    spritesheet.save(f"{output_name}.png")
    
    # Generar metadata JSON
    metadata = {
        "frames": len(frames),
        "frameWidth": frame_width,
        "frameHeight": frame_height,
        "cols": cols,
        "rows": rows
    }
    
    with open(f"{output_name}.json", 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"✅ Created {output_name}.png ({len(frames)} frames)")

# Compilar todos los skins
skins = [
    ("assets/store/skins/animations/player_skin_anonymous_lpc", "player_skin_anonymous"),
    ("assets/store/skins/animations/player_skin_influencer_lpc", "player_skin_influencer"),
    ("assets/store/skins/animations/player_skin_moderator_lpc", "player_skin_moderator"),
    ("assets/store/skins/animations/player_skin_troll_lpc", "player_skin_troll"),
    ("assets/store/skins/animations/player_skin_ghost_user_lpc", "player_skin_ghost_user"),
    ("assets/store/skins/animations/sin_gluttony_porcelain_lpc", "sin_gluttony_porcelain"),
    ("assets/store/skins/animations/sin_gluttony_glitch_lpc", "sin_gluttony_glitch"),
    ("assets/store/skins/animations/sin_greed_porcelain_lpc", "sin_greed_porcelain"),
    ("assets/store/skins/animations/sin_greed_glitch_lpc", "sin_greed_glitch"),
]

for input_folder, output_name in skins:
    compile_spritesheet(input_folder, output_name)

print("\n✅ All spritesheets compiled!")
```

**Uso**:
```bash
pip install Pillow
python compile_spritesheets.py
```

---

## 📁 ESTRUCTURA FINAL

Después de compilar, deberías tener:

```
assets/store/skins/
├── animations/ (carpetas LPC originales)
│   ├── player_skin_anonymous_lpc/
│   ├── player_skin_influencer_lpc/
│   └── ...
│
├── player/ (spritesheets compilados)
│   ├── player_skin_anonymous.png
│   ├── player_skin_anonymous.json
│   ├── player_skin_influencer.png
│   ├── player_skin_influencer.json
│   └── ...
│
└── sins/ (spritesheets compilados)
    ├── sin_gluttony_porcelain.png
    ├── sin_gluttony_porcelain.json
    ├── sin_gluttony_glitch.png
    ├── sin_gluttony_glitch.json
    └── ...
```

---

## 🎯 DESPUÉS DE COMPILAR

### **1. Actualiza pubspec.yaml**:
```yaml
assets:
  - assets/store/skins/player/
  - assets/store/skins/sins/
```

### **2. Carga los sprites en el código**:
```dart
// En store_screen.dart, reemplaza el placeholder:

// ANTES:
Icon(Icons.person, color: wineRed, size: 48)

// DESPUÉS:
Image.asset(
  'assets/store/skins/player/player_skin_anonymous.png',
  width: 64,
  height: 64,
)
```

### **3. Usa Flame para animaciones**:
```dart
import 'package:flame/components.dart';

final spriteSheet = await images.load('store/skins/player/player_skin_anonymous.png');
final sprite = SpriteAnimation.fromFrameData(
  spriteSheet,
  SpriteAnimationData.sequenced(
    amount: 16, // número de frames
    stepTime: 0.1,
    textureSize: Vector2(128, 128),
  ),
);
```

---

## 📊 ESPECIFICACIONES TÉCNICAS

### **Formato de Salida**:
- **Tipo**: PNG-24 con canal alpha
- **Tamaño**: Variable (depende del número de frames)
- **Organización**: Grid o atlas optimizado
- **Padding**: 2px entre frames (recomendado)

### **Metadata JSON** (ejemplo):
```json
{
  "frames": 16,
  "frameWidth": 128,
  "frameHeight": 128,
  "cols": 4,
  "rows": 4,
  "animations": {
    "idle": { "start": 0, "end": 3 },
    "walk": { "start": 4, "end": 7 },
    "run": { "start": 8, "end": 11 },
    "hide": { "start": 12, "end": 15 }
  }
}
```

---

## ⏱️ TIEMPO ESTIMADO

| Método | Tiempo por Skin | Total (9 skins) |
|--------|-----------------|-----------------|
| **TexturePacker** | 5 min | ~45 min |
| **Free Texture Packer** | 7 min | ~1 hora |
| **Leshy Tool** | 8 min | ~1.2 horas |
| **Script Python** | 1 min | ~10 min (automatizado) |

---

## 💡 TIPS

### **Optimización**:
1. Usa TinyPNG después de compilar para reducir tamaño
2. Mantén el padding en 2px para evitar bleeding
3. Usa potencias de 2 para el tamaño (512, 1024, 2048)

### **Organización**:
1. Nombra los archivos consistentemente
2. Guarda los JSON junto a los PNG
3. Mantén las carpetas LPC originales como backup

### **Testing**:
1. Verifica que todos los frames estén presentes
2. Comprueba que no haya frames duplicados
3. Asegúrate de que el orden sea correcto

---

## 🐛 PROBLEMAS COMUNES

### **"Frames en orden incorrecto"**:
- Solución: Asegúrate de que los archivos estén ordenados alfabéticamente

### **"Spritesheet muy grande"**:
- Solución: Reduce el tamaño de los frames o usa más spritesheets

### **"Frames con bleeding"**:
- Solución: Aumenta el padding a 2-4px

### **"JSON no se genera"**:
- Solución: Usa TexturePacker o crea el JSON manualmente

---

## ✅ CHECKLIST

Antes de considerar terminado:
- [ ] Todos los 9 spritesheets compilados
- [ ] Archivos PNG en las carpetas correctas
- [ ] JSON metadata generado (opcional pero recomendado)
- [ ] Assets agregados al pubspec.yaml
- [ ] Sprites probados en la app
- [ ] Tamaño de archivos optimizado

---

## 🎉 CONCLUSIÓN

**Recomendación**: Usa **TexturePacker** si quieres calidad profesional, o el **script Python** si quieres automatizar el proceso.

Una vez compilados los spritesheets, la tienda estará 100% completa visualmente. 🚀

