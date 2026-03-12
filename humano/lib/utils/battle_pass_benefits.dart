/// Utilidades para calcular los beneficios del Battle Pass
class BattlePassBenefits {
  /// Multiplicador de SEGS para usuarios con Battle Pass
  static const double segsMultiplier = 1.15; // +15%
  
  /// Calcula los SEGS con el bonus del Battle Pass
  static int calculateSegsWithBonus(int baseSegs, bool hasBattlePass) {
    if (!hasBattlePass) return baseSegs;
    return (baseSegs * segsMultiplier).round();
  }
  
  /// Verifica si un contenido del Archivo es exclusivo del Battle Pass
  static bool isExclusiveContent(String contentId) {
    // Contenido exclusivo del Archivo desbloqueado por Battle Pass
    const exclusiveContent = [
      'archive_concept_art_premium',
      'archive_soundtrack_extended',
      'archive_narrative_classified',
      'archive_magnolia_messages_extra',
      'archive_making_of',
    ];
    return exclusiveContent.contains(contentId);
  }
  
  /// Obtiene el mensaje de beneficio para mostrar en la UI
  static String getBenefitMessage() {
    return '🎖️ Battle Pass Activo: +15% SEGS, contenido exclusivo del Archivo';
  }
}
