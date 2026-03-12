# Implementation Plan - Integración de Stripe en Modo Prueba

- [x] 1. Configurar dependencias y entorno de Stripe


  - Agregar flutter_stripe al pubspec.yaml
  - Crear cuenta de Stripe en modo test
  - Obtener claves de API de prueba (publishable y secret)
  - Configurar Stripe.publishableKey en main.dart
  - _Requirements: 3.1, 9.2_





- [ ] 2. Crear modelos de datos para pagos
- [ ] 2.1 Implementar CoinPackage model
  - Crear clase CoinPackage con id, coins, priceUSD, displayPrice
  - Agregar campo bonusCoins opcional


  - Implementar getter totalCoins
  - Crear lista estática de paquetes disponibles
  - _Requirements: 1.2, 1.3_



- [ ] 2.2 Implementar PaymentResult model
  - Crear clase PaymentResult con isSuccess, paymentIntentId, errorMessage
  - Agregar constructores named para success, error, cancelled
  - _Requirements: 4.1, 6.2_

- [ ] 2.3 Implementar PaymentTransaction model
  - Crear clase con campos: id, userId, packageId, coinsAdded, amountUSD, paymentIntentId, status, timestamp
  - Implementar método toFirestore() para serialización
  - _Requirements: 7.2, 7.4, 7.5_





- [ ] 3. Implementar Firebase Cloud Function para Payment Intents
  - Crear función createPaymentIntent en Firebase Functions
  - Configurar Stripe SDK en Cloud Functions
  - Validar autenticación del usuario

  - Crear Payment Intent con Stripe API
  - Retornar client_secret al cliente
  - Configurar secret key con firebase functions:config:set
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 4. Crear StripePaymentService
- [x] 4.1 Implementar inicialización de Stripe

  - Crear método initialize() que configure Stripe.publishableKey
  - Configurar merchantIdentifier
  - Habilitar test mode
  - _Requirements: 2.2, 3.1_





- [ ] 4.2 Implementar método purchaseCoins
  - Llamar a Cloud Function para crear Payment Intent
  - Inicializar Payment Sheet con client_secret
  - Presentar Payment Sheet al usuario
  - Manejar resultado del pago
  - Retornar PaymentResult apropiado

  - _Requirements: 2.1, 2.3, 4.1_

- [ ] 4.3 Implementar manejo de errores de Stripe
  - Capturar StripeException con diferentes códigos
  - Manejar errores de red (SocketException)

  - Manejar errores de Cloud Functions
  - Retornar mensajes user-friendly
  - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [ ] 5. Integrar UI de compra de monedas en StoreScreen
- [x] 5.1 Crear sección de paquetes de monedas



  - Agregar título "COMPRAR MONEDAS" con estética VHS
  - Crear grid de coin packages
  - Diseñar cards con fondo oscuro y bordes rojos
  - Mostrar cantidad de monedas, bonus, y precio
  - Agregar botón "COMPRAR" en cada card

  - _Requirements: 1.1, 1.2, 1.3, 8.1, 8.2, 8.3_

- [ ] 5.2 Agregar indicador de TEST MODE
  - Crear badge "TEST MODE" en esquina superior
  - Usar fuente Courier Prime
  - Aplicar estilo consistente con el juego
  - _Requirements: 3.4, 8.4_


- [ ] 5.3 Implementar diálogo de ayuda para tarjetas de prueba
  - Crear botón "?" para mostrar ayuda
  - Diseñar diálogo con lista de tarjetas de test
  - Incluir 4242 4242 4242 4242 (siempre exitosa)


  - Incluir 4000 0000 0000 9995 (siempre falla)
  - Explicar que cualquier fecha futura y CVC funcionan
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 6. Implementar flujo completo de pago
- [ ] 6.1 Conectar botón de compra con StripePaymentService
  - Manejar tap en botón "COMPRAR"
  - Mostrar loading indicator
  - Llamar a purchaseCoins con el package seleccionado
  - _Requirements: 2.1, 5.1_

