import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customization_provider.dart';
import '../providers/order_provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
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
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final scan = context.read<ScanProvider>();
    final custom = context.read<CustomizationProvider>();
    final orderProvider = context.read<OrderProvider>();

    final userId = auth.currentUser?.id ?? '';
    final scanId = scan.currentScan?.scanId ?? '';

    await orderProvider.createOrder(
      bodyPart: scan.selectedBodyPart ?? 'Unknown',
      colorValue: custom.selectedColor.value,
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
      totalAmount: _calculateTotal(custom.price),
      userId: userId,
      scanId: scanId,
    );

    if (!mounted) return;
    context.go('/success');
  }

  double _calculateTotal(double price) {
    final shipping = 9.99;
    final tax = price * 0.08;
    return price + shipping + tax;
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final customProvider = context.watch<CustomizationProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Product';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/preview'),
        ),
        title: const Text('Checkout'),
      ),
      body: orderProvider.isProcessing
          ? _buildProcessingView()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Card
                      _buildOrderSummary(
                          bodyPart, customProvider),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Shipping Address
                      Text(
                        'Shipping Address',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      CustomTextField(
                        controller: _addressController,
                        label: 'Street Address',
                        hint: 'Enter your street address',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cityController,
                              label: 'City',
                              hint: 'City',
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: CustomTextField(
                              controller: _zipController,
                              label: 'Zip Code',
                              hint: 'Zip',
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      CustomTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'Enter your country',
                        prefixIcon: Icons.flag_outlined,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Payment Method
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                      const SizedBox(height: AppTheme.spacingSm),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: AppTheme.warning, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Stripe Test Mode — No real charges',
                              style: TextStyle(
                                  color: AppTheme.warning, fontSize: 12),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      CustomTextField(
                        controller: _cardNumberController,
                        label: 'Card Number',
                        hint: '4242 4242 4242 4242',
                        prefixIcon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _expiryController,
                              label: 'Expiry',
                              hint: 'MM/YY',
                              keyboardType: TextInputType.datetime,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: CustomTextField(
                              controller: _cvvController,
                              label: 'CVV',
                              hint: '123',
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 650.ms),

                      const SizedBox(height: AppTheme.spacingXl),

                      // Order Total
                      _buildOrderTotal(customProvider.price)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 700.ms),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Place Order Button
                      GradientButton(
                        text: 'Place Order',
                        icon: Icons.lock_rounded,
                        onPressed: _handlePlaceOrder,
                      ).animate().fadeIn(duration: 400.ms, delay: 750.ms),

                      const SizedBox(height: AppTheme.spacingLg),
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
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                  strokeWidth: 3,
                ),
              ),
            ),
          ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
              ),
          const SizedBox(height: AppTheme.spacingLg),
          const Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we process your order',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(
    String bodyPart,
    CustomizationProvider custom,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: custom.selectedColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: custom.selectedColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.view_in_ar_rounded,
              color: custom.selectedColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$bodyPart Support',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${custom.selectedMaterial} · ${custom.selectedPattern}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${custom.selectedFitType} · ${custom.selectedStrapStyle}',
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: custom.selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildOrderTotal(double price) {
    final shipping = 9.99;
    final tax = price * 0.08;
    final total = price + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', '\$${price.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildTotalRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildTotalRow('Tax (8%)', '\$${tax.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.cardBorder, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
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

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 14)),
      ],
    );
  }
}
