# Design Document

## Overview

El diseño implementa un sistema centralizado de contenido específico por arco que extiende el `ArcDataProvider` existente con información detallada para briefings, game over, y victorias. Se crea una estructura de datos `ArcContent` que contiene toda la información temática y mecánica de cada arco, permitiendo que las pantallas de UI consulten este contenido dinámicamente basándose en el `arcId` actual.

## Architecture

### Component Structure

```
lib/data/
├── models/
│   ├── arc.dart (existente)
│   └── arc_content.dart (nuevo)
└── providers/
    └── arc_data_provider.dart (modificar)

lib/screens/
└── arc_selection_screen.dart (modificar _ArcBriefingScreen)

lib/game/ui/
├── game_over_screen.dart (modificar)
└── arc_victory_cinematic.dart (modificar)
```

### Data Flow

1. **Inicialización**: `ArcDataProvider` carga contenido estático de todos los arcos
2. **Briefing**: `_ArcBriefingScreen` consulta `ArcContent` por `arcId` y muestra información específica
3. **Game Over**: `GameOverScreen` recibe `arcId`, consulta contenido y muestra mensajes temáticos
4. **Victory**: `ArcVictoryCinematic` recibe `arcId` y estadísticas, muestra contenido personalizado

## Components and Interfaces

### 1. ArcContent Model

```dart
class ArcContent {
  final String arcId;
  final String arcNumber;
  final String title;
  final String subtitle;
  
  // Briefing content
  final BriefingContent briefing;
  
  // Game over content
  final GameOverContent gameOver;
  
  // Victory content
  final VictoryContent victory;
  
  ArcContent({
    required this.arcId,
    required this.arcNumber,
    required this.title,
    required this.subtitle,
    required this.briefing,
    required this.gameOver,
    required this.victory,
  });
}

class BriefingContent {
  final String objective;           // "Recolecta 5 evidencias"
  final String mechanicTitle;       // "MECÁNICA ESPECIAL"
  final String mechanicDescription; // "La Hiena roba evidencias..."
  final String controls;            // "Joystick + Botón morado"
  final String tip;                 // "Usa las cajas registradoras..."
  
  BriefingContent({
    required this.objective,
    required this.mechanicTitle,
    required this.mechanicDescription,
    required this.controls,
    required this.tip,
  });
}

class GameOverContent {
  final List<String> messages;      // Mensajes temáticos
  final String flavorText;          // Texto adicional
  
  GameOverContent({
    required this.messages,
    required this.flavorText,
  });
}

class VictoryContent {
  final List<String> cinematicLines; // Líneas de la cinemática
  final List<StatConfig> stats;      // Configuración de estadísticas
  
  VictoryContent({
    required this.cinematicLines,
    required this.stats,
  });
}

class StatConfig {
  final String key;          // "stolenItems", "cashRegistersLooted"
  final String label;        // "Evidencias Robadas"
  final String Function(dynamic value) formatter; // Formateo del valor
  
  StatConfig({
    required this.key,
    required this.label,
    required this.formatter,
  });
}
```

### 2. Extended ArcDataProvider

```dart
class ArcDataProvider {
  static final Map<String, ArcContent> _arcContent = {
    'arc_1_gula': ArcContent(...),
    'arc_2_greed': ArcContent(...),
    // ... otros arcos
  };
  
  ArcContent? getArcContent(String arcId) {
    return _arcContent[arcId];
  }
  
  // Métodos existentes se mantienen
  Arc? getArcById(String id) { ... }
  List<Arc> getAllArcs() { ... }
}
```

### 3. Modified Briefing Screen