- [ ] 6.2 Procesar resultado exitoso del pago
  - Actualizar balance de monedas en Firebase Firestore
  - Guardar transacción en Firestore
  - Mostrar mensaje de éxito con animación
  - Actualizar UI del store con nuevo balance
  - Agregar haptic feedback
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.3, 5.5_

- [ ] 6.3 Manejar errores y cancelaciones
  - Mostrar diálogo de error con mensaje apropiado
  - Permitir retry en caso de error
  - Manejar cancelación sin mostrar error
  - Mantener estabilidad de la app
  - _Requirements: 6.2, 6.3, 6.5_

- [ ] 7. Implementar logging y tracking de transacciones
  - Crear colección "transactions" en Firestore
  - Guardar cada intento de pago con timestamp
  - Incluir Payment Intent ID de Stripe
  - Registrar status (succeeded, failed, canceled)
  - Agregar logs en consola para debugging
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 8. Checkpoint - Verificar flujo básico de pago
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 9. Escribir tests de propiedad
- [ ]* 9.1 Property test: Payment Intent Creation Consistency
  - **Property 1: Payment Intent Creation Consistency**
  - **Validates: Requirements 2.1, 9.3**
  - Generar paquetes de monedas aleatorios
  - Verificar que el amount en Payment Intent = priceUSD * 100
  - _Requirements: 2.1, 9.3_

- [ ]* 9.2 Property test: Coin Addition Accuracy
  - **Property 2: Coin Addition Accuracy**
  - **Validates: Requirements 4.1, 4.2**
  - Generar pagos exitosos con diferentes paquetes
  - Verificar que coins agregadas = package.totalCoins
  - _Requirements: 4.1, 4.2_

- [ ]* 9.3 Property test: Transaction Record Completeness
  - **Property 3: Transaction Record Completeness**
  - **Validates: Requirements 7.2, 7.4, 7.5**
  - Generar transacciones aleatorias (éxito y fallo)
  - Verificar que todos los campos requeridos estén presentes
  - _Requirements: 7.2, 7.4, 7.5_

- [ ]* 9.4 Property test: Payment Cancellation Safety
  - **Property 6: Payment Cancellation Safety**
  - **Validates: Requirements 6.3, 4.1**
  - Simular cancelaciones de pago
  - Verificar que no se agreguen monedas


  - Verificar que la app no crashee
  - _Requirements: 6.3, 4.1_

- [ ]* 9.5 Property test: Error Handling Stability
  - **Property 5: Error Handling Stability**
  - **Validates: Requirements 6.1, 6.2, 6.3, 6.5**
  - Generar diferentes tipos de errores de Stripe
  - Verificar que la app permanezca estable
  - Verificar que se muestren mensajes user-friendly
  - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [ ]* 10. Escribir unit tests
- [ ]* 10.1 Unit test para CoinPackage model
  - Test cálculo de totalCoins con bonus
  - Test valores de paquetes predefinidos
  - _Requirements: 1.2_

- [ ]* 10.2 Unit test para PaymentResult
  - Test creación de resultado exitoso
  - Test creación de resultado con error
  - Test creación de resultado cancelado
  - _Requirements: 4.1, 6.3_

- [ ]* 10.3 Unit test para PaymentTransaction
  - Test serialización a Firestore
  - Test validación de campos requeridos
  - _Requirements: 7.4_

- [ ] 11. Testing manual con tarjetas de Stripe
  - Probar con 4242 4242 4242 4242 (éxito)
  - Probar con 4000 0000 0000 9995 (fallo)
  - Probar cancelación de pago
  - Verificar actualización de balance
  - Verificar guardado de transacciones
  - Verificar mensajes de éxito/error
  - _Requirements: 3.2, 3.3, 4.3, 4.4, 5.3_

- [ ] 12. Pulir UI y animaciones
  - Agregar animación de éxito al recibir monedas
  - Mejorar transiciones del Payment Sheet
  - Agregar efectos VHS/glitch sutiles
  - Optimizar loading states
  - _Requirements: 5.3, 5.4, 8.4, 8.5_

- [ ] 13. Checkpoint final - Verificar integración completa
  - Ensure all tests pass, ask the user if questions arise.
