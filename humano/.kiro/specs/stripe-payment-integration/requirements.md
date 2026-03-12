# Requirements Document - Integración de Stripe en Modo Prueba

## Introduction

La integración de Stripe en modo prueba permite a los jugadores experimentar el flujo completo de compra de monedas virtuales usando las APIs reales de Stripe pero sin procesar pagos reales. Utiliza las claves de prueba de Stripe y tarjetas de test oficiales para validar el flujo completo de pago.

## Glossary

- **Stripe**: Plataforma de procesamiento de pagos
- **Test Mode**: Modo de prueba de Stripe que usa claves de test y no procesa pagos reales
- **Payment Sheet**: UI nativa de Stripe para Flutter que captura información de pago
- **Payment Intent**: Objeto de Stripe que representa una intención de pago
- **Publishable Key**: Clave pública de Stripe para modo test
- **Secret Key**: Clave secreta de Stripe para modo test (usada en backend)
- **Coin Package**: Paquete de monedas virtuales disponible para compra
- **Test Card**: Tarjeta de prueba oficial de Stripe (ej: 4242 4242 4242 4242)
- **Player**: Usuario que realiza la compra de prueba
- **Cloud Function**: Función de Firebase que gestiona la comunicación con Stripe API

## Requirements

### Requirement 1

**User Story:** As a Player, I want to see available coin packages, so that I can choose how many coins to purchase

#### Acceptance Criteria

1. THE Store Screen SHALL display a section for purchasing coins with real money
2. THE Payment System SHALL show at least 3 coin packages with different quantities
3. WHEN displaying a package, THE Payment System SHALL show coin amount and price in USD
4. THE Payment System SHALL clearly indicate these are real money purchases
5. THE Payment System SHALL display packages in an organized grid or list

### Requirement 2

**User Story:** As a Player, I want to use Stripe's payment interface, so that I can complete the purchase securely

#### Acceptance Criteria

1. WHEN the Player selects a coin package, THE Payment System SHALL initialize Stripe Payment Sheet
2. THE Payment System SHALL use flutter_stripe package for native Stripe integration
3. THE Payment Sheet SHALL display Stripe's official UI for payment information
4. THE Payment System SHALL accept Stripe test cards (4242 4242 4242 4242)
5. THE Payment System SHALL validate card information using Stripe's validation

### Requirement 3

**User Story:** As a Developer, I want to use Stripe test mode, so that no real charges are processed

#### Acceptance Criteria

1. THE Payment System SHALL use Stripe test publishable key
2. THE Payment System SHALL configure flutter_stripe with test mode enabled
3. THE Payment System SHALL accept only Stripe test card numbers
4. THE Payment System SHALL display a "TEST MODE" indicator in the UI
5. THE Payment System SHALL log all test transactions for debugging

### Requirement 4

**User Story:** As a Player, I want to receive my coins immediately after payment, so that I can use them right away

#### Acceptance Criteria

1. WHEN Stripe confirms payment success, THE Payment System SHALL add coins to the Player's balance
2. THE Payment System SHALL update the coin balance in Firebase Firestore immediately
3. THE Payment System SHALL show a success message with the amount of coins received
4. THE Payment System SHALL refresh the store UI to reflect the new balance
5. THE Payment System SHALL save the transaction record in Firebase

### Requirement 5

**User Story:** As a Player, I want clear feedback during payment, so that I know what's happening

#### Acceptance Criteria

1. WHEN initiating payment, THE Payment System SHALL show a loading indicator
2. THE Payment System SHALL display the Stripe Payment Sheet with loading states
3. WHEN payment completes, THE Payment System SHALL show a success animation
4. THE Payment System SHALL use visual effects consistent with the game aesthetic
5. THE Payment System SHALL provide haptic feedback on successful purchase

### Requirement 6

**User Story:** As a Developer, I want to handle payment errors gracefully, so that the app doesn't crash

#### Acceptance Criteria

1. THE Payment System SHALL catch all StripeException types
2. WHEN network errors occur, THE Payment System SHALL show a user-friendly message
3. WHEN payment is cancelled by user, THE Payment System SHALL return to the store without errors
4. THE Payment System SHALL log Stripe errors with error codes for debugging
5. THE Payment System SHALL maintain app stability during payment failures

### Requirement 7

**User Story:** As a Developer, I want to track payment transactions, so that I can debug issues

#### Acceptance Criteria

1. THE Payment System SHALL log all payment attempts with timestamps
2. THE Payment System SHALL store Stripe Payment Intent IDs
3. THE Payment System SHALL record payment status (succeeded, failed, canceled)
4. THE Payment System SHALL save transaction history in Firebase Firestore
5. THE Payment System SHALL include user ID, package details, and Stripe metadata in transaction records

### Requirement 8

**User Story:** As a Player, I want the payment UI to match the game aesthetic, so that the experience is cohesive

#### Acceptance Criteria

1. THE coin package cards SHALL use the VHS/glitch aesthetic
2. THE Payment System SHALL use Courier Prime font for package information
3. THE coin packages SHALL have dark backgrounds with red accents
4. THE success/error messages SHALL match the game's visual style
5. THE Payment System SHALL integrate seamlessly with the existing Store Screen


### Requirement 9

**User Story:** As a Developer, I want to use Firebase Cloud Functions for backend logic, so that API keys remain secure

#### Acceptance Criteria

1. THE Payment System SHALL use Firebase Cloud Functions to create Payment Intents
2. THE Cloud Function SHALL store the Stripe secret key securely
3. THE Cloud Function SHALL validate requests before creating Payment Intents
4. THE Cloud Function SHALL return the client secret to the Flutter app
5. THE Payment System SHALL never expose the Stripe secret key in the Flutter app

### Requirement 10

**User Story:** As a Player, I want to see available test cards, so that I know which cards to use

#### Acceptance Criteria

1. THE Payment System SHALL display a help button showing test card information
2. THE help dialog SHALL list Stripe test card numbers (4242 4242 4242 4242)
3. THE help dialog SHALL explain that any future date and CVC work for test cards
4. THE help dialog SHALL use the game's aesthetic for consistency
5. THE Payment System SHALL make it clear these are test cards only
