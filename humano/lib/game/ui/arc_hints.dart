import 'package:flutter/material.dart';

/// Hint data for each arc
class ArcHint {
  final String id;
  final String message;
  final IconData icon;
  final HintTrigger trigger;
  final int? triggerValue;

  const ArcHint({
    required this.id,
    required this.message,
    required this.icon,
    required this.trigger,
    this.triggerValue,
  });
}

/// When to trigger a hint
enum HintTrigger {
  onStart,           // Show at game start
  onEvidenceCount,   // Show when evidence count reaches value
  onLowSanity,       // Show when sanity is low
  onNearEnemy,       // Show when near enemy
  onItemAvailable,   // Show when specific item is available
  onTime,            // Show after X seconds
}

/// Hints for each arc
class ArcHints {
  /// Gluttony Arc (Arco 1) hints
  static List<ArcHint> get gluttonyHints => [
    const ArcHint(
      id: 'gluttony_start',
      message: 'Recoge 5 fragmentos',
      icon: Icons.flag,
      trigger: HintTrigger.onStart,
    ),
    const ArcHint(
      id: 'gluttony_food',
      message: 'Comida distrae al enemigo',
      icon: Icons.apple,
      trigger: HintTrigger.onTime,
      triggerValue: 15,
    ),
    const ArcHint(
      id: 'gluttony_hide',
      message: 'Escóndete en spots verdes',
      icon: Icons.visibility_off,
      trigger: HintTrigger.onNearEnemy,
    ),
    const ArcHint(
      id: 'gluttony_slow',
      message: 'Fragmentos te hacen lento',
      icon: Icons.warning,
      trigger: HintTrigger.onEvidenceCount,
      triggerValue: 3,
    ),
  ];

  /// Greed Arc (Arco 2) hints
  static List<ArcHint> get greedHints => [
    const ArcHint(
      id: 'greed_start',
      message: 'Cuidado con la rata',
      icon: Icons.flag,
      trigger: HintTrigger.onStart,
    ),
    const ArcHint(
      id: 'greed_coins',
      message: 'Monedas distraen enemigo',
      icon: Icons.monetization_on,
      trigger: HintTrigger.onTime,
      triggerValue: 15,
    ),
    const ArcHint(
      id: 'greed_registers',
      message: 'Cajas recuperan cordura',
      icon: Icons.favorite,
      trigger: HintTrigger.onLowSanity,
    ),
    const ArcHint(
      id: 'greed_rat',
      message: 'Rata roba cada 5s',
      icon: Icons.warning,
      trigger: HintTrigger.onEvidenceCount,
      triggerValue: 1,
    ),
  ];

  /// Envy Arc (Arco 3) hints
  static List<ArcHint> get envyHints => [
    const ArcHint(
      id: 'envy_start',
      message: 'Fotos congelan enemigo',
      icon: Icons.flag,
      trigger: HintTrigger.onStart,
    ),
    const ArcHint(
      id: 'envy_photos',
      message: 'Coloca fotos en su camino',
      icon: Icons.camera_alt,
      trigger: HintTrigger.onTime,
      triggerValue: 15,
    ),
    const ArcHint(
      id: 'envy_mirror',
      message: 'Enemigo copia movimientos',
      icon: Icons.compare_arrows,
      trigger: HintTrigger.onNearEnemy,
    ),
    const ArcHint(
      id: 'envy_inaccessible',
      message: 'Algunas fotos inaccesibles',
      icon: Icons.info_outline,
      trigger: HintTrigger.onTime,
      triggerValue: 20,
    ),
  ];

  /// Lust Arc (Arco 4) hints
  static List<ArcHint> get lustHints => [
    const ArcHint(
      id: 'lust_start',
      message: 'Evita zonas de atracción',
      icon: Icons.flag,
      trigger: HintTrigger.onStart,
    ),
  ];

  /// Pride Arc (Arco 5) hints
  static List<ArcHint> get prideHints => [
    const ArcHint(
      id: 'pride_start',
      message: 'Enemigo se fortalece',
      icon: Icons.flag,
      trigger: HintTrigger.onStart,
    ),
  ];

  /// Sloth Arc (Arco 6) hints
  static List<ArcHint> get slothHints => [
    const ArcHint(
      id: 'sloth_start',
      message: 'Mantén ruido bajo',
      icon: Icons.flag,
      trigger: HintTrigger.onStart,
    ),
  ];

  /// Wrath Arc (Arco 7) hints
  static List<ArcHint> get wrathHints => [
    const ArcHint(
      id: 'wrath_start',
      message: 'Enemigo se enfurece',
      icon: Icons.flag,
      trigger: HintTrigger.onStart,
    ),
  ];

  /// Get hints for a specific arc
  static List<ArcHint> getHintsForArc(String arcId) {
    switch (arcId) {
      case 'arc_1_gula':
        return gluttonyHints;
      case 'arc_2_greed':
        return greedHints;
      case 'arc_3_envy':
        return envyHints;
      case 'arc_4_lust':
        return lustHints;
      case 'arc_5_pride':
        return prideHints;
      case 'arc_6_sloth':
        return slothHints;
      case 'arc_7_wrath':
        return wrathHints;
      default:
        return [];
    }
  }
}