```dart
class _ArcBriefingScreen extends StatelessWidget {
  final dynamic arc;
  final VoidCallback onStart;
  
  @override
  Widget build(BuildContext context) {
    final arcDataProvider = ArcDataProvider();
    final arcContent = arcDataProvider.getArcContent(arc.id);
    
    // Usar arcContent.briefing para mostrar información
    return Scaffold(
      body: Column(
        children: [
          // Header con título del arco
          _buildHeader(arcContent),
          
          // Body con dos columnas
          Row(
            children: [
              // Columna izquierda: Info del arco
              Expanded(
                flex: 60,
                child: _buildArcInfo(arcContent),
              ),
              
              // Columna derecha: Botones
              Expanded(
                flex: 40,
                child: _buildActionButtons(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildArcInfo(ArcContent content) {
    return Column(
      children: [
        Text(content.title),
        Text(content.subtitle),
        _buildInfoRow('OBJETIVO', content.briefing.objective),
        _buildInfoRow('CONTROLES', content.briefing.controls),
        _buildMechanicSection(content.briefing),
        _buildTipSection(content.briefing.tip),
      ],
    );
  }
}
```

### 4. Modified Game Over Screen

```dart
class GameOverScreen extends StatelessWidget {
  final String arcId;
  final VoidCallback onRetry;
  final VoidCallback onExit;
  
  @override
  Widget build(BuildContext context) {
    final arcDataProvider = ArcDataProvider();
    final arcContent = arcDataProvider.getArcContent(arcId);
    final gameOverContent = arcContent?.gameOver;
    
    return Scaffold(
      body: Column(
        children: [
          Text('GAME OVER'),
          Text(arcContent?.title ?? 'UNKNOWN'),
          
          // Mensajes temáticos
          ...gameOverContent?.messages.map((msg) => 
            Text(msg, style: thematicStyle)
          ) ?? [],
          
          Text(gameOverContent?.flavorText ?? ''),
          
          // Botones
          ElevatedButton(onPressed: onRetry, child: Text('REINTENTAR')),
          ElevatedButton(onPressed: onExit, child: Text('SALIR')),
        ],
      ),
    );
  }
}
```

### 5. Modified Victory Cinematic

```dart
class ArcVictoryCinematic extends StatefulWidget {
  final String arcId;
  final Map<String, dynamic> gameStats;
  final VoidCallback onComplete;
  
  // gameStats contiene: evidenceCollected, timeElapsed, sanityRemaining,
  // y estadísticas específicas del arco como stolenItems, cashRegistersLooted
}

class _ArcVictoryCinematicState extends State<ArcVictoryCinematic> {
  void _showCinematic() {
    final arcDataProvider = ArcDataProvider();
    final arcContent = arcDataProvider.getArcContent(widget.arcId);
    
    // Mostrar líneas cinemáticas
    for (final line in arcContent.victory.cinematicLines) {
      _showLine(line);
    }
    
    // Mostrar estadísticas configuradas
    _showStats(arcContent.victory.stats);
  }
  
  void _showStats(List<StatConfig> statsConfig) {
    for (final config in statsConfig) {
      final value = widget.gameStats[config.key];
      final formattedValue = config.formatter(value);
      _displayStat(config.label, formattedValue);
    }
  }
}
```

## Data Models

### Arco 2: Avaricia - Content Example

```dart
ArcContent(
  arcId: 'arc_2_greed',
  arcNumber: '2',
  title: 'AVARICIA',
  subtitle: 'El Precio de un Click',
  
  briefing: BriefingContent(
    objective: 'Recolecta 5 evidencias y escapa',
    mechanicTitle: 'ROBO DE RECURSOS',
    mechanicDescription: 
      'La Hiena roba tus evidencias cuando te atrapa. '
      'También te quita 10% de cordura por cada robo.',
    controls: 'Joystick para mover + Botón morado para esconderte',
    tip: 
      'Usa las cajas registradoras (brillo dorado) para recuperar '
      '50% de la cordura robada. ¡Planifica tu ruta!',
  ),
  
  gameOver: GameOverContent(
    messages: [
      'La avaricia te consumió',
      'Perdiste todo lo que robaste',
      'Los likes no valen tu cordura',
    ],
    flavorText: 'Valeria sigue sin hogar. Tú sigues con tus likes.',
  ),
  
  victory: VictoryContent(
    cinematicLines: [
      'Compartiste algo que no debías',
      'Número de cuenta: ████████',
      'Dirección: █████████',
      '',
      'Valeria lo perdió todo',
      'Su casa. Sus ahorros. Sus hijos.',
      '',
      'Tú ganaste 15,632 likes',
      '',
      '¿Valió la pena?',
    ],
    stats: [
      StatConfig(
        key: 'stolenItems',
        label: 'Evidencias Robadas',
        formatter: (value) => '$value veces',
      ),
      StatConfig(
        key: 'cashRegistersLooted',
        label: 'Cajas Saqueadas',
        formatter: (value) => '$value de 5',
      ),
      StatConfig(
        key: 'stolenSanity',
        label: 'Cordura Robada',
        formatter: (value) => '${(value * 100).toInt()}%',
      ),
      StatConfig(
        key: 'evidenceCollected',
        label: 'Evidencias Finales',
        formatter: (value) => '$value de 5',
      ),
      StatConfig(
        key: 'timeElapsed',
        label: 'Tiempo',
        formatter: (value) => '${value.toStringAsFixed(1)}s',
      ),
    ],
  ),
)
```

