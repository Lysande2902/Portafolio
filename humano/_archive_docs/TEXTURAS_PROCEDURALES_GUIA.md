# 🎨 GUÍA: TEXTURAS PROCEDURALES

## 🎯 ¿Qué son las Texturas Procedurales?

Son texturas generadas **con código** en lugar de usar imágenes. Esto significa:

✅ **Sin assets** - No necesitas archivos PNG/JPG  
✅ **Ligero** - Menos peso en la app  
✅ **Flexible** - Cambias colores/patrones fácilmente  
✅ **Dinámico** - Puedes animar o variar las texturas  
✅ **Consistente** - Mismo estilo en todo el juego  

---

## 🛠️ TEXTURAS IMPLEMENTADAS

### 1. Concreto Agrietado (`concrete`)

**Uso:** Pisos de almacén, paredes industriales

**Características:**
- Textura granulada (1000 puntos aleatorios)
- 8 grietas ramificadas
- Variación de brillo sutil

**Código:**
```dart
TexturedBackgroundComponent(
  textureType: 'concrete',
  baseColor: Color(0xFF1a0f0a),
  seed: 1, // Cambia el patrón
)
```

**Resultado visual:**
- Base gris/marrón
- Grietas negras irregulares
- Aspecto desgastado

---

### 2. Metal Oxidado (`metal`)

**Uso:** Cajas fuertes, puertas de bóveda, paredes metálicas

**Características:**
- Base metálica
- 50 manchas de óxido (marrón)
- 20 rayones aleatorios
- Efecto blur en manchas

**Código:**
```dart
TexturedObstacleComponent(
  textureType: 'vault',
  baseColor: Color(0xFF2a2a3a),
  seed: 42,
)
```

**Resultado visual:**
- Base gris-azul metálica
- Manchas marrones de óxido
- Rayones negros
- Cerradura circular (para vaults)

---

### 3. Madera (`wood`)

**Uso:** Cajas, mesas, puertas

**Características:**
- Vetas horizontales onduladas
- 5 nudos de madera
- Variación de tono

**Código:**
```dart
TexturedObstacleComponent(
  textureType: 'crate',
  baseColor: Color(0xFF3a2f2a),
  seed: 100,
)
```

**Resultado visual:**
- Base marrón
- Líneas onduladas (vetas)
- Óvalos oscuros (nudos)
- Borde negro (para cajas)

---

### 4. Ladrillos (`brick`)

**Uso:** Paredes, muros

**Características:**
- Patrón de ladrillos offset
- Mortero entre ladrillos
- Sombras en ladrillos

**Código:**
```dart
TexturedObstacleComponent(
  textureType: 'wall',
  baseColor: Color(0xFF4a3a3a),
)
```

**Resultado visual:**
- Ladrillos rojos/marrones
- Mortero gris oscuro
- Patrón alternado

---

## 📐 CÓMO USAR

### En Backgrounds (Fondos)

```dart
// Fondo de concreto
final bg = TexturedBackgroundComponent(
  position: Vector2(0, 0),
  size: Vector2(2400, 1600),
  textureType: 'concrete',
  baseColor: Color(0xFF1a0f0a),
  seed: 1,
);
world.add(bg);
```

### En Obstáculos

```dart
// Caja de madera
final crate = TexturedObstacleComponent(
  position: Vector2(400, 200),
  size: Vector2(120, 120),
  textureType: 'crate',
  baseColor: Color(0xFF3a2f2a),
  seed: 100,
);
world.add(crate);
```

### Variación con Seeds

El parámetro `seed` cambia el patrón aleatorio:

```dart
// Tres cajas con patrones diferentes
world.add(TexturedObstacleComponent(
  position: Vector2(400, 200),
  textureType: 'crate',
  baseColor: Color(0xFF3a2f2a),
  seed: 100, // Patrón A
));

world.add(TexturedObstacleComponent(
  position: Vector2(600, 200),
  textureType: 'crate',
  baseColor: Color(0xFF3a2f2a),
  seed: 101, // Patrón B (diferente)
));

world.add(TexturedObstacleComponent(
  position: Vector2(800, 200),
  textureType: 'crate',
  baseColor: Color(0xFF3a2f2a),
  seed: 102, // Patrón C (diferente)
));
```

---

## 🎨 PALETAS DE COLORES POR ARCO

### Arco 1: Consumo y Codicia

**Fase 1 (Warehouse):**
```dart
// Fondo
baseColor: Color(0xFF1a0f0a), // Marrón oscuro
textureType: 'concrete',

// Obstáculos
baseColor: Color(0xFF3a2f2a), // Marrón medio
textureType: 'crate',
```

**Fase 2 (Vault):**
```dart
// Fondo
baseColor: Color(0xFF0a0a0f), // Gris-azul oscuro
textureType: 'metal',

// Obstáculos
baseColor: Color(0xFF2a2a3a), // Gris-azul medio
textureType: 'vault',
```

### Arco 2: Envidia y Lujuria

**Fase 1 (Gimnasio):**
```dart
// Fondo
baseColor: Color(0xFF0f1a0f), // Verde oscuro
textureType: 'concrete',

// Obstáculos
baseColor: Color(0xFF2a3a2a), // Verde medio
textureType: 'crate',
```

