# FIX: Arcos Fusionados Marcados como Implementados

**Fecha**: 28 de enero de 2025  
**Problema**: Al intentar jugar Arc 1 (Consumo y Codicia), aparecía el mensaje "GAMEPLAY EN DESARROLLO"

## Causa Raíz

El archivo `arc_selection_screen.dart` tiene una lista `implementedArcs` que determina qué arcos están listos para jugar. Esta lista solo contenía los IDs de los arcos antiguos:

```dart
final implementedArcs = [
  'arc_1_gula',
  'arc_2_greed',
  'arc_3_envy',
  // ...
];
```

Los nuevos arcos fusionados tienen IDs diferentes:
- `arc_1_consumo_codicia` (Gula + Avaricia)
- `arc_2_envidia_lujuria` (Envidia + Lujuria)

Como estos IDs no estaban en la lista, el juego mostraba el diálogo de "en desarrollo" en lugar de iniciar el juego.

## Solución

Actualicé la lista `implementedArcs` para incluir los nuevos IDs de arcos fusionados:

```dart
final implementedArcs = [
  // Arcos fusionados (nuevos)
  'arc_1_consumo_codicia',
  'arc_2_envidia_lujuria',
  // Arcos antiguos (mantener por compatibilidad)
  'arc_1_gula',
  'arc_2_greed',
  'arc_3_envy',
  'arc_4_lust',
  'arc_5_pride',
  'arc_6_sloth',
  'arc_7_wrath',
];
```

## Archivos Modificados

- `humano/lib/screens/arc_selection_screen.dart` (línea 971-979)

## Resultado

Ahora cuando seleccionas "CONSUMO Y CODICIA" o "ENVIDIA Y LUJURIA" en el menú de selección de arcos:
1. ✅ Se muestra la cinemática de introducción
2. ✅ Se abre la pantalla de selección de items
3. ✅ El juego inicia correctamente con el mapa de 4800x1600
4. ✅ Los enemigos aparecen en sus fases correspondientes

## Próximos Pasos

Cuando implementes los arcos 3 y 4, recuerda agregar sus IDs a esta lista:
- `arc_3_soberbia_pereza`
- `arc_4_ira`

## Verificación

Para verificar que el fix funciona:
1. Ejecuta `flutter run`
2. Ve al menú de selección de arcos
3. Selecciona "CONSUMO Y CODICIA"
4. Deberías ver la cinemática de intro, NO el mensaje de "gameplay en desarrollo"
5. El juego debe iniciar con Mateo (Cerdo) en la primera fase
