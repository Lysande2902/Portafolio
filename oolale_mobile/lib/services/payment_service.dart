import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Procesa un pago simulado y registra la transacción
  Future<bool> processPayment({
    required String userId,
    required double amount,
    required String concept,
    String gateway = 'Simulado',
  }) async {
    try {
      debugPrint('[PAYMENT] Inicio processPayment userId=$userId amount=$amount concept=$concept gateway=$gateway');
      // 1. Simular delay de procesamiento bancario
      await Future.delayed(const Duration(seconds: 2));

      // 2. Registrar la transacción en tickets_pagos
      final paymentData = {
        'comprador_id': userId,
        'monto_total': amount,
        'estatus': 'completado',
        'pasarela': '$gateway - $concept',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('tickets_pagos').insert(paymentData);
      debugPrint('[PAYMENT] Insert en tickets_pagos OK');

      debugPrint('[PAYMENT] Verificación Premium pendiente de confirmación backend/webhook');

      return true;
    } catch (e) {
      debugPrint('[PAYMENT][ERROR] $e');
      return false;
    }
  }

  /// Inicia el flujo de pago con MercadoPago
  /// Retorna la URL de pago si es exitoso, o null si falla
  Future<String?> initiateMercadoPagoPayment({
    required String userId,
    required double amount,
    required String concept,
  }) async {
    try {
      debugPrint('[PAYMENT] Inicio initiateMercadoPagoPayment userId=$userId amount=$amount concept=$concept');
      // TODO: Llamar al backend real cuando esté disponible
      // final response = await ApiService().post('/ranking/upgrade', {
      //   'nivel': concept,
      //   'metodo_pago': 'mercadopago'
      // });
      // return response['url_pago'];

      // Por ahora, simulamos una URL de Sandbox o una URL de éxito directa para testing
      // En un flujo real, el backend crea la preferencia en MP y devuelve el init_point.
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulamos que el backend nos devolvió una URL válida
      // Usamos la home de MP como placeholder funcional para demostrar la apertura del navegador
      final url = 'https://www.mercadopago.com.mx'; 
      debugPrint('[PAYMENT] URL MP generada $url');
      return url;
    } catch (e) {
      debugPrint('[PAYMENT][ERROR] initiateMercadoPagoPayment $e');
      return null;
    }
  }

  /// Inicia el flujo de pago con PayPal (Simulado)
  Future<String?> initiatePayPalPayment({
    required String userId,
    required double amount,
    required String concept,
  }) async {
    try {
      debugPrint('[PAYMENT][PayPal] Iniciando pago userId=$userId amount=$amount');
      await Future.delayed(const Duration(seconds: 2));
      
      // URL ficticia de PayPal Sandbox
      final url = 'https://www.paypal.com/signin'; 
      debugPrint('[PAYMENT][PayPal] URL generada $url');
      return url;
    } catch (e) {
      debugPrint('[PAYMENT][PayPal][ERROR] $e');
      return null;
    }
  }

  /// Verifica el estado de un pago (Simulado)
  /// En producción, esto consultaría al backend que a su vez consulta a MP/PayPal
  Future<bool> checkPaymentStatus(String paymentId) async {
    debugPrint('[PAYMENT] Verificando estado de pago $paymentId...');
    await Future.delayed(const Duration(seconds: 2));
    // Simulamos éxito siempre para la demo
    return true;
  }

  /// Actualiza el estado del usuario a Premium en la base de datos
  Future<bool> upgradeUserToPremium(String userId, String plan) async {
    try {
      debugPrint('[PAYMENT] Actualizando usuario $userId a Premium ($plan)...');
      
      // 1. Registrar la transacción
      final paymentData = {
        'comprador_id': userId,
        'monto_total': plan == 'Anual' ? 990.0 : 99.0,
        'estatus': 'completado',
        'pasarela': 'Simulada',
        'concepto': 'Suscripción $plan',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('tickets_pagos').insert(paymentData);
      
      // 2. Actualizar perfil del usuario
      // Asumimos que hay una columna 'es_premium' o 'nivel_suscripcion'
      // Si no existe, este paso fallará en una DB real sin migración, pero es lo correcto.
      // Intentaremos actualizar 'verificado' como proxy de premium si no hay columna específica,
      // o simplemente 'nivel' si existe.
      
      // Intento seguro: Upsert o Update en perfiles
       await _supabase.from('perfiles').update({
        'es_premium': true, // Asumimos esta columna
        'nivel_suscripcion': plan.toLowerCase(),
        'fecha_suscripcion': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      debugPrint('[PAYMENT] Usuario actualizado correctamente');
      return true;
    } catch (e) {
      debugPrint('[PAYMENT][ERROR] Al actualizar premium: $e');
      // Si falla porque no existe la columna, no bloqueamos el flujo de UI simulado
      return false;
    }
  }

  /// Abre la URL de pago
  Future<bool> launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } else {
      debugPrint('[PAYMENT][ERROR] No se pudo abrir la URL: $url');
      return false;
    }
  }
}
