# 🪞 Arco 3: ENVIDIA - Implementación "Espejo Adaptativo" v2.0

## 📋 Resumen

**Arco ID**: `arc_3_envy`  
**Título**: ENVIDIA - Reflejo en el Espejo  
**Mecánica Principal**: Enemigo que imita movimientos con dificultad adaptativa EXTREMA  
**Dificultad**: ⭐⭐⭐⭐⭐ (5/5) - **MUY DIFÍCIL**

---

## 🎮 Mecánica: Sistema de Espejo Adaptativo v2.0

### Concepto Core
El enemigo **aprende del jugador** y se vuelve progresivamente MÁS PELIGROSO. **SIN ESCONDITES** - solo movimiento puro.

### Sistema de 3 Fases (AUMENTADO)

#### **FASE 1: Imitación Rápida** (0-1 evidencia)
- **Delay**: 0.7 segundos (antes 1.0)
- **Velocidad**: 90% del jugador (antes 80%)
- **Dash Cooldown**: 10 segundos (antes 12)
- **Dash Duration**: 2.5 segundos (antes 2.0)
- **Color**: Verde claro (#4A7C4A)
- **Comportamiento**: Rápida desde el inicio

#### **FASE 2: Imitación Agresiva** (2-3 evidencias)
- **Delay**: 0.4 segundos (antes 0.6)
- **Velocidad**: 115% del jugador (antes 100%)
- **Dash Cooldown**: 7 segundos (antes 12)
- **Dash Duration**: 3.0 segundos (antes 2.0)
- **Color**: Verde intenso (#2D8B2D)
- **Comportamiento**: MÁS RÁPIDA que el jugador

#### **FASE 3: Imitación Perfecta** (4-5 evidencias)
- **Delay**: 0.2 segundos (antes 0.3)
- **Velocidad**: 135% del jugador (antes 110%)
- **Dash Cooldown**: 5 segundos (antes 8)
- **Dash Duration**: 4.0 segundos (antes 3.0)
- **Color**: Verde neón (#00FF00)
- **Comportamiento**: IMPARABLE - escape extremo

---

## 🎯 Mecánicas Especiales

### 1. Sistema de Dash MEJORADO
- Velocidad durante dash: **x2 de velocidad base**
- Cooldown MÁS CORTO en cada fase
- Duración MÁS LARGA en cada fase
- Visual: Glow blanco pulsante

### 2. Zona de Envidia MEJORADA
- Cuando jugador está a <150 pixels
- Enemigo se mueve **10% MÁS RÁPIDO**
- Presión constante

### 3. **SIN ESCONDITES**
- ❌ NO hay lugares para esconderse
- ✅ Usa obstáculos para romper línea de visión
- ✅ Movimiento constante es la ÚNICA defensa

### 4. Sprite Animado
- **Sprite**: `lpc_male_envy.png`
- Animaciones: Idle, Walk, Run
- Direcciones: Up, Down, Left, Right
- Cambia a RUN en Fase 2+

---

## 🗺️ Diseño del Mapa

### Dimensiones
- **Ancho**: 3000 pixels
- **Alto**: 1000 pixels
- **Paleta**: Verde oscuro/bosque

### Posiciones de Evidencias (5 total)
1. `Vector2(600, 400)` - Cerca del inicio
2. `Vector2(1200, 250)` - Cerca de obstáculo
3. `Vector2(1500, 600)` - **CENTRO** (peligroso)
4. `Vector2(2000, 350)` - Cerca de obstáculo
5. `Vector2(2400, 500)` - Cerca del final

### Escondites
**NINGUNO** - Puro movimiento y estrategia

---

## 💻 Implementación Técnica

### Archivos Modificados

#### 1. `chameleon_enemy.dart` → `MirrorEnemy`
**Cambios v2.0**:
- ✅ Delays reducidos (0.7 → 0.4 → 0.2)
- ✅ Velocidades aumentadas (90% → 115% → 135%)
- ✅ Dash cooldowns reducidos (10s → 7s → 5s)
- ✅ Dash durations aumentadas (2.5s → 3s → 4s)
- ✅ Sprite animado `lpc_male_envy`
- ✅ Sistema de animación integrado

#### 2. `animated_envy_enemy_sprite.dart` (NUEVO)
**Sprite animado específico**:
- Carga `lpc_male_envy.png`
- Animaciones: Idle, Walk, Run
- 4 direcciones
- Integración con sistema de fases

#### 3. `envy_arc_game.dart`
**Cambios v2.0**:
- ❌ Eliminados TODOS los escondites
- ✅ Actualizado briefing (sin escondites)
- ✅ Mecánica de puro movimiento

#### 4. `arc_data_provider.dart`
**Cambios v2.0**:
- ✅ Briefing actualizado: "SIN ESCONDITES"
- ✅ Descripción: "Fase 1: Rápida. Fase 2: Muy rápida. Fase 3: Imparable"
- ✅ Tip: "¡PURO MOVIMIENTO!"

---

## 🎨 Feedback Visual

### Indicadores de Fase
- **Fase 1**: Glow verde claro + Walk animation
- **Fase 2**: Glow verde intenso + Run animation
- **Fase 3**: Glow verde neón pulsante + Run animation

### Durante Dash
- Glow blanco adicional
- Radio aumentado (+25 pixels)
- Velocidad x2 visible

---

## 📊 Balanceo de Dificultad v2.0

### Progresión AUMENTADA
```
Fase 1 (0-1 evidencia):
- Delay: 0.7s → Cercano
- Speed: 0.9x → Casi igual
- Dash: 10s cooldown → Frecuente

Fase 2 (2-3 evidencias):
- Delay: 0.4s → Muy cercano
- Speed: 1.15x → MÁS RÁPIDA
- Dash: 7s cooldown → Muy frecuente

Fase 3 (4-5 evidencias):
- Delay: 0.2s → Casi instantáneo
- Speed: 1.35x → MUCHO MÁS RÁPIDA
- Dash: 5s cooldown → Constante
```

### Comparación con otros Arcos
- **Arco 1 (Gula)**: ⭐⭐ - Enemigo básico, muchos escondites
- **Arco 2 (Avaricia)**: ⭐⭐⭐ - Robo de recursos, cajas registradoras
- **Arco 3 (Envidia)**: ⭐⭐⭐⭐⭐ - **MUY DIFÍCIL**, sin escondites, enemigo muy rápido

---

## 🧪 Testing Checklist v2.0

### Funcionalidad Básica
- [ ] Enemigo imita movimientos con delay corto
- [ ] Sistema de fases se activa (0-1, 2-3, 4-5 evidencias)
- [ ] Dash se ejecuta frecuentemente
- [ ] NO hay escondites en el mapa

### Mecánicas Especiales
- [ ] Zona de Envidia funciona (enemigo más rápido cerca)
- [ ] Sprite animado `lpc_male_envy` carga correctamente
- [ ] Animaciones cambian según fase (Walk → Run)
- [ ] Feedback visual por fase funciona

### Balanceo
- [ ] Fase 1 es desafiante pero manejable
- [ ] Fase 2 es muy difícil
- [ ] Fase 3 es extremadamente difícil
- [ ] Jugadores expertos pueden completarlo

---

## 🎯 Objetivos de Diseño v2.0

✅ **MUY DIFÍCIL**: Sin escondites + enemigo muy rápido  
✅ **Temático con Envidia**: Te imita y supera  
✅ **Puro movimiento**: Habilidad > Esconderse  
✅ **Justo pero brutal**: Posible con buena ejecución  
✅ **Sprite animado**: Visual mejorado con `lpc_male_envy`  
✅ **Progresión clara**: Cada fase es un salto de dificultad  

---

## 📝 Cambios v2.0

### Aumentos de Dificultad
1. ❌ **Eliminados TODOS los escondites**
2. ⚡ **Delays reducidos** en todas las fases
3. ⚡ **Velocidades aumentadas** significativamente
4. ⚡ **Dash cooldowns reducidos** (más frecuentes)
5. ⚡ **Dash durations aumentadas** (más largos)
6. 🎨 **Sprite animado** `lpc_male_envy` añadido

### Resultado
- Dificultad: ⭐⭐⭐⭐ → ⭐⭐⭐⭐⭐
- Gameplay: Estratégico → **INTENSO**
- Escondites: 3 limitados → **NINGUNO**

---

**Fecha de Implementación**: 2025-11-19  
**Versión**: 2.0 (Dificultad Aumentada + Sprite Animado)  
**Estado**: ✅ Completo y funcional  
**Próximo Arco**: Arco 4 - Lujuria (Teletransporte)
