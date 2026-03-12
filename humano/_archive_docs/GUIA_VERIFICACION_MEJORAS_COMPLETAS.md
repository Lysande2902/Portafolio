# GUÍA DE VERIFICACIÓN - MEJORAS COMPLETAS

**Fecha**: 28 de enero de 2025  
**Estado**: ✅ LISTO PARA PROBAR

---

## 🎯 RESUMEN DE MEJORAS

Se completaron **4 mejoras críticas** en el Arco 1 (Consumo y Codicia):

1. ✅ **Cristal roto optimizado** - Realista y sin lag
2. ✅ **Penumbra negra progresiva** - Intensifica con fragmentos
3. ✅ **Botón de esconderse arreglado** - Funciona en todos los arcos
4. ✅ **Escondites mejorados** - Diseño realista y más pequeños

---

## 🚀 PASOS PARA PROBAR

### 1. Compilar el Juego

```cmd
cd humano
flutter clean
flutter pub get
flutter run
```

**Tiempo estimado**: 2-3 minutos

---

### 2. Iniciar Arco 1 (Consumo y Codicia)

1. Abrir el juego
2. Iniciar sesión (o modo invitado)
3. Seleccionar **Arco 1: Consumo y Codicia**
4. Iniciar el juego

---

## ✅ CHECKLIST DE VERIFICACIÓN

### A. Cristal Roto Optimizado

#### Prueba 1: Recolectar Primer Fragmento
- [ ] Recolectar 1 fragmento
- [ ] Verificar que aparece cristal roto
- [ ] Verificar que tiene:
  - [ ] Grietas radiales (6-8)
  - [ ] Ramificaciones visibles
  - [ ] Anillos concéntricos
  - [ ] Fragmentos pequeños
  - [ ] Sombras realistas
- [ ] Verificar que NO tiene punto de impacto feo en el centro
- [ ] Verificar que la animación es suave (sin lag)

**Resultado esperado**: Cristal roto realista aparece suavemente

---

#### Prueba 2: Recolectar 5 Fragmentos
- [ ] Recolectar 5 fragmentos en total
- [ ] Verificar que hay 5 puntos de impacto
- [ ] Verificar que el juego sigue a 60 FPS (sin lag)
- [ ] Verificar que las grietas se superponen naturalmente

**Resultado esperado**: 5 puntos de cristal roto, sin lag

---

#### Prueba 3: Recolectar 10 Fragmentos
- [ ] Recolectar los 10 fragmentos
- [ ] Verificar que hay 10 puntos de impacto
- [ ] Verificar que el juego sigue a 60 FPS (sin lag)
- [ ] Verificar que la pantalla está muy fracturada pero fluida

**Resultado esperado**: 10 puntos de cristal roto, 60 FPS constante

---

### B. Penumbra Negra Progresiva

#### Prueba 4: Fragmentos 0-5 (Penumbra Sutil)
- [ ] Con 0 fragmentos: Sin penumbra
- [ ] Con 1 fragmento: Penumbra apenas perceptible (8%)
- [ ] Con 2 fragmentos: Penumbra sutil (16%)
- [ ] Con 3 fragmentos: Penumbra ligera (24%)
- [ ] Con 4 fragmentos: Penumbra moderada (32%)
- [ ] Con 5 fragmentos: Penumbra notable (40%)

**Resultado esperado**: Penumbra aumenta gradualmente pero sigue siendo jugable

---

#### Prueba 5: Fragmentos 6+ (Penumbra Intensa)
- [ ] Con 6 fragmentos: Penumbra muy oscura (50%)
- [ ] Con 7 fragmentos: Difícil de ver (57%)
- [ ] Con 8 fragmentos: Muy difícil (64%)
- [ ] Con 9 fragmentos: Casi ciego (71%)
- [ ] Con 10 fragmentos: Extremadamente oscuro (78%)

**Resultado esperado**: A partir de 6 fragmentos, la penumbra es muy intensa y dificulta la visibilidad

---

#### Prueba 6: Gradiente Radial
- [ ] Verificar que el centro de la pantalla es más claro
- [ ] Verificar que los bordes son más oscuros
- [ ] Verificar que la transición es suave (gradiente)

**Resultado esperado**: Gradiente radial desde el centro (claro) hacia los bordes (oscuro)

---

### C. Botón de Esconderse Arreglado

#### Prueba 7: Detectar Escondite
- [ ] Acercarse a un escondite (caja marrón)
- [ ] Verificar que aparece el botón morado de esconderse
- [ ] Verificar que el botón tiene el icono correcto

**Resultado esperado**: Botón morado aparece al acercarse

---

#### Prueba 8: Esconderse
- [ ] Presionar el botón morado
- [ ] Verificar que el jugador se vuelve semi-transparente (30% opacidad)
- [ ] Verificar que el jugador no puede moverse
- [ ] Verificar que el botón cambia a "Salir"

**Resultado esperado**: Jugador se esconde correctamente

---

#### Prueba 9: Enemigo No Detecta
- [ ] Esconderse en un escondite
- [ ] Esperar a que el enemigo pase cerca
- [ ] Verificar que el enemigo NO detecta al jugador
- [ ] Verificar que el enemigo sigue su patrulla normal

**Resultado esperado**: Enemigo no detecta al jugador escondido

---

#### Prueba 10: Salir del Escondite
- [ ] Presionar el botón "Salir"
- [ ] Verificar que el jugador vuelve a opacidad 100%
- [ ] Verificar que el jugador puede moverse
- [ ] Alejarse del escondite
- [ ] Verificar que el botón desaparece

