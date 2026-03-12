import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/store_provider.dart';
import '../providers/auth_provider.dart';
import '../models/coin_package.dart';
import '../models/payment_transaction.dart';
import '../services/stripe_payment_service.dart';

class CoinsPurchaseScreen extends StatefulWidget {
  const CoinsPurchaseScreen({super.key});

  @override
  State<CoinsPurchaseScreen> createState() => _CoinsPurchaseScreenState();
}

class _CoinsPurchaseScreenState extends State<CoinsPurchaseScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Forzar modo vertical para la pantalla de compra
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Mantener modo vertical al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Horizontal layout: single row with scroll
    final cardHeight = screenHeight * 0.6; // 60% de la altura
    final cardWidth = screenWidth * 0.28; // ~28% del ancho para que quepan 3.5 visibles
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Horizontal scrollable packages
            Center(
              child: SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: CoinPackage.available.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 12),
                      child: _buildCoinPackage(CoinPackage.available[index]),
                    );
                  },
                ),
              ),
            ),
            // TEST MODE indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Text(
                  'TEST MODE',
                  style: GoogleFonts.courierPrime(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Help button for test cards
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                onPressed: () => _showTestCardsHelp(),
                icon: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            // Loading overlay
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFFCD5C5C),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Procesando pago...',
                        style: GoogleFonts.courierPrime(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Back button
            Positioned(
              left: 8,
              top: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPackage(CoinPackage package) {
    final wineRed = const Color(0xFF8B0000);
    final darkGray = const Color(0xFF1A1A1A);
    final mediumGray = const Color(0xFF252525);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: package.isPopular
              ? [
                  wineRed.withOpacity(0.15),
                  wineRed.withOpacity(0.08),
                  Colors.black.withOpacity(0.95),
                ]
              : [
                  mediumGray,
                  darkGray,
                  Colors.black,
                ],
        ),
        border: Border.all(
          color: package.isPopular ? wineRed.withOpacity(0.6) : Colors.grey[800]!,
          width: package.isPopular ? 1.5 : 1,
        ),
        boxShadow: package.isPopular
            ? [
                BoxShadow(
                  color: wineRed.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Stack(
        children: [
          // Popular badge
          if (package.isPopular)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF8B0000),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '★ POPULAR',
                  style: GoogleFonts.courierPrime(
                    fontSize: 7,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Bonus badge
          if (package.bonusCoins != null && package.bonusCoins! > 0)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AA00).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF00AA00),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '+${package.bonusCoins}',
                  style: GoogleFonts.courierPrime(
                    fontSize: 7,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group,
                  color: const Color(0xFFCD5C5C),
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  '${package.totalCoins} SEGS',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: const Color(0xFFE57373),
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                if (package.bonusCoins != null && package.bonusCoins! > 0)
                  Text(
                    '(${package.coins} + ${package.bonusCoins})',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 7,
                      color: Colors.grey[500],
                      height: 1.0,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 26,
                  decoration: BoxDecoration(
                    color: package.isPopular 
                        ? const Color(0xFF8B0000).withOpacity(0.7)
                        : Colors.grey[850],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: package.isPopular 
                          ? const Color(0xFF8B0000)
                          : Colors.grey[700]!,
                      width: 1,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _purchaseCoins(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      package.displayPrice,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseCoins(CoinPackage package) async {
    // Obtener referencias ANTES de iniciar el pago
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      _showErrorDialog('Debes iniciar sesión para comprar seguidores');
      return;
    }

    print('🔐 [STRIPE] Usuario autenticado: ${user.uid}');

    setState(() {
      _isProcessing = true;
    });

    try {
      final stripeService = StripePaymentService();
      final result = await stripeService.purchaseCoins(package);

      if (!mounted) return;

      if (result.isSuccess) {
        await _addCoinsToUser(package, result.paymentIntentId!, user.uid, storeProvider);
        _showSuccessDialog(package.totalCoins);
      } else if (result.errorMessage != 'Pago cancelado') {
        _showErrorDialog(result.errorMessage ?? 'Error desconocido');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _addCoinsToUser(
    CoinPackage package, 
    String paymentIntentId,
    String userId,
    StoreProvider storeProvider,
  ) async {
    print('💳 [STRIPE] Procesando compra de ${package.totalCoins} monedas...');
    print('💰 [STRIPE] Usuario: $userId');
    print('💵 [STRIPE] Paquete: ${package.id} (\$${package.priceUSD})');
    print('🪙 [STRIPE] Monedas a añadir: ${package.totalCoins}');

    try {
      // Añadir monedas al usuario
      await storeProvider.addCoins(package.totalCoins);
      print('✅ [STRIPE] Monedas añadidas exitosamente');

      // Guardar transacción en Firestore
      final transaction = PaymentTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        packageId: package.id,
        coinsAdded: package.totalCoins,
        amountUSD: package.priceUSD,
        paymentIntentId: paymentIntentId,
        status: 'succeeded',
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transaction.toFirestore());
      
      print('✅ [STRIPE] Transacción guardada en Firestore');
      print('═══════════════════════════════════════');
      print('✅ [STRIPE] Compra completada exitosamente');
      print('═══════════════════════════════════════');
    } catch (e) {
      print('❌ [STRIPE] Error al procesar compra: $e');
      rethrow;
    }
  }

  void _showSuccessDialog(int coins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF00AA00), width: 2),
        ),
        title: Text(
          '¡Compra Exitosa!',
          style: GoogleFonts.courierPrime(
            color: const Color(0xFF00AA00),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Has ganado $coins SEGUIDORES',
          style: GoogleFonts.courierPrime(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.courierPrime(
                color: const Color(0xFF00AA00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFFF0000), width: 2),
        ),
        title: Text(
          'Error en el Pago',
          style: GoogleFonts.courierPrime(
            color: const Color(0xFFFF0000),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.courierPrime(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.courierPrime(
                color: const Color(0xFFFF0000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestCardsHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFCD5C5C), width: 2),
        ),
        title: Text(
          'TARJETAS DE PRUEBA',
          style: GoogleFonts.courierPrime(
            color: const Color(0xFFCD5C5C),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Usa estas tarjetas para probar:',
                style: GoogleFonts.courierPrime(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _buildTestCardInfo(
                '4242 4242 4242 4242',
                'Visa - Siempre exitosa',
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildTestCardInfo(
                '4000 0025 0000 3155',
                'Requiere 3D Secure',
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildTestCardInfo(
                '4000 0000 0000 9995',
                'Siempre falla',
                Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                'Fecha: Cualquier fecha futura\nCVC: Cualquier 3 dígitos',
                style: GoogleFonts.courierPrime(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CERRAR',
              style: GoogleFonts.courierPrime(
                color: const Color(0xFFCD5C5C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCardInfo(String number, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.courierPrime(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: GoogleFonts.courierPrime(
              color: Colors.grey[400],
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
