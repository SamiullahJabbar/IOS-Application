import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// Conditionally import flutter_stripe only on non-web
import 'stripe_service_native.dart' if (dart.library.html) 'stripe_service_web.dart' as platform;

class StripeService {
  // Test mode keys
  static const String publishableKey =
      'pk_test_51R3DkdHkfI3gmJuNGlbcjyFkT1kuzuEC7sM0KaCfo6PnxlNLlzqECqzmmukvSJexZNNJ0QopD18pZJLT0YCugeD100gRlA4YTM';
  static const String _secretKey =
      'sk_test_51R3DkdHkfI3gmJuNhJw24dRwYIKoVffDWNbewvzCqwYmdasum2MZZJ0wvJrA31HKSIhnqL3RqoXWMfKImeDmapnl00WWcCljGW';

  /// Call once at app startup
  static void init() {
    platform.initStripe(publishableKey);
  }

  /// Create a PaymentIntent via Stripe API (test mode, direct call).
  static Future<Map<String, dynamic>> _createPaymentIntent({
    required int amountInCents,
    String currency = 'usd',
  }) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create PaymentIntent: ${response.body}');
    }
  }

  /// Process payment — uses native Stripe on mobile, simulates on web.
  static Future<bool> processPayment({
    required double amount,
    required String customerName,
    required String customerEmail,
  }) async {
    if (kIsWeb) {
      // On web, simulate a successful test payment
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

    // On mobile — create intent then present native payment sheet
    final amountInCents = (amount * 100).round();
    final paymentIntent = await _createPaymentIntent(amountInCents: amountInCents);

    final clientSecret = paymentIntent['client_secret'];
    if (clientSecret == null) {
      throw Exception('No client_secret in PaymentIntent response');
    }

    return platform.presentPaymentSheet(
      clientSecret: clientSecret,
      customerName: customerName,
      customerEmail: customerEmail,
    );
  }
}
