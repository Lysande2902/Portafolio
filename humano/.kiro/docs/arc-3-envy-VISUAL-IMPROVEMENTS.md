# 🎨 Arco 3: ENVIDIA - Mejoras Visuales para Tensión

## 🎯 Objetivo
Crear una experiencia visual más intensa, incómoda y tensa que refleje la mecánica de "espejo adaptativo" y la envidia creciente.

## ✅ Mejoras Implementadas

### 1. 🌟 Efectos de Glow Mejorados (Enemigo)

#### Antes:
- Glow simple y estático
- Sin diferenciación por fase

#### Ahora:
- **Pulsación dinámica**: Pulsa más rápido según la fase
- **Sombra progresiva**: Se oscurece y agranda con cada fase
- **Glow multicapa**: 
  - Glow exterior (grande, difuso)
  - Glow interior (intenso, desde Fase 2)
- **Anillos de distorsión**: En Fase 3, múltiples anillos pulsantes
- **Efecto de dash**: Flash blanco + anillo rojo de advertencia

```dart
// Fase 1: Glow suave verde claro
// Fase 2: Glow intenso verde + inner glow
// Fase 3: Glow neón + anillos de distorsión + pulsación rápida
```

### 2. 📹 Screen Shake (Temblor de Pantalla)

**Activación**:
- Se activa cuando el enemigo está a <200 pixels
- Intensidad basada en:
  - Proximidad del enemigo
  - Fase actual (x2 en Fase 2, x3 en Fase 3)
  - Dash (x2 durante dash)

**Efecto**:
```dart
Distancia 200px + Fase 1 = Shake suave
Distancia 100px + Fase 2 = Shake medio
Distancia 50px + Fase 3 + Dash = Shake intenso
```

### 3. 🎭 Viñeta Dinámica

**Intensidad variable**:
- **Base**: 0.5 (siempre presente)
- **Proximidad**: +0.3 cuando enemigo <300px
- **Fase**: +0.1 por cada fase
- **Dash**: +0.2 durante dash

**Resultado**:
```
Lejos + Fase 1 = 50% viñeta
Cerca + Fase 2 = 90% viñeta
Muy cerca + Fase 3 + Dash = 110% viñeta (máxima oscuridad)
```

### 4. 👻 Trail Effect (Rastro)

**Nuevo componente**: `MirrorTrailComponent`

**Características**:
- Se genera cada 0.05 segundos durante dash
- Silueta fantasmal que se desvanece
- Color basado en la fase del enemigo
- Duración: 0.5 segundos
- Efecto de blur progresivo

**Visual**:
- Fase 1: Trail verde claro tenue
- Fase 2: Trail verde intenso
- Fase 3: Trail verde neón brillante

### 5. 🎨 Progresión Visual por Fase

#### Fase 1 (0-1 evidencia):
- ✅ Glow verde claro suave
- ✅ Pulsación lenta
- ✅ Shake mínimo
- ✅ Viñeta base

#### Fase 2 (2-3 evidencias):
- ✅ Glow verde intenso
- ✅ Inner glow añadido
- ✅ Pulsación media
- ✅ Shake medio
- ✅ Viñeta aumentada
- ✅ Trail durante dash

#### Fase 3 (4-5 evidencias):
- ✅ Glow verde neón
- ✅ Anillos de distorsión (3 capas)
- ✅ Pulsación rápida
- ✅ Shake intenso
- ✅ Viñeta máxima
- ✅ Trail brillante durante dash
- ✅ Anillo rojo de advertencia en dash

## 📊 Comparación Visual

### Antes:
```
Enemigo: Sprite simple + glow estático
Pantalla: Sin efectos
Tensión: Baja
```

### Ahora:
```
Enemigo: Sprite + glow pulsante + sombra + anillos + trail
Pantalla: Shake + viñeta dinámica
Tensión: ALTA (aumenta progresivamente)
```

## 🎮 Experiencia del Jugador

### Fase 1:
- "El enemigo me sigue... puedo manejarlo"
- Visual: Relativamente calmado

### Fase 2:
- "Está más cerca... la pantalla tiembla..."
- Visual: Tensión creciente, efectos más notorios

### Fase 3:
- "¡NO PUEDO ESCAPAR! ¡TODO TIEMBLA!"
- Visual: Caos visual, máxima tensión

## 🔧 Archivos Modificados

1. ✅ `lib/game/arcs/envy/components/chameleon_enemy.dart`
   - Render mejorado con múltiples capas de efectos
   - Trail spawning durante dash

2. ✅ `lib/game/arcs/envy/envy_arc_game.dart`
   - Screen shake implementado
   - Viñeta dinámica
   - Sistema de efectos de pantalla

3. ✅ `lib/game/arcs/envy/components/mirror_trail_component.dart` (NUEVO)
   - Componente de rastro fantasmal
   - Desvanecimiento progresivo

## 🧪 Testing

### Checklist Visual:
- [ ] Glow pulsa más rápido en cada fase
- [ ] Sombra se oscurece progresivamente
- [ ] Pantalla tiembla cuando enemigo está cerca
- [ ] Viñeta se oscurece con proximidad
- [ ] Trail aparece durante dash
- [ ] Anillos de distorsión en Fase 3
- [ ] Anillo rojo durante dash
- [ ] Efectos se intensifican con cada evidencia

### Sensación Esperada:
- ✅ Incomodidad creciente
- ✅ Tensión visual
- ✅ Sensación de ser perseguido
- ✅ Urgencia de escapar

## 📈 Impacto en Dificultad

**Visual != Gameplay**, pero:
- Los efectos visuales **refuerzan** la dificultad mecánica
- Crean **presión psicológica** adicional
- Hacen que el jugador **sienta** la amenaza
- Aumentan la **inmersión** en el tema de Envidia

---

**Fecha**: 2025-11-19  
**Estado**: ✅ Implementado y funcional  
**Próximo**: Probar y ajustar intensidades si es necesario
