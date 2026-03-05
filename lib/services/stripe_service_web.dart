// Web stub — flutter_stripe doesn't support web
// Payment is simulated in StripeService.processPayment()

void initStripe(String publishableKey) {
  // No-op on web — Stripe SDK not available
}

Future<bool> presentPaymentSheet({
  required String clientSecret,
  required String customerName,
  required String customerEmail,
}) async {
  // Should never be called on web (guarded by kIsWeb check)
  return true;
}
