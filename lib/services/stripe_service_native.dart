// Native (iOS/Android) Stripe implementation
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void initStripe(String publishableKey) {
  Stripe.publishableKey = publishableKey;
}

Future<bool> presentPaymentSheet({
  required String clientSecret,
  required String customerName,
  required String customerEmail,
}) async {
  try {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Body Scan Pro',
        style: ThemeMode.dark,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            background: Color(0xFF0A0E1A),
            primary: Color(0xFF3B82F6),
            componentBackground: Color(0xFF141824),
            componentBorder: Color(0xFF1E2536),
            primaryText: Color(0xFFFFFFFF),
            secondaryText: Color(0xFF8B95A9),
            placeholderText: Color(0xFF4A5568),
            icon: Color(0xFF8B95A9),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 16,
            borderWidth: 1,
          ),
        ),
        billingDetails: BillingDetails(
          name: customerName,
          email: customerEmail,
        ),
      ),
    );

    await Stripe.instance.presentPaymentSheet();
    return true;
  } on StripeException catch (e) {
    if (e.error.code == FailureCode.Canceled) {
      return false;
    }
    rethrow;
  }
}
