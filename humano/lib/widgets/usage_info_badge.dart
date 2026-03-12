import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge que muestra información de dónde se usa un item
class UsageInfoBadge extends StatelessWidget {
  /// Texto de uso
  final String usageText;
  
  /// Icono apropiado
  final IconData icon;
  
  /// Color del badge (opcional)
  final Color? backgroundColor;
  
  /// Color del texto (opcional)
  final Color? textColor;

  const UsageInfoBadge({
    super.key,
    required this.usageText,
    required this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF8B0000).withOpacity(0.3);
    final txtColor = textColor ?? Colors.white.withOpacity(0.9);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B0000).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: txtColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              usageText,
              style: GoogleFonts.courierPrime(
                fontSize: 9,
                color: txtColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
