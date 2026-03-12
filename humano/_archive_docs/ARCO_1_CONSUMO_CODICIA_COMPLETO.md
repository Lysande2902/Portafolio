# ARCO 1: CONSUMO Y CODICIA - DOCUMENTACIÓN COMPLETA

**Fecha**: 28 de enero de 2025  
**Estado**: ✅ IMPLEMENTADO Y FUNCIONAL  
**Tipo**: Arco Fusionado (Gula + Avaricia)

---

## 📋 INFORMACIÓN GENERAL

### Identificación
- **ID**: `arc_1_consumo_codicia`
- **Número**: 1
- **Título**: CONSUMO Y CODICIA
- **Subtítulo**: Excesos Materiales
- **Pecados**: Gula (Gluttony) + Avaricia (Greed)

### Descripción
Escapa del almacén mientras enfrentas a dos enemigos que representan los excesos materiales: Mateo (Cerdo) que devora todo a su paso, y Valeria (Rata) que roba evidencias y cordura.

### Desbloqueo
- **Desbloqueado por defecto**: Sí (primer arco del juego)
- **Requisitos**: Ninguno

---

## 🎮 MECÁNICAS DE JUEGO

### Objetivo Principal
Recolectar 10 fragmentos de evidencia y escapar por la puerta de salida.

### Sistema de Fases
El arco está dividido en 2 fases con checkpoint:

#### Fase 1: Mateo (Cerdo) - Gula
- **Fragmentos**: 0-5
- **Enemigo**: Mateo (Cerdo)
- **Mecánica**: Devora evidencias si las alcanza
- **Área**: Primera mitad del mapa (x: 0-2400)
- **Tema visual**: Almacén/Restaurante (cajas de madera)

#### Fase 2: Valeria (Rata) - Avaricia
- **Fragmentos**: 5-10
- **Enemigo**: Valeria (Rata)
- **Mecánica**: Roba evidencias y cordura
- **Área**: Segunda mitad del mapa (x: 2400-4800)
- **Tema visual**: Bóveda/Banco (cajas fuertes metálicas)

### Checkpoint (5 Fragmentos)
Al recolectar 5 fragmentos:
1. Mateo desaparece del mapa
2. Valeria aparece en la segunda mitad
3. El jugador continúa en la misma posición
4. Log: `🎯 [CHECKPOINT] Reached! Switching from Mateo to Valeria`

---

## 🗺️ MAPA Y ESCENARIO

### Dimensiones
- **Ancho total**: 4800 píxeles (doble de un arco normal)
- **Alto**: 1600 píxeles
- **Área jugable**: (40, 40) a (4760, 1560)
- **Grosor de paredes**: 40 píxeles

### Distribución del Mapa

```
┌─────────────────────────────────────────────────────────────┐
│                    FASE 1: ALMACÉN                          │
│                    (0 - 2400)                               │
│                                                             │
│  Tema: Warehouse/Restaurant                                │
│  Fondo: Textura de concreto oscuro                         │
│  Obstáculos: Cajas de madera (crate texture)              │
│  Enemigo: Mateo (Cerdo)                                    │
│  Fragmentos: 5 evidencias                                  │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                  CHECKPOINT (x=2400)                        │
│                  Línea roja vertical                        │
├─────────────────────────────────────────────────────────────┤
│                    FASE 2: BÓVEDA                           │
│                    (2400 - 4800)                            │
│                                                             │
│  Tema: Vault/Bank                                          │
│  Fondo: Textura metálica oscura                            │
│  Obstáculos: Cajas fuertes (vault texture)                │
│  Enemigo: Valeria (Rata)                                   │
│  Fragmentos: 5 evidencias                                  │
│  Salida: Puerta en x=4600                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Texturas Procedurales

#### Fase 1: Cajas de Madera (`crate`)
- Vetas de madera horizontales
- Tablones verticales
- Clavos en las esquinas
- Manchas de suciedad/desgaste
- Color base: `#3a2f2a` (marrón)

#### Fase 2: Cajas Fuertes (`vault`)
- Brillo metálico diagonal
- Remaches alrededor de los bordes
- Cerradura central (en cajas grandes)
- Rayones y desgaste
- Color base: `#2a2a3a` (gris-azul)

