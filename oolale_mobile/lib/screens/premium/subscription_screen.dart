import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackgroundGradient(context),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeroSection(context),
                        _buildFeatures(context),
                        _buildPricingCards(context),
                        _buildFAQ(context),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildBackgroundGradient(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConstants.accentColor.withOpacity(0.1),
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: ThemeColors.icon(context)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.accentColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppConstants.accentColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  'PREMIUM',
                  style: GoogleFonts.outfit(
                    color: AppConstants.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppConstants.accentColor, AppConstants.accentColor.withOpacity(0.5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.accentColor.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.star_rounded, color: Colors.black, size: 60),
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            child: Text(
              'Lleva tu música\nal siguiente nivel',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Desbloquea herramientas profesionales\ny conecta con más oportunidades',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = [
      {'icon': Icons.verified_rounded, 'title': 'Badge Verificado', 'desc': 'Destaca con el check azul'},
      {'icon': Icons.visibility_rounded, 'title': 'Mayor Visibilidad', 'desc': 'Aparece primero en búsquedas'},
      {'icon': Icons.analytics_rounded, 'title': 'Analytics Avanzado', 'desc': 'Estadísticas de tu perfil'},
      {'icon': Icons.cloud_upload_rounded, 'title': 'Almacenamiento Ilimitado', 'desc': 'Sube todo tu portafolio'},
      {'icon': Icons.support_agent_rounded, 'title': 'Soporte Prioritario', 'desc': 'Atención VIP 24/7'},
      {'icon': Icons.campaign_rounded, 'title': 'Promoción de Eventos', 'desc': 'Destaca tus gigs'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BENEFICIOS PREMIUM',
            style: GoogleFonts.outfit(
              color: AppConstants.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          ...features.map((f) => FadeInLeft(
            child: _buildFeatureTile(
              context,
              f['icon'] as IconData,
              f['title'] as String,
              f['desc'] as String,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConstants.accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: ThemeColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: ThemeColors.secondaryText(context), fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppConstants.accentColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildPricingCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            'ELIGE TU PLAN',
            style: GoogleFonts.outfit(
              color: AppConstants.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          _buildPricingCard(
            'Mensual',
            '\$99',
            'MXN/mes',
            false,
            context,
          ),
          const SizedBox(height: 16),
          _buildPricingCard(
            'Anual',
            '\$990',
            'MXN/año',
            true,
            context,
            savings: 'Ahorra \$198',
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(String title, String price, String period, bool isPopular, BuildContext context, {String? savings}) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(
                colors: [AppConstants.accentColor.withOpacity(0.2), AppConstants.primaryColor.withOpacity(0.2)],
              )
            : null,
        color: isPopular ? null : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? AppConstants.accentColor : Theme.of(context).dividerColor.withOpacity(0.1),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.accentColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Center(
                child: Text(
                  'MÁS POPULAR',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.outfit(
                        color: AppConstants.accentColor,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        period,
                        style: TextStyle(color: ThemeColors.secondaryText(context), fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (savings != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      savings,
                      style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = isPopular ? 990.0 : 99.0;
                      _showPaymentDialog(context, title, amount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? AppConstants.accentColor : AppConstants.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'SUSCRIBIRSE',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildFAQ(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            'PREGUNTAS FRECUENTES',
            style: GoogleFonts.outfit(
              color: AppConstants.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          _buildFAQItem(context, '¿Puedo cancelar en cualquier momento?', 'Sí, sin compromisos ni penalizaciones.'),
          _buildFAQItem(context, '¿Qué métodos de pago aceptan?', 'MercadoPago, PayPal, tarjetas de crédito/débito.'),
          _buildFAQItem(context, '¿Hay prueba gratis?', 'Sí, 7 días gratis para nuevos usuarios.'),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(color: ThemeColors.secondaryText(context), fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String planName, double amount) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentModal(planName: planName, amount: amount),
    );
  }
}

class _PaymentModal extends StatefulWidget {
  final String planName;
  final double amount;
  
  const _PaymentModal({required this.planName, required this.amount});

  @override
  State<_PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<_PaymentModal> {
  bool _isLoading = false;
  bool _isWaitingForPayment = false; // Estado cuando el usuario está en el navegador
  String _currentProvider = '';

  Future<void> _processPayment(String provider) async {
    setState(() {
      _isLoading = true;
      _currentProvider = provider;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debes iniciar sesión para suscribirte')),
            );
         }
         return;
      }
      
      final paymentService = PaymentService();
      String? url;

      if (provider == 'MercadoPago') {
        url = await paymentService.initiateMercadoPagoPayment(
          userId: user.id,
          amount: widget.amount,
          concept: "Suscripción ${widget.planName}",
        );
      } else {
        url = await paymentService.initiatePayPalPayment(
          userId: user.id,
          amount: widget.amount,
          concept: "Suscripción ${widget.planName}",
        );
      }

      if (url != null) {
        // Lanzamos la URL
        await paymentService.launchPaymentUrl(url);
        
        // Cambiamos estado a "Esperando confirmación"
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isWaitingForPayment = true;
          });
        }
      } else {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al iniciar el pago')),
            );
            setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
         );
         setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);
    
    // Simulamos verificación con backend
    await Future.delayed(const Duration(seconds: 2));
    
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final paymentService = PaymentService();
      // Simulamos upgrade exitoso
      await paymentService.upgradeUserToPremium(user.id, widget.planName);
    }

    if (mounted) {
      Navigator.pop(context); // Cerrar modal
      // Mostrar éxito
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
          title: Text('¡Pago Exitoso!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Text(
            'Bienvenido a Premium. Tu suscripción ${widget.planName} está activa.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Comenzar', style: TextStyle(color: AppConstants.primaryColor)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si estamos esperando confirmación, mostramos UI diferente
    if (_isWaitingForPayment) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top_rounded, size: 50, color: AppConstants.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Pagando con $_currentProvider...',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor completa el pago en tu navegador. Al terminar, presiona "Confirmar Pago".',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _isLoading 
              ? const CircularProgressIndicator(color: AppConstants.primaryColor)
              : ElevatedButton(
                  onPressed: _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('CONFIRMAR PAGO'),
                ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isWaitingForPayment = false),
              child: const Text('Cancelar / Volver', style: TextStyle(color: Colors.grey)),
            ),
             const SizedBox(height: 24),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Resumen de Suscripción',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primaryText(context),
                ),
              ),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(context, 'Plan:', widget.planName),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Precio:', '\$${widget.amount} MXN'),
          const SizedBox(height: 32),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          else
            Column(
              children: [
                // Botón MercadoPago
                ElevatedButton(
                  onPressed: () => _processPayment('MercadoPago'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009EE3), // MercadoPago Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.account_balance_wallet, size: 20),
                       const SizedBox(width: 8),
                       Text(
                        'MERCADO PAGO',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Botón PayPal
                ElevatedButton(
                  onPressed: () => _processPayment('PayPal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003087), // PayPal Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.payment, size: 20),
                       const SizedBox(width: 8),
                       Text(
                        'PAYPAL',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: ThemeColors.secondaryText(context),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: ThemeColors.primaryText(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
