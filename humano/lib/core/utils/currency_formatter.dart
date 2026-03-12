/// Utilidad para formatear cantidades de monedas
/// 0-999: Número completo
/// 1,000-999,999: "1K", "10K", "999K"
/// 1,000,000+: "1M", "10M", etc.
class CurrencyFormatter {
  /// Formatea una cantidad de monedas
  static String format(int amount) {
    if (amount < 0) {
      return '0';
    }
    
    if (amount < 1000) {
      return amount.toString();
    } else if (amount < 1000000) {
      final k = amount / 1000;
      // Si es número entero, no mostrar decimales
      if (k % 1 == 0) {
        return '${k.toInt()}K';
      }
      // Si tiene decimales, mostrar 1 decimal
      return '${k.toStringAsFixed(1)}K';
    } else if (amount < 1000000000) {
      final m = amount / 1000000;
      if (m % 1 == 0) {
        return '${m.toInt()}M';
      }
      return '${m.toStringAsFixed(1)}M';
    } else {
      final b = amount / 1000000000;
      if (b % 1 == 0) {
        return '${b.toInt()}B';
      }
      return '${b.toStringAsFixed(1)}B';
    }
  }
  
  /// Formatea con símbolo de moneda personalizado
  static String formatWithSymbol(int amount, {String symbol = '🪙'}) {
    return '$symbol ${format(amount)}';
  }
}