#### Fondos
- **Fase 1**: Concreto con grietas, manchas, cuadrícula de baldosas
- **Fase 2**: Metal con paneles, remaches, rayas de brillo

---

## 🎯 POSICIONES DE ELEMENTOS

### Jugador
- **Posición inicial**: `Vector2(200, 800)` (centro-izquierda)
- **Tamaño**: 40x60 píxeles
- **Velocidad**: 180 píxeles/segundo

### Evidencias (10 total)

#### Fase 1 (5 evidencias)
```dart
Vector2(500, 700),    // Evidencia 1
Vector2(1000, 1100),  // Evidencia 2
Vector2(1500, 700),   // Evidencia 3
Vector2(1900, 1200),  // Evidencia 4
Vector2(1200, 1400),  // Evidencia 5
```

#### Fase 2 (5 evidencias)
```dart
Vector2(2700, 800),   // Evidencia 6
Vector2(3200, 1200),  // Evidencia 7
Vector2(3700, 800),   // Evidencia 8
Vector2(4100, 1300),  // Evidencia 9
Vector2(3400, 1400),  // Evidencia 10
```

### Obstáculos

#### Fase 1: Cajas de Madera (25 obstáculos)
- **Tamaño mediano**: 120x120 píxeles (23 cajas)
- **Tamaño grande**: 160x160 píxeles (2 cajas centrales)
- **Distribución**: 5 filas alineadas a grid (múltiplos de 100)

#### Fase 2: Cajas Fuertes (25 obstáculos)
- **Tamaño mediano**: 120x120 píxeles (23 cajas)
- **Tamaño grande**: 160x160 píxeles (2 cajas centrales)
- **Distribución**: 5 filas alineadas a grid

### Escondites (8 total)

#### Fase 1 (4 escondites)
```dart
Vector2(300, 400),    // Tamaño: 160x160
Vector2(1100, 600),   // Tamaño: 180x180
Vector2(800, 1100),   // Tamaño: 170x170
Vector2(1700, 1200),  // Tamaño: 160x160
```

#### Fase 2 (4 escondites)
```dart
Vector2(2700, 600),   // Tamaño: 170x170
Vector2(3300, 1000),  // Tamaño: 180x180
Vector2(3900, 700),   // Tamaño: 160x160
Vector2(4300, 1300),  // Tamaño: 170x170
```

### Puerta de Salida
- **Posición**: `Vector2(4600, 800)` (final del mapa)
- **Requisito**: 10 fragmentos recolectados
- **Radio de activación**: 60 píxeles

---

## 👹 ENEMIGOS

### Mateo (Cerdo) - Fase 1

#### Características
- **Tipo**: `EnemyComponent` (del arco Gluttony)
- **Pecado**: Gula
- **Apariencia**: Cerdo (sprite LPC)
- **Skin personalizable**: Sí

#### Comportamiento
- **Patrullaje**: Sigue waypoints en la primera mitad del mapa
- **Detección**: Detecta al jugador por proximidad
- **Persecución**: Persigue al jugador cuando lo detecta
- **Mecánica especial**: Devora evidencias si las alcanza

#### Waypoints (8 puntos)
```dart
Vector2(400, 600),
Vector2(800, 1000),
Vector2(1200, 600),
Vector2(1600, 1100),
Vector2(2000, 700),
Vector2(1600, 1300),
Vector2(1000, 1200),
Vector2(600, 900),
```

#### Estadísticas
- **Velocidad base**: Media
- **Radio de detección**: ~200 píxeles
- **Radio de captura**: 40 píxeles

### Valeria (Rata) - Fase 2

#### Características
- **Tipo**: `BankerEnemy` (del arco Greed)
- **Pecado**: Avaricia
- **Apariencia**: Rata (sprite LPC)
- **Skin personalizable**: Sí

#### Comportamiento
- **Patrullaje**: Sigue waypoints en la segunda mitad del mapa
- **Detección**: Detecta al jugador por proximidad
- **Persecución**: Persigue al jugador cuando lo detecta
- **Mecánica especial**: Roba evidencias y cordura

#### Waypoints (8 puntos)
```dart
Vector2(2600, 700),
Vector2(3000, 1100),
Vector2(3400, 700),
Vector2(3800, 1200),
Vector2(4200, 800),
Vector2(3800, 1400),
Vector2(3200, 1300),
Vector2(2800, 1000),
```

