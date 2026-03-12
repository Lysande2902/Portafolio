import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/config/store_assets.dart';

/// Widget para mostrar preview de skins con frame decorativo
class SkinPreview extends StatelessWidget {
  /// ID de la skin
  final String skinId;
  
  /// Si la skin está equipada
  final bool isEquipped;
  
  /// Si la skin es premium
  final bool isPremium;
  
  /// Callback cuando se hace tap
  final VoidCallback? onTap;
  
  /// Tamaño del preview
  final double size;

  const SkinPreview({
    super.key,
    required this.skinId,
    this.isEquipped = false,
    this.isPremium = false,
    this.onTap,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    
    return content;
  }

  Widget _buildContent() {
    final wineRed = const Color(0xFF8B0000);
    final lightRed = const Color(0xFFE57373);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: wineRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPremium ? lightRed : wineRed.withOpacity(0.3),
          width: isPremium ? 2 : 1,
        ),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: lightRed.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Sprite de la skin
          Center(
            child: _buildSkinSprite(),
          ),
          
          // Indicador de equipado
          if (isEquipped)
            Positioned(
              top: 4,
              right: 4,
              child: _buildEquippedBadge(),
            ),
        ],
      ),
    );
  }

  /// Construye el sprite de la skin
  Widget _buildSkinSprite() {
    String? assetPath;
    
    // Determinar la ruta según el ID
    if (skinId.startsWith('player_')) {
      assetPath = StoreAssets.getPlayerSkinSprite(skinId);
    } else if (skinId.startsWith('sin_')) {
      assetPath = StoreAssets.getSinSkinSprite(skinId);
    }

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size * 0.8,
        height: size * 0.8,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    
    return _buildPlaceholder();
  }

  /// Construye el placeholder cuando no se puede cargar el sprite
  Widget _buildPlaceholder() {
    return Icon(
      Icons.person,
      color: const Color(0xFF8B0000),
      size: size * 0.5,
    );
  }

  /// Construye el badge de equipado
  Widget _buildEquippedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            'EQUIPADO',
            style: GoogleFonts.courierPrime(
              fontSize: 8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
