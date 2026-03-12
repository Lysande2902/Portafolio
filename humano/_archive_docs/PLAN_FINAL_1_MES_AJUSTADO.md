# 🎯 PLAN FINAL AJUSTADO - 1 MES PARA ENTREGA

**Fecha Límite:** ~27 de Febrero, 2026  
**Tiempo Disponible:** 30 días  
**Objetivo:** Juego COMPLETO y funcional para entrega

---

## 🚨 DECISIONES FINALES

### ✅ QUÉ MANTENER (OBLIGATORIO)
- ✅ **5 ARCOS con FINAL** (Gula, Avaricia, Envidia, Lujuria, Soberbia)
- ✅ **MULTIJUGADOR** (requerido oficialmente)
- ✅ **Store básica** (skins comunes/profesionales, items)
- ✅ **Archive** (expedientes de 5 arcos)
- ✅ **Leaderboard** (clasificación global)
- ✅ **Settings** (configuración básica)
- ✅ **Firebase Auth** (login/registro)

### ❌ QUÉ ELIMINAR (SIMPLIFICACIÓN)
- ❌ **Sistema de Logros** (achievements completo)
- ❌ **Pantalla de Estadísticas** (stats detalladas)
- ❌ **Arcos 6 y 7** (Pereza e Ira → DLC futuro)
- ❌ **Skins Épicas y Legendarias** (solo común/profesional)
- ❌ **Battle Pass** (monetización compleja)
- ❌ **Demo Ending** (no aplica con final real)
- ❌ **True Ending múltiple** (solo 1 ending)

---

## 📋 CONTENIDO FINAL DEL JUEGO

### 🎮 ARCOS (5 Total)
1. **Arco 1: GULA** (Mateo) ✅
2. **Arco 2: AVARICIA** (Valeria) ✅
3. **Arco 3: ENVIDIA** (Lucía) ✅
4. **Arco 4: LUJURIA** (Adriana) ⚠️ (necesita imagen)
5. **Arco 5: SOBERBIA** (Carlos) ⚠️ (necesita imagen)

**Duración Total:** 25-40 minutos

### 🎬 FINAL
- **Ending Screen Simple** después de completar 5 arcos
- Cinemática de cierre
- Créditos
- Mensaje: "Gracias por jugar"

### 👥 MULTIJUGADOR
- **Modo:** Usuario vs Algoritmo (1v1)
- **Lobby:** Crear/Unirse a partida
- **Gameplay:** Versión simplificada del modo historia
- **Objetivo:** 3 evidencias (en vez de 5)
- **Duración:** 5-10 minutos por partida

### 🛍️ STORE (Simplificada)
**Items Consumibles:**
- Aturdidor (50 monedas)
- Invisibilidad (75 monedas)
- Boost de Velocidad (60 monedas)
- Mapa Temporal (40 monedas)
- Escudo (100 monedas)

**Skins (Solo Básicas):**
- **Gratis:** Default, Usuario, Fantasma
- **Comunes (50-75 monedas):** Hacker, Corporativo, Agente, Periodista
- **Profesionales (100-150 monedas):** Punk, Gótico, Cyberpunk, Sombra

**Total:** 3 gratis + 8 de pago = 11 skins

### 🏆 LEADERBOARD
- Top 100 jugadores
- Puntuación basada en:
  - Arcos completados × 500
  - Tiempo total (menos = mejor)
  - Monedas acumuladas ÷ 10

### 📁 ARCHIVE
- 5 pestañas (1 por arco)
- 5 fragmentos por arco = 25 total
- Expedientes completos (5 documentos cada uno)

---

## 🗓️ CRONOGRAMA AJUSTADO (30 DÍAS)

### 🔴 SEMANA 1 (Días 1-7): ASSETS CRÍTICOS + TESTING BÁSICO

**Días 1-2: CREAR ASSETS FALTANTES (URGENTE)**
- [ ] **Crear arc4_complete.jpg** (Lujuria)
  - Imagen oscura/perturbadora
  - Tema: sextorsión/chantaje
  - Resolución: 1920x1080
  
- [ ] **Crear arc5_complete.jpg** (Soberbia)
  - Imagen de poder/arrogancia
  - Tema: fraude de influencer
  - Resolución: 1920x1080

**Opción rápida:** Usar IA (Midjourney, DALL-E) o placeholders temporales

**Días 3-4: ELIMINAR CÓDIGO INNECESARIO**
- [ ] Comentar/eliminar Achievements system
- [ ] Comentar/eliminar Stats screen
- [ ] Comentar/eliminar Arcos 6 y 7
- [ ] Comentar/eliminar Skins épicas/legendarias
- [ ] Comentar/eliminar Battle Pass
- [ ] Actualizar menú (quitar botones)

