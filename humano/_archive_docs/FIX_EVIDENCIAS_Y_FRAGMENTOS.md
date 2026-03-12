# FIX: Evidencias y Fragmentos en Arcos Fusionados

**Fecha**: 28 de enero de 2025  
**Problemas**:
1. Algunas evidencias no se podían recoger
2. El contador mostraba "5 fragmentos" en lugar de "10 fragmentos"

## Problema 1: Evidencias Difíciles de Recoger

### Causa
El radio de recolección era muy pequeño (50 píxeles), haciendo difícil recoger evidencias.

### Solución
Aumentado el radio de recolección de 50 a 80 píxeles en `consumo_codicia_arc_game.dart`:

```dart
// ANTES
if (distance < 50) {
  component.collect();
  // ...
}

// DESPUÉS
if (distance < 80) {  // Increased from 50 to 80
  component.collect();
  // ...
}
```

### Logs de Debug Agregados
```dart
debugPrint('📄 [CONSUMO_CODICIA] Evidence collected! Total: $evidenceCollected/10 (Phase $currentPhase)');
debugPrint('   Evidence position: ${component.position}');
debugPrint('   Player position: ${_player!.position}');
debugPrint('   Distance: ${distance.toStringAsFixed(1)}');
```

## Problema 2: Contador Mostraba 5 en Lugar de 10

### Causa
El sistema de fragmentos estaba configurado para arcos individuales (5 fragmentos cada uno), pero los arcos fusionados tienen 10 fragmentos.

### Archivos Afectados

#### 1. `fragments_provider.dart`

**Problema**: Límite hardcodeado de 5 fragmentos por arco

**Solución**: 
- Agregados IDs de arcos fusionados al mapa
- Implementada lógica dinámica para determinar máximo de fragmentos

```dart
// ANTES
Map<String, Set<int>> _unlockedFragments = {
  'arc_1_gula': {},
  'arc_2_greed': {},
  // ...
};

if (fragmentNumber < 1 || fragmentNumber > 5) {
  // Error
}

// DESPUÉS
Map<String, Set<int>> _unlockedFragments = {
  'arc_1_consumo_codicia': {}, // Fusionado: 10 fragmentos
  'arc_2_envidia_lujuria': {}, // Fusionado: 10 fragmentos
  'arc_3_soberbia_pereza': {}, // Fusionado: 10 fragmentos
  'arc_4_ira': {}, // Final: 5 fragmentos
  // IDs antiguos para compatibilidad
  'arc_1_gula': {},
  // ...
};

// Determinar máximo de fragmentos según el arco
int maxFragments = 10; // Por defecto para arcos fusionados
if (arcId == 'arc_4_ira' || arcId == 'arc_7_wrath') {
  maxFragments = 5; // Arco final solo tiene 5 fragmentos
}

if (fragmentNumber < 1 || fragmentNumber > maxFragments) {
  // Error
}
```

#### 2. `arc_data_provider.dart`

**Problema**: El formatter mostraba "de 10" pero el comentario no era claro

**Solución**: Agregado comentario explicativo

```dart
StatConfig(
  key: 'evidenceCollected',
  label: 'Fragmentos Recolectados',
  formatter: (value) => '$value de 10', // Arco fusionado: 10 fragmentos
),
```

## Estructura de Arcos

### Arcos Fusionados (10 fragmentos cada uno)
1. **Arco 1**: Consumo y Codicia (Gula + Avaricia)
   - ID: `arc_1_consumo_codicia`
   - Fragmentos: 10
   - Checkpoint: 5 fragmentos (cambio de enemigo)

2. **Arco 2**: Envidia y Lujuria
   - ID: `arc_2_envidia_lujuria`
   - Fragmentos: 10
   - Checkpoint: 5 fragmentos

3. **Arco 3**: Soberbia y Pereza
   - ID: `arc_3_soberbia_pereza`
   - Fragmentos: 10
   - Checkpoint: 5 fragmentos

### Arco Final (5 fragmentos)
4. **Arco 4**: Ira
   - ID: `arc_4_ira`
   - Fragmentos: 5
   - Sin checkpoint (1 solo enemigo)

## Total de Fragmentos

- Arcos fusionados: 3 × 10 = 30 fragmentos
- Arco final: 1 × 5 = 5 fragmentos
- **Total**: 35 fragmentos

## Archivos Modificados

1. ✅ `humano/lib/game/arcs/consumo_codicia/consumo_codicia_arc_game.dart`
   - Aumentado radio de recolección de 50 a 80
   - Agregados logs de debug

2. ✅ `humano/lib/data/providers/fragments_provider.dart`
   - Agregados IDs de arcos fusionados
   - Implementada lógica dinámica para máximo de fragmentos
   - Actualizado cálculo de progreso

3. ✅ `humano/lib/data/providers/arc_data_provider.dart`
   - Agregado comentario explicativo en formatter

4. ✅ `humano/lib/game/arcs/consumo_codicia/components/evidence_component.dart`
   - Agregado comentario sobre anchor

## Testing

### Verificar Recolección de Evidencias

1. Ejecuta `flutter run`
2. Inicia Arco 1 (Consumo y Codicia)
3. Acércate a una evidencia (ícono de archivo)
4. **Resultado esperado**: Se recoge cuando estás a ~80 píxeles de distancia
5. **Logs esperados**:
```
📄 [CONSUMO_CODICIA] Evidence collected! Total: 1/10 (Phase 1)
   Evidence position: Vector2(500.0, 700.0)
   Player position: Vector2(480.0, 690.0)
   Distance: 22.4
```

### Verificar Contador de Fragmentos

1. Recoge 1 fragmento
2. Pausa el juego o ve al menú
3. **Resultado esperado**: Contador muestra "1/10" o "1 de 10"
4. Recoge los 10 fragmentos
5. **Resultado esperado**: Contador muestra "10/10"

### Verificar Checkpoint

1. Recoge 5 fragmentos en Fase 1
2. **Resultado esperado**: 
   - Mateo (Cerdo) desaparece
   - Valeria (Rata) aparece
   - Log: `🎯 [CHECKPOINT] Reached! Switching from Mateo to Valeria`
   - Log: `   Fragments collected: 5/10`

## Resultado

✅ **Evidencias más fáciles de recoger** (radio 80px)  
✅ **Contador muestra 10 fragmentos correctamente**  
✅ **Sistema soporta arcos fusionados (10) y arco final (5)**  
✅ **Logs de debug para diagnosticar problemas**  

---

**Autor**: Kiro AI  
**Fecha**: 28 de enero de 2025  