#### Estadísticas
- **Velocidad base**: Media-Alta
- **Radio de detección**: ~250 píxeles
- **Radio de captura**: 40 píxeles

---

## 🎨 SISTEMA DE COLISIONES

### Componentes con Colisión

#### Jugador (`PlayerComponent`)
- **Anchor**: `Anchor.topLeft`
- **Tamaño**: 40x60 píxeles
- **Hitbox**: `RectangleHitbox` (40x60)
- **Verificación**: Manual AABB en `update()`

#### Obstáculos (`ObstacleComponent`, `TexturedObstacleComponent`)
- **Anchor**: `Anchor.topLeft`
- **Tamaños**: 120x120 o 160x160 píxeles
- **Hitbox**: `RectangleHitbox` (mismo tamaño)

#### Paredes (`WallComponent`)
- **Anchor**: `Anchor.topLeft`
- **Grosor**: 40 píxeles
- **Hitbox**: `RectangleHitbox` (mismo tamaño)

### Algoritmo de Colisión (AABB)

```dart
// En PlayerComponent.update()
void update(double dt) {
  // 1. Guardar posición actual
  previousPosition = position.clone();
  
  // 2. Calcular nueva posición
  final newPosition = position + velocity * dt;
  
  // 3. Verificar colisiones ANTES de mover
  bool wouldCollide = false;
  
  for (final component in parent!.children) {
    if (component is Obstacle || Wall || TexturedObstacle) {
      // Crear rectángulos AABB
      final myRect = Rect.fromLTWH(newPosition.x, newPosition.y, size.x, size.y);
      final otherRect = Rect.fromLTWH(component.position.x, component.position.y, 
                                       component.size.x, component.size.y);
      
      // Verificar overlap
      if (myRect.overlaps(otherRect)) {
        wouldCollide = true;
        break;
      }
    }
  }
  
  // 4. Solo mover si NO hay colisión
  if (!wouldCollide) {
    position = newPosition;
  } else {
    velocity = Vector2.zero();
  }
}
```

### Ventajas del Sistema
- ✅ Predictivo (verifica ANTES de mover)
- ✅ Preciso (AABB es exacto para rectángulos)
- ✅ Confiable (no depende de callbacks de Flame)
- ✅ Eficiente (~50 obstáculos verificados en <1ms)

---

## 📄 SISTEMA DE FRAGMENTOS

### Recolección Durante el Juego

```dart
void _checkEvidenceCollection() {
  for (final component in world.children) {
    if (component is EvidenceComponent && !component.isCollected) {
      final distance = (component.position - _player!.position).length;
      
      // Radio de recolección: 80 píxeles
      if (distance < 80) {
        component.collect();
        evidenceCollected++;  // Contador local (temporal)
        
        // Actualizar UI
        onEvidenceCollectedChanged?.call();
        
        debugPrint('📄 Evidence collected! Total: $evidenceCollected/10');
      }
    }
  }
}
```

### Guardado en Firebase (Al Ganar)

```dart
// En arc_game_screen.dart
void _onVictory() async {
  final fragmentsProvider = Provider.of<FragmentsProvider>(context);
  
  // Guardar fragmentos recolectados
  await fragmentsProvider.unlockFragmentsForArcProgress(
    'arc_1_consumo_codicia',  // ID del arco
    game.evidenceCollected,    // Cuántos fragmentos (0-10)
  );
}
```

### Lógica de Guardado Progresivo

```dart
// En fragments_provider.dart
Future<void> unlockFragmentsForArcProgress(String arcId, int fragmentsCollected) async {
  int maxFragments = 10;  // Arco fusionado
  
  // Desbloquear fragmentos progresivamente
  for (int i = 1; i <= fragmentsCollected && i <= maxFragments; i++) {
    if (!isFragmentUnlocked(arcId, i)) {
      await unlockFragment(arcId, i);  // Guarda en Firebase
    }
  }
}
```

### Contenido de Fragmentos

#### Fragmento 1: "El Video Viral"
```
"El video explotó. 2.3 millones de vistas en 24 horas. 
Los comentarios eran brutales. 'Gordo asqueroso', 'Merece morir de hambre'..."
```

#### Fragmento 2: "Intenté Borrarlo"
```
"Intenté borrarlo, pero ya era tarde. Lo habían compartido miles de veces. 
Alguien encontró su perfil. Su nombre. Su dirección..."
```

