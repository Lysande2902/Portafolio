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
        errorMessage = 'Pago cancelado';
}
