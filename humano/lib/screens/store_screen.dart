import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/store_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';
import '../core/theme/app_theme.dart';
import '../data/providers/store_data_provider.dart';
import '../data/models/store_item.dart';
import '../models/coin_package.dart';
import '../models/payment_transaction.dart';
import '../services/stripe_payment_service.dart';
import '../widgets/coin_display.dart';
import '../widgets/item_icon.dart';
import 'coins_purchase_screen.dart';
import 'battle_pass_screen.dart';
import 'archive_screen.dart';
import 'special_cinematic_screen.dart';
import 'lore_detail_screen.dart';


class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'battlepass';

  @override
  void initState() {
    super.initState();
    // Forzar modo vertical para la tienda
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
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryTabs(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          bottom: BorderSide(
            color: appTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: appTheme.secondaryColor, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          
          const SizedBox(width: 12),
          
          // Title estilo terminal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TIENDA_SISTEMA',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    color: appTheme.primaryColor.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'MERCADO DIGITAL',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Coins indicator (clickable) estilo terminal
          Consumer<StoreProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = 'coins';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(
                      color: appTheme.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group, color: appTheme.secondaryColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.coins}',
                        style: GoogleFonts.shareTechMono(
                          color: appTheme.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SEGS',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.grey[600],
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(
          bottom: BorderSide(
            color: appTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabItem('ACCESO TOTAL', 'battlepass', Icons.military_tech_outlined),
            const SizedBox(width: 8),
            _buildTabItem('HARDWARE', 'hardware', Icons.screenshot_monitor_outlined),
            const SizedBox(width: 8),
            _buildTabItem('PROTOCOLOS', 'protocols', Icons.security_outlined),
            const SizedBox(width: 8),
            _buildTabItem('MELODÍAS', 'music', Icons.music_note_outlined),
            const SizedBox(width: 8),
            _buildTabItem('NARRATIVA', 'narrative', Icons.library_books_outlined),
            const SizedBox(width: 8),
            _buildTabItem('COINS', 'coins', Icons.monetization_on_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? appTheme.primaryColor.withOpacity(0.2) 
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? appTheme.secondaryColor 
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? appTheme.accentColor : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.shareTechMono(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      color: const Color(0xFF030000), // Mismo fondo del lobby
      child: _buildCategoryContent(),
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategory) {
      case 'battlepass':
        return _buildBattlePassContent();
      case 'coins':
        return _buildCoinsContent();
      case 'hardware':
        return _buildHardwareContent();
      case 'protocols':
        return _buildProtocolsContent();
      case 'music':
        return _buildMusicContent();
      case 'narrative':
        return _buildNarrativeContent();
      default:
        return _buildBattlePassContent();
    }
  }

  Widget _buildNarrativeContent() {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    final narrativeItems = StoreDataProvider.narrativeContent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(color: appTheme.primaryColor.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.library_books_outlined, color: appTheme.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'ARCHIVOS CLASIFICADOS',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        color: appTheme.primaryColor.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'REGISTROS DEL SISTEMA',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accede a memorias, diarios y expedientes recuperados del servidor WitnessOS',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'ARCHIVOS_SECRETOS',
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: appTheme.primaryColor.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Todos los items de narrativa del StoreDataProvider
          ...narrativeItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNarrativeItem(item, appTheme),
          )),

          const SizedBox(height: 20),

          // Cinemáticas especiales
          Text(
            'CINEMÁTICAS_ESPECIALES',
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: appTheme.primaryColor.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          _buildPurchasableCinematic('CINEMÁTICA 01', 'El Despertar', 1000, 'cinematic_01'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 02', 'La Verdad Oculta', 1500, 'cinematic_02'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 03', 'Fragmentos del Pasado', 2000, 'cinematic_03'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 04', 'El Juicio Final', 2500, 'cinematic_04'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 05', 'Epílogo Secreto', 3000, 'cinematic_05'),
        ],
      ),
    );
  }

  Widget _buildNarrativeItem(StoreItem item, dynamic appTheme) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final isOwned = storeProvider.ownsItem(item.id);
        final preview = item.loreContent != null && item.loreContent!.length > 80
            ? '${item.loreContent!.substring(0, 80)}...'
            : item.loreContent ?? '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border.all(
              color: isOwned
                  ? appTheme.primaryColor.withOpacity(0.5)
                  : (item.isPremium
                      ? const Color(0xFFFFD700).withOpacity(0.4)
                      : Colors.red[900]!.withOpacity(0.3)),
              width: item.isPremium ? 1.5 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (item.isPremium)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: const Color(0xFFFFD700),
                    child: Text(
                      'ELITE',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 8,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y estado
                    Row(
                      children: [
                        Icon(
                          isOwned ? Icons.lock_open_outlined : Icons.lock_outline,
                          color: isOwned ? appTheme.accentColor : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.shareTechMono(
                              fontSize: 12,
                              color: isOwned ? Colors.white : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (isOwned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: appTheme.primaryColor.withOpacity(0.3),
                            child: Text(
                              'ADQUIRIDO',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 8,
                                color: appTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Descripción
                    Text(
                      item.description,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.grey[500],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Extracto del contenido (siempre visible como hook)
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.black.withOpacity(0.4),
                      child: Row(
                        children: [
                          Icon(Icons.text_snippet_outlined, color: appTheme.primaryColor.withOpacity(0.5), size: 12),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isOwned ? preview : '[DATOS CIFRADOS] — Adquiere el archivo para descifrar el contenido...',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 9,
                                color: isOwned ? Colors.grey[400] : Colors.grey[700],
                                fontStyle: isOwned ? FontStyle.normal : FontStyle.italic,
                                letterSpacing: 0.3,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botones de acción
                    Row(
                      children: [
                        // Precio
                        if (!isOwned)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.toll, color: appTheme.primaryColor, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.price} SEGS',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 11,
                                    color: appTheme.accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Spacer(),
                        
                        // Botón LEER (siempre visible si es owned o free)
                        if (isOwned || item.price == 0)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => LoreDetailScreen(item: item),
                                  transitionsBuilder: (_, anim, __, child) =>
                                      FadeTransition(opacity: anim, child: child),
                                ),
                              );
                            },
                            icon: Icon(Icons.menu_book_outlined, size: 14, color: appTheme.accentColor),
                            label: Text(
                              'LEER ARCHIVO',
                              style: GoogleFonts.shareTechMono(fontSize: 10, color: appTheme.accentColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: appTheme.accentColor.withOpacity(0.6)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                          ),

                        if (!isOwned) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _purchaseStoreItem(item),
                            icon: const Icon(Icons.lock_open_outlined, size: 14, color: Colors.white),
                            label: Text(
                              'DESCIFRAR',
                              style: GoogleFonts.shareTechMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildCoinsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: Colors.red[900]!.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'COMPRA_DE_SEGS',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        color: Colors.red[900]!.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'MONEDA VIRTUAL DEL SISTEMA',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adquiere SEGS para desbloquear contenido premium',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Paquetes de SEGS con sistema de pago integrado
          _buildCoinPackage('PAQUETE PEQUEÑO', CoinPackage.available[0]),
          const SizedBox(height: 12),
          _buildCoinPackage('PAQUETE MEDIANO', CoinPackage.available[1]),
          const SizedBox(height: 12),
          _buildCoinPackage('PAQUETE GRANDE', CoinPackage.available[2]),
          const SizedBox(height: 12),
          _buildCoinPackage('PAQUETE MEGA', CoinPackage.available[3], isRecommended: true),
          
          const SizedBox(height: 20),
          
          // Info adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los SEGS se pueden usar para comprar el Battle Pass y desbloquear contenido del Archivo',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
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

  Widget _buildCoinPackage(String name, CoinPackage package, {bool isRecommended = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border.all(
          color: isRecommended 
              ? Colors.red[700]! 
              : Colors.red[900]!.withOpacity(0.3),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: Colors.red[900]!.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(Icons.group, color: Colors.red[700], size: 32),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                    ),
                    child: Text(
                      'RECOMENDADO',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (isRecommended) const SizedBox(height: 4),
                Text(
                  name,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${package.totalCoins}',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 16,
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SEGS',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (package.bonusCoins != null && package.bonusCoins! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[900],
                        ),
                        child: Text(
                          '+${package.bonusCoins}',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Price button
          ElevatedButton(
            onPressed: () => _purchaseCoinsPackage(package),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              package.displayPrice,
              style: GoogleFonts.shareTechMono(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseCoinsPackage(CoinPackage package) async {
    // Obtener referencias ANTES de iniciar el pago
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debes iniciar sesión para comprar SEGS',
            style: GoogleFonts.shareTechMono(color: Colors.white),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
      return;
    }

    try {
      final stripeService = StripePaymentService();
      final result = await stripeService.purchaseCoins(package);

      if (!mounted) return;

      if (result.isSuccess) {
        // Añadir monedas al usuario
        await storeProvider.addCoins(package.totalCoins);
        
        // Guardar transacción en Firestore
        final transaction = PaymentTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          packageId: package.id,
          coinsAdded: package.totalCoins,
          amountUSD: package.priceUSD,
          paymentIntentId: result.paymentIntentId!,
          status: 'succeeded',
          timestamp: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('transactions')
            .add(transaction.toFirestore());
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${package.totalCoins} SEGS añadidos exitosamente',
              style: GoogleFonts.shareTechMono(color: Colors.white),
            ),
            backgroundColor: Colors.green[900],
          ),
        );
      } else if (result.errorMessage != 'Pago cancelado') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${result.errorMessage ?? "Error desconocido"}',
              style: GoogleFonts.shareTechMono(color: Colors.white),
            ),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } on SocketException {
      // Error de conexión a internet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sin conexión a internet. Verifica tu conexión e intenta de nuevo.',
                    style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange[900],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Verificar si es un error de conexión
      final errorMessage = e.toString().toLowerCase();
      final isConnectionError = errorMessage.contains('socket') ||
          errorMessage.contains('network') ||
          errorMessage.contains('host lookup') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('resolve host');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isConnectionError ? Icons.wifi_off : Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isConnectionError
                        ? 'Sin conexión a internet. Verifica tu conexión e intenta de nuevo.'
                        : 'Error inesperado. Intenta de nuevo más tarde.',
                    style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            backgroundColor: isConnectionError ? Colors.orange[900] : Colors.red[900],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildArchiveContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: Colors.red[900]!.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder_special, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'ARCHIVO',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        color: Colors.red[900]!.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'CONTENIDO DESBLOQUEABLE',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Desbloquea cinemáticas exclusivas con SEGS',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Cinemáticas especiales (desbloqueables con SEGS)
          Text(
            'CINEMÁTICAS_ESPECIALES',
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: Colors.red[900]!.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildPurchasableCinematic('CINEMÁTICA 01', 'El Despertar', 1000, 'cinematic_01'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 02', 'La Verdad Oculta', 1500, 'cinematic_02'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 03', 'Fragmentos del Pasado', 2000, 'cinematic_03'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 04', 'El Juicio Final', 2500, 'cinematic_04'),
          const SizedBox(height: 12),
          _buildPurchasableCinematic('CINEMÁTICA 05', 'Epílogo Secreto', 3000, 'cinematic_05'),
          
          const SizedBox(height: 20),
          
          // Info adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Las cinemáticas desbloqueadas se pueden ver en cualquier momento desde el Archivo de Evidencias',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botón para ver archivo completo
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArchiveScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, color: Colors.white, size: 16),
                  const SizedBox(width: 12),
                  Text(
                    'VER ARCHIVO COMPLETO',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasableCinematic(String id, String title, int price, String cinematicId) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final isUnlocked = storeProvider.ownsItem(cinematicId);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border.all(
              color: isUnlocked 
                  ? Colors.green[900]!.withOpacity(0.5)
                  : Colors.red[900]!.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.red[900]!.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isUnlocked ? Icons.play_circle_outline : Icons.lock_outline,
                  color: isUnlocked ? Colors.green[700] : Colors.grey[700],
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.red[900]!.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        color: isUnlocked ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.group, color: Colors.red[700], size: 12),
                        const SizedBox(width: 4),
                        Text(
                          isUnlocked ? 'DESBLOQUEADA' : '$price SEGS',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: isUnlocked ? Colors.green[700] : Colors.red[400],
                            letterSpacing: 0.5,
                            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action button
              if (isUnlocked)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecialCinematicScreen(
                          cinematicId: cinematicId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900]!.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: Colors.green[700]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.green[700], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'VER',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => _purchaseCinematic(cinematicId, title, price),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'COMPRAR',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _purchaseCinematic(String cinematicId, String title, int price) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    
    // Verificar si tiene suficientes SEGS
    if (storeProvider.coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No tienes suficientes SEGS. Necesitas $price SEGS.',
                  style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[900],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.red[900]!, width: 1),
        ),
        title: Text(
          'CONFIRMAR_COMPRA',
          style: GoogleFonts.shareTechMono(
            color: Colors.red[700],
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.shareTechMono(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.group, color: Colors.red[700], size: 16),
                const SizedBox(width: 8),
                Text(
                  '$price SEGS',
                  style: GoogleFonts.shareTechMono(
                    color: Colors.red[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Balance actual: ${storeProvider.coins} SEGS',
              style: GoogleFonts.shareTechMono(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.shareTechMono(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              'COMPRAR',
              style: GoogleFonts.shareTechMono(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Crear un item temporal para la cinemática (usando 'skin' para que sea único)
    final cinematicItem = StoreItem(
      id: cinematicId,
      name: title,
      description: 'Cinemática especial',
      price: price,
      type: StoreItemType.skin, // Usar 'skin' para que sea un item único (no consumible)
      iconPath: 'assets/cinematics/$cinematicId.png',
      isPremium: true,
    );
    
    // Comprar usando el sistema existente
    final success = await storeProvider.purchaseItem(cinematicItem);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✅ "$title" desbloqueada. Disponible en Archivo de Evidencias.',
                  style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[900],
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Refrescar la UI
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '❌ ${storeProvider.error ?? "Error al comprar"}',
                  style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[900],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildBattlePassContent() {
    return _buildBattlePassView();
  }

  Widget _buildBattlePassView() {
    // Obtener estado del Battle Pass del usuario
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final hasBattlePass = userDataProvider.userData?.inventory.hasBattlePass ?? false;
    // Variable kept for potential future use
    if (hasBattlePass) {
      debugPrint('User has Battle Pass');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner estilo terminal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(
                color: Colors.red[900]!.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.military_tech, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'ACCESO_TOTAL',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        color: Colors.red[900]!.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ACTIVO',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '"EL JUICIO DIGITAL"',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SISTEMA DE PROGRESIÓN PREMIUM',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Benefits panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BENEFICIOS_INCLUIDOS',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 11,
                    color: Colors.red[900]!.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBenefit(Icons.monetization_on_outlined, '6,600 SEGS en recompensas extra'),
                const SizedBox(height: 12),
                _buildBenefit(Icons.discount_outlined, '10% de descuento en todos los items'),
                const SizedBox(height: 12),
                _buildBenefit(Icons.trending_up, '15% boost de SEGS en cada arco'),
                const SizedBox(height: 12),
                _buildBenefit(Icons.military_tech_outlined, 'Badge exclusivo de "Testigo Premium"'),
                const SizedBox(height: 12),
                _buildBenefit(Icons.check_circle_outline, '20 Niveles de recompensas'),
                const SizedBox(height: 12),
                _buildBenefit(Icons.movie_outlined, 'Acceso prioritario a contenido nuevo'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Purchase buttons
          Row(
            children: [
              Expanded(
                child: _buildPurchaseButton(
                  '2,500 SEGS',
                  Icons.group,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BattlePassScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPurchaseButton(
                  '\$350 MXN',
                  Icons.attach_money,
                  () => _purchaseBattlePass(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[900],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.shareTechMono(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.red[700],
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.shareTechMono(
              fontSize: 11,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // Legacy icon getter removed - item types simplified

  Future<void> _purchaseItem(dynamic item, int finalPrice) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final hasBattlePass = userDataProvider.hasActiveBattlePass;
    final hasDiscount = hasBattlePass && finalPrice < item.price;
    
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Confirmar Compra',
          style: GoogleFonts.courierPrime(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: GoogleFonts.courierPrime(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: GoogleFonts.courierPrime(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Precio: ',
                  style: GoogleFonts.courierPrime(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                if (hasDiscount) ...[
                  Text(
                    '${item.price} ',
                    style: GoogleFonts.courierPrime(
                      color: Colors.grey[600],
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                CoinDisplay(
                  amount: finalPrice,
                  size: CoinDisplaySize.small,
                  textColor: const Color(0xFFE57373),
                  iconColor: const Color(0xFFCD5C5C),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Tu balance: ',
                  style: GoogleFonts.courierPrime(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                CoinDisplay(
                  amount: storeProvider.coins,
                  size: CoinDisplaySize.small,
                  textColor: const Color(0xFFE57373),
                  iconColor: const Color(0xFFCD5C5C),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.courierPrime(
                color: Colors.grey[400],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
            ),
            child: Text(
              'COMPRAR',
              style: GoogleFonts.courierPrime(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Realizar la compra con el precio final (con descuento si aplica)
    final success = await storeProvider.purchaseItem(item, finalPrice: finalPrice);

    if (!mounted) return;

    if (success) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${item.name} comprado exitosamente',
            style: GoogleFonts.courierPrime(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${storeProvider.error ?? "Error al comprar"}',
            style: GoogleFonts.courierPrime(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8B0000),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _purchaseBattlePass(bool withRealMoney) async {
    if (withRealMoney) {
      // Comprar con dinero real usando Stripe
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Debes iniciar sesión para comprar el Acceso Total',
              style: GoogleFonts.shareTechMono(color: Colors.white),
            ),
            backgroundColor: Colors.red[900],
          ),
        );
        return;
      }

      // Verificar si ya tiene el Battle Pass
      if (userDataProvider.hasActiveBattlePass) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ya tienes el Acceso Total activo',
              style: GoogleFonts.shareTechMono(color: Colors.white),
            ),
            backgroundColor: Colors.orange[900],
          ),
        );
        return;
      }

      try {
        // Crear un paquete especial para el Battle Pass
        final battlePassPackage = CoinPackage(
          id: 'battle_pass_direct',
          coins: 0, // No da monedas, da el Battle Pass directamente
          priceUSD: 350.0, // $350 MXN
          displayPrice: '\$350 MXN',
          isPopular: true,
        );

        final stripeService = StripePaymentService();
        final result = await stripeService.purchaseCoins(battlePassPackage);

        if (!mounted) return;

        if (result.isSuccess) {
          // Activar el Battle Pass
          final updatedInventory = userDataProvider.inventory.copyWith(
            hasBattlePass: true,
          );
          await userDataProvider.updateInventory(updatedInventory);
          
          // Guardar transacción en Firestore
          final transaction = PaymentTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: user.uid,
            packageId: 'battle_pass_direct',
            coinsAdded: 0,
            amountUSD: 350.0,
            paymentIntentId: result.paymentIntentId!,
            status: 'succeeded',
            timestamp: DateTime.now(),
          );

          await FirebaseFirestore.instance
              .collection('transactions')
              .add(transaction.toFirestore());
          
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Acceso Total activado exitosamente',
                style: GoogleFonts.shareTechMono(color: Colors.white),
              ),
              backgroundColor: Colors.green[900],
            ),
          );
        } else if (result.errorMessage != 'Pago cancelado') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ ${result.errorMessage ?? "Error desconocido"}',
                style: GoogleFonts.shareTechMono(color: Colors.white),
              ),
              backgroundColor: Colors.red[900],
            ),
          );
        }
      } on SocketException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sin conexión a internet. Verifica tu conexión e intenta de nuevo.',
                      style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange[900],
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        final errorMessage = e.toString().toLowerCase();
        final isConnectionError = errorMessage.contains('socket') ||
            errorMessage.contains('network') ||
            errorMessage.contains('host lookup') ||
            errorMessage.contains('connection') ||
            errorMessage.contains('resolve host');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    isConnectionError ? Icons.wifi_off : Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isConnectionError
                          ? 'Sin conexión a internet. Verifica tu conexión e intenta de nuevo.'
                          : 'Error inesperado. Intenta de nuevo más tarde.',
                      style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
              backgroundColor: isConnectionError ? Colors.orange[900] : Colors.red[900],
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
      return;
    }

    // Comprar con monedas (sin descuento en el Battle Pass mismo)
    final battlePass = StoreDataProvider.battlePass;
    await _purchaseItem(battlePass, battlePass.price);
  }

  Widget _buildHardwareContent() {
    return _buildItemsList(
      'HARDWARE_VISUAL',
      'MODULOS DE INTERFAZ',
      'Personaliza la estética del sistema WitnessOS',
      StoreDataProvider.visualThemes,
      Icons.screenshot_monitor_outlined,
    );
  }

  Widget _buildProtocolsContent() {
    return _buildItemsList(
      'PROTOCOLOS_DE_RED',
      'HERRAMIENTAS DE HACKEO',
      'Mejora tus capacidades durante las intrusiones',
      StoreDataProvider.protocols,
      Icons.security_outlined,
    );
  }

  Widget _buildMusicContent() {
    return _buildItemsList(
      'MELODÍAS_DEL_SISTEMA',
      'SOUNDTRACK PERSONALIZADO',
      'Selecciona el acompañamiento sonoro para tu experiencia',
      StoreDataProvider.backgroundMusic,
      Icons.music_note_outlined,
    );
  }


  Widget _buildItemsList(String id, String title, String subtitle, List<StoreItem> items, IconData headerIcon) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(id, title, subtitle, headerIcon),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGenericPurchasableItem(item),
          )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String id, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border.all(
          color: Colors.red[900]!.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red[700], size: 16),
              const SizedBox(width: 8),
              Text(
                id,
                style: GoogleFonts.shareTechMono(
                  fontSize: 12,
                  color: Colors.red[900]!.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.shareTechMono(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.shareTechMono(
              fontSize: 10,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericPurchasableItem(StoreItem item) {
    return Consumer2<StoreProvider, AppThemeProvider>(
      builder: (context, storeProvider, themeProvider, child) {
        final isUnlocked = storeProvider.ownsItem(item.id);
        final isTheme = item.type == StoreItemType.theme;
        final isMusic = item.type == StoreItemType.music;
        
        bool isEquipped = false;
        if (isTheme) {
          isEquipped = storeProvider.inventory.equippedTheme == item.id;
        } else if (isMusic) {
          isEquipped = storeProvider.inventory.equippedMusic == item.id;
        } else {
          isEquipped = storeProvider.inventory.equippedPlayerSkin == item.id;
        }
        
        // Preview theme colors for hardware items
        final previewTheme = isTheme ? WitnessTheme.fromId(item.id) : null;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEquipped 
                ? (previewTheme?.primaryColor ?? themeProvider.currentTheme.primaryColor).withOpacity(0.08)
                : Colors.black.withOpacity(0.6),
            border: Border.all(
              color: isEquipped
                  ? (previewTheme?.accentColor ?? themeProvider.currentTheme.accentColor).withOpacity(0.7)
                  : isUnlocked 
                      ? Colors.green[900]?.withOpacity(0.5) ?? Colors.green
                      : (item.isPremium 
                          ? const Color(0xFFFFD700).withOpacity(0.4) 
                          : Colors.red[900]?.withOpacity(0.3) ?? Colors.red.withOpacity(0.3)),
              width: isEquipped ? 2 : (item.isPremium ? 1.5 : 1),
            ),
            boxShadow: [
              if (isEquipped && previewTheme != null)
                BoxShadow(
                  color: previewTheme.accentColor.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              if (item.isPremium && !isUnlocked)
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (isEquipped)
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: previewTheme?.accentColor ?? themeProvider.currentTheme.accentColor,
                    child: Text(
                      'ACTIVO',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 7,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (item.isPremium && !isEquipped)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: const Color(0xFFFFD700),
                    child: Text(
                      'ELITE',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 8,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  // Icon or Theme Color Preview
                  if (isTheme && previewTheme != null)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: previewTheme.backgroundColor,
                        border: Border.all(
                          color: previewTheme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 10, height: 10, color: previewTheme.primaryColor),
                              const SizedBox(width: 2),
                              Container(width: 10, height: 10, color: previewTheme.secondaryColor),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 22,
                            height: 10,
                            color: previewTheme.accentColor,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        border: Border.all(
                          color: Colors.red[900]!.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isUnlocked 
                          ? (isTheme ? Icons.palette_outlined : (isMusic ? Icons.music_note_outlined : Icons.check_circle_outline)) 
                          : (isMusic ? Icons.music_off_outlined : Icons.lock_outline),
                        color: isUnlocked ? Colors.green[700] : Colors.grey[700],
                        size: 24,
                      ),
                    ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 12,
                            color: isUnlocked ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.group, color: Colors.red[700], size: 12),
                            const SizedBox(width: 4),
                            Text(
                              isUnlocked ? (isEquipped ? 'EQUIPADO' : 'ADQUIRIDO') : '${item.price} SEGS',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 10,
                                color: isUnlocked ? Colors.green[700] : Colors.red[400],
                                letterSpacing: 0.5,
                                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Action button
                  if (isUnlocked && (isTheme || isMusic))
                    ElevatedButton(
                      onPressed: isEquipped 
                          ? null 
                          : () {
                              if (isTheme) {
                                storeProvider.equipTheme(item.id);
                              } else if (isMusic) {
                                storeProvider.equipMusic(item.id);
                                // El AudioProvider reaccionará automáticamente al detectar el cambio en el inventario
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEquipped ? Colors.grey[900] : Colors.green[900],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        isEquipped ? 'EQUIPADO' : 'EQUIPAR',
                        style: GoogleFonts.shareTechMono(fontSize: 10, color: Colors.white),
                      ),
                    )
                  else if (!isUnlocked)
                    ElevatedButton(
                      onPressed: () => _purchaseStoreItem(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        'COMPRAR',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _purchaseStoreItem(StoreItem item) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    
    if (storeProvider.coins < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'FONDOS INSUFICIENTES: Necesitas ${item.price} SEGS.',
            style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          '¿AUTORIZAR COMPRA?',
          style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 14),
        ),
        content: Text(
          'Se descontarán ${item.price} SEGS para desbloquear ${item.name}.',
          style: GoogleFonts.shareTechMono(color: Colors.grey, fontSize: 11),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCELAR', style: GoogleFonts.shareTechMono(color: Colors.grey, fontSize: 10)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('CONFIRMAR', style: GoogleFonts.shareTechMono(color: Colors.red, fontSize: 10)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await storeProvider.purchaseItem(item);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${item.name} DESBLOQUEADO'),
            backgroundColor: Colors.green[900],
          ),
        );
      }
    }
  }
}