## Error Handling

### Missing Content Fallback

```dart
ArcContent? getArcContent(String arcId) {
  final content = _arcContent[arcId];
  if (content == null) {
    print('⚠️ No content found for arc: $arcId, using default');
    return _getDefaultContent(arcId);
  }
  return content;
}

ArcContent _getDefaultContent(String arcId) {
  return ArcContent(
    arcId: arcId,
    arcNumber: '?',
    title: 'UNKNOWN',
    subtitle: 'Arc in development',
    briefing: BriefingContent(
      objective: 'Recolecta 5 evidencias',
      mechanicTitle: 'MECÁNICA',
      mechanicDescription: 'Mecánica en desarrollo',
      controls: 'Joystick + Botón morado',
      tip: 'Evita al enemigo',
    ),
    gameOver: GameOverContent(
      messages: ['Game Over'],
      flavorText: '',
    ),
    victory: VictoryContent(
      cinematicLines: ['Victoria'],
      stats: [],
    ),
  );
}
```

### Null Safety

- Todos los widgets que usan `ArcContent` deben manejar `null`
- Usar operador `??` para valores por defecto
- Validar `arcId` antes de consultar contenido

## Testing Strategy

### Unit Tests

1. **ArcContent Model Tests**
   - Verificar creación de instancias
   - Validar todos los campos requeridos

2. **ArcDataProvider Tests**
   - Verificar que todos los arcos tienen contenido
   - Verificar fallback para arcos no encontrados
   - Verificar que el contenido es consistente

### Integration Tests

1. **Briefing Screen Tests**
   - Verificar que muestra contenido correcto por arcId
   - Verificar que maneja arcos sin contenido
   - Verificar layout responsive

2. **Game Over Screen Tests**
   - Verificar mensajes temáticos por arco
   - Verificar que no muestra contenido de otros arcos

3. **Victory Cinematic Tests**
   - Verificar que muestra líneas correctas
   - Verificar que muestra estadísticas configuradas
   - Verificar formateo de valores

### Manual Testing Checklist

- [ ] Abrir briefing de Arco 2, verificar contenido de Avaricia
- [ ] Perder en Arco 2, verificar mensajes de avaricia (no gula)
- [ ] Ganar Arco 2, verificar cinemática de Valeria
- [ ] Verificar estadísticas específicas (robos, cajas)
- [ ] Repetir para cada arco implementado

## Performance Considerations

- `ArcContent` es estático, se carga una vez al inicio
- No hay operaciones costosas en tiempo de ejecución
- Contenido se consulta por `arcId` (O(1) con Map)
- Cinemáticas usan animaciones existentes, no agregan overhead

## Migration Path

1. Crear `arc_content.dart` con modelos
2. Extender `ArcDataProvider` con contenido de Arco 1 y 2
3. Modificar `_ArcBriefingScreen` para usar nuevo contenido
4. Modificar `GameOverScreen` para recibir y usar `arcId`
5. Modificar `ArcVictoryCinematic` para usar configuración de stats
6. Agregar contenido para arcos restantes (3-7)
7. Testing exhaustivo

## Future Enhancements

- Soporte para múltiples idiomas en contenido
- Contenido dinámico basado en dificultad
- Cinemáticas con imágenes/videos
- Logros específicos por arco
- Comparación de estadísticas entre intentos
