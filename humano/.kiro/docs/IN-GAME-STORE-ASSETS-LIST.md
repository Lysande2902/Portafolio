# 🛍️ ASSETS PARA LA TIENDA IN-GAME (DEMO) - ESTADO ACTUAL
## "CONDICIÓN: HUMANO" - Store Assets para 3 Arcos

---

## 📋 ESTADO ACTUAL

**Arcos disponibles**: 3 (Gula, Avaricia, Envidia)
**Assets completados**: Animaciones + Backgrounds
**Assets pendientes**: Spritesheets compilados + Marco de preview

---

## ✅ LO QUE YA TIENES

### **Animaciones de Skins** (carpetas LPC):
- ✅ `player_skin_anonymous_lpc/` - Animaciones del skin gratuito
- ✅ `player_skin_influencer_lpc/` - Animaciones del skin influencer
- ✅ `player_skin_moderator_lpc/` - Animaciones del skin moderador
- ✅ `player_skin_troll_lpc/` - Animaciones del skin troll
- ✅ `player_skin_ghost_user_lpc/` - Animaciones del skin fantasma
- ✅ `sin_gluttony_porcelain_lpc/` - Animaciones Gula porcelana
- ✅ `sin_gluttony_glitch_lpc/` - Animaciones Gula glitch
- ✅ `sin_greed_porcelain_lpc/` - Animaciones Avaricia porcelana
- ✅ `sin_greed_glitch_lpc/` - Animaciones Avaricia glitch

### **Backgrounds**:
- ✅ `store_background.jpg` - Fondo principal de la tienda
- ✅ `store_background_skins.jpg` - Fondo de sección de skins
- ✅ `store_background_battlepass.jpg` - Fondo de pase de batalla

### **Otros Assets**:
- ✅ **Items consumibles** - Ya implementados
- ✅ **Sistema de monedas** - Ya implementado
- ✅ **Banner de battlepass** - Ya existe
- ✅ **Botones UI** - Se harán con iconos de Flutter
- ✅ **Barras de progreso** - Se harán con iconos de Flutter

---

## ❌ LO QUE FALTA

### **1. Spritesheets Compilados** (necesarios para el juego)

Tienes las animaciones LPC pero necesitas compilarlas en spritesheets:

#### **Skins de Jugador** (5 archivos):
- [ ] `player_skin_anonymous.png` - Spritesheet compilado
- [ ] `player_skin_influencer.png` - Spritesheet compilado
- [ ] `player_skin_moderator.png` - Spritesheet compilado
- [ ] `player_skin_troll.png` - Spritesheet compilado
- [ ] `player_skin_ghost_user.png` - Spritesheet compilado

#### **Skins de Pecados** (4 archivos - solo Gula y Avaricia):
- [ ] `sin_gluttony_porcelain.png` - Spritesheet compilado
- [ ] `sin_gluttony_glitch.png` - Spritesheet compilado
- [ ] `sin_greed_porcelain.png` - Spritesheet compilado
- [ ] `sin_greed_glitch.png` - Spritesheet compilado

**Nota sobre Envidia**: NO necesitas skins de Envidia porque copia el skin del jugador.

### **2. Marco de Preview** (1 archivo):
- [ ] `skin_preview_frame.png` - Marco decorativo para mostrar skins

**Total pendiente**: 10 archivos

---

## 🎯 ASSETS FINALES NECESARIOS

### **Estructura Completa**:

```
assets/
├── store/
│   ├── backgrounds/
│   │   ├── store_background.jpg ✅
│   │   ├── store_background_skins.jpg ✅
│   │   └── store_background_battlepass.jpg ✅
│   │
│   └── skins/
│       ├── animations/ (carpetas LPC) ✅
│       │   ├── player_skin_anonymous_lpc/
│       │   ├── player_skin_influencer_lpc/
│       │   ├── player_skin_moderator_lpc/
│       │   ├── player_skin_troll_lpc/
│       │   ├── player_skin_ghost_user_lpc/
│       │   ├── sin_gluttony_porcelain_lpc/
│       │   ├── sin_gluttony_glitch_lpc/
│       │   ├── sin_greed_porcelain_lpc/
│       │   └── sin_greed_glitch_lpc/
│       │
│       ├── player/ (spritesheets compilados) ❌
│       │   ├── player_skin_anonymous.png
│       │   ├── player_skin_influencer.png
│       │   ├── player_skin_moderator.png
│       │   ├── player_skin_troll.png
│       │   └── player_skin_ghost_user.png
│       │
│       ├── sins/ (spritesheets compilados) ❌
│       │   ├── sin_gluttony_porcelain.png
│       │   ├── sin_gluttony_glitch.png
│       │   ├── sin_greed_porcelain.png
│       │   └── sin_greed_glitch.png
│       │
│       └── ui/ ❌
│           └── skin_preview_frame.png
```

---

## 📊 RESUMEN DE ASSETS

| Categoría | Completado | Pendiente | Total |
|-----------|------------|-----------|-------|
| **Animaciones LPC** | 9 ✅ | 0 | 9 |
| **Backgrounds** | 3 ✅ | 0 | 3 |
| **Spritesheets Jugador** | 0 | 5 ❌ | 5 |
| **Spritesheets Pecados** | 0 | 4 ❌ | 4 |
| **UI Frames** | 0 | 1 ❌ | 1 |
| **TOTAL** | **12** | **10** | **22** |

---

## 🔧 CÓMO COMPILAR LOS SPRITESHEETS

