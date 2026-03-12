import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:humano/models/coin_package.dart';
import 'package:humano/models/payment_result.dart';

class StripePaymentService {
  // Clave secreta de Stripe (solo para modo test - en producción debe estar en backend)
  static const String _secretKey =
      'YOUR_STRIPE_SECRET_KEY';

  /// Inicializa el servicio de Stripe
  static Future<void> initialize() async {
    // La inicialización ya se hace en main.dart
    debugPrint('✅ Stripe Payment Service initialized');
  }

  /// Compra un paquete de monedas usando Stripe
  Future<PaymentResult> purchaseCoins(CoinPackage package) async {
    try {
      debugPrint('🔄 Iniciando compra de ${package.totalCoins} monedas...');

      // 1. Crear Payment Intent
      final paymentIntent = await _createPaymentIntent(package);
      final clientSecret = paymentIntent['client_secret'];
      final paymentIntentId = paymentIntent['id'];

      debugPrint('✅ Payment Intent creado: $paymentIntentId');

      // 2. Inicializar Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Humano Game',
        ),
      );

      debugPrint('✅ Payment Sheet inicializado');

      // 3. Presentar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint('✅ Pago completado exitosamente');

      // 4. Retornar resultado exitoso
      return PaymentResult.success(paymentIntentId);
    } on StripeException catch (e) {
      debugPrint('❌ Stripe Error: ${e.error.code} - ${e.error.message}');

      // Manejar diferentes tipos de errores
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult.cancelled();
      }

      return PaymentResult.error(
        e.error.localizedMessage ?? 'Error en el pago',
      );
    } catch (e) {
      debugPrint('❌ Error inesperado: $e');
      return PaymentResult.error('Error inesperado: $e');
    }
  }

  /// Crea un Payment Intent en Stripe
  /// NOTA: En producción, esto debe hacerse en el backend (Cloud Functions)
  /// Solo funciona en modo test porque exponemos la secret key
  Future<Map<String, dynamic>> _createPaymentIntent(
    CoinPackage package,
  ) async {
    try {
      final amount = (package.priceUSD * 100).toInt(); // Convertir a centavos

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': 'usd',
          'metadata[packageId]': package.id,
          'metadata[coins]': package.totalCoins.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al crear Payment Intent: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error creando Payment Intent: $e');
      rethrow;
    }
  }
}
