# Design Document - Integración de Stripe en Modo Prueba

## Overview

Este diseño implementa la integración completa de Stripe en modo prueba para permitir compras de monedas virtuales. Utiliza el paquete `flutter_stripe` para la UI nativa de pago, Firebase Cloud Functions para el backend seguro, y las APIs de Stripe en modo test para procesar pagos sin cargos reales.

## Architecture

### High-Level Architecture

```
Flutter App (Client)
    ↓
    ├─→ flutter_stripe (Payment Sheet UI)
    ├─→ Firebase Cloud Functions (Backend)
    │       ↓
    │   Stripe API (Test Mode)
    │       ↓
    │   Payment Intent Created
    └─→ Firebase Firestore (Transaction Storage)
```

### Component Structure

```
StoreScreen
├── Coin Packages Section
│   ├── Package Cards (100, 500, 1000 coins)
│   └── Buy Button
├── Payment Flow
│   ├── StripePaymentService
│   │   ├── Initialize Payment
│   │   ├── Present Payment Sheet
│   │   └── Confirm Payment
│   └── Firebase Cloud Function
│       └── Create Payment Intent
└── Transaction History
    └── Firebase Firestore Storage
```

### Data Flow

```
1. User taps "Buy Coins"
2. App calls Cloud Function with package info
3. Cloud Function creates Stripe Payment Intent
4. Cloud Function returns client_secret
5. App initializes Payment Sheet with client_secret
6. User enters test card (4242 4242 4242 4242)
7. Stripe validates and processes payment
8. App receives payment confirmation
9. App updates coins in Firebase Firestore
10. App shows success message
```

## Components and Interfaces

### 1. Coin Package Model

```dart
class CoinPackage {
  final String id;
  final int coins;
  final double priceUSD;
  final String displayPrice;
  final bool isPopular;
  final int? bonusCoins;

  const CoinPackage({
    required this.id,
    required this.coins,
    required this.priceUSD,
    required this.displayPrice,
    this.isPopular = false,
    this.bonusCoins,
  });

  int get totalCoins => coins + (bonusCoins ?? 0);
}
```

### 2. Stripe Payment Service

```dart
class StripePaymentService {
  static const String publishableKey = 'pk_test_...'; // Test key
  
  Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
    Stripe.merchantIdentifier = 'merchant.com.humano';
  }

  Future<PaymentResult> purchaseCoins(CoinPackage package) async {
    try {
      // 1. Create Payment Intent via Cloud Function
      final paymentIntent = await _createPaymentIntent(package);
      
      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Humano Game',
          style: ThemeMode.dark,
          testEnv: true, // Enable test mode
        ),
      );
      
      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      
      // 4. Payment successful
      return PaymentResult.success(paymentIntent['id']);
      
    } on StripeException catch (e) {
      return PaymentResult.error(e.error.localizedMessage ?? 'Payment failed');
    } catch (e) {
      return PaymentResult.error('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(CoinPackage package) async {
    final callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
    final result = await callable.call({
      'amount': (package.priceUSD * 100).toInt(), // Convert to cents
      'currency': 'usd',
      'packageId': package.id,
      'coins': package.totalCoins,
    });
    return result.data;
  }
}
```

### 3. Payment Result Model

```dart
class PaymentResult {
  final bool isSuccess;
  final String? paymentIntentId;
  final String? errorMessage;

  PaymentResult.success(this.paymentIntentId)
      : isSuccess = true,
        errorMessage = null;

  PaymentResult.error(this.errorMessage)
      : isSuccess = false,
        paymentIntentId = null;

  PaymentResult.cancelled()
      : isSuccess = false,
        paymentIntentId = null,
        errorMessage = 'Payment cancelled';
}
```

### 4. Transaction Model

```dart
class PaymentTransaction {
  final String id;
  final String userId;
  final String packageId;
  final int coinsAdded;
  final double amountUSD;
  final String paymentIntentId;
  final String status; // 'succeeded', 'failed', 'canceled'
  final DateTime timestamp;

  const PaymentTransaction({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.coinsAdded,
    required this.amountUSD,
    required this.paymentIntentId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'packageId': packageId,
      'coinsAdded': coinsAdded,
      'amountUSD': amountUSD,
      'paymentIntentId': paymentIntentId,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
```

## Data Models

### Coin Packages (Static Data)

