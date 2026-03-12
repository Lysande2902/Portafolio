import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/store_item.dart';

/// Widget para mostrar iconos de items con fallback
class ItemIcon extends StatelessWidget {
  /// ID del item
  final String itemId;
  
  /// Tipo de item
  final StoreItemType type;
  
  /// Tamaño del icono
  final double size;
  
  /// Si debe mostrar badge
  final bool showBadge;
  
  /// Texto del badge (opcional)
  final String? badgeText;
  
  /// Si el item es premium
  final bool isPremium;

  const ItemIcon({
    super.key,
    required this.itemId,
    required this.type,
    this.size = 40.0,
    this.showBadge = false,
    this.badgeText,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Contenedor del icono
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF8B0000).withOpacity(0.2),
            borderRadius: BorderRadius.circular(size * 0.1),
            border: Border.all(
              color: isPremium 
                  ? const Color(0xFFE57373) 
                  : const Color(0xFF8B0000).withOpacity(0.3),
              width: isPremium ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.1),
            child: _buildIcon(),
          ),
        ),
        
        // Badge si es necesario
        if (showBadge && badgeText != null)
          Positioned(
            top: -4,
            right: -4,
            child: _buildBadge(),
          ),
      ],
    );
  }

  /// Construye el icono del item
  Widget _buildIcon() {
    // Siempre usar placeholder (iconos de Flutter)
    return _buildPlaceholder();
  }

  /// Construye el placeholder cuando no se puede cargar el icono
  Widget _buildPlaceholder() {
    IconData iconData;
    
    switch (type) {
      case StoreItemType.consumable:
        iconData = Icons.inventory_2;
        break;
      case StoreItemType.skin:
        iconData = Icons.person;
        break;
      case StoreItemType.bundle:
        iconData = Icons.card_giftcard;
        break;
      case StoreItemType.battlePass:
        iconData = Icons.military_tech;
        break;
      case StoreItemType.theme:
        iconData = Icons.palette;
        break;
      case StoreItemType.protocol:
        iconData = Icons.security;
        break;
      case StoreItemType.narrative:
        iconData = Icons.library_books;
        break;
      case StoreItemType.music:
        iconData = Icons.music_note;
        break;
    }
    
    return Center(
      child: Icon(
        iconData,
        color: const Color(0xFF8B0000),
        size: size * 0.6,
      ),
    );
  }

  /// Construye el badge
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isPremium 
            ? const Color(0xFFE57373) 
            : const Color(0xFF8B0000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Text(
        badgeText!,
        style: GoogleFonts.courierPrime(
          fontSize: 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
