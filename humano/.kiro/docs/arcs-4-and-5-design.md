# Arcos 4 y 5 - Diseño y Especificaciones

## ARCO 4: LUJURIA - "Entre Sábanas y Pantallas"

### Tema
**Adriana (Cabra)** - Víctima de revenge porn viral. Perdió trabajo, familia y dignidad.

### Pecado del Jugador
Distribuiste contenido íntimo sin consentimiento que se volvió viral.

### Escenario
**Hotel de lujo → Club nocturno sórdido**
- Colores: Rojos intensos, rosas neón, púrpuras oscuros
- Ambiente: Seductor pero perturbador
- Iluminación: Luces intermitentes, neón parpadeante

### Mecánica Única: Deepfakes Visuales

#### 1. Ilusiones y Duplicaciones
```dart
class IllusionSystem {
  // Pasillos que se duplican
  List<FakeHallway> fakeHallways = [];
  
  // Puertas falsas que no llevan a ningún lado
  List<FakeDoor> fakeDoors = [];
  
  // Duplicados del enemigo (solo uno es real)
  List<EnemyIllusion> illusions = [];
  
  void spawnIllusion() {
    // Crear 2-3 copias del enemigo
    // Solo una es real y puede dañar
    // Las otras desaparecen al tocarlas
  }
}
```

#### 2. Distorsión de Realidad
- **Efecto visual**: Pantallas glitcheadas, duplicación de sprites
- **Confusión espacial**: El mapa se "dobla" sobre sí mismo
- **Puertas trampa**: Algunas puertas te teletransportan a lugares aleatorios

#### 3. Mecánica de Identificación
```dart
// El jugador debe identificar cuál enemigo es real
// Pistas:
// - El real proyecta sombra
// - El real hace sonido al moverse
// - Las ilusiones tienen ligero efecto de transparencia
```

### Comportamiento del Enemigo (Cabra)

#### Estados
```dart
enum LustEnemyState {
  seducing,    // Movimiento lento, crea ilusiones
  aggressive,  // Persecución rápida cuando te detecta
  illusion,    // Se divide en múltiples copias
}
```

#### Características
- **Velocidad base**: 100 px/s (normal)
- **Velocidad agresiva**: 200 px/s (muy rápida)
- **Frecuencia de ilusiones**: Cada 10 segundos
- **Número de ilusiones**: 2-3 copias
- **Duración de ilusiones**: 8 segundos

### Cinemática Final
**Escena**: Adriana te atrapa en el club nocturno.
- No te toca físicamente
- Reproduce en loop el video que arruinó su vida
- Todas las pantallas del club muestran el contenido
- Mensaje: El daño permanente del contenido viral

### Cinemática de Victoria
```
"Ese video era privado"
"Hasta que lo compartiste"
[Pausa larga]
"Ahora su nombre está en todas partes"
"Y tú seguiste scrolleando"
```

### Valores de Referencia
| Parámetro | Valor |
|-----------|-------|
| Velocidad seducción | 100 px/s |
| Velocidad agresiva | 200 px/s |
| Ilusiones simultáneas | 2-3 |
| Duración ilusión | 8s |
| Cooldown ilusión | 10s |
| Radio detección | 250px |

---

## ARCO 5: SOBERBIA - "El Teatro de los Acusados"

### Tema
**Ricardo (León)** - Activista cuya reputación fue destruida por acusaciones falsas virales.

### Pecado del Jugador
Iniciaste una cancelación masiva con un thread de Twitter lleno de mentiras.

### Escenario
**Teatro vacío → Set de televisión**
- Colores: Dorados, amarillos brillantes, blancos cegadores
- Ambiente: Teatral, dramático, escenario
- Iluminación: Reflectores, luces de escenario

### Mecánica Única: Sistema de Diálogo y Trampas

#### 1. Debate Verbal
```dart
class DebateSystem {
  List<Question> questions = [];
  
  void presentQuestion(Question q) {
    // Mostrar pregunta en pantalla
    // 3 opciones de respuesta
    // Timer de 10 segundos para responder
  }
  
  void evaluateAnswer(int choice) {
    if (choice == correctAnswer) {
      // Avanzar, desactivar trampa
      disableTrap();
    } else {
      // Activar trampa escénica
      activateTrap();
    }
  }
}
```

