# Diagrama Simple: Sistema de Fragmentos

## Flujo Básico

```
┌─────────────────────────────────────────────────────────────┐
│                    JUGANDO EL ARCO 1                        │
│                                                             │
│  Jugador recoge evidencias:                                │
│  📄 Evidencia 1 → evidenceCollected = 1                    │
│  📄 Evidencia 2 → evidenceCollected = 2                    │
│  📄 Evidencia 3 → evidenceCollected = 3                    │
│  ...                                                        │
│  📄 Evidencia 7 → evidenceCollected = 7                    │
│                                                             │
│  (Jugador llega a la puerta de salida)                    │
│  🚪 VICTORIA!                                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  GUARDANDO EN FIREBASE                      │
│                                                             │
│  unlockFragmentsForArcProgress('arc_1_consumo_codicia', 7) │
│                                                             │
│  Loop: for (i = 1; i <= 7; i++)                           │
│    ✅ Fragmento 1 → Guardado en Firebase                   │
│    ✅ Fragmento 2 → Guardado en Firebase                   │
│    ✅ Fragmento 3 → Guardado en Firebase                   │
│    ✅ Fragmento 4 → Guardado en Firebase                   │
│    ✅ Fragmento 5 → Guardado en Firebase                   │
│    ✅ Fragmento 6 → Guardado en Firebase                   │
│    ✅ Fragmento 7 → Guardado en Firebase                   │
│                                                             │
│  Fragmentos 8, 9, 10 → Aún bloqueados 🔒                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  EN EL ARCHIVO (EXPEDIENTES)                │
│                                                             │
│  Fragmento 1: ✅ "El video explotó..."                     │
│  Fragmento 2: ✅ "Intenté borrarlo..."                     │
│  Fragmento 3: ✅ "Mateo dejó de responder..."              │
│  Fragmento 4: ✅ "Hoy supe que Mateo..."                   │
│  Fragmento 5: ✅ "Sus niños siguen esperándola..."         │
│  Fragmento 6: ✅ "Valeria perdió su casa..."               │
│  Fragmento 7: ✅ "El banco se quedó con todo..."           │
│  Fragmento 8: 🔒 Bloqueado                                 │
│  Fragmento 9: 🔒 Bloqueado                                 │
│  Fragmento 10: 🔒 Bloqueado                                │
│                                                             │
│  Progreso: 7/10 (70%)                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Rejugando el Arco

```
┌─────────────────────────────────────────────────────────────┐
│              REJUGANDO EL ARCO 1 (Segunda Vez)              │
│                                                             │
│  Ya tienes: Fragmentos 1-7 ✅                              │
│  Objetivo: Conseguir fragmentos 8, 9, 10                   │
│                                                             │
│  Jugador recoge evidencias:                                │
│  📄 Evidencia 1 → evidenceCollected = 1                    │
│  📄 Evidencia 2 → evidenceCollected = 2                    │
│  ...                                                        │
│  📄 Evidencia 10 → evidenceCollected = 10 ✅               │
│                                                             │
│  🚪 VICTORIA!                                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  GUARDANDO EN FIREBASE                      │
│                                                             │
│  unlockFragmentsForArcProgress('arc_1_consumo_codicia', 10)│
│                                                             │
│  Loop: for (i = 1; i <= 10; i++)                          │
│    ⏭️ Fragmento 1 → Ya estaba desbloqueado (skip)         │
│    ⏭️ Fragmento 2 → Ya estaba desbloqueado (skip)         │
│    ⏭️ Fragmento 3 → Ya estaba desbloqueado (skip)         │
│    ⏭️ Fragmento 4 → Ya estaba desbloqueado (skip)         │
│    ⏭️ Fragmento 5 → Ya estaba desbloqueado (skip)         │
│    ⏭️ Fragmento 6 → Ya estaba desbloqueado (skip)         │
│    ⏭️ Fragmento 7 → Ya estaba desbloqueado (skip)         │
│    ✅ Fragmento 8 → NUEVO! Guardado en Firebase            │
│    ✅ Fragmento 9 → NUEVO! Guardado en Firebase            │
│    ✅ Fragmento 10 → NUEVO! Guardado en Firebase           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  EN EL ARCHIVO (EXPEDIENTES)                │
│                                                             │
│  Fragmento 1: ✅ "El video explotó..."                     │
│  Fragmento 2: ✅ "Intenté borrarlo..."                     │
│  Fragmento 3: ✅ "Mateo dejó de responder..."              │
│  Fragmento 4: ✅ "Hoy supe que Mateo..."                   │
│  Fragmento 5: ✅ "Sus niños siguen esperándola..."         │
│  Fragmento 6: ✅ "Valeria perdió su casa..."               │
│  Fragmento 7: ✅ "El banco se quedó con todo..."           │
│  Fragmento 8: ✅ "La deuda creció exponencialmente..."     │
│  Fragmento 9: ✅ "Valeria intentó suicidarse..."           │
│  Fragmento 10: ✅ "Ahora sabes la verdad completa..."      │
│                                                             │
│  Progreso: 10/10 (100%) 🎉                                 │
│  ARCO COMPLETO!                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Comparación: Antes vs Después del Fix

### ❌ ANTES (Problema)

```
Arco 1: Consumo y Codicia
├─ Fragmentos en el juego: 10 evidencias
├─ Fragmentos que se guardaban: Solo 5 (límite hardcodeado)
└─ Resultado: Fragmentos 6-10 se PERDÍAN ❌

Ejemplo:
  Recolectas 10 evidencias → Solo se guardan 5
  Fragmentos 6, 7, 8, 9, 10 → NUNCA se desbloquean
  Imposible completar el arco al 100%
```

### ✅ DESPUÉS (Solucionado)

```
Arco 1: Consumo y Codicia
├─ Fragmentos en el juego: 10 evidencias
├─ Fragmentos que se guardan: 10 (dinámico según arco)
└─ Resultado: Todos los fragmentos se guardan ✅

Ejemplo:
  Recolectas 10 evidencias → Se guardan los 10
  Fragmentos 1-10 → Todos se desbloquean
  Posible completar el arco al 100% ✅
```

---

## Tabla de Arcos

| Arco | Nombre | Fragmentos | Checkpoint |
|------|--------|------------|------------|
| 1 | Consumo y Codicia | 10 | 5 (Mateo → Valeria) |
| 2 | Envidia y Lujuria | 10 | 5 (Lucía → Adriana) |
| 3 | Soberbia y Pereza | 10 | 5 (Carlos → Miguel) |
| 4 | Ira | 5 | No (solo Víctor) |
| **TOTAL** | | **35** | |

---

## Código Clave

### Determinar Máximo de Fragmentos

```dart
// En fragments_provider.dart
int maxFragments = 10;  // Por defecto: arcos fusionados
if (arcId == 'arc_4_ira' || arcId == 'arc_7_wrath') {
  maxFragments = 5;  // Arco final
}
```

### Guardar Fragmentos Progresivamente

```dart
// En fragments_provider.dart
for (int i = 1; i <= fragmentsCollected && i <= maxFragments; i++) {
  if (!isFragmentUnlocked(arcId, i)) {
    await unlockFragment(arcId, i);  // Guarda en Firebase
  }
}
```

### Verificar si Está Desbloqueado

```dart
// En archive_screen.dart
bool isUnlocked = fragmentsProvider.isFragmentUnlocked(
  'arc_1_consumo_codicia',
  fragmentNumber,  // 1-10
);
```

---

**Autor**: Kiro AI  
**Fecha**: 28 de enero de 2025  