**Días 5-7: TESTING BÁSICO**
- [ ] Compilar sin errores
- [ ] Jugar Arco 1 completo
- [ ] Jugar Arco 2 completo
- [ ] Jugar Arco 3 completo
- [ ] Documentar bugs críticos

---

### 🟡 SEMANA 2 (Días 8-14): ARCOS 4-5 + FIXES CRÍTICOS

**Días 8-9: TESTING ARCOS 4-5**
- [ ] Jugar Arco 4 (Lujuria) completo
  - Verificar Spider enemy funciona
  - Verificar teletransporte funciona
  - Verificar redes ralentizan
  
- [ ] Jugar Arco 5 (Soberbia) completo
  - Verificar Lion enemy funciona
  - Verificar escalada de poder funciona
  - Verificar fases de velocidad

**Días 10-12: FIXES CRÍTICOS**
- [ ] Arreglar crashes
- [ ] Arreglar colisiones rotas
- [ ] Arreglar enemigos que no funcionan
- [ ] Arreglar evidencias que no se recolectan
- [ ] Arreglar Victory/Game Over

**Días 13-14: ENDING SCREEN**
- [ ] Crear Ending Screen simple
- [ ] Cinemática de cierre (texto typewriter)
- [ ] Créditos básicos
- [ ] Botón "Volver al Menú"

---

### 🟢 SEMANA 3 (Días 15-21): MULTIJUGADOR + POLISH

**Días 15-17: MULTIJUGADOR (PRIORIDAD)**
- [ ] Verificar MultiplayerLobbyScreen funciona
- [ ] Verificar crear/unirse a partida funciona
- [ ] Verificar AlgorithmGameScreen funciona
- [ ] Simplificar a 3 evidencias (en vez de 5)
- [ ] Testing básico de sincronización
- [ ] Arreglar bugs críticos de multijugador

**Días 18-19: POLISH VISUAL**
- [ ] Verificar efectos de fractura
- [ ] Verificar efectos de sanity
- [ ] Verificar transiciones
- [ ] Mejorar UI donde sea necesario

**Días 20-21: POLISH AUDIO**
- [ ] Verificar música en todos los arcos
- [ ] Ajustar volúmenes
- [ ] Verificar SFX básicos
- [ ] Settings de audio funcionan

---

### 🔵 SEMANA 4 (Días 22-30): OPTIMIZACIÓN + RELEASE

**Días 22-23: BALANCE**
- [ ] Ajustar velocidades de enemigos
- [ ] Ajustar drain de sanity
- [ ] Ajustar dificultad general
- [ ] Verificar que 5 arcos son jugables

**Días 24-25: PERFORMANCE**
- [ ] Profiler desktop (60 FPS)
- [ ] Profiler mobile (30 FPS)
- [ ] Optimizar si es necesario
- [ ] Verificar memoria

**Días 26-27: TESTING FINAL**
- [ ] Jugar 5 arcos completos de nuevo
- [ ] Verificar multijugador funciona
- [ ] Verificar Store funciona
- [ ] Verificar Archive funciona
- [ ] Verificar Leaderboard funciona
- [ ] Verificar Ending funciona

**Días 28-29: BUILDS**
- [ ] Build Android (APK/AAB)
- [ ] Build iOS (IPA)
- [ ] Build Web
- [ ] Build Desktop

**Día 30: ENTREGA 🚀**
- [ ] Entregar builds
- [ ] Documentación básica
- [ ] Video demo (opcional)

---

## ✂️ CÓDIGO A ELIMINAR/COMENTAR

### 1. Achievements System
```dart
// En main.dart
// Comentar AchievementsProvider
// MultiProvider(
//   providers: [
//     ChangeNotifierProvider(create: (_) => AchievementsProvider()),
//   ],
// )

// En menu_screen.dart
// Comentar botón de Achievements
```

### 2. Stats Screen
```dart
// En settings_screen.dart
// Comentar botón "Ver Estadísticas"

// Eliminar archivo:
// lib/screens/stats_screen.dart
```

### 3. Arcos 6 y 7
```dart
// En arc_data_provider.dart
final availableArcs = [
  'arc_1_gula',
  'arc_2_greed',
  'arc_3_envy',
  'arc_4_lust',
  'arc_5_pride',
  // 'arc_6_sloth',  // ELIMINADO
  // 'arc_7_wrath',  // ELIMINADO
];
```

### 4. Skins Épicas/Legendarias
```dart
// En store_data_provider.dart
// Comentar skins con precio > 150 monedas
// Solo mantener:
// - Gratis: Default, Usuario, Fantasma
// - 50-75: Hacker, Corporativo, Agente, Periodista
// - 100-150: Punk, Gótico, Cyberpunk, Sombra
```

### 5. Battle Pass
```dart
// En store_screen.dart
// Comentar tab de Battle Pass
```

---