#### Fragmento 3: "Mateo Dejó de Responder"
```
"Mateo dejó de responder mensajes. Sus amigos dijeron que no salía de casa. 
Que había dejado de comer. Que solo leía los comentarios una y otra vez..."
```

#### Fragmento 4: "En el Hospital"
```
"Hoy supe que Mateo está en el hospital. Desnutrición severa. 
Yo gané 847,392 likes. Él perdió su dignidad. ¿Valió la pena?"
```

#### Fragmento 5: "Sus Niños Esperan"
```
"Sus niños siguen esperándola en casa. No saben que mamá perdió todo. 
La casa, el carro, los ahorros. Todo por mi culpa..."
```

#### Fragmento 6: "Valeria Perdió Su Casa"
```
"Valeria perdió su casa. El banco se la quitó. Tres meses de retraso. 
Yo le presté dinero... con intereses. Mucho interés."
```

#### Fragmento 7: "El Banco Se Quedó con Todo"
```
"El banco se quedó con todo. Muebles, ropa, recuerdos. 
Valeria llamó llorando. Le dije que no era mi problema."
```

#### Fragmento 8: "La Deuda Creció"
```
"La deuda creció exponencialmente. Intereses sobre intereses. 
Valeria trabajaba 16 horas al día. Nunca fue suficiente."
```

#### Fragmento 9: "Intentó Suicidarse"
```
"Valeria intentó suicidarse. Pastillas. La encontraron a tiempo. 
Yo seguí cobrando. El dinero no tiene sentimientos."
```

#### Fragmento 10: "La Verdad Completa"
```
"Ahora sabes la verdad completa. Dos vidas destruidas por excesos. 
Mateo por consumo. Valeria por codicia. ¿Quién es el verdadero monstruo?"
```

---

## 🎬 CINEMÁTICAS Y PANTALLAS

### Briefing (Antes de Jugar)

```
OBJETIVO:
Recolecta 10 fragmentos y escapa del almacén

MECÁNICA: DOBLE AMENAZA
Primera mitad: Mateo (Cerdo) devora evidencias.
Segunda mitad: Valeria (Rata) roba evidencias y cordura.
Checkpoint a los 5 fragmentos.

CONTROLES:
Joystick para mover + Botón morado para esconderte

TIP:
Usa escondites contra Mateo. Usa cajas registradoras
para recuperar cordura robada por Valeria.
```

### Game Over

```
MENSAJES:
- "Los excesos te consumieron"
- "Mateo y Valeria ganaron"
- "No quedó nada de ti"

FLAVOR TEXT:
"Dos pecados. Una víctima."
```

### Victoria

```
CINEMÁTICA:
"SU MADRE MURIÓ ESPERÁNDOLO"
"SUS NIÑOS SIGUEN ESPERÁNDOLA EN CASA"

ESTADÍSTICAS:
- Fragmentos Recolectados: X de 10
- Tiempo: X.Xs
- Cordura Final: X%
```

---

## 🎮 CONTROLES

### Teclado (PC)
- **WASD / Flechas**: Mover jugador
- **Espacio**: Esconderse (si está cerca de un escondite)
- **ESC**: Pausar juego

### Táctil (Móvil)
- **Joystick virtual**: Mover jugador
- **Botón morado**: Esconderse
- **Botón pausa**: Pausar juego

---

## 📊 CONDICIONES DE VICTORIA Y DERROTA

### Victoria ✅
1. Recolectar 10 fragmentos
2. Llegar a la puerta de salida (x=4600)
3. Estar a menos de 60 píxeles de la puerta
4. La puerta debe estar desbloqueada (10 fragmentos)

```dart
void _checkVictoryCondition() {
  for (final component in world.children) {
    if (component is ExitDoorComponent) {
      final distance = (component.position - _player!.position).length;
      
      if (distance < 60 && evidenceCollected >= 10 && !component.isLocked) {
        onVictory();
      }
    }
  }
}
```

### Game Over ❌

#### Condición 1: Enemigo Atrapa al Jugador
```dart
final distance = (_currentEnemy!.position - _player!.position).length;
if (distance < 40 && !_player!.isHidden) {
  onGameOver();
}
```

