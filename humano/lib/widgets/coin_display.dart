import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/config/store_assets.dart';
import '../core/utils/currency_formatter.dart';

/// Tamaño del display de monedas
enum CoinDisplaySize {
  small,
  medium,
  large,
}

/// Widget reutilizable para mostrar monedas con icono
class CoinDisplay extends StatelessWidget {
  /// Cantidad de monedas a mostrar
  final int amount;
  
  /// Tamaño del display
  final CoinDisplaySize size;
  
  /// Si el widget es clickeable
  final bool clickable;
  
  /// Callback cuando se hace click (solo si clickable es true)
  final VoidCallback? onTap;
  
  /// Color del texto (opcional)
  final Color? textColor;
  
  /// Color del icono (opcional)
  final Color? iconColor;

  const CoinDisplay({
    super.key,
    required this.amount,
    this.size = CoinDisplaySize.medium,
    this.clickable = false,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    
    if (clickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    
    return content;
  }

  Widget _buildContent() {
    // Icons.group para representar "Seguidores"
    // Ignoramos StoreAssets para usar el nuevo icono temático
    
    // Obtener tamaños según el size
    final iconSize = _getIconSize();
    final fontSize = _getFontSize();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icono de Seguidores
        Icon(
          Icons.group,
          size: iconSize,
          color: iconColor ?? const Color(0xFFE57373),
        ),
        
        SizedBox(width: _getSpacing()),
        
        // Cantidad
        Text(
          '${_formatAmount(amount)} SEGS',
          style: GoogleFonts.shareTechMono(
            fontSize: fontSize,
            color: textColor ?? const Color(0xFFE57373),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        
        // Icono de agregar si es clickeable
        if (clickable && onTap != null) ...[
          SizedBox(width: _getSpacing()),
          Icon(
            Icons.add_circle,
            size: iconSize * 0.8,
            color: iconColor ?? const Color(0xFFE57373),
          ),
        ],
      ],
    );
  }

  /// Obtiene el tamaño del icono según el size
  double _getIconSize() {
    switch (size) {
      case CoinDisplaySize.small:
        return 12.0;
      case CoinDisplaySize.medium:
        return 16.0;
      case CoinDisplaySize.large:
        return 24.0;
    }
  }

  /// Obtiene el tamaño de fuente según el size
  double _getFontSize() {
    switch (size) {
      case CoinDisplaySize.small:
        return 10.0;
      case CoinDisplaySize.medium:
        return 12.0;
      case CoinDisplaySize.large:
        return 16.0;
    }
  }

  /// Obtiene el espaciado según el size
  double _getSpacing() {
    switch (size) {
      case CoinDisplaySize.small:
        return 2.0;
      case CoinDisplaySize.medium:
        return 4.0;
      case CoinDisplaySize.large:
        return 6.0;
    }
  }

  /// Formatea la cantidad para mostrar (ej: 1000 -> 1K)
  String _formatAmount(int amount) {
    return CurrencyFormatter.format(amount);
  }
}
