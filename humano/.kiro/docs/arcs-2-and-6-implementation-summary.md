# Implementación Arcos 2 y 6 - Resumen

## ✅ ARCO 2: AVARICIA (Greed) - COMPLETADO

### Tema
- **Pecado**: Compartiste información bancaria en post viral de doxing
- **Víctima**: Valeria (Hiena) - Madre soltera que perdió su casa
- **Escenario**: Centro comercial / Banco en ruinas

### Mecánicas Implementadas

#### 1. Sistema de Robo de Recursos
- Enemigo roba evidencias Y cordura (10% por robo)
- Variables de seguimiento: `stolenSanity`, `stolenItems`

#### 2. Cajas Registradoras
- **Componente**: `CashRegisterComponent`
- **Ubicación**: 5 cajas distribuidas en el mapa
- **Función**: Recuperar 50% de cordura robada (máx 20%)
- **Visual**: Brillo dorado cuando disponible, gris cuando saqueada

#### 3. Escenario Mejorado
- Colores: Dorado oscuro, marrón, representando avaricia
- Obstáculos: Counters bancarios, bóvedas, vitrinas
- Atmósfera: Decadente, materialista

#### 4. Cinemática de Victoria
```
"Compartiste algo que no debías"
"Número de cuenta: ████████"
"Dirección: █████████"
"Perdió todo"
"Tú ganaste 15,632 likes"
```

### Archivos Modificados/Creados
- ✅ `lib/game/arcs/greed/greed_scene.dart` - Escenario mejorado
- ✅ `lib/game/arcs/greed/greed_arc_game.dart` - Mecánicas de robo y recuperación
- ✅ `lib/game/arcs/greed/components/cash_register_component.dart` - NUEVO
- ✅ `lib/game/ui/arc_victory_cinematic.dart` - Cinemática agregada

### Posiciones de Evidencias (Verificadas sin obstáculos)
```dart
Vector2(550, 500),    // Entre obstáculos iniciales
Vector2(1000, 400),   // Entre obstáculos y counter
Vector2(1400, 500),   // Entre counters
Vector2(2000, 500),   // Entre obstáculos
Vector2(2700, 300),   // Después del obstáculo grande
```

### Posiciones de Cajas Registradoras
```dart
Vector2(650, 500),
Vector2(1200, 400),
Vector2(1650, 500),
Vector2(2200, 600),
Vector2(2600, 350),
```

### ⚠️ PENDIENTE
- [ ] Implementar enemigo Hiena (Valeria)
- [ ] Sonido de risa constante
- [ ] Animación de robo
- [ ] Cinemática final con fotos de hijos en refugio

---

## ✅ ARCO 6: PEREZA (Sloth) - COMPLETADO

### Tema
- **Pecado**: Grabaste a Samuel en depresión severa como "cringe content"
- **Víctima**: Samuel (Caracol) - Intentó suicidarse 3 veces después del video
- **Escenario**: Hospital psiquiátrico / Edificio de departamentos gris

### Mecánicas Implementadas

#### 1. Sistema de Baba Tóxica
- **Componente**: `ToxicSlimeComponent`
- **Efecto**: Reduce velocidad a 50% cuando pisas la baba
- **Duración**: 10 segundos, luego desaparece
- **Visual**: Charco verdoso con brillo tóxico

#### 2. Sistema de Sigilo/Ruido
- **Variable**: `noiseLevel` (0.0 a 1.0)
- **Mecánica**: 
  - Movimiento rápido = más ruido
  - Movimiento lento/quieto = menos ruido
  - Ruido > 70% = enemigo despierta
- **Integración**: Se actualiza cada frame basado en velocidad de movimiento

#### 3. Modificador de Velocidad
- **Variable**: `currentSpeedModifier`
- **Aplicación**: Se aplica al jugador cuando está en baba
- **Valores**: 1.0 = normal, 0.5 = en baba (50% velocidad)

#### 4. Escenario Mejorado
- Colores: Gris oscuro, depresivo, hospital
- Obstáculos: Camas de hospital, puertas, muebles
- Atmósfera: Silenciosa, opresiva, gris

#### 5. Cinemática de Victoria
```
"Lo grabaste en su peor momento"
"'CRINGE COMPILATION #47'"
[Glitch. Estática breve]
"Tres intentos"
"Tres veces que no llegó al amanecer"
```

