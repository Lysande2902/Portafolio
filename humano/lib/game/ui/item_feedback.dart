import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que muestra feedback animado cuando se usa un item
class ItemFeedback extends StatefulWidget {
  final String itemId;
  final VoidCallback onComplete;

  const ItemFeedback({
    super.key,
    required this.itemId,
    required this.onComplete,
  });

  @override
  State<ItemFeedback> createState() => _ItemFeedbackState();
}

class _ItemFeedbackState extends State<ItemFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemInfo = _getItemInfo(widget.itemId);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (itemInfo['color'] as Color).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (itemInfo['color'] as Color).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    itemInfo['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemInfo['name'] as String,
                        style: GoogleFonts.courierPrime(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        itemInfo['description'] as String,
                        style: GoogleFonts.courierPrime(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getItemInfo(String itemId) {
    switch (itemId) {
      case 'modo_incognito':
        return {
          'name': 'MODO INCÓGNITO ACTIVADO',
          'icon': Icons.visibility_off,
          'color': const Color(0xFF9C27B0), // Purple
          'description': 'Invisible por 30 segundos',
        };
      case 'firewall_digital':
        return {
          'name': 'FIREWALL ACTIVADO',
          'icon': Icons.shield,
          'color': const Color(0xFF2196F3), // Blue
          'description': 'Protegido por 60 segundos',
        };
      case 'vpn_emocional':
        return {
          'name': 'VPN ACTIVADO',
          'icon': Icons.vpn_key,
          'color': const Color(0xFF4CAF50), // Green
          'description': 'Invisible por 120 segundos',
        };
      case 'alt_account':
        return {
          'name': 'CUENTA ALTERNATIVA',
          'icon': Icons.person_add,
          'color': const Color(0xFFFF9800), // Orange
          'description': 'Enemigos ralentizados 45s',
        };
      default:
        return {
          'name': 'ITEM ACTIVADO',
          'icon': Icons.check_circle,
          'color': Colors.grey,
          'description': 'Efecto aplicado',
        };
    }
  }
}
