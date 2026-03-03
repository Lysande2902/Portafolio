# 💳 GUÍA DE INTEGRACIÓN MERCADO PAGO

## 1. CONFIGURACIÓN INICIAL

### 1.1 Crear cuenta en Mercado Pago
1. Ir a https://www.mercadopago.com.ar/developers
2. Crear cuenta / Ingresar
3. Ir a "Credenciales" o "API Keys"
4. Copiar:
   - **Access Token** (producción)
   - **Public Key**

### 1.2 Variables de entorno (.env)
```bash
# Mercado Pago
MERCADOPAGO_ACCESS_TOKEN=APP_USR_xxxxxxxxxxxxxx
MERCADOPAGO_PUBLIC_KEY=APP_USR_xxxxxxxxxxxxxx
MERCADOPAGO_CURRENCY=ARS

# Webhook
MERCADOPAGO_WEBHOOK_URL=https://tudominio.com/webhook/mercadopago
```

### 1.3 Instalación de SDK
```bash
npm install @react-native-mercadopago/sdk
npm install mercadopago
```

---

## 2. NIVELES Y PRECIOS

| Nivel | Precio | Duración | Beneficios |
|-------|--------|----------|-----------|
| **PRO** | $9.99 ARS | 30 días | - Perfil destacado en búsqueda<br>- 2x visibilidad |
| **TOP #1** | $29.99 ARS | 30 días | - Posición TOP en categoría<br>- 5x visibilidad<br>- Contacto visible sin conexión |
| **LEGEND** | $99.99 ARS | 30 días | - Posición TOP global<br>- 10x visibilidad<br>- Prioridad en eventos<br>- Badge especial |

---

## 3. BACKEND - CREAR PREFERENCIA DE PAGO

### 3.1 Endpoint: POST /ranking/upgrade

