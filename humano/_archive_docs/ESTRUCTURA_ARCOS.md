# Estructura de Archivos por Arco - CONDICIÓN: HUMANO

Este documento lista todos los archivos que debe tener cada arco del juego para estar completamente implementado.

---

## 📁 Estructura Base de un Arco

Cada arco debe seguir esta estructura de carpetas y archivos:

```
lib/game/arcs/{nombre_arco}/
├── {nombre_arco}_arc_game.dart          # Clase principal del juego del arco
├── {nombre_arco}_scene.dart             # Generador de escena (obstáculos, decoración)
└── components/
    ├── player_component.dart            # Componente del jugador (si es específico del arco)
    ├── enemy_component.dart             # Componente del enemigo principal
    ├── evidence_component.dart          # Componente de evidencia
    ├── hiding_spot_component.dart       # Lugares para esconderse
    ├── exit_door_component.dart         # Puerta de salida
    └── {mecánica_específica}_component.dart  # Componentes únicos del arco
```

---

## 🎮 ARCO 1: GULA (Gluttony)

### ✅ Archivos Implementados

#### Juego Principal
- `lib/game/arcs/gluttony/gluttony_arc_game.dart`
  - Lógica principal del arco
  - Sistema de evidencia
  - Mecánica de gula (velocidad reducida con evidencia)
  - Sistema de proyectiles

#### Escena
- `lib/game/arcs/gluttony/gluttony_scene.dart`
  - Generación de obstáculos
  - Decoración del nivel
  - Colores y atmósfera

#### Componentes
- `lib/game/arcs/gluttony/components/player_component.dart`
  - Jugador con sprites animados LPC
  - Sistema de velocidad variable (mecánica de gula)
  - Animaciones: idle, walk, run

- `lib/game/arcs/gluttony/components/enemy_component.dart`
  - Enemigo "Mateo" con sprites animados LPC musculares
  - IA: patrullaje, persecución, enrage, charge
  - Animaciones: idle, walk, run
  - Sistema de proyectiles

- `lib/game/arcs/gluttony/components/food_projectile_component.dart`
  - Proyectiles de jamón giratorios
  - Sprite de ham.png
  - Efectos visuales (glow)

- `lib/game/arcs/gluttony/components/evidence_component.dart`
  - Evidencia coleccionable
  - 5 piezas en total

- `lib/game/arcs/gluttony/components/hiding_spot_component.dart`
  - Lugares para esconderse del enemigo
  - 5 spots distribuidos

- `lib/game/arcs/gluttony/components/exit_door_component.dart`
  - Puerta de salida al final del nivel

- `lib/game/arcs/gluttony/components/vignette_overlay.dart`
  - Efecto de viñeta visual

#### Assets Necesarios
```
assets/images/
├── ham.png                              # Proyectil de comida
└── animations/
    ├── lpc_male_animations_2025-11-14T19-18-55/standard/
    │   ├── idle.png                     # Jugador idle
    │   ├── walk.png                     # Jugador walk
    │   └── run.png                      # Jugador run
    └── lpc_muscular_animations_enemigo_gula/standard/
        ├── idle.png                     # Enemigo idle
        ├── walk.png                     # Enemigo walk
        └── run.png                      # Enemigo run
```

---

## 🎮 ARCO 2: AVARICIA (Greed)

### 📋 Archivos Necesarios

#### Juego Principal
- `lib/game/arcs/greed/greed_arc_game.dart`
  - Lógica principal del arco
  - Mecánica de avaricia (acumular recursos, decisiones de riesgo/recompensa)

#### Escena
- `lib/game/arcs/greed/greed_scene.dart`
  - Generación de obstáculos temáticos (cajas fuertes, pilas de dinero)
  - Decoración dorada/monetaria
  - Atmósfera de banco/bóveda

#### Componentes
- `lib/game/arcs/greed/components/player_component.dart` (opcional, puede usar el base)

- `lib/game/arcs/greed/components/banker_enemy.dart`
  - Enemigo "Banquero"
  - IA específica de avaricia

- `lib/game/arcs/greed/components/evidence_component.dart`
  - Evidencia temática (documentos financieros, contratos)

- `lib/game/arcs/greed/components/hiding_spot_component.dart`
  - Lugares para esconderse

- `lib/game/arcs/greed/components/exit_door_component.dart`
  - Puerta de salida

- `lib/game/arcs/greed/components/coin_collectible.dart` (mecánica única)
  - Monedas/dinero coleccionable
  - Sistema de riesgo: más dinero = más lento o más visible

#### Assets Necesarios
```
assets/images/
├── coin.png                             # Moneda coleccionable
├── money_bag.png                        # Bolsa de dinero
└── animations/
    └── lpc_banker_animations/standard/
        ├── idle.png
        ├── walk.png
        └── run.png
```

---

## 🎮 ARCO 3: ENVIDIA (Envy)

### 📋 Archivos Necesarios

#### Juego Principal
- `lib/game/arcs/envy/envy_arc_game.dart`
  - Lógica principal del arco
  - Mecánica de envidia (copiar habilidades, transformación)

