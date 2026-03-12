# ARCO 1: CONSUMO Y CODICIA - RESUMEN EJECUTIVO

**Fecha**: 28 de enero de 2025  
**Estado**: ✅ IMPLEMENTADO Y FUNCIONAL

---

## 🎯 INFORMACIÓN ESENCIAL

### Identificación
- **ID**: `arc_1_consumo_codicia`
- **Título**: CONSUMO Y CODICIA
- **Pecados**: Gula + Avaricia
- **Tipo**: Arco Fusionado (doble longitud)

### Objetivo
Recolectar 10 fragmentos de evidencia y escapar del almacén mientras enfrentas a dos enemigos.

---

## 🗺️ ESTRUCTURA DEL MAPA

### Dimensiones
- **Tamaño**: 4800 × 1600 píxeles (doble de un arco normal)
- **Área jugable**: (40, 40) a (4760, 1560)

### División en Fases

```
┌──────────────────────┬──────────────────────┐
│   FASE 1: ALMACÉN    │   FASE 2: BÓVEDA     │
│   (0 - 2400)         │   (2400 - 4800)      │
│                      │                      │
│ Enemigo: Mateo       │ Enemigo: Valeria     │
│ Fragmentos: 5        │ Fragmentos: 5        │
│ Obstáculos: Cajas    │ Obstáculos: Bóvedas  │
└──────────────────────┴──────────────────────┘
         CHECKPOINT EN X=2400
```

---

## 👹 ENEMIGOS

### Fase 1: Mateo (Cerdo) - Gula
- **Fragmentos**: 0-5
- **Mecánica**: Devora evidencias si las alcanza
- **Velocidad**: Media
- **Estrategia**: Usa escondites, patrón predecible

### Fase 2: Valeria (Rata) - Avaricia
- **Fragmentos**: 5-10
- **Mecánica**: Roba evidencias y cordura
- **Velocidad**: Media-Alta
- **Estrategia**: Muévete rápido, usa cajas registradoras

---

## 🎮 MECÁNICAS CLAVE

### Sistema de Checkpoint (5 Fragmentos)
1. Mateo desaparece
2. Valeria aparece
3. El jugador continúa en su posición
4. Cambio visual: Almacén → Bóveda

### Recolección de Evidencias
- **Radio**: 80 píxeles
- **Total**: 10 fragmentos
- **Distribución**: 5 en cada fase

### Sistema de Colisiones
- **Tipo**: AABB manual predictivo
- **Anchor**: `Anchor.topLeft` en todos los componentes
- **Verificación**: Antes de mover (no callbacks)

---

## 📊 ELEMENTOS DEL MAPA

### Cantidades
- **Obstáculos**: 50 (25 por fase)
- **Escondites**: 8 (4 por fase)
- **Evidencias**: 10 (5 por fase)
- **Enemigos**: 2 (1 activo por fase)

### Posiciones Clave
- **Jugador inicial**: (200, 800)
- **Puerta de salida**: (4600, 800)
- **Checkpoint**: x = 2400

---

## 🎬 HISTORIA Y FRAGMENTOS

### Narrativa
Dos vidas destruidas por excesos materiales:
- **Mateo**: Víctima de burlas por video viral sobre su peso
- **Valeria**: Perdió todo por deudas con intereses abusivos

### Fragmentos (10 total)
1. El Video Viral
2. Intenté Borrarlo
3. Mateo Dejó de Responder
4. En el Hospital
5. Sus Niños Esperan
6. Valeria Perdió Su Casa
7. El Banco Se Quedó con Todo
8. La Deuda Creció
9. Intentó Suicidarse
10. La Verdad Completa

---

## ✅ CONDICIONES DE VICTORIA/DERROTA

### Victoria
1. Recolectar 10 fragmentos ✓
2. Llegar a la puerta (x=4600) ✓
3. Estar a <60px de la puerta ✓

### Game Over
1. Enemigo atrapa al jugador (<40px, no escondido)
2. Cordura agotada (0%)

---

## 🔧 ARCHIVOS PRINCIPALES

### Lógica del Juego
- `consumo_codicia_arc_game.dart` - Clase principal
- `consumo_codicia_scene.dart` - Configuración del mapa

### Componentes
- `player_component.dart` - Jugador con colisiones
- `enemy_component.dart` - Mateo (Fase 1)
- `banker_enemy.dart` - Valeria (Fase 2)
- `evidence_component.dart` - Fragmentos recolectables
- `exit_door_component.dart` - Puerta de salida

### Sistemas
- `textured_obstacle_component.dart` - Obstáculos con textura
- `wall_component.dart` - Paredes y colisiones
- `hiding_spot_component.dart` - Escondites

---

## 🎨 TEXTURAS PROCEDURALES

### Fase 1: Cajas de Madera
- Vetas de madera
- Tablones verticales
- Clavos en esquinas
- Color: Marrón (#3a2f2a)

### Fase 2: Cajas Fuertes
- Brillo metálico
- Remaches en bordes
- Cerradura central
- Color: Gris-azul (#2a2a3a)

---

## 📈 ESTADÍSTICAS

### Tiempo de Juego
- **Speedrun**: 3-5 minutos
- **Normal**: 8-12 minutos
- **Explorando**: 15-20 minutos

### Dificultad
- **Fase 1**: Media
- **Fase 2**: Media-Alta
- **General**: Media

---

## 🐛 PROBLEMAS RESUELTOS

### ✅ Colisiones
- **Problema**: Jugador atravesaba paredes
- **Solución**: Anchor.topLeft + AABB manual

### ✅ Recolección
- **Problema**: Evidencias difíciles de recoger
- **Solución**: Radio aumentado a 80px

### ✅ Contador
- **Problema**: Mostraba 5 en lugar de 10
- **Solución**: Lógica dinámica en fragments_provider

---

## 🎯 TIPS RÁPIDOS

### Fase 1 (Mateo)
- Usa escondites cuando te persiga
- Aprende su patrón de patrullaje
- Recolecta evidencias rápido

### Fase 2 (Valeria)
- Muévete constantemente
- Usa cajas registradoras para cordura
- Planifica ruta hacia la puerta

---

## 📚 DOCUMENTACIÓN RELACIONADA

- `ARCO_1_CONSUMO_CODICIA_COMPLETO.md` - Documentación completa
- `LOGICA_FRAGMENTOS_EXPLICACION.md` - Sistema de fragmentos
- `FIX_COLISIONES_ANCHOR_PROBLEMA.md` - Solución de colisiones
- `SISTEMA_COLISIONES_MEJORADO.md` - Sistema de colisiones
- `TEXTURAS_PROCEDURALES_GUIA.md` - Guía de texturas

---

**Versión**: 1.0  
**Última actualización**: 28 de enero de 2025  
**Estado**: Producción