#### Condición 2: Cordura Agotada
```dart
if (sanitySystem.isDepleted()) {
  onGameOver();
}
```

---

## 🔧 ARCHIVOS TÉCNICOS

### Archivos Principales

#### 1. `consumo_codicia_arc_game.dart`
- Clase principal del juego
- Maneja lógica de fases y checkpoint
- Controla enemigos y recolección
- **Ubicación**: `lib/game/arcs/consumo_codicia/`

#### 2. `consumo_codicia_scene.dart`
- Configuración del mapa
- Creación de obstáculos y fondos
- Posicionamiento de elementos
- **Ubicación**: `lib/game/arcs/consumo_codicia/`

#### 3. `evidence_component.dart`
- Componente de evidencia/fragmento
- Animación de pulso
- Lógica de recolección
- **Ubicación**: `lib/game/arcs/consumo_codicia/components/`

#### 4. `exit_door_component.dart`
- Puerta de salida
- Actualización de estado según fragmentos
- Verificación de victoria
- **Ubicación**: `lib/game/arcs/consumo_codicia/components/`

#### 5. `hiding_spot_component.dart`
- Escondites para el jugador
- Detección de proximidad
- **Ubicación**: `lib/game/arcs/consumo_codicia/components/`

### Archivos de Soporte

#### 6. `player_component.dart`
- Componente del jugador
- Sistema de colisiones manual
- Animaciones y movimiento
- **Ubicación**: `lib/game/arcs/gluttony/components/`

#### 7. `enemy_component.dart` (Mateo)
- Enemigo de Fase 1
- Patrullaje y persecución
- **Ubicación**: `lib/game/arcs/gluttony/components/`

#### 8. `banker_enemy.dart` (Valeria)
- Enemigo de Fase 2
- Mecánica de robo
- **Ubicación**: `lib/game/arcs/greed/components/`

#### 9. `textured_obstacle_component.dart`
- Obstáculos con textura procedural
- Sistema de colisiones
- **Ubicación**: `lib/game/core/components/`

#### 10. `wall_component.dart`
- Paredes y obstáculos simples
- Colisiones básicas
- **Ubicación**: `lib/game/core/components/`

---

## 🐛 PROBLEMAS CONOCIDOS Y SOLUCIONES

### ✅ SOLUCIONADO: Colisiones No Funcionaban

**Problema**: El jugador atravesaba paredes y obstáculos.

**Causa**: Anchor incorrecto (`Anchor.center` vs `Anchor.topLeft`).

**Solución**: 
- Todos los componentes usan `Anchor.topLeft`
- Verificación manual AABB en `update()`
- **Documentación**: `FIX_COLISIONES_ANCHOR_PROBLEMA.md`

### ✅ SOLUCIONADO: Evidencias Difíciles de Recoger

**Problema**: Algunas evidencias no se podían recoger.

**Causa**: Radio de recolección muy pequeño (50px).

**Solución**: 
- Aumentado radio a 80 píxeles
- Agregados logs de debug
- **Documentación**: `FIX_EVIDENCIAS_Y_FRAGMENTOS.md`

### ✅ SOLUCIONADO: Contador Mostraba 5 en Lugar de 10

**Problema**: El contador mostraba "5 fragmentos" en lugar de "10".

**Causa**: Sistema configurado para arcos individuales (5 fragmentos).

**Solución**: 
- Actualizado `fragments_provider.dart` para soportar 10 fragmentos
- Lógica dinámica según tipo de arco
- **Documentación**: `FIX_EVIDENCIAS_Y_FRAGMENTOS.md`

---

## 📈 ESTADÍSTICAS Y MÉTRICAS

### Complejidad del Mapa
- **Área total**: 7,680,000 píxeles² (4800 × 1600)
- **Obstáculos**: 50 (25 por fase)
- **Escondites**: 8 (4 por fase)
- **Evidencias**: 10 (5 por fase)
- **Enemigos**: 2 (1 por fase)

### Tiempo Estimado de Juego
- **Speedrun**: 3-5 minutos
- **Normal**: 8-12 minutos
- **Explorando todo**: 15-20 minutos

### Dificultad
- **Fase 1**: Media (Mateo es predecible)
- **Fase 2**: Media-Alta (Valeria es más rápida)
- **General**: Media

---

## 🎯 TIPS Y ESTRATEGIAS