#### 2. Trampas Escénicas
```dart
enum StageTrap {
  fallingLights,    // Luces caen del techo
  trapdoor,         // Puerta trampa en el suelo
  movingWalls,      // Paredes que se cierran
  spotlightBurn,    // Reflector que quema (daño)
}
```

#### 3. Preguntas de Debate
Ejemplos de preguntas que Ricardo hace:
- "¿Verificaste los hechos antes de publicar?"
- "¿Sabías que era mentira?"
- "¿Te importó el daño que causarías?"

**Respuestas**:
- Opción A: Honesta (correcta)
- Opción B: Evasiva (incorrecta - activa trampa)
- Opción C: Mentira (incorrecta - activa trampa)

### Comportamiento del Enemigo (León)

#### Estados
```dart
enum PrideEnemyState {
  challenging,  // Te desafía verbalmente, no ataca
  judging,      // Espera tu respuesta
  punishing,    // Activa trampas si mientes
  accepting,    // Si dices la verdad, te deja pasar
}
```

#### Características
- **Velocidad**: 80 px/s (lento, teatral)
- **No persigue**: Se mantiene en el escenario
- **Invoca trampas**: En vez de atacar directamente
- **Frecuencia de preguntas**: Cada 15 segundos
- **Tiempo para responder**: 10 segundos

### Mecánica de Progresión
```dart
// Para avanzar, debes:
// 1. Recolectar evidencias (como siempre)
// 2. Responder correctamente a 3 preguntas de Ricardo
// 3. Llegar a la puerta de salida

int correctAnswers = 0;
const int requiredAnswers = 3;

void checkVictoryCondition() {
  if (evidenceCollected >= 5 && correctAnswers >= 3) {
    // Puede salir
    exitUnlocked = true;
  }
}
```

### Cinemática Final
**Escena**: Ricardo te ofrece un micrófono en el set de TV.
- "Di la verdad ante el mundo"
- Si dices la verdad: Avanzas, pero con peso de culpa
- Si mientes: Ricardo ataca (game over alternativo)

### Cinemática de Victoria
```
"Thread: 'LA VERDAD SOBRE ████████'"
"47 retweets en 3 minutos"
"Trending Topic en 1 hora"
[Glitch]
"Familia destruida"
"Carrera terminada"
"Verdad enterrada"
```

### Valores de Referencia
| Parámetro | Valor |
|-----------|-------|
| Velocidad enemigo | 80 px/s |
| Preguntas requeridas | 3 |
| Tiempo por pregunta | 10s |
| Cooldown pregunta | 15s |
| Daño por trampa | 15% cordura |
| Radio de trampa | 100px |

---

## Implementación Técnica

### Arco 4: Lujuria

#### Componentes Necesarios
```dart
// Enemigo
- animated_lust_enemy_sprite.dart
- lust_enemy_component.dart (Cabra)

// Mecánicas
- illusion_system.dart
- fake_door_component.dart
- fake_hallway_component.dart
- enemy_illusion_component.dart

// Escenario
- lust_scene.dart (Hotel/Club)
```

#### Sistema de Ilusiones
```dart
class IllusionManager {
  void createIllusions(Vector2 enemyPos) {
    // Crear 2-3 copias del enemigo
    for (int i = 0; i < 3; i++) {
      final offset = Vector2(
        random.nextDouble() * 200 - 100,
        random.nextDouble() * 200 - 100,
      );
      
      final illusion = EnemyIllusion(
        position: enemyPos + offset,
        duration: 8.0,
      );
      
      world.add(illusion);
    }
  }
}
```

### Arco 5: Soberbia

#### Componentes Necesarios
```dart
// Enemigo
- animated_pride_enemy_sprite.dart
- pride_enemy_component.dart (León)

// Mecánicas
- debate_system.dart
- question_ui_component.dart
- stage_trap_component.dart
- trap_manager.dart

// Escenario
- pride_scene.dart (Teatro/TV Set)
```