## 🎯 PRIORIDADES POR IMPORTANCIA

### 🔴 CRÍTICO (Sin esto no funciona)
1. **Assets faltantes** (2 imágenes)
2. **Testing de 5 arcos** (jugables completos)
3. **Multijugador básico** (funcional)
4. **Ending Screen** (cierre del juego)
5. **Eliminar código roto** (achievements, stats)

### 🟡 IMPORTANTE (Afecta experiencia)
6. **Balance de dificultad**
7. **Polish visual básico**
8. **Audio funcional**
9. **Performance aceptable** (30+ FPS)

### 🟢 DESEABLE (Si hay tiempo)
10. **Polish avanzado**
11. **Optimización extra**
12. **Testing exhaustivo**

---

## 📊 MÉTRICAS DE ÉXITO MÍNIMAS

**Para considerar el juego ENTREGABLE:**

✅ **Gameplay (CRÍTICO):**
- [ ] 5 arcos jugables sin crashes
- [ ] Enemigos funcionan
- [ ] Evidencias se recolectan (5/5)
- [ ] Victory/Game Over funcionan
- [ ] Ending Screen funciona

✅ **Multijugador (CRÍTICO):**
- [ ] Crear partida funciona
- [ ] Unirse a partida funciona
- [ ] Gameplay básico funciona
- [ ] No crashes en multijugador

✅ **Sistemas (IMPORTANTE):**
- [ ] Firebase Auth funciona
- [ ] Progreso se guarda
- [ ] Store funciona (comprar items/skins)
- [ ] Archive funciona (5 expedientes)
- [ ] Leaderboard funciona

✅ **Performance (IMPORTANTE):**
- [ ] Desktop: >= 45 FPS (bajamos estándar)
- [ ] Mobile: >= 25 FPS (bajamos estándar)
- [ ] No crashes frecuentes

---

## 🚨 PLAN DE CONTINGENCIA

**Si algo sale mal:**

### Si no terminas Arco 4 o 5:
- **Plan B:** Lanzar con 3 arcos + Ending
- Mensaje: "Arcos adicionales próximamente"

### Si multijugador no funciona:
- **Plan B:** Comentar botón de multijugador
- Mensaje: "Modo multijugador en beta"

### Si performance es mala:
- **Plan B:** Reducir calidad gráfica
- Mapas más pequeños (1200x800)
- Menos efectos visuales

### Si hay bugs críticos:
- **Plan B:** Documentar bugs conocidos
- Incluir en "Known Issues"
- Prometer hotfix post-entrega

---

## 📝 CHECKLIST FINAL DE ENTREGA

```
ANTES DE ENTREGAR:
- [ ] 5 arcos jugables completos
- [ ] Multijugador funcional (básico)
- [ ] Ending Screen implementado
- [ ] 2 imágenes de expedientes creadas
- [ ] Código de achievements/stats eliminado
- [ ] Skins épicas/legendarias eliminadas
- [ ] Arcos 6-7 eliminados
- [ ] Store funciona
- [ ] Archive funciona (5 expedientes)
- [ ] Leaderboard funciona
- [ ] Firebase Auth funciona
- [ ] Builds compilados (Android, iOS, Web, Desktop)
- [ ] No crashes críticos
- [ ] Performance aceptable (25+ FPS mobile)

DOCUMENTACIÓN:
- [ ] README con instrucciones
- [ ] Lista de features implementadas
- [ ] Lista de bugs conocidos (si hay)
- [ ] Controles del juego
- [ ] Requisitos del sistema

OPCIONAL (si hay tiempo):
- [ ] Video demo
- [ ] Screenshots
- [ ] Trailer corto
```

---

## 💡 CONSEJOS PARA SOBREVIVIR EL MES

1. **Prioriza despiadadamente:** Si algo no es crítico, córtalo.
2. **Testing diario:** Juega al menos 1 arco por día.
3. **Documenta bugs:** No confíes en tu memoria.
4. **Commits frecuentes:** Git es tu amigo.
5. **Duerme:** El código cansado tiene más bugs.
6. **Pide ayuda:** Si te atascas, busca ayuda.
7. **Acepta imperfección:** Mejor hecho que perfecto.

---

## 🎯 OBJETIVO FINAL

**Entregar un juego:**
- ✅ Jugable de inicio a fin (5 arcos)
- ✅ Con multijugador funcional
- ✅ Sin crashes críticos
- ✅ Con narrativa completa
- ✅ Que se sienta profesional

**NO necesitas:**
- ❌ Perfección
- ❌ Todos los features
- ❌ 0 bugs
- ❌ 60 FPS en todo

---

**¿Listo para empezar? ¡Vamos a hacerlo! 🚀**

**PRIMER PASO HOY:** Crear las 2 imágenes faltantes (arc4 y arc5)

