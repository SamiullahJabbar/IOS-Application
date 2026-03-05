import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customization_provider.dart';
import '../providers/order_provider.dart';
import '../providers/scan_provider.dart';
import '../services/stripe_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipController = TextEditingController();
  bool _paymentProcessing = false;
  String? _paymentError;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  double _calculateTotal(double price) {
    final shipping = 9.99;
    final tax = price * 0.08;
    return price + shipping + tax;
  }

  Future<void> _handlePayWithStripe() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final scan = context.read<ScanProvider>();
    final custom = context.read<CustomizationProvider>();
    final orderProvider = context.read<OrderProvider>();

    final total = _calculateTotal(custom.price);

    setState(() {
      _paymentProcessing = true;
      _paymentError = null;
    });

    try {
      final success = await StripeService.processPayment(
        amount: total,
        customerName: _nameController.text.trim(),
        customerEmail: auth.currentUser?.email ?? 'customer@test.com',
      );

      if (!mounted) return;

      if (success) {
        // Payment succeeded — create order
        final userId = auth.currentUser?.id ?? '';
        final scanId = scan.currentScan?.scanId ?? '';

        await orderProvider.createOrder(
          bodyPart: scan.selectedBodyPart ?? 'Unknown',
          colorValue: custom.selectedColor.toARGB32(),
          material: custom.selectedMaterial,
          pattern: custom.selectedPattern,
          personalizationText: custom.personalizationText,
          fitType: custom.selectedFitType,
          strapStyle: custom.selectedStrapStyle,
          shippingName: _nameController.text.trim(),
          shippingAddress: _addressController.text.trim(),
          shippingCity: _cityController.text.trim(),
          shippingCountry: _countryController.text.trim(),
          shippingZip: _zipController.text.trim(),
          totalAmount: total,
          userId: userId,
          scanId: scanId,
        );

        if (!mounted) return;
        context.go('/success');
      } else {
        // User cancelled
        setState(() => _paymentProcessing = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paymentProcessing = false;
        _paymentError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final customProvider = context.watch<CustomizationProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Product';

    return Scaffold(
      backgroundColor: const Color(0xFF060A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
          onPressed: () => context.go('/preview'),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: (_paymentProcessing || orderProvider.isProcessing)
          ? _buildProcessingView()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Card
                      _buildOrderSummary(bodyPart, customProvider)
                          .animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Shipping Address
                      const Text(
                        'Shipping Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _addressController,
                        label: 'Street Address',
                        hint: 'Enter your street address',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cityController,
                              label: 'City',
                              hint: 'City',
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _zipController,
                              label: 'Zip Code',
                              hint: 'Zip',
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'Enter your country',
                        prefixIcon: Icons.flag_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                      const SizedBox(height: 28),

                      // Payment — Stripe
                      const Text(
                        'Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

                      const SizedBox(height: 8),

                      // Stripe test mode badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF635BFF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF635BFF).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.credit_card_rounded,
                                color: const Color(0xFF635BFF).withValues(alpha: 0.8), size: 16),
                            const SizedBox(width: 6),
                            const Text(
                              'Powered by Stripe · Test Mode',
                              style: TextStyle(
                                color: Color(0xFF635BFF),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                      const SizedBox(height: 12),

                      // Info about Stripe
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF635BFF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.lock_rounded, color: Color(0xFF635BFF), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Secure Payment',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                                  ),
                                  Text(
                                    'Card details are handled securely by Stripe',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

                      // Error message
                      if (_paymentError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _paymentError!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Order Total
                      _buildOrderTotal(customProvider.price)
                          .animate().fadeIn(duration: 400.ms, delay: 600.ms),

                      const SizedBox(height: 20),

                      // Pay button
                      GradientButton(
                        text: 'Pay with Stripe',
                        icon: Icons.payment_rounded,
                        onPressed: _handlePayWithStripe,
                      ).animate().fadeIn(duration: 400.ms, delay: 650.ms),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF635BFF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: Color(0xFF635BFF),
                  strokeWidth: 3,
                ),
              ),
            ),
          ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
              ),
          const SizedBox(height: 24),
          const Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completing your secure payment via Stripe',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(String bodyPart, CustomizationProvider custom) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: custom.selectedColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: custom.selectedColor.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.radar_rounded, color: custom.selectedColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$bodyPart Support',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white),
                ),
                Text(
                  '${custom.selectedMaterial} · ${custom.selectedPattern}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                ),
                Text(
                  '${custom.selectedFitType} · ${custom.selectedStrapStyle}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: custom.selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotal(double price) {
    final shipping = 9.99;
    final tax = price * 0.08;
    final total = price + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', '\$${price.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildRow('Tax (8%)', '\$${tax.toStringAsFixed(2)}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
