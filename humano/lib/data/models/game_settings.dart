class GameSettings {
  final double masterVolume; // Volumen general (nuevo)
  final double musicVolume;
  final double sfxVolume;
  final double touchSensitivity; // Sensibilidad del toque (nuevo)
  final bool vibrationEnabled; // Vibración (nuevo)
  
  // Efectos visuales (mantener por compatibilidad, pero no se usan en móvil)
  final bool vhsEffectsEnabled;
  final bool glitchEffectsEnabled;
  final bool screenShakeEnabled;

  const GameSettings({
    required this.masterVolume,
    required this.musicVolume,
    required this.sfxVolume,
    required this.touchSensitivity,
    required this.vibrationEnabled,
    required this.vhsEffectsEnabled,
    required this.glitchEffectsEnabled,
    required this.screenShakeEnabled,
  });

  static GameSettings get defaults => const GameSettings(
        masterVolume: 0.8, // 80% por defecto
        musicVolume: 0.6, // 60% por defecto
        sfxVolume: 1.0, // 100% por defecto
        touchSensitivity: 1.0, // Normal por defecto
        vibrationEnabled: true, // Activado por defecto
        vhsEffectsEnabled: true,
        glitchEffectsEnabled: true,
        screenShakeEnabled: true,
      );

  Map<String, dynamic> toJson() {
    return {
      'masterVolume': masterVolume,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'touchSensitivity': touchSensitivity,
      'vibrationEnabled': vibrationEnabled,
      'vhsEffectsEnabled': vhsEffectsEnabled,
      'glitchEffectsEnabled': glitchEffectsEnabled,
      'screenShakeEnabled': screenShakeEnabled,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? 0.8,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.6,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
      touchSensitivity: (json['touchSensitivity'] as num?)?.toDouble() ?? 1.0,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      vhsEffectsEnabled: json['vhsEffectsEnabled'] as bool? ?? true,
      glitchEffectsEnabled: json['glitchEffectsEnabled'] as bool? ?? true,
      screenShakeEnabled: json['screenShakeEnabled'] as bool? ?? true,
    );
  }

  GameSettings copyWith({
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    double? touchSensitivity,
    bool? vibrationEnabled,
    bool? vhsEffectsEnabled,
    bool? glitchEffectsEnabled,
    bool? screenShakeEnabled,
  }) {
    return GameSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      touchSensitivity: touchSensitivity ?? this.touchSensitivity,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      vhsEffectsEnabled: vhsEffectsEnabled ?? this.vhsEffectsEnabled,
      glitchEffectsEnabled: glitchEffectsEnabled ?? this.glitchEffectsEnabled,
      screenShakeEnabled: screenShakeEnabled ?? this.screenShakeEnabled,
    );
  }
}