```dart
class CoinPackages {
  static const List<CoinPackage> available = [
    CoinPackage(
      id: 'coins_100',
      coins: 100,
      priceUSD: 0.99,
      displayPrice: '\$0.99',
    ),
    CoinPackage(
      id: 'coins_500',
      coins: 500,
      priceUSD: 4.99,
      displayPrice: '\$4.99',
      isPopular: true,
      bonusCoins: 50, // 10% bonus
    ),
    CoinPackage(
      id: 'coins_1000',
      coins: 1000,
      priceUSD: 9.99,
      displayPrice: '\$9.99',
      bonusCoins: 150, // 15% bonus
    ),
    CoinPackage(
      id: 'coins_2500',
      coins: 2500,
      priceUSD: 19.99,
      displayPrice: '\$19.99',
      bonusCoins: 500, // 20% bonus
    ),
  ];
}
```

### Firebase Firestore Structure

```
users/{userId}/
  └── inventory/
      └── coins: 5000

transactions/{transactionId}/
  ├── userId: "user123"
  ├── packageId: "coins_500"
  ├── coinsAdded: 550
  ├── amountUSD: 4.99
  ├── paymentIntentId: "pi_test_..."
  ├── status: "succeeded"
  └── timestamp: Timestamp
```

## Firebase Cloud Function

### createPaymentIntent Function

```javascript
const functions = require('firebase-functions');
const stripe = require('stripe')(functions.config().stripe.secret_key);

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { amount, currency, packageId, coins } = data;

  // Validate input
  if (!amount || !currency || !packageId || !coins) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required parameters'
    );
  }

  try {
    // Create Payment Intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount, // Amount in cents
      currency: currency,
      metadata: {
        userId: context.auth.uid,
        packageId: packageId,
        coins: coins.toString(),
      },
    });

    return {
      id: paymentIntent.id,
      client_secret: paymentIntent.client_secret,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
```

## UI/UX Design

### Coin Packages Section in Store

```
┌─────────────────────────────────────┐
│ COMPRAR MONEDAS                     │
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│ │  100💰  │ │  500💰  │ │ 1000💰  ││
│ │         │ │ +50 BONUS│ │+150 BONUS│
│ │  $0.99  │ │  $4.99  │ │  $9.99  ││
│ │ [COMPRAR]│ │[COMPRAR]│ │[COMPRAR]││
│ └─────────┘ └─────────┘ └─────────┘│
│                                     │
│ [?] Tarjetas de Prueba             │
│ TEST MODE                           │
└─────────────────────────────────────┘
```

### Test Cards Help Dialog

```
┌─────────────────────────────────────┐
│ TARJETAS DE PRUEBA                  │
├─────────────────────────────────────┤
│ Usa estas tarjetas para probar:    │
│                                     │
│ ✓ 4242 4242 4242 4242              │
│   (Visa - Siempre exitosa)         │
│                                     │
│ ✓ 4000 0025 0000 3155              │
│   (Requiere 3D Secure)             │
│                                     │
│ ✓ 4000 0000 0000 9995              │
│   (Siempre falla)                  │
│                                     │
│ Fecha: Cualquier fecha futura      │
│ CVC: Cualquier 3 dígitos           │
│                                     │
│ [CERRAR]                            │
└─────────────────────────────────────┘
```

### Payment Flow States

1. **Initial State**: Show coin packages
2. **Loading**: "Iniciando pago..."
3. **Payment Sheet**: Stripe native UI
4. **Processing**: "Procesando pago..."
5. **Success**: "¡Monedas agregadas! +500💰"
6. **Error**: "Error en el pago. Intenta de nuevo."

## Error Handling

### Stripe Exception Types

```dart
void _handleStripeError(StripeException error) {
  String message;
  
  switch (error.error.code) {
    case FailureCode.Canceled:
      message = 'Pago cancelado';
      break;
    case FailureCode.Failed:
      message = 'El pago falló. Verifica tu tarjeta.';
      break;
    case FailureCode.Timeout:
      message = 'Tiempo de espera agotado. Intenta de nuevo.';
      break;
    default:
      message = 'Error: ${error.error.localizedMessage}';
  }
  
  _showErrorDialog(message);
}
```

### Network Error Handling

```dart
try {
  final result = await stripeService.purchaseCoins(package);
  if (result.isSuccess) {
    await _addCoinsToUser(package.totalCoins, result.paymentIntentId!);
  }
} on FirebaseFunctionsException catch (e) {
  _showErrorDialog('Error del servidor: ${e.message}');
} on SocketException {
  _showErrorDialog('Sin conexión a internet');
} catch (e) {
  _showErrorDialog('Error inesperado: $e');
}
```

