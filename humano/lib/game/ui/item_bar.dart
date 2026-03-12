import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item bar widget that displays available consumable items in the game HUD
class ItemBar extends StatelessWidget {
  final Map<String, int> availableItems;
  final Function(String itemId) onUseItem;
  final bool isGameActive;

  const ItemBar({
    super.key,
    required this.availableItems,
    required this.onUseItem,
    this.isGameActive = true,
  });

  @override
  Widget build(BuildContext context) {
    // Filter items with quantity > 0
    final activeItems = availableItems.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: activeItems.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildItemButton(entry.key, entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildItemButton(String itemId, int quantity) {
    final itemInfo = _getItemInfo(itemId);

    return GestureDetector(
      onTap: isGameActive ? () => onUseItem(itemId) : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: itemInfo['color'] as Color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (itemInfo['color'] as Color).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icon
            Center(
              child: Icon(
                itemInfo['icon'] as IconData,
                color: itemInfo['color'] as Color,
                size: 28,
              ),
            ),
            
            // Quantity badge
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: itemInfo['color'] as Color,
                    width: 1,
                  ),
                ),
                child: Text(
                  'x$quantity',
                  style: GoogleFonts.courierPrime(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Cooldown overlay (if needed)
            if (!isGameActive)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getItemInfo(String itemId) {
    switch (itemId) {
      case 'modo_incognito':
        return {
          'icon': Icons.visibility_off,
          'color': const Color(0xFF9C27B0), // Purple
          'name': 'Modo Incógnito',
        };
      case 'firewall_digital':
        return {
          'icon': Icons.shield,
          'color': const Color(0xFF2196F3), // Blue
          'name': 'Firewall Digital',
        };
      case 'vpn_emocional':
        return {
          'icon': Icons.vpn_key,
          'color': const Color(0xFF4CAF50), // Green
          'name': 'VPN Emocional',
        };
      case 'alt_account':
        return {
          'icon': Icons.person_add,
          'color': const Color(0xFFFF9800), // Orange
          'name': 'Cuenta Alternativa',
        };
      default:
        return {
          'icon': Icons.help_outline,
          'color': Colors.grey,
          'name': 'Item Desconocido',
        };
    }
  }
}
