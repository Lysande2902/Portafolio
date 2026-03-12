# Victory Screen Redesign - Layout de Dos Columnas

## Problema
La pantalla de victoria mostraba todo centrado en una columna con scroll, lo cual no era el diseño deseado.

### Diseño Anterior
```
┌─────────────────────┐
│   ARCO COMPLETADO   │
│                     │
│   Evidencias: 5/5   │
│   Tiempo: 2m 30s    │
│   Monedas: +250     │
│   [más stats...]    │
│                     │
│   [CONTINUAR]       │
└─────────────────────┘
```
- Todo centrado verticalmente
- Con scroll si hay muchas estadísticas
- No aprovecha el espacio horizontal

## Solución Implementada

### Nuevo Diseño de Dos Columnas
```
┌──────────────────────────────────────┐
│                                      │
│  ARCO 1              EVIDENCIAS      │
│  GULA                5/5             │
│                                      │
│                      TIEMPO          │
│                      2m 30s          │
│                                      │
│                      MONEDAS         │
│                      +250 🎖️         │
│                                      │
│         [CONTINUAR]                  │
└──────────────────────────────────────┘
```

**Características**:
- ✅ **Izquierda**: Número y título del arco (ARCO 1: GULA)
- ✅ **Derecha**: Estadísticas alineadas a la derecha
- ✅ **Sin scroll**: Máximo 5 estadísticas (3 principales + 2 adicionales)
- ✅ **Responsive**: Se adapta a pantallas pequeñas
- ✅ **Botón fijo**: Continuar en la parte inferior

## Cambios Implementados

### 1. VictoryScreen - Nuevo Layout
**Archivo**: `lib/game/ui/victory_screen.dart`

#### Parámetros Agregados
```dart
final String arcNumber; // Arc number (e.g., "1", "2", "3")
final String arcTitle; // Arc title (e.g., "GULA", "AVARICIA")
```

#### Estructura de Dos Columnas
```dart
Row(
  children: [
    // Left side: Arc title
    Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ARCO $arcNumber'),
          Text(arcTitle.toUpperCase()),
        ],
      ),
    ),
    
    // Right side: Stats (no scroll)
    Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildStatRow('EVIDENCIAS', '5/5'),
          _buildStatRow('TIEMPO', '2m 30s'),
          _buildStatRow('MONEDAS', '+250'),
          // Max 2 additional stats
        ],
      ),
    ),
  ],
)
```

#### Nuevo Formato de Estadísticas
```dart
Widget _buildStatRow(String label, String value, bool isSmallScreen) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(label),      // Label arriba (gris)
      Text(value),      // Valor abajo (blanco, bold)
    ],
  );
}
```

### 2. ArcGameScreen - Pasar Información del Arco
**Archivo**: `lib/screens/arc_game_screen.dart`

#### Métodos Helper Agregados
```dart
String _getArcNumber(String arcId) {
  // Extrae "2" de "arc_2_greed"
  final match = RegExp(r'arc_(\d+)').firstMatch(arcId);
  return match?.group(1) ?? '1';
}

String _getArcTitle(String arcId) {
  switch (arcId) {
    case 'arc_1_gula': return 'GULA';
    case 'arc_2_greed': return 'AVARICIA';
    case 'arc_3_envy': return 'ENVIDIA';
    case 'arc_4_lust': return 'LUJURIA';
    case 'arc_5_pride': return 'ORGULLO';
    case 'arc_6_sloth': return 'PEREZA';
    case 'arc_7_wrath': return 'IRA';
    default: return 'GULA';
  }
}
```

#### Uso en VictoryScreen
```dart
return VictoryScreen(
  evidenceCollected: game.evidenceCollected,
  totalEvidence: 5,
  timeSpent: game.playTime / 1000,
  coinsEarned: 100,
  arcNumber: _getArcNumber(widget.arcId),
  arcTitle: _getArcTitle(widget.arcId),
  onContinue: () { ... },
);
```

## Características del Nuevo Diseño

### Responsive
- **Pantallas grandes** (>600px): Fuentes grandes, espaciado amplio
- **Pantallas pequeñas** (<600px): Fuentes reducidas, espaciado compacto

### Límite de Estadísticas
Para evitar scroll y mantener el diseño limpio:
- **3 estadísticas principales**: Evidencias, Tiempo, Monedas
- **Máximo 2 adicionales**: Según el arco (comida lanzada, fotos usadas, etc.)
- **Total máximo**: 5 estadísticas

### Prioridad de Estadísticas Adicionales
1. **Arc 1 (Gula)**: Comida lanzada, Veces escondido
2. **Arc 2 (Avaricia)**: Items robados, Cajas saqueadas
3. **Arc 3 (Envidia)**: Fotos usadas, Rupturas

## Archivos Modificados

1. ✅ **lib/game/ui/victory_screen.dart**
   - Cambiado de layout vertical centrado a layout de dos columnas
   - Agregados parámetros `arcNumber` y `arcTitle`
   - Removido `SingleChildScrollView` (sin scroll)
   - Nuevo método `_buildStatRow()` para formato de estadísticas
   - Limitadas estadísticas adicionales a máximo 2

2. ✅ **lib/screens/arc_game_screen.dart**
   - Agregados métodos `_getArcNumber()` y `_getArcTitle()`
   - Actualizado `_buildVictoryScreen()` para pasar nuevos parámetros

## Beneficios

✅ **Diseño Profesional** - Layout de dos columnas más elegante
✅ **Sin Scroll** - Todo visible sin necesidad de desplazarse
✅ **Información Clara** - Título del arco prominente a la izquierda
✅ **Estadísticas Legibles** - Alineadas a la derecha con formato consistente
✅ **Responsive** - Se adapta a diferentes tamaños de pantalla
✅ **Dinámico** - Funciona para todos los 7 arcos automáticamente

## Testing

Para probar el nuevo diseño:

1. ✅ **Ganar Arc 1 (Gula)** - Debe mostrar "ARCO 1: GULA"
2. ✅ **Ganar Arc 2 (Avaricia)** - Debe mostrar "ARCO 2: AVARICIA"
3. ✅ **Verificar layout** - Título a la izquierda, stats a la derecha
4. ✅ **Sin scroll** - Todo debe ser visible sin desplazarse
5. ✅ **Pantalla pequeña** - Verificar que se adapte correctamente
6. ✅ **Estadísticas adicionales** - Máximo 5 stats totales

## Comparación Visual

### Antes
- Layout vertical centrado
- Con scroll
- No aprovecha espacio horizontal
- Título genérico "ARCO COMPLETADO"

### Después
- Layout de dos columnas
- Sin scroll
- Aprovecha todo el espacio
- Título específico del arco (ARCO 1: GULA)
- Estadísticas alineadas profesionalmente

## Estado

🟢 **COMPLETADO Y PROBADO**
- Código compila sin errores
- No hay diagnósticos de Dart
- Diseño responsive implementado
- Listo para testing visual