#### Escena
- `lib/game/arcs/envy/envy_scene.dart`
  - Generación de obstáculos temáticos (espejos, reflejos)
  - Decoración verde/gris
  - Atmósfera de duplicación

#### Componentes
- `lib/game/arcs/envy/components/player_component.dart` (opcional)

- `lib/game/arcs/envy/components/chameleon_enemy.dart`
  - Enemigo "Camaleón"
  - IA con camuflaje/invisibilidad
  - Se disfraza como objetos

- `lib/game/arcs/envy/components/evidence_component.dart`
  - Evidencia temática

- `lib/game/arcs/envy/components/hiding_spot_component.dart`

- `lib/game/arcs/envy/components/exit_door_component.dart`

- `lib/game/arcs/envy/components/mirror_component.dart` (mecánica única)
  - Espejos que revelan al enemigo camuflado

#### Assets Necesarios
```
assets/images/
├── mirror.png                           # Espejo
└── animations/
    └── lpc_chameleon_animations/standard/
        ├── idle.png
        ├── walk.png
        ├── run.png
        └── camouflage.png               # Animación de camuflaje
```

---

## 🎮 ARCO 4: LUJURIA (Lust)

### 📋 Archivos Necesarios

#### Juego Principal
- `lib/game/arcs/lust/lust_arc_game.dart`
  - Lógica principal del arco
  - Mecánica de lujuria (atracción, distracción)

#### Escena
- `lib/game/arcs/lust/lust_scene.dart`
  - Generación de obstáculos temáticos
  - Decoración rosa/roja
  - Atmósfera seductora/peligrosa

#### Componentes
- `lib/game/arcs/lust/components/player_component.dart` (opcional)

- `lib/game/arcs/lust/components/siren_enemy.dart`
  - Enemigo "Sirena"
  - IA con atracción magnética
  - Puede atraer al jugador hacia ella

- `lib/game/arcs/lust/components/evidence_component.dart`

- `lib/game/arcs/lust/components/hiding_spot_component.dart`

- `lib/game/arcs/lust/components/exit_door_component.dart`

- `lib/game/arcs/lust/components/attraction_field.dart` (mecánica única)
  - Campos que atraen al jugador
  - Dificultan el control

#### Assets Necesarios
```
assets/images/
├── heart.png                            # Ya existe
└── animations/
    └── lpc_siren_animations/standard/
        ├── idle.png
        ├── walk.png
        └── attract.png                  # Animación de atracción
```

---

## 🎮 ARCO 5: SOBERBIA (Pride)

### 📋 Archivos Necesarios

#### Juego Principal
- `lib/game/arcs/pride/pride_arc_game.dart`
  - Lógica principal del arco
  - Mecánica de soberbia (poder creciente, arrogancia)

#### Escena
- `lib/game/arcs/pride/pride_scene.dart`
  - Generación de obstáculos temáticos (tronos, estatuas)
  - Decoración dorada/púrpura
  - Atmósfera majestuosa/opresiva

#### Componentes
- `lib/game/arcs/pride/components/player_component.dart` (opcional)

- `lib/game/arcs/pride/components/lion_enemy.dart`
  - Enemigo "León"
  - IA que se vuelve más fuerte con el tiempo
  - Sistema de power-up progresivo

- `lib/game/arcs/pride/components/evidence_component.dart`

- `lib/game/arcs/pride/components/hiding_spot_component.dart`

- `lib/game/arcs/pride/components/exit_door_component.dart`

- `lib/game/arcs/pride/components/crown_collectible.dart` (mecánica única)
  - Coronas que dan poder temporal
  - Pero atraen más al enemigo

#### Assets Necesarios
```
assets/images/
├── crown.png                            # Corona
└── animations/
    └── lpc_lion_animations/standard/
        ├── idle.png
        ├── walk.png
        ├── run.png
        └── roar.png                     # Animación de rugido
```

---

## 🎮 ARCO 6: PEREZA (Sloth)

### 📋 Archivos Necesarios

#### Juego Principal
- `lib/game/arcs/sloth/sloth_arc_game.dart`
  - Lógica principal del arco
  - Mecánica de pereza (lentitud, cansancio)

#### Escena
- `lib/game/arcs/sloth/sloth_scene.dart`
  - Generación de obstáculos temáticos (camas, sofás)
  - Decoración gris/azul oscuro
  - Atmósfera somnolienta

#### Componentes
- `lib/game/arcs/sloth/components/player_component.dart` (opcional)

- `lib/game/arcs/sloth/components/sloth_enemy.dart`
  - Enemigo "Perezoso"
  - IA lenta pero inevitable
  - Crea zonas de lentitud

- `lib/game/arcs/sloth/components/evidence_component.dart`

- `lib/game/arcs/sloth/components/hiding_spot_component.dart`

- `lib/game/arcs/sloth/components/exit_door_component.dart`

- `lib/game/arcs/sloth/components/sleep_zone.dart` (mecánica única)
  - Zonas que ralentizan al jugador
  - Representan la tentación de rendirse