### **Opción 1: Usar TexturePacker**
1. Abre TexturePacker
2. Arrastra la carpeta LPC completa
3. Configura:
   - Output: PNG
   - Data Format: JSON (o el que uses en Flame)
   - Tamaño máximo: 2048x2048
4. Exporta el spritesheet

### **Opción 2: Usar script Python/Node**
Puedes crear un script que tome todas las imágenes de la carpeta LPC y las compile en un solo spritesheet.

### **Opción 3: Usar herramienta online**
- [Free Texture Packer](http://free-tex-packer.com/)
- [Leshy SpriteSheet Tool](https://www.leshylabs.com/apps/sstool/)

---

## 🎨 ESPECIFICACIONES PARA LOS SPRITESHEETS

### **Formato**:
- **Tipo**: PNG-24 con canal alpha
- **Tamaño recomendado**: Flexible (depende de cuántos frames tengas)
- **Organización**: Grid ordenado o atlas optimizado
- **Compresión**: TinyPNG después de compilar

### **Metadata**:
Necesitarás un archivo JSON que describa:
- Posición de cada frame
- Tamaño de cada frame
- Nombre de cada animación
- Número de frames por animación

---

## 🎭 NOTA ESPECIAL: ENVIDIA

### **Envidia NO necesita skins propios**

**Razón**: Envidia copia el skin del jugador actual.

**Implementación**:
```dart
// Pseudo-código
class EnvyEnemy {
  String currentSkin;
  
  void copySkinFromPlayer(Player player) {
    currentSkin = player.equippedSkin;
    // Usar el mismo spritesheet que el jugador
  }
}
```

**Por lo tanto**:
- ❌ NO crear `sin_envy_porcelain.png`
- ❌ NO crear `sin_envy_glitch.png`
- ✅ Envidia usa dinámicamente el skin del jugador

---

## ✅ CHECKLIST DE PRODUCCIÓN

### **Prioridad ALTA** (Para funcionalidad básica):
- [ ] Compilar `player_skin_anonymous.png` (skin gratuito)
- [ ] Compilar `player_skin_influencer.png` (skin premium básico)
- [ ] Crear `skin_preview_frame.png` (marco de preview)

**Subtotal**: 3 archivos

### **Prioridad MEDIA** (Para tienda completa):
- [ ] Compilar `player_skin_moderator.png`
- [ ] Compilar `player_skin_troll.png`
- [ ] Compilar `player_skin_ghost_user.png`

**Subtotal**: +3 archivos

### **Prioridad BAJA** (Contenido adicional):
- [ ] Compilar `sin_gluttony_porcelain.png`
- [ ] Compilar `sin_gluttony_glitch.png`
- [ ] Compilar `sin_greed_porcelain.png`
- [ ] Compilar `sin_greed_glitch.png`

**Subtotal**: +4 archivos

---

## 🚀 PLAN DE ACCIÓN

### **Paso 1: Compilar Spritesheets**
Usa una herramienta para convertir las carpetas LPC en spritesheets PNG:
- TexturePacker (recomendado)
- Free Texture Packer (gratis online)
- Script personalizado

### **Paso 2: Crear Marco de Preview**
Diseña un marco decorativo simple:
- Tamaño: 450x650px
- Estilo: Borde con efecto glitch/digital
- Transparencia en el centro
- Formato: PNG con alpha

### **Paso 3: Organizar Archivos**
Coloca los spritesheets compilados en:
- `assets/store/skins/player/`
- `assets/store/skins/sins/`
- `assets/store/skins/ui/`

### **Paso 4: Actualizar Código**
Asegúrate de que el código cargue los spritesheets correctamente:
```dart
// Ejemplo
final playerSkin = await Flame.images.load('store/skins/player/player_skin_anonymous.png');
```

---

## 💡 RECOMENDACIONES

### **Para los Spritesheets**:
1. **Mantén el orden**: Asegúrate de que los frames estén en orden lógico
2. **Documenta**: Crea un JSON con la metadata de cada spritesheet
3. **Optimiza**: Usa TinyPNG para reducir el tamaño sin perder calidad
4. **Prueba**: Verifica que las animaciones se vean bien en el juego

### **Para el Marco de Preview**:
1. **Simple es mejor**: Un borde elegante es suficiente
2. **Consistente**: Usa el mismo estilo visual del juego
3. **Transparente**: El centro debe ser transparente para ver el skin
4. **Escalable**: Debe verse bien en diferentes tamaños

---

## 📝 NOTAS FINALES

### **Lo que YA TIENES** ✅:
- Todas las animaciones en formato LPC
- Todos los backgrounds
- Sistema de items y monedas

### **Lo que NECESITAS** ❌:
- Compilar las animaciones LPC en spritesheets PNG
- Crear un marco de preview simple

### **Lo que NO NECESITAS** 🚫:
- Skins de Envidia (copia al jugador)
- Skins de Pereza, Lujuria, Soberbia, Ira (no están en la demo)
- Botones/iconos (se harán con Flutter)

### **Tiempo estimado**:
- Compilar spritesheets: 2-3 horas (con herramienta)
- Crear marco: 30 minutos
- **Total**: ~3-4 horas de trabajo

---

## 🎮 RESUMEN EJECUTIVO

**Estado actual**: 55% completado (12/22 assets)

**Para tener la tienda funcional necesitas**:
1. Compilar 9 spritesheets desde las carpetas LPC
2. Crear 1 marco de preview

**Herramienta recomendada**: TexturePacker o Free Texture Packer

**Próximo paso**: Compilar los spritesheets de los skins de jugador (prioridad alta)