### Para Fase 1 (Mateo)
1. **Usa escondites**: Mateo no puede verte si estás escondido
2. **Patrón predecible**: Aprende sus waypoints
3. **Recolecta rápido**: Mateo devora evidencias si las alcanza
4. **Mantén distancia**: Su radio de detección es ~200px

### Para Fase 2 (Valeria)
1. **Muévete rápido**: Valeria es más veloz que Mateo
2. **Protege tu cordura**: Valeria roba cordura al acercarse
3. **Usa cajas registradoras**: Recuperan cordura robada
4. **Planifica ruta**: Los últimos 5 fragmentos están más dispersos

### General
1. **Memoriza posiciones**: Las evidencias siempre están en el mismo lugar
2. **No te escondas innecesariamente**: Pierdes tiempo
3. **Checkpoint automático**: A los 5 fragmentos cambia el enemigo
4. **Puerta al final**: Está en x=4600, extremo derecho del mapa

---

## 🔄 FLUJO COMPLETO DEL ARCO

```
1. INICIO
   ├─ Pantalla de briefing
   ├─ Selección de items (opcional)
   └─ Carga del juego

2. FASE 1 (0-5 fragmentos)
   ├─ Spawn del jugador en (200, 800)
   ├─ Spawn de Mateo en (400, 600)
   ├─ Recolección de evidencias 1-5
   └─ Checkpoint al llegar a 5 fragmentos

3. CHECKPOINT
   ├─ Mateo desaparece
   ├─ Valeria aparece en (2600, 700)
   └─ Jugador continúa en su posición

4. FASE 2 (5-10 fragmentos)
   ├─ Recolección de evidencias 6-10
   ├─ Navegación hacia la puerta (4600, 800)
   └─ Activación de puerta con 10 fragmentos

5. VICTORIA
   ├─ Cinemática de victoria
   ├─ Guardado de fragmentos en Firebase
   ├─ Pantalla de estadísticas
   └─ Regreso al menú

6. GAME OVER (si aplica)
   ├─ Pantalla de game over
   ├─ Opción de reintentar
   └─ Opción de volver al menú
```

---

## 📝 NOTAS DE DESARROLLO

### Versión Actual
- **Versión**: 1.0
- **Última actualización**: 28 de enero de 2025
- **Estado**: Producción

### Cambios Recientes
- ✅ Sistema de colisiones implementado y funcional
- ✅ Texturas procedurales mejoradas
- ✅ Sistema de fragmentos actualizado a 10
- ✅ Radio de recolección aumentado a 80px
- ✅ Logs de debug agregados

### Próximas Mejoras
- [ ] Optimización de rendimiento (spatial partitioning)
- [ ] Más variedad de texturas procedurales
- [ ] Efectos de sonido específicos por fase
- [ ] Animaciones de transición en checkpoint

---

## 🎓 LECCIONES APRENDIDAS

### Diseño
- Los arcos fusionados funcionan bien con checkpoint claro
- 10 fragmentos es un buen balance (no muy corto, no muy largo)
- La división visual (almacén vs bóveda) ayuda a la orientación

### Técnico
- `Anchor.topLeft` es crítico para colisiones AABB
- Verificación manual es más confiable que callbacks
- Logs de debug son esenciales para diagnosticar problemas

### Gameplay
- Radio de recolección de 80px es cómodo
- 2 enemigos con mecánicas diferentes mantiene interés
- Checkpoint a mitad del arco da sensación de progreso

---

**Autor**: Kiro AI  
**Fecha**: 28 de enero de 2025  
**Versión del Documento**: 1.0  

---

## 📚 DOCUMENTACIÓN RELACIONADA

- `LOGICA_FRAGMENTOS_EXPLICACION.md` - Explicación del sistema de fragmentos
- `DIAGRAMA_FRAGMENTOS_SIMPLE.md` - Diagramas visuales del sistema
- `FIX_COLISIONES_ANCHOR_PROBLEMA.md` - Solución de colisiones
- `FIX_EVIDENCIAS_Y_FRAGMENTOS.md` - Solución de recolección
- `SISTEMA_COLISIONES_MEJORADO.md` - Documentación del sistema de colisiones
- `TEXTURAS_PROCEDURALES_GUIA.md` - Guía de texturas procedurales