**Fase 2 (Club):**
```dart
// Fondo
baseColor: Color(0xFF1a0f1a), // Púrpura oscuro
textureType: 'metal',

// Obstáculos
baseColor: Color(0xFF3a2a3a), // Púrpura medio
textureType: 'vault',
```

### Arco 3: Soberbia y Pereza

**Fase 1 (Estudio):**
```dart
// Fondo
baseColor: Color(0xFF1a1a0f), // Dorado oscuro
textureType: 'wood',

// Obstáculos
baseColor: Color(0xFF3a3a2a), // Dorado medio
textureType: 'crate',
```

**Fase 2 (Hospital):**
```dart
// Fondo
baseColor: Color(0xFF0f0f0f), // Gris muy oscuro
textureType: 'concrete',

// Obstáculos
baseColor: Color(0xFF2a2a2a), // Gris medio
textureType: 'wall',
```

### Arco 4: Ira

**Casa en llamas:**
```dart
// Fondo
baseColor: Color(0xFF1a0a0a), // Rojo oscuro
textureType: 'concrete',

// Obstáculos
baseColor: Color(0xFF3a1a1a), // Rojo medio
textureType: 'crate',
```

---

## 🔧 PERSONALIZACIÓN

### Crear Nueva Textura

1. Añade función en `procedural_texture.dart`:

```dart
static void drawMyTexture(
  Canvas canvas,
  Rect rect,
  Color baseColor,
  {int seed = 42}
) {
  final random = Random(seed);
  
  // Tu código de dibujo aquí
  canvas.drawRect(rect, Paint()..color = baseColor);
  
  // Añadir detalles...
}
```

2. Añade case en `TexturedObstacleComponent`:

```dart
case 'mytexture':
  ProceduralTexture.drawMyTexture(
    canvas,
    rect,
    baseColor,
    seed: seed,
  );
  break;
```

3. Usa en tu escena:

```dart
TexturedObstacleComponent(
  textureType: 'mytexture',
  baseColor: Color(0xFF123456),
)
```

---

## 📊 VENTAJAS vs IMÁGENES

| Aspecto | Imágenes | Texturas Procedurales |
|---------|----------|----------------------|
| **Tamaño** | 500KB - 2MB por imagen | 0KB (código) |
| **Flexibilidad** | Fijo | Infinitas variaciones |
| **Carga** | Async, puede fallar | Instantáneo |
| **Memoria** | Alta | Baja |
| **Variación** | Necesitas múltiples archivos | Un seed diferente |
| **Mantenimiento** | Difícil cambiar | Fácil ajustar código |

---

## 🎮 EFECTOS ADICIONALES

### Efecto VHS (Scanlines)

Añade líneas horizontales para efecto retro:

```dart
// En render()
for (double y = 0; y < size.y; y += 4) {
  canvas.drawLine(
    Offset(0, y),
    Offset(size.x, y),
    Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1,
  );
}
```

### Ruido Animado

Cambia el seed cada frame para ruido dinámico:

```dart
int _frameCount = 0;

@override
void update(double dt) {
  _frameCount++;
  // Actualizar textura cada 10 frames
  if (_frameCount % 10 == 0) {
    seed = Random().nextInt(1000);
  }
}
```

### Iluminación Dinámica

Ajusta el brillo según la posición del jugador:

```dart
final distanceToPlayer = (playerPosition - position).length;
final brightness = (300 - distanceToPlayer) / 300;
final adjustedColor = _adjustBrightness(baseColor, brightness * 0.3);
```

---

## 🐛 TROUBLESHOOTING

### Problema: Textura no se ve

**Solución:**
- Verifica que el componente esté añadido al world
- Verifica que size > 0
- Verifica que baseColor no sea transparente

### Problema: Textura se ve pixelada

**Solución:**
- Aumenta la resolución de los detalles
- Usa más puntos en el ruido
- Añade blur a las manchas

### Problema: Performance baja

**Solución:**
- Reduce el número de detalles (menos puntos de ruido)
- Usa texturas más simples
- Cachea el resultado si es estático

---

## 📝 CHECKLIST DE IMPLEMENTACIÓN

Por cada escena:

- [ ] Definir paleta de colores
- [ ] Elegir tipo de textura para fondo
- [ ] Elegir tipo de textura para obstáculos
- [ ] Asignar seeds únicos a cada obstáculo
- [ ] Testing visual
- [ ] Ajustar colores si es necesario
- [ ] Verificar performance

---

## 🎯 PRÓXIMOS PASOS

1. ✅ Sistema de texturas procedurales creado
2. ✅ Arco 1 actualizado con texturas
3. ⏳ Aplicar a Arco 2
4. ⏳ Aplicar a Arco 3
5. ⏳ Aplicar a Arco 4
6. ⏳ Añadir efectos VHS opcionales
7. ⏳ Optimizar performance si es necesario

---

## 💡 TIPS

1. **Usa seeds incrementales:** 100, 101, 102... para variación sutil
2. **Mantén colores oscuros:** El juego es horror, evita colores brillantes
3. **Prueba diferentes texturas:** Cambia el `textureType` fácilmente
4. **Documenta tus paletas:** Guarda los códigos de color que funcionan
5. **Reutiliza componentes:** Misma textura, diferente seed = variación gratis

---

**Fecha:** 27 de Enero de 2025  
**Estado:** Sistema implementado y funcionando en Arco 1  
**Ventaja:** 0KB de assets, infinitas variaciones