### Archivos Modificados/Creados
- ✅ `lib/game/arcs/sloth/sloth_scene.dart` - Escenario mejorado
- ✅ `lib/game/arcs/sloth/sloth_arc_game.dart` - Mecánicas de sigilo y baba
- ✅ `lib/game/arcs/sloth/components/toxic_slime_component.dart` - NUEVO
- ✅ `lib/game/ui/arc_victory_cinematic.dart` - Cinemática agregada

### Mecánica de Sigilo - Detalles
```dart
// Actualización de ruido
if (movementMagnitude > 0.5) {
  noiseLevel += dt * 2.0;  // Movimiento rápido
} else {
  noiseLevel -= dt * 1.0;  // Movimiento lento
}

// Detección
if (noiseLevel > 0.7) {
  // Enemigo despierta
}
```

### ⚠️ PENDIENTE
- [ ] Implementar enemigo Caracol (Samuel)
- [ ] Comportamiento de dormir/despertar
- [ ] Generación de rastros de baba al moverse
- [ ] Cinemática final con diálogo "Yo también era humano"
- [ ] Efecto de glitch en cinemática

---

## 🎨 Optimizaciones Aplicadas

### Ambos Arcos
1. **Efectos visuales simplificados** desde el inicio
2. **Blur reducido** (8px en vez de 15px)
3. **Componentes optimizados** para móvil
4. **Posiciones verificadas** sin obstáculos

### Cinemática de Victoria
- **Layout horizontal** sin scroll
- **Tamaños de fuente adaptativos** para pantallas pequeñas
- **mainAxisSize: MainAxisSize.min** para evitar overflow
- **Espacios mínimos** en móvil (1-2px)

---

## 📋 Checklist de Integración

### Para Completar Arco 2 (Avaricia)
- [ ] Crear `HyenaEnemy` component
- [ ] Implementar comportamiento de robo
- [ ] Agregar sonido de risa
- [ ] Crear cinemática final especial
- [ ] Probar mecánica de recuperación en cajas registradoras
- [ ] Verificar balance de robo de cordura

### Para Completar Arco 6 (Pereza)
- [ ] Crear `SlothEnemyComponent` (Caracol)
- [ ] Implementar comportamiento dormido/despierto
- [ ] Agregar generación de baba al moverse
- [ ] Implementar detección por ruido
- [ ] Crear cinemática final con glitch
- [ ] Probar mecánica de sigilo
- [ ] Ajustar velocidades para sensación de lentitud

### Testing General
- [ ] Probar en diferentes resoluciones
- [ ] Verificar rendimiento en móvil
- [ ] Verificar que evidencias sean accesibles
- [ ] Probar retry y reset completo
- [ ] Verificar cinemáticas sin overflow
- [ ] Probar mecánicas únicas de cada arco

---

## 🎯 Valores de Referencia

### Arco 2: Avaricia
- **Cordura robada por captura**: 10%
- **Recuperación por caja**: 50% de lo robado (máx 20%)
- **Cajas registradoras**: 5 totales
- **Evidencias**: 5 totales

### Arco 6: Pereza
- **Slowdown de baba**: 50% velocidad
- **Duración de baba**: 10 segundos
- **Umbral de ruido**: 70% para despertar enemigo
- **Velocidad de acumulación de ruido**: 2.0/s rápido, -1.0/s lento
- **Evidencias**: 5 totales

---

## 💡 Notas de Diseño

### Avaricia
- **Tema visual**: Dorado oscuro, materialismo, decadencia
- **Sensación**: Desesperación por recuperar lo perdido
- **Mensaje**: El precio de los likes vs. la vida de una persona

### Pereza
- **Tema visual**: Gris, depresión, hospital
- **Sensación**: Lentitud, sigilo, peso de la culpa
- **Mensaje**: El impacto de burlarse del sufrimiento mental

---

## 🔧 Próximos Pasos

1. **Implementar enemigos** para ambos arcos
2. **Crear cinemáticas finales** específicas
3. **Agregar efectos de sonido** temáticos
4. **Testing exhaustivo** de mecánicas
5. **Ajustar balance** basado en playtesting
6. **Documentar** decisiones de diseño específicas

---

## 📚 Referencias

- Ver `arc-1-gula-documentation.md` para estructura base
- Seguir patrones de optimización establecidos
- Mantener consistencia en valores de referencia
- Documentar cualquier desviación del patrón base
