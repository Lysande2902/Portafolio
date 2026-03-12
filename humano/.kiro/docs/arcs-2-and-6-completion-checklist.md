# Checklist de Completación - Arcos 2 y 6

## Estado Actual

### ✅ COMPLETADO

#### Arco 2: Avaricia (Greed)
- [x] Escenario de centro comercial/banco
- [x] Sistema de cajas registradoras
- [x] Mecánica de robo de cordura (10%)
- [x] Componente de caja registradora con visual
- [x] Enemigo Hiena con sprite animado LPC
- [x] Estados de patrulla y persecución
- [x] Velocidades aumentadas (20% más rápido)
- [x] Cooldown de robo (5 segundos)
- [x] Cinemática de victoria

#### Arco 6: Pereza (Sloth)
- [x] Escenario de hospital psiquiátrico
- [x] Sistema de baba tóxica
- [x] Sistema de ruido/sigilo
- [x] Componente de baba con slowdown
- [x] Enemigo Caracol con sprite animado LPC
- [x] Estados: sleeping, patrol, chase
- [x] Mecánica de despertar por ruido
- [x] Generación de rastro de baba
- [x] Velocidades muy lentas (40%)
- [x] Cinemática de victoria

---

## ⚠️ PENDIENTE PARA COMPLETAR

### Arco 2: Avaricia

#### 1. Testing y Balance
```bash
# Probar en el juego:
- [ ] Enemigo Hiena aparece correctamente
- [ ] Sprite animado funciona en 4 direcciones
- [ ] Robo de evidencia funciona
- [ ] Robo de cordura (10%) funciona
- [ ] Cajas registradoras son visibles
- [ ] Recuperación de cordura funciona
- [ ] Velocidad del enemigo se siente correcta
- [ ] Cooldown de robo funciona
```

#### 2. Audio (Opcional)
```dart
- [ ] Sonido de risa constante de la Hiena
- [ ] Sonido al robar evidencia
- [ ] Sonido al abrir caja registradora
- [ ] Música de fondo tensa
```

#### 3. Efectos Visuales (Opcional)
```dart
- [ ] Partículas doradas al abrir caja
- [ ] Efecto visual al robar
- [ ] Animación de robo
```

#### 4. Cinemática Final Especial
```dart
- [ ] Escena con fotos de hijos en refugio
- [ ] Diálogo: "¿Valió la pena los likes?"
- [ ] Transición emocional
```

---

### Arco 6: Pereza

#### 1. Testing y Balance
```bash
# Probar en el juego:
- [ ] Enemigo Caracol aparece correctamente
- [ ] Sprite animado funciona en 4 direcciones
- [ ] Comienza dormido
- [ ] Despierta con ruido > 70%
- [ ] Vuelve a dormir con ruido < 30%
- [ ] Genera baba al moverse
- [ ] Baba ralentiza al jugador
- [ ] Baba desaparece después de 10s
- [ ] Velocidades se sienten correctas
```

#### 2. Audio (Opcional)
```dart
- [ ] Sonido de ronquidos cuando duerme
- [ ] Sonido al despertar
- [ ] Sonido de movimiento lento
- [ ] Ambiente silencioso/opresivo
```

#### 3. Efectos Visuales (Opcional)
```dart
- [ ] Partículas de baba al moverse
- [ ] Efecto de sueño (Z's flotando)
- [ ] Indicador visual de nivel de ruido
- [ ] Efecto de slowdown en jugador
```

#### 4. Cinemática Final Especial
```dart
- [ ] Efecto de glitch en cinemática
- [ ] Diálogo: "Yo también era humano"
- [ ] Samuel desaparece en las sombras
- [ ] Transición melancólica
```

---

## 🔧 Pasos para Completar

### Fase 1: Testing Básico (PRIORITARIO)

1. **Compilar y ejecutar el juego**
```bash
flutter run
```

2. **Probar Arco 2: Avaricia**
   - Seleccionar Arco 2 desde el menú
   - Verificar que el enemigo Hiena aparece
   - Verificar animaciones
   - Probar mecánica de robo
   - Probar cajas registradoras
   - Completar el arco

3. **Probar Arco 6: Pereza**
   - Seleccionar Arco 6 desde el menú
   - Verificar que el enemigo Caracol aparece
   - Verificar que comienza dormido
   - Probar mecánica de ruido
   - Probar baba tóxica
   - Completar el arco

### Fase 2: Ajustes de Balance

Basado en el testing, ajustar:

#### Arco 2
```dart
// Si el enemigo es muy rápido:
static const double chaseSpeed = 160.0; // Reducir de 180

// Si roba muy seguido:
static const double stealCooldownTime = 7.0; // Aumentar de 5

// Si recuperas mucha cordura:
final recovered = (stolenSanity * 0.3); // Reducir de 0.5
```

#### Arco 6
```dart
// Si el enemigo despierta muy fácil:
if (noiseLevel > 0.8) { // Aumentar de 0.7

// Si la baba ralentiza mucho:
final slowdownFactor = 0.6; // Aumentar de 0.5

// Si despierta muy rápido:
noiseLevel += dt * 1.5; // Reducir de 2.0
```

### Fase 3: Pulido (Opcional)

1. **Agregar sonidos básicos**
   - Usar assets de sonido existentes
   - Implementar AudioPlayer para efectos

2. **Mejorar feedback visual**
   - Partículas simples
   - Efectos de pantalla

3. **Cinemáticas finales especiales**
   - Implementar escenas únicas
   - Agregar diálogos

---

## 📋 Checklist de Verificación Final

### Antes de Considerar Completo

#### Funcionalidad Core
- [ ] Ambos arcos son jugables de inicio a fin
- [ ] No hay crashes ni errores de compilación
- [ ] Sprites animados funcionan correctamente
- [ ] Mecánicas únicas funcionan como se espera
- [ ] Cinemáticas de victoria se muestran
- [ ] Progreso se guarda correctamente

#### Balance
- [ ] Dificultad es apropiada (no muy fácil/difícil)
- [ ] Mecánicas únicas son claras para el jugador
- [ ] Tiempos y velocidades se sienten bien
- [ ] Recompensas son justas

#### Pulido
- [ ] No hay bugs visuales obvios
- [ ] Rendimiento es aceptable (no lag)
- [ ] UI es clara y legible
- [ ] Transiciones son suaves

---

## 🐛 Problemas Conocidos a Verificar

### Arco 2: Avaricia
```dart
// Verificar que el enemigo no robe cuando está en cooldown
if (stealCooldown > 0) {
  print('Cooldown activo: ${stealCooldown.toStringAsFixed(1)}s');
  return; // No robar
}

// Verificar que las cajas no se pueden saquear dos veces
if (cashRegister.isLooted) {
  return; // Ya saqueada
}
```

### Arco 6: Pereza
```dart
// Verificar que el enemigo no se queda atascado dormido
if (noiseLevel < 0.3 && distanceToPlayer > 300) {
  goToSleep(); // Solo si está lejos
}

// Verificar que la baba no causa lag
if (slimeCount > 50) {
  removeOldestSlime(); // Limpiar baba vieja
}
```

---

## 📊 Métricas de Éxito

### Arco 2: Avaricia
- Tiempo promedio de completación: 3-5 minutos
- Veces robado por partida: 2-4
- Cajas saqueadas: 2-3
- Tasa de victoria: 60-70%

### Arco 6: Pereza
- Tiempo promedio de completación: 4-6 minutos
- Veces que despierta enemigo: 1-3
- Charcos de baba generados: 20-40
- Tasa de victoria: 50-60%

---

## 🚀 Comando de Testing Rápido

```bash
# Compilar y ejecutar
flutter run

# Si hay errores, revisar:
flutter doctor
flutter clean
flutter pub get
flutter run
```

---

## 📝 Notas Finales

### Prioridades
1. **CRÍTICO**: Que ambos arcos sean jugables sin crashes
2. **IMPORTANTE**: Que las mecánicas únicas funcionen
3. **DESEABLE**: Audio y efectos visuales
4. **OPCIONAL**: Cinemáticas finales especiales

### Siguiente Paso
Una vez que Arcos 2 y 6 estén completos y testeados:
- Documentar lecciones aprendidas
- Usar como base para Arcos 3, 4, 5, 7
- Considerar sistema de dificultad ajustable

---

## ✅ Criterio de "Completado"

Un arco se considera completado cuando:
1. ✅ Es jugable de inicio a fin sin crashes
2. ✅ La mecánica única funciona correctamente
3. ✅ El enemigo se comporta como se espera
4. ✅ La cinemática de victoria se muestra
5. ✅ El progreso se guarda
6. ✅ No hay bugs críticos
7. ✅ El rendimiento es aceptable

**Los Arcos 2 y 6 están ~95% completos. Solo falta testing y ajustes menores.**