**Resultado esperado**: Jugador sale del escondite correctamente

---

### D. Escondites Mejorados

#### Prueba 11: Diseño Visual
- [ ] Observar un escondite de cerca
- [ ] Verificar que tiene:
  - [ ] Gradiente de colores (profundidad)
  - [ ] Sombras interiores
  - [ ] Highlights (luz)
  - [ ] Líneas de textura (madera)
  - [ ] Borde exterior oscuro
  - [ ] Borde interior claro
  - [ ] Icono de escondite en el centro (ojo cerrado)

**Resultado esperado**: Escondite con diseño realista de caja/barril

---

#### Prueba 12: Tamaño Reducido
- [ ] Comparar tamaño de escondites con objetos cercanos
- [ ] Verificar que son más pequeños que antes (100-110px)
- [ ] Verificar que siguen siendo fáciles de identificar

**Resultado esperado**: Escondites más pequeños pero visibles

---

#### Prueba 13: Funcionalidad en Fase 1
- [ ] Probar escondites en la primera mitad del mapa (Fase 1 - Mateo)
- [ ] Verificar que todos funcionan correctamente

**Resultado esperado**: 4 escondites funcionales en Fase 1

---

#### Prueba 14: Funcionalidad en Fase 2
- [ ] Recolectar 5 fragmentos para activar Fase 2
- [ ] Probar escondites en la segunda mitad del mapa (Fase 2 - Valeria)
- [ ] Verificar que todos funcionan correctamente

**Resultado esperado**: 4 escondites funcionales en Fase 2

---

## 🎮 EXPERIENCIA COMPLETA

### Prueba 15: Juego Completo
- [ ] Jugar el Arco 1 completo (0 a 10 fragmentos)
- [ ] Verificar que:
  - [ ] Cristal roto aparece progresivamente
  - [ ] Penumbra aumenta gradualmente
  - [ ] A partir de 6 fragmentos, el juego se vuelve muy oscuro
  - [ ] Escondites funcionan en todo momento
  - [ ] No hay lag en ningún momento
  - [ ] FPS se mantiene a 60 constante
  - [ ] La experiencia es fluida y desafiante

**Resultado esperado**: Experiencia de juego completa, fluida y desafiante

---

## 📊 MÉTRICAS DE RENDIMIENTO

### Verificar FPS

**Método 1: Visual**
- [ ] Observar si el juego se ve fluido
- [ ] Verificar que no hay stuttering
- [ ] Verificar que las animaciones son suaves

**Método 2: Flutter DevTools**
1. Ejecutar con `flutter run --profile`
2. Abrir Flutter DevTools
3. Ir a la pestaña "Performance"
4. Verificar que FPS se mantiene cerca de 60

**Resultado esperado**: 60 FPS constante

---

## 🐛 PROBLEMAS CONOCIDOS

### Si el Botón de Esconderse No Aparece

**Posibles causas**:
1. No estás lo suficientemente cerca del escondite
2. El escondite no tiene hitbox correcta

**Solución**:
- Acércate más al escondite (distancia < 80px)
- Verifica que el escondite tiene `RectangleHitbox`

---

### Si Hay Lag con 10 Fragmentos

**Posibles causas**:
1. Dispositivo de baja potencia
2. Otros procesos consumiendo recursos

**Solución**:
- Cerrar otras aplicaciones
- Probar en modo release: `flutter run --release`

---

### Si la Penumbra es Demasiado Oscura

**Ajuste**:
Editar `shattered_screen_overlay.dart` línea ~180:

```dart
// Reducir intensidad
final adjustedIntensity = crackPoints.length >= 6 
    ? 0.4 + (crackPoints.length - 5) * 0.05 // Menos intenso
    : crackPoints.length * 0.06;
```

---

## ✅ CHECKLIST FINAL

### Antes de Reportar Éxito

- [ ] Todas las pruebas A (Cristal Roto) pasadas
- [ ] Todas las pruebas B (Penumbra) pasadas
- [ ] Todas las pruebas C (Botón Esconderse) pasadas
- [ ] Todas las pruebas D (Escondites Mejorados) pasadas
- [ ] Prueba 15 (Juego Completo) pasada
- [ ] FPS constante a 60
- [ ] Sin lag perceptible
- [ ] Experiencia de juego fluida

---

## 📝 REPORTAR RESULTADOS

### Si Todo Funciona Correctamente

✅ **Mensaje de éxito**:
```
"Todas las mejoras verificadas y funcionando correctamente:
- Cristal roto optimizado ✅
- Penumbra negra progresiva ✅
- Botón de esconderse arreglado ✅
- Escondites mejorados ✅
- 60 FPS constante ✅"
```

---

### Si Hay Problemas

❌ **Reportar**:
1. Qué prueba falló
2. Qué comportamiento esperabas
3. Qué comportamiento obtuviste
4. Capturas de pantalla si es posible

---

## 🎯 PRÓXIMOS PASOS

Una vez verificado todo:

1. **Jugar y disfrutar** el Arco 1 mejorado
2. **Feedback**: Reportar si algo necesita ajuste
3. **Continuar**: Aplicar mejoras similares a otros arcos

---

**Estado**: 🟢 LISTO PARA VERIFICAR

---

**Autor**: Kiro AI  
**Fecha**: 28 de enero de 2025  
**Versión**: 1.0
