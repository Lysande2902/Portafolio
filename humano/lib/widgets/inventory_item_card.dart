import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/inventory_item.dart';
import '../data/models/store_item.dart';
import 'item_icon.dart';
import 'skin_preview.dart';
import 'usage_info_badge.dart';

/// Card para mostrar items en el inventario
class InventoryItemCard extends StatelessWidget {
  /// Item del inventario
  final InventoryItem item;
  
  /// Callback para equipar/desequipar
  final VoidCallback? onEquip;
  
  /// Callback para ver detalles
  final VoidCallback? onDetails;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onEquip,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final wineRed = const Color(0xFF8B0000);
    final lightRed = const Color(0xFFE57373);
    
    return GestureDetector(
      onTap: onDetails,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isPremium ? lightRed : wineRed.withOpacity(0.5),
            width: item.isPremium ? 2 : 1,
          ),
          boxShadow: item.isPremium
              ? [
                  BoxShadow(
                    color: lightRed.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con badges
            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  // Premium badge
                  if (item.isPremium)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: lightRed,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: GoogleFonts.courierPrime(
                            fontSize: 7,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Cantidad para consumibles
                  if (item.type == StoreItemType.consumable && item.quantity > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: wineRed,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: GoogleFonts.courierPrime(
                          fontSize: 7,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Icono/Preview
            Expanded(
              flex: 3,
              child: Center(
                child: _buildItemPreview(),
              ),
            ),
            
            // Información
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      item.name,
                      style: GoogleFonts.courierPrime(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Descripción
                    Text(
                      item.description,
                      style: GoogleFonts.courierPrime(
                        fontSize: 7,
                        color: Colors.grey[400],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Badge de uso
                    UsageInfoBadge(
                      usageText: item.getUsageText(),
                      icon: item.getUsageIcon(),
                    ),
                    
                    const Spacer(),
                    
                    // Botón de equipar (solo para skins)
                    if (item.canBeEquipped())
                      SizedBox(
                        width: double.infinity,
                        height: 24,
                        child: ElevatedButton(
                          onPressed: item.isEquipped ? null : onEquip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.isEquipped 
                                ? Colors.grey[800] 
                                : wineRed,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (item.isEquipped)
                                const Icon(
                                  Icons.check_circle,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              if (item.isEquipped)
                                const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  item.isEquipped ? 'EQUIPADO' : 'EQUIPAR',
                                  style: GoogleFonts.courierPrime(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el preview del item según su tipo
  Widget _buildItemPreview() {
    if (item.type == StoreItemType.skin) {
      return SkinPreview(
        skinId: item.id,
        isEquipped: item.isEquipped,
        isPremium: item.isPremium,
        size: 80,
      );
    } else {
      return ItemIcon(
        itemId: item.id,
        type: item.type,
        size: 60,
        isPremium: item.isPremium,
        showBadge: item.quantity > 1,
        badgeText: 'x${item.quantity}',
      );
    }
  }
}