#### Assets Necesarios
```
assets/images/
├── bed.png                              # Cama
├── pillow.png                           # Almohada
└── animations/
    └── lpc_sloth_animations/standard/
        ├── idle.png
        ├── walk.png                     # Muy lento
        └── sleep.png                    # Animación durmiendo
```

---

## 🎮 ARCO 7: IRA (Wrath)

### 📋 Archivos Necesarios

#### Juego Principal
- `lib/game/arcs/wrath/wrath_arc_game.dart`
  - Lógica principal del arco
  - Mecánica de ira (explosiones, destrucción)

#### Escena
- `lib/game/arcs/wrath/wrath_scene.dart`
  - Generación de obstáculos temáticos (fuego, destrucción)
  - Decoración roja/naranja
  - Atmósfera caótica/violenta

#### Componentes
- `lib/game/arcs/wrath/components/player_component.dart` (opcional)

- `lib/game/arcs/wrath/components/berserker_enemy.dart`
  - Enemigo "Berserker"
  - IA extremadamente agresiva
  - Ataques de área

- `lib/game/arcs/wrath/components/evidence_component.dart`

- `lib/game/arcs/wrath/components/hiding_spot_component.dart`

- `lib/game/arcs/wrath/components/exit_door_component.dart`

- `lib/game/arcs/wrath/components/explosion_component.dart` (mecánica única)
  - Explosiones periódicas
  - Zonas de peligro

- `lib/game/arcs/wrath/components/fire_projectile.dart`
  - Proyectiles de fuego

#### Assets Necesarios
```
assets/images/
├── fire.png                             # Fuego
├── explosion.png                        # Explosión
└── animations/
    └── lpc_berserker_animations/standard/
        ├── idle.png
        ├── walk.png
        ├── run.png
        └── attack.png                   # Animación de ataque
```

---

## 🎨 Assets Compartidos (Ya Existen)

Estos assets son usados por todos los arcos:

```
assets/
├── images/
│   ├── background.png
│   ├── heart.png
│   └── menu.png
├── videos/
│   ├── lobby.mp4
│   └── menu.mp4
├── music/
│   ├── horror-361619.mp3
│   └── suspense-music-56054.mp3
└── sounds/
    ├── angry-baby-cry-36152.mp3
    ├── camara-101596.mp3
    ├── glitch_09-226602.mp3
    ├── golpes-323708.mp3
    ├── i-see-you-313586.mp3
    ├── laughter-track-361870.mp3
    ├── new-notification-09-352705.mp3
    ├── new-notification-3-398649.mp3
    ├── small-group-laughing-6192.mp3
    └── tape-player-sounds-90780.mp3
```

---

## 📝 Checklist de Implementación por Arco

Para cada arco, asegúrate de tener:

### Código
- [ ] `{arco}_arc_game.dart` - Lógica principal
- [ ] `{arco}_scene.dart` - Generación de escena
- [ ] `enemy_component.dart` - Enemigo con IA
- [ ] `evidence_component.dart` - Evidencia coleccionable
- [ ] `hiding_spot_component.dart` - Lugares para esconderse
- [ ] `exit_door_component.dart` - Puerta de salida
- [ ] Componentes de mecánicas únicas

### Assets
- [ ] Sprites del enemigo (idle, walk, run)
- [ ] Sprites del jugador (si es específico)
- [ ] Imágenes de objetos únicos
- [ ] Sonidos específicos (opcional)

### Integración
- [ ] Registrado en `arc_game_screen.dart`
- [ ] Datos en `arc_data_provider.dart`
- [ ] Assets en `pubspec.yaml`

---

## 🎯 Prioridad de Implementación

1. ✅ **ARCO 1: GULA** - Completamente implementado
2. 🔄 **ARCO 2: AVARICIA** - Parcialmente implementado
3. 🔄 **ARCO 3: ENVIDIA** - Parcialmente implementado
4. 🔄 **ARCO 4: LUJURIA** - Parcialmente implementado
5. 🔄 **ARCO 5: SOBERBIA** - Parcialmente implementado
6. 🔄 **ARCO 6: PEREZA** - Parcialmente implementado
7. 🔄 **ARCO 7: IRA** - Parcialmente implementado

---

## 💡 Notas Importantes

1. **Reutilización**: Muchos componentes pueden ser reutilizados entre arcos (player_component, evidence_component, etc.)

2. **Mecánicas Únicas**: Cada arco debe tener al menos UNA mecánica única que represente su pecado

3. **Assets**: Los sprites LPC pueden ser generados en: https://sanderfrenken.github.io/Universal-LPC-Spritesheet-Character-Generator/

4. **Consistencia**: Mantener la misma estructura de carpetas y nombres para facilitar el mantenimiento

5. **Testing**: Cada arco debe ser jugable de principio a fin antes de considerarse completo

---

**Fecha de creación**: 14 de Noviembre, 2025
**Última actualización**: 14 de Noviembre, 2025