## Testing Strategy

### Unit Tests

1. **CoinPackage Model Tests**
   - Test totalCoins calculation with bonus
   - Test package data integrity

2. **PaymentResult Tests**
   - Test success result creation
   - Test error result creation
   - Test cancelled result creation

3. **Transaction Model Tests**
   - Test Firestore serialization
   - Test data validation

### Integration Tests

1. **Payment Flow Test**
   - Mock Stripe service
   - Test successful payment flow
   - Test payment cancellation
   - Test payment failure

2. **Firebase Integration Test**
   - Test Cloud Function call
   - Test Firestore transaction storage
   - Test coin balance update

### Manual Testing with Stripe Test Cards

1. **Successful Payment**: 4242 4242 4242 4242
2. **Declined Payment**: 4000 0000 0000 0002
3. **Insufficient Funds**: 4000 0000 0000 9995
4. **3D Secure Required**: 4000 0025 0000 3155

## Security Considerations

1. **API Keys**
   - Publishable key in Flutter app (safe for client)
   - Secret key only in Cloud Functions
   - Never commit keys to version control

2. **Authentication**
   - Verify user authentication in Cloud Function
   - Include user ID in Payment Intent metadata

3. **Validation**
   - Validate package IDs server-side
   - Verify payment amounts match packages
   - Check payment status before adding coins

4. **Test Mode Indicators**
   - Clear "TEST MODE" badge in UI
   - Log all test transactions
   - Prevent confusion with production

## Implementation Notes

### Dependencies

```yaml
dependencies:
  flutter_stripe: ^10.0.0
  cloud_functions: ^4.5.0
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
```

### Environment Setup

1. Create Stripe account (test mode)
2. Get test API keys from Stripe Dashboard
3. Configure Firebase Cloud Functions
4. Set Stripe secret key in Firebase config:
   ```bash
   firebase functions:config:set stripe.secret_key="sk_test_..."
   ```

### Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_...';
  
  runApp(MyApp());
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Payment Intent Creation Consistency
*For any* valid coin package, when creating a payment intent, the amount in the payment intent should equal the package price in cents
**Validates: Requirements 2.1, 9.3**

### Property 2: Coin Addition Accuracy
*For any* successful payment, the coins added to the user's balance should exactly match the totalCoins value of the purchased package
**Validates: Requirements 4.1, 4.2**

### Property 3: Transaction Record Completeness
*For any* payment attempt (success or failure), a transaction record should be created in Firestore with all required fields (userId, packageId, paymentIntentId, status, timestamp)
**Validates: Requirements 7.2, 7.4, 7.5**

### Property 4: Test Mode Isolation
*For any* payment processed in test mode, no real charges should be created and all transactions should use test API keys
**Validates: Requirements 3.1, 3.2, 3.4**

### Property 5: Error Handling Stability
*For any* Stripe exception or network error, the app should remain stable, display a user-friendly message, and allow retry without crashing
**Validates: Requirements 6.1, 6.2, 6.3, 6.5**

### Property 6: Payment Cancellation Safety
*For any* payment that is cancelled by the user, no coins should be added to the balance and the app should return to the store screen without errors
**Validates: Requirements 6.3, 4.1**

### Property 7: Authentication Requirement
*For any* payment intent creation request, the Cloud Function should reject requests from unauthenticated users
**Validates: Requirements 9.3, 2.4**

### Property 8: Balance Update Atomicity
*For any* successful payment, the coin balance update in Firestore should complete fully or not at all (no partial updates)
**Validates: Requirements 4.2**

## Phase Implementation Plan

### Phase 1: Setup & Configuration
- Add flutter_stripe dependency
- Configure Stripe test keys
- Create Firebase Cloud Function
- Deploy and test Cloud Function

### Phase 2: Core Payment Service
- Implement StripePaymentService
- Create payment models
- Add error handling
- Test with mock data

### Phase 3: UI Integration
- Add coin packages section to StoreScreen
- Create package cards with game aesthetic
- Add test mode indicator
- Implement help dialog for test cards

### Phase 4: Payment Flow
- Integrate Payment Sheet
- Handle payment results
- Update coin balance
- Save transactions to Firestore

### Phase 5: Testing & Polish
- Test with all Stripe test cards
- Add loading states and animations
- Implement success/error messages
- Verify transaction logging