#### Sistema de Debate
```dart
class DebateSystem {
  List<Question> questions = [
    Question(
      text: "¿Verificaste los hechos?",
      options: ["Sí, lo hice", "No importaba", "No lo recuerdo"],
      correctIndex: 0,
    ),
    // ... más preguntas
  ];
  
  void showQuestion() {
    // Pausar juego
    // Mostrar UI de pregunta
    // Iniciar timer
  }
  
  void onAnswer(int choice) {
    if (choice == currentQuestion.correctIndex) {
      correctAnswers++;
      // Desactivar trampa
    } else {
      // Activar trampa
      activateRandomTrap();
    }
  }
}
```

---

## Paletas de Color

### Arco 4: Lujuria
```dart
static const Color backgroundColor = Color(0xFF1A0A0F); // Rojo muy oscuro
static const Color wallColor = Color(0xFF2D1420); // Púrpura oscuro
static const Color neonPink = Color(0xFFFF1493); // Rosa neón
static const Color neonRed = Color(0xFFFF0040); // Rojo neón
static const Color floorColor = Color(0xFF0F0A0D); // Casi negro
```

### Arco 5: Soberbia
```dart
static const Color backgroundColor = Color(0xFF1A1A0F); // Dorado oscuro
static const Color stageColor = Color(0xFF2D2A15); // Madera de escenario
static const Color spotlightGold = Color(0xFFFFD700); // Dorado brillante
static const Color curtainRed = Color(0xFF8B0000); // Rojo cortina
static const Color floorColor = Color(0xFF0F0F0A); // Casi negro
```

---

## Checklist de Implementación

### Arco 4: Lujuria
- [ ] Crear escenario Hotel/Club
- [ ] Implementar enemigo Cabra con sprite
- [ ] Sistema de ilusiones (copias del enemigo)
- [ ] Puertas falsas y pasillos duplicados
- [ ] Efecto de distorsión visual
- [ ] Mecánica de identificación (real vs ilusión)
- [ ] Cinemática final con pantallas en loop
- [ ] Cinemática de victoria
- [ ] Testing de mecánicas de confusión

### Arco 5: Soberbia
- [ ] Crear escenario Teatro/TV Set
- [ ] Implementar enemigo León con sprite
- [ ] Sistema de debate con UI
- [ ] Preguntas y respuestas
- [ ] Timer de respuesta
- [ ] Trampas escénicas (4 tipos)
- [ ] Mecánica de progresión (evidencias + respuestas)
- [ ] Cinemática final con micrófono
- [ ] Cinemática de victoria
- [ ] Testing de sistema de diálogo

---

## Notas de Diseño

### Lujuria
- **Tema**: Violación de privacidad, revenge porn
- **Sensación**: Confusión, desorientación, paranoia
- **Mensaje**: El contenido íntimo compartido sin consentimiento destruye vidas
- **Mecánica refleja tema**: Las ilusiones representan cómo la víctima ya no sabe qué es real

### Soberbia
- **Tema**: Cancel culture, acusaciones falsas virales
- **Sensación**: Juicio público, presión de responder
- **Mensaje**: Las mentiras virales destruyen reputaciones sin posibilidad de defensa
- **Mecánica refleja tema**: Debes enfrentar la verdad o sufrir consecuencias

---

## Próximos Pasos

1. **Decidir orden de implementación**: ¿Lujuria o Soberbia primero?
2. **Crear sprites LPC** para Cabra y León (si no existen)
3. **Implementar mecánicas únicas** antes que enemigos
4. **Testing exhaustivo** de sistemas complejos (ilusiones, diálogo)
5. **Balance** de dificultad y tiempos

---

## Advertencia Importante

**Este contenido es ficción y parte de un juego educativo sobre las consecuencias del cyberbullying y la viralización irresponsable de contenido.**

El juego no glorifica ni trivializa estos temas, sino que busca crear conciencia sobre el impacto real de las acciones en línea.
