/// Content model for arc-specific information
/// Used for briefings, game over screens, and victory cinematics
class ArcContent {
  final String arcId;
  final String arcNumber;
  final String title;
  final String subtitle;
  
  final BriefingContent briefing;
  final GameOverContent gameOver;
  final VictoryContent victory;
  
  const ArcContent({
    required this.arcId,
    required this.arcNumber,
    required this.title,
    required this.subtitle,
    required this.briefing,
    required this.gameOver,
    required this.victory,
  });
}

/// Content for the mission briefing screen
class BriefingContent {
  final String objective;
  final String mechanicTitle;
  final String mechanicDescription;
  final String controls;
  final String tip;
  final List<String> phaseNames;
  
  const BriefingContent({
    required this.objective,
    required this.mechanicTitle,
    required this.mechanicDescription,
    required this.controls,
    required this.tip,
    this.phaseNames = const [],
  });
}

/// Content for the game over screen
class GameOverContent {
  final List<String> messages;
  /* 
   * CRUELTY UPDATE:
   * Changed from single flavorText to flavorTexts list to support
   * multiple random mocking messages from the system.
   */
  final List<String> flavorTexts; 
  
  const GameOverContent({
    required this.messages,
    this.flavorTexts = const [],
  });
  
  // Getter for backwards compatibility in UI code
  String get flavorText => flavorTexts.isNotEmpty ? flavorTexts[0] : '';
}

/// Content for the victory cinematic
class VictoryContent {
  final List<String> cinematicLines;
  final List<StatConfig> stats;
  
  const VictoryContent({
    required this.cinematicLines,
    required this.stats,
  });
}

/// Configuration for a statistic display
class StatConfig {
  final String key;
  final String label;
  final String Function(dynamic value) formatter;
  
  const StatConfig({
    required this.key,
    required this.label,
    required this.formatter,
  });
}
