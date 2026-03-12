# Design Document

## Overview

Este diseño aborda dos problemas críticos del juego mediante soluciones específicas y medibles:

1. **Balance del Arco de Envidia**: Ajustar la progresión de dificultad del enemigo para que sea desafiante pero ganable
2. **Disclaimer del Demo Ending**: Implementar una pantalla de advertencia clara y respetuosa antes del contenido sensible

Ambas soluciones se enfocan en mejorar la experiencia del jugador sin comprometer la intención artística del juego.

## Architecture

### Balance de Envidia

```
ChameleonEnemy
├── Base Speed: 80 (patrol) / 110 (chase)
├── Phase 1 (0-1 evidence): Base speeds
├── Phase 2 (2-3 evidence): +10 speed (90/120)
└── Phase 3 (4-5 evidence): +10 speed (100/130)
```

### Disclaimer Flow

```
Envy Arc Victory
    ↓
Check Disclaimer Preference
    ↓
Show Disclaimer Screen
    ├── "Continuar" → Demo Ending
    └── "Saltar" → Archive Screen (save preference)
```

## Components and Interfaces

### 1. ChameleonEnemy (Modified)

**Changes**:
```dart
class ChameleonEnemy extends PositionComponent {
  // OLD: Increase speed by 20
  // NEW: Increase speed by 10
  void increasePhase() {
    currentSpeed += 10.0; // Changed from 20.0
    debugPrint('⚡ [CHAMELEON-ENEMY] Phase increased! New speed: $currentSpeed');
  }
  
  // NEW: Grace period after unhiding
  double _graceTimer = 0.0;
  static const double gracePeriod = 1.0;
  
  void update(double dt) {
    // Handle grace period
    if (_graceTimer > 0) {
      _graceTimer -= dt;
    }
    
    // Check chase condition with grace period
    bool canChase = distanceToPlayer < chaseDistance && 
                    !isPlayerHidden && 
                    _graceTimer <= 0;
    // ...
  }
}
```

### 2. DisclaimerPreferenceManager

**Purpose**: Gestionar la preferencia del jugador sobre ver contenido sensible

**Interface**:
```dart
class DisclaimerPreferenceManager {
  static const String _keyDemoEndingSkipped = 'demo_ending_skipped';
  
  /// Check if player has chosen to skip demo ending
  Future<bool> hasSkippedDemoEnding();
  
  /// Save player's decision to skip
  Future<void> setDemoEndingSkipped(bool skipped);
  
  /// Reset preference (for settings/data reset)
  Future<void> resetPreference();
}
```

### 3. ImprovedDemoEndingDisclaimerScreen

**Purpose**: Pantalla de disclaimer mejorada con diseño claro y opciones

**Features**:
- Diseño visual calmado (colores neutros)
- Advertencias específicas y claras
- Dos botones grandes: "Continuar" y "Saltar"
- Iconos de advertencia apropiados
- Texto legible (18px+)
- Animación suave de entrada

**Layout**:
```
┌─────────────────────────────────────┐
│         ⚠️  ADVERTENCIA             │
│                                     │
│  Este contenido contiene:           │
│  • Temas de salud mental            │
│  • Referencias a autolesión         │
│  • Contenido emocionalmente intenso │
│                                     │
│  Este es el final de la demo.       │
│  El juego completo explorará estos  │
│  temas con mayor profundidad.       │
│                                     │
│  Si necesitas apoyo:                │
│  [Recursos de ayuda]                │
│                                     │
│  ┌──────────┐    ┌──────────┐      │
│  │CONTINUAR │    │  SALTAR  │      │
│  └──────────┘    └──────────┘      │
└─────────────────────────────────────┘
```

## Data Models

### DisclaimerPreference

```dart
class DisclaimerPreference {
  final bool hasSkippedDemoEnding;
  final DateTime? lastDecisionTime;
  
  DisclaimerPreference({
    required this.hasSkippedDemoEnding,
    this.lastDecisionTime,
  });
  
  factory DisclaimerPreference.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### EnemyBalanceConfig

```dart
class EnemyBalanceConfig {
  final double basePatrolSpeed;
  final double baseChaseSpeed;
  final double phaseIncrement;
  final double chaseDetectionRange;
  final double gracePeriod;
  