```javascript
const mercadopago = require('mercadopago');

// Configurar
mercadopago.configure({
  access_token: process.env.MERCADOPAGO_ACCESS_TOKEN,
});

/**
 * POST /ranking/upgrade
 * Crear preferencia de pago
 */
router.post('/ranking/upgrade', authenticateToken, async (req, res) => {
  try {
    const { nivel, duracion_dias = 30 } = req.body;
    const userId = req.user.id;

    // Validar nivel
    const precios = {
      pro: 999, // en centavos = $9.99
      top1: 2999, // $29.99
      legend: 9999, // $99.99
    };

    if (!precios[nivel]) {
      return res.status(400).json({ error: 'Nivel inválido' });
    }

    // Obtener usuario
    const { data: usuario } = await supabase
      .from('profiles')
      .select('nombre_artistico, email')
      .eq('id', userId)
      .single();

    // Crear transacción en BD
    const { data: transaccion, error: txError } = await supabase
      .from('pagos_ranking')
      .insert({
        profile_id: userId,
        nivel,
        monto: precios[nivel] / 100, // convertir a pesos
        duracion_dias,
        estado: 'pendiente',
        created_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (txError) throw txError;

    // Crear preferencia de pago
    const preference = {
      items: [
        {
          id: `ranking_${nivel}`,
          title: `Upgrade a ${nivel.toUpperCase()} - ${duracion_dias} días`,
          unit_price: precios[nivel] / 100,
          quantity: 1,
          currency_id: 'ARS',
          picture_url: 'https://tudominio.com/images/ranking_badge.png',
        },
      ],
      payer: {
        name: usuario.nombre_artistico,
        email: usuario.email,
        identification: {
          type: 'DNI',
          // number: usuario.dni // si lo tienes
        },
      },
      back_urls: {
        success: `https://tudominio.com/payment/success?id=${transaccion.id}`,
        failure: `https://tudominio.com/payment/failure?id=${transaccion.id}`,
        pending: `https://tudominio.com/payment/pending?id=${transaccion.id}`,
      },
      auto_return: 'approved',
      notification_url: `${process.env.MERCADOPAGO_WEBHOOK_URL}`,
      external_reference: transaccion.id, // ID de transacción en tu BD
      metadata: {
        profile_id: userId,
        nivel,
        duracion_dias,
      },
    };

    // Crear preferencia en Mercado Pago
    const mpPreference = await mercadopago.preferences.create(preference);

    // Guardar preference_id
    await supabase
      .from('pagos_ranking')
      .update({ preference_id: mpPreference.id })
      .eq('id', transaccion.id);

    res.json({
      success: true,
      transaccion: transaccion.id,
      preference_id: mpPreference.id,
      init_point: mpPreference.init_point, // URL del checkout
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
```

---

## 4. FRONTEND (FLUTTER)

### 4.1 Pantalla de opciones de upgrade

```dart
// lib/screens/ranking/upgrade_options_screen.dart

class UpgradeOptionsScreen extends StatefulWidget {
  @override
  State<UpgradeOptionsScreen> createState() => _UpgradeOptionsScreenState();
}

class _UpgradeOptionsScreenState extends State<UpgradeOptionsScreen> {
  late SupabaseClient _supabase;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
  }

  final options = [
    {
      'nivel': 'pro',
      'nombre': 'PRO',
      'precio': '\$9.99',
      'beneficios': [
        'Perfil destacado',
        '2x visibilidad',
        'Válido 30 días',
      ],
      'color': Colors.orange,
    },
    {
      'nivel': 'top1',
      'nombre': 'TOP #1',
      'precio': '\$29.99',
      'beneficios': [
        'Posición TOP',
        '5x visibilidad',
        'Contacto visible',
        'Válido 30 días',
      ],
      'color': Colors.amber,
    },
    {
      'nivel': 'legend',
      'nombre': 'LEGEND',
      'precio': '\$99.99',
      'beneficios': [
        'TOP global',
        '10x visibilidad',
        'Prioridad eventos',
        'Badge especial',
        'Válido 30 días',
      ],
      'color': Colors.amber[700],
    },
  ];

  Future<void> _startPayment(String nivel) async {
    try {
      // Llamar backend para crear preferencia
      final response = await http.post(
        Uri.parse('https://api.tudominio.com/ranking/upgrade'),
        headers: {
          'Authorization': 'Bearer ${_supabase.auth.currentUser!.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nivel': nivel,
          'duracion_dias': 30,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final initPoint = data['init_point']; // URL del checkout

      // Abrir en WebView o lanzar URL
      if (await canLaunchUrl(Uri.parse(initPoint))) {
        await launchUrl(initPoint, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Upgrade a TOP'),
        backgroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: options.map((option) {
          return Card(
            color: Colors.grey[850],
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option['nombre'],
                        style: TextStyle(
                          color: option['color'],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        option['precio'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Beneficios
                  ...List<String>.from(option['beneficios']).map((beneficio) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            beneficio,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Botón de compra
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startPayment(option['nivel']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: option['color'],
                      ),
                      child: const Text('Comprar ahora'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

---

## 5. WEBHOOK - Confirmar pago

### 5.1 Endpoint: POST /webhook/mercadopago

```javascript
/**
 * POST /webhook/mercadopago
 * Recibe notificaciones de Mercado Pago
 */
router.post('/webhook/mercadopago', async (req, res) => {
  try {
    const { id, type } = req.query;

    // Mercado Pago envía notificaciones para:
    // - payment (pago realizado)
    // - merchant_order (pedido completado)

    if (type === 'payment') {
      // Obtener detalles del pago
      const payment = await mercadopago.payment.findById(id);

      if (payment.body.status === 'approved') {
        const externalRef = payment.body.external_reference;
        const transaccionId = externalRef;

        // Obtener transacción en BD
        const { data: transaccion } = await supabase
          .from('pagos_ranking')
          .select('*')
          .eq('id', transaccionId)
          .single();

        if (!transaccion) {
          return res.status(404).json({ error: 'Transacción no encontrada' });
        }

        // ===== PROCESAMIENTO DE PAGO APROBADO =====
        // Usar transacción para evitar duplicados

        // 1. Actualizar estado de pago
        await supabase
          .from('pagos_ranking')
          .update({
            estado: 'completado',
            transaccion_id_mp: payment.body.id,
            fecha_completacion: new Date().toISOString(),
          })
          .eq('id', transaccion.id);

        // 2. Crear/actualizar ranking_top
        const fechaInicio = new Date();
        const fechaExpiracion = new Date();
        fechaExpiracion.setDate(fechaExpiracion.getDate() + transaccion.duracion_dias);

        await supabase
          .from('ranking_top')
          .upsert(
            {
              profile_id: transaccion.profile_id,
              nivel: transaccion.nivel,
              fecha_inicio: fechaInicio.toISOString(),
              fecha_expiracion: fechaExpiracion.toISOString(),
              renovaciones_count: 1,
            },
            { onConflict: 'profile_id' }
          );

        // 3. Actualizar perfil
        await supabase
          .from('profiles')
          .update({
            ranking_tipo: transaccion.nivel,
            ranking_fecha_expiracion: fechaExpiracion.toISOString(),
          })
          .eq('id', transaccion.profile_id);

        // 4. Crear beneficio_top para tracking
        await supabase
          .from('beneficios_top')
          .insert({
            ranking_top_id: (await supabase
              .from('ranking_top')
              .select('id')
              .eq('profile_id', transaccion.profile_id)
              .single()).data.id,
            tipo_beneficio: 'visibilidad',
            valor: transaccion.nivel === 'legend' ? 10 : transaccion.nivel === 'top1' ? 5 : 2,
            fecha: new Date().toISOString(),
          });

        // 5. Enviar notificación al usuario
        await supabase
          .from('notificaciones')
          .insert({
            profile_id: transaccion.profile_id,
            tipo: 'ranking_upgrade',
            titulo: `¡Felicidades! Eres ${transaccion.nivel.toUpperCase()}`,
            descripcion: `Tu perfil está destacado por ${transaccion.duracion_dias} días`,
            leido: false,
            created_at: new Date().toISOString(),
          });

        // 6. Log para debugging
        console.log(`✅ Pago aprobado: ${transaccion.id} - ${transaccion.profile_id} -> ${transaccion.nivel}`);
      }

      if (payment.body.status === 'rejected') {
        // Actualizar estado a rechazado
        await supabase
          .from('pagos_ranking')
          .update({ estado: 'rechazado' })
          .eq('transaccion_id_mp', payment.body.id);

        console.log(`❌ Pago rechazado: ${payment.body.id}`);
      }

      if (payment.body.status === 'pending') {
        // Pendiente de confirmar
        await supabase
          .from('pagos_ranking')
          .update({ estado: 'pendiente_confirmacion' })
          .eq('transaccion_id_mp', payment.body.id);

        console.log(`⏳ Pago pendiente: ${payment.body.id}`);
      }
    }

    // Mercado Pago espera respuesta 200 OK
    res.sendStatus(200);
  } catch (err) {
    console.error('Webhook error:', err);
    res.status(500).json({ error: err.message });
  }
});
```

---

## 6. TESTING EN SANDBOX

### 6.1 Cambiar a ambiente de prueba

```javascript
// Usar Public Key de testing
mercadopago.configure({
  access_token: process.env.MERCADOPAGO_ACCESS_TOKEN_SANDBOX,
  // o usar integración manual:
  client_id: process.env.MERCADOPAGO_CLIENT_ID_SANDBOX,
  client_secret: process.env.MERCADOPAGO_CLIENT_SECRET_SANDBOX,
});
```

### 6.2 Tarjetas de prueba

| Marca | Número | Resultado |
|-------|--------|-----------|
| Visa | 4111 1111 1111 1111 | ✅ Aprobado |
| Visa | 4000 0000 0000 0002 | ❌ Rechazado |
| Mastercard | 5555 5555 5555 4444 | ✅ Aprobado |

**Fecha:** 12/25  
**CVV:** 123  
**Nombre:** Cualquiera

---

## 7. MONITOREO

### 7.1 Verificar pagos en BD

```sql
-- Últimas transacciones
SELECT 
  pr.id,
  pr.profile_id,
  pr.nivel,
  pr.monto,
  pr.estado,
  pr.created_at,
  pr.fecha_completacion,
  p.nombre_artistico
FROM pagos_ranking pr
JOIN profiles p ON pr.profile_id = p.id
ORDER BY pr.created_at DESC
LIMIT 20;

-- Ingresos totales
SELECT 
  DATE_TRUNC('day', fecha_completacion) as fecha,
  COUNT(*) as transacciones,
  SUM(monto) as ingresos,
  nivel
FROM pagos_ranking
WHERE estado = 'completado'
  AND fecha_completacion > NOW() - INTERVAL '30 days'
GROUP BY fecha, nivel
ORDER BY fecha DESC;

-- Usuarios TOP activos
SELECT 
  p.nombre_artistico,
  rt.nivel,
  rt.fecha_expiracion,
  COUNT(bt.id) as beneficios_utilizados
FROM ranking_top rt
JOIN profiles p ON rt.profile_id = p.id
LEFT JOIN beneficios_top bt ON rt.id = bt.ranking_top_id
WHERE rt.fecha_expiracion > NOW()
GROUP BY rt.id, p.nombre_artistico, rt.nivel
ORDER BY rt.fecha_expiracion DESC;
```

---

## 8. TROUBLESHOOTING

| Problema | Causa | Solución |
|----------|-------|----------|
| Pago no se procesa | Token inválido | Verificar ACCESS_TOKEN en .env |
| Webhook no llega | URL incorrecta | Validar MERCADOPAGO_WEBHOOK_URL |
| Duplicadas transacciones | Sin idempotencia | Usar external_reference como clave única |
| Error 402 | Fondos insuficientes | Usar tarjeta de prueba |
| Webhook devuelve 404 | Transacción no existe | Revisar external_reference |

---

## 9. CHECKLIST DE IMPLEMENTACIÓN

- [ ] Crear cuenta Mercado Pago y obtener credenciales
- [ ] Añadir variables de entorno
- [ ] Implementar endpoint POST /ranking/upgrade
- [ ] Implementar endpoint POST /webhook/mercadopago
- [ ] Crear pantalla Flutter de opciones
- [ ] Integrar pago con WebView
- [ ] Testing con tarjetas sandbox
- [ ] Documentar flujo completo
- [ ] Setup de alertas para pagos fallidos
- [ ] Implementar retry logic para pagos rechazados

---

**Próximo:** Una vez aprobados los pagos, automáticamente se activa el ranking TOP con beneficios reales.
