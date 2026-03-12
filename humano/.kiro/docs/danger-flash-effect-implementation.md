# ⚫ Efecto de Parpadeos Negros (Danger Flash)

## 🎯 Objetivo
Crear parpadeos/destellos negros que aumenten la tensión cuando el enemigo está cerca del jugador en los Arcos 1, 2 y 3.

## ✅ Implementación

### Componente Creado: `DangerFlashOverlay`

**Ubicación**: `lib/game/core/effects/danger_flash_overlay.dart`

**Características**:
- Parpadeos negros que cubren toda la pantalla
- Frecuencia basada en proximidad del enemigo
- Intensidad variable según distancia
- Duración aleatoria para impredecibilidad

### 📊 Mecánica del Efecto

#### Activación:
- **Umbral de peligro**: 200 pixels
- **Cuando enemigo > 200px**: Sin parpadeos
- **Cuando enemigo < 200px**: Parpadeos activos

#### Frecuencia de Parpadeos:
```dart
Distancia 200px = Parpadeo cada 2.0 segundos
Distancia 150px = Parpadeo cada 1.4 segundos
Distancia 100px = Parpadeo cada 0.8 segundos
Distancia 50px  = Parpadeo cada 0.6 segundos
```

#### Intensidad (Opacidad):
```dart
Distancia 200px = 40% opacidad
Distancia 150px = 55% opacidad
Distancia 100px = 70% opacidad
Distancia 50px  = 80% opacidad
```

#### Duración del Flash:
- Base: 0.1 - 0.2 segundos
- Aleatorio para crear imprevisibilidad
- Fade in rápido (30% del tiempo)
- Hold (40% del tiempo)
- Fade out rápido (30% del tiempo)

### 🎮 Implementado en:

#### ✅ Arco 1: Gula
- Archivo: `lib/game/arcs/gluttony/gluttony_arc_game.dart`
- Integrado con sistema de sanidad
- Funciona con mecánica de escondites

#### ✅ Arco 2: Avaricia
- Archivo: `lib/game/arcs/greed/greed_arc_game.dart`
- Integrado con mecánica de robo
- Complementa el flash de sanidad robada

#### ✅ Arco 3: Envidia
- Archivo: `lib/game/arcs/envy/envy_arc_game.dart`
- Integrado con screen shake
- Complementa viñeta dinámica
- Máxima tensión con todos los efectos combinados

### 🎨 Efecto Visual

#### Lejos (>200px):
```
Sin parpadeos
Jugador: "Estoy seguro por ahora"
```

#### Cerca (100-200px):
```
Parpadeos ocasionales
Jugador: "Se está acercando..."
```

#### Muy Cerca (<100px):
```
Parpadeos frecuentes e intensos
Jugador: "¡ESTÁ AQUÍ!"
```

### 💡 Psicología del Efecto

1. **Desorientación**: Los parpadeos interrumpen la visión
2. **Tensión**: Frecuencia creciente = peligro creciente
3. **Urgencia**: Obliga al jugador a reaccionar
4. **Imprevisibilidad**: Duración aleatoria mantiene al jugador alerta

### 🔧 Código Clave

```dart
// Crear el overlay
_dangerFlash = DangerFlashOverlay(size: Vector2(size.x, size.y));
camera.viewport.add(_dangerFlash!);

// Actualizar cada frame
final distance = (enemy.position - player.position).length;
_dangerFlash!.updateEnemyDistance(distance);
```

### 📈 Progresión de Tensión

#### Sin Efecto (Antes):
```
Enemigo cerca → Jugador ve al enemigo → Reacciona
```

#### Con Efecto (Ahora):
```
Enemigo cerca → Parpadeos negros → Desorientación → 
Tensión aumentada → Jugador reacciona con urgencia
```

### 🎯 Combinación de Efectos por Arco

#### Arco 1 (Gula):
- ✅ Viñeta estática (70%)
- ✅ Parpadeos negros (nuevo)
- ✅ Sistema de sanidad
- **Resultado**: Tensión media-alta

#### Arco 2 (Avaricia):
- ✅ Viñeta estática (50%)
- ✅ Parpadeos negros (nuevo)
- ✅ Flash de sanidad robada
- ✅ Sistema de sanidad
- **Resultado**: Tensión alta

#### Arco 3 (Envidia):
- ✅ Viñeta dinámica (50-110%)
- ✅ Parpadeos negros (nuevo)
- ✅ Screen shake
- ✅ Glow pulsante del enemigo
- ✅ Trail effect
- ✅ Sistema de sanidad
- **Resultado**: Tensión MÁXIMA

### 🧪 Testing

#### Checklist:
- [ ] Parpadeos aparecen cuando enemigo <200px
- [ ] Frecuencia aumenta con proximidad
- [ ] Intensidad aumenta con proximidad
- [ ] Duración es variable/aleatoria
- [ ] No interfiere con gameplay
- [ ] Funciona en Arco 1
- [ ] Funciona en Arco 2
- [ ] Funciona en Arco 3

#### Sensación Esperada:
- ✅ Incomodidad visual
- ✅ Tensión creciente
- ✅ Urgencia de escapar
- ✅ Desorientación controlada

### ⚙️ Parámetros Ajustables

Si necesitas ajustar la intensidad:

```dart
// En danger_flash_overlay.dart

// Frecuencia base (más alto = menos frecuente)
double flashInterval = 2.0;

// Umbral de activación (más alto = activa más lejos)
double dangerThreshold = 200.0;

// Duración del flash (más alto = flash más largo)
double flashDuration = 0.15;

// Opacidad máxima (0.0 - 1.0)
final maxOpacity = 0.4 + (proximityFactor * 0.4);
```

### 📊 Impacto en Experiencia

**Antes**:
- Tensión: ⭐⭐⭐
- Incomodidad: ⭐⭐
- Urgencia: ⭐⭐⭐

**Después**:
- Tensión: ⭐⭐⭐⭐⭐
- Incomodidad: ⭐⭐⭐⭐
- Urgencia: ⭐⭐⭐⭐⭐

---

**Fecha**: 2025-11-19  
**Estado**: ✅ Implementado en Arcos 1, 2 y 3  
**Archivos Modificados**: 4 archivos  
**Próximo**: Probar y ajustar intensidad si es necesario