  const EnemyBalanceConfig({
    this.basePatrolSpeed = 80.0,
    this.baseChaseSpeed = 110.0,
    this.phaseIncrement = 10.0,
    this.chaseDetectionRange = 250.0,
    this.gracePeriod = 1.0,
  });
}
```

## Implementation Details

### Balance Changes

**File**: `lib/game/arcs/envy/components/chameleon_enemy.dart`

**Changes**:
1. Reduce `increasePhase()` increment from 20 to 10
2. Add grace period timer and logic
3. Adjust chase detection to respect grace period

**Expected Results**:
- Phase 1: 80/110 speed (unchanged)
- Phase 2: 90/120 speed (was 100/140)
- Phase 3: 100/130 speed (was 120/160)

### Disclaimer Implementation

**File**: `lib/screens/demo_ending_disclaimer_screen.dart`

**New Implementation**:
```dart
class ImprovedDemoEndingDisclaimerScreen extends StatefulWidget {
  const ImprovedDemoEndingDisclaimerScreen({super.key});
  
  @override
  State<ImprovedDemoEndingDisclaimerScreen> createState() => 
      _ImprovedDemoEndingDisclaimerScreenState();
}

class _ImprovedDemoEndingDisclaimerScreenState 
    extends State<ImprovedDemoEndingDisclaimerScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _fadeController;
  final DisclaimerPreferenceManager _preferenceManager = 
      DisclaimerPreferenceManager();
  
  void _onContinue() async {
    await _preferenceManager.setDemoEndingSkipped(false);
    // Navigate to demo ending
  }
  
  void _onSkip() async {
    await _preferenceManager.setDemoEndingSkipped(true);
    // Navigate to archive
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A2A2A), // Neutral dark
      body: FadeTransition(
        opacity: _fadeController,
        child: SafeArea(
          child: Center(
            child: Container(
              // Disclaimer content
            ),
          ),
        ),
      ),
    );
  }
}
```

## Error Handling

### Storage Errors

**Scenario**: SharedPreferences fails to save disclaimer preference

**Handling**:
1. Log error
2. Default to showing disclaimer (safe fallback)
3. Continue game flow without blocking

### Navigation Errors

**Scenario**: Navigation fails after disclaimer choice

**Handling**:
1. Log error
2. Provide fallback navigation to main menu
3. Show error message to user

## Testing Strategy

### Balance Testing

**Manual Testing**:
- Play through Envy arc collecting all evidence
- Verify enemy speeds at each phase
- Confirm game is winnable with skill
- Test grace period after unhiding

**Metrics to Track**:
- Win rate at each phase
- Average time to complete
- Number of deaths per playthrough
- Player feedback on difficulty

### Disclaimer Testing

**Unit Tests**:
- Test DisclaimerPreferenceManager persistence
- Test preference loading and saving
- Test preference reset

**Widget Tests**:
- Test disclaimer screen rendering
- Test button interactions
- Test navigation flows
- Test animations

**Manual Testing**:
- Verify disclaimer shows before demo ending
- Test "Continuar" flow
- Test "Saltar" flow
- Verify preference persistence
- Test text readability
- Verify emotional tone is appropriate

## Performance Considerations

### Balance Changes

- Minimal performance impact (simple arithmetic changes)
- No additional memory allocation
- No new components or systems

### Disclaimer Screen

- Lightweight screen (< 2MB memory)
- Single SharedPreferences write
- Fast navigation transitions
- Dispose animation controllers properly

## Accessibility

### Visual

- High contrast text on disclaimer
- Large font sizes (18px+)
- Clear button labels
- Sufficient spacing

### Cognitive

- Clear, simple language
- Specific warnings (not vague)
- Easy-to-understand options
- No time pressure on decision

### Emotional

- Calm, neutral design
- Supportive tone
- Respect for player's choice
- Resources provided

## Future Enhancements

### Balance

- Difficulty settings (Easy/Normal/Hard)
- Adaptive difficulty based on player performance
- More photo charges or cooldown reduction
- Additional hiding spots

### Disclaimer

- Customizable content warnings
- Link to external mental health resources
- Option to view skipped content from archive
- Parental controls for sensitive content

## Success Metrics

### Balance

- Win rate increases to 60-70% (from current ~30%)
- Player feedback indicates "challenging but fair"
- Completion rate of Envy arc increases
- Fewer rage quits or early exits

### Disclaimer

- 100% of players see disclaimer before sensitive content
- Clear understanding of content warnings
- Positive feedback on respectful handling
- Reduced complaints about unexpected content
