import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/customization_provider.dart';
import '../providers/order_provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.currentOrder;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacingXxl),

              // Success Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.success,
                    size: 52,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(
                    duration: 1200.ms,
                    color: AppTheme.success.withValues(alpha: 0.3),
                  ),

              const SizedBox(height: AppTheme.spacingLg),

              // Title
              const Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

              const SizedBox(height: AppTheme.spacingSm),

              Text(
                'Your custom product is being prepared',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

              const SizedBox(height: AppTheme.spacingXl),

              // Order Number
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Order Number',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order?.orderId ?? 'ORD-XXXXXXXX',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    const Divider(color: AppTheme.cardBorder),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Delivery estimate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(Icons.local_shipping_rounded,
                              color: AppTheme.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Delivery',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '5-7 Business Days',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 500.ms,
                  ),

              const SizedBox(height: AppTheme.spacingMd),

              // Order details card
              if (order != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildDetailRow(
                          'Product', '${order.bodyPart} Support'),
                      _buildDetailRow('Material', order.material),
                      _buildDetailRow('Pattern', order.pattern),
                      _buildDetailRow('Fit', order.fitType),
                      _buildDetailRow('Strap', order.strapStyle),
                      if (order.personalizationText.isNotEmpty)
                        _buildDetailRow(
                            'Text', order.personalizationText),
                      const Divider(
                          color: AppTheme.cardBorder, height: 24),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

              const SizedBox(height: AppTheme.spacingXl),

              // Action Buttons
              GradientButton(
                text: 'Scan Another Body Part',
                icon: Icons.view_in_ar_rounded,
                onPressed: () {
                  // Clear session state
                  context.read<ScanProvider>().clearCurrentSession();
                  context.read<CustomizationProvider>().resetCustomization();
                  context.read<OrderProvider>().clearCurrentOrder();
                  context.go('/select-part');
                },
              ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

              const SizedBox(height: AppTheme.spacingMd),

              OutlinedButton.icon(
                onPressed: () {
                  context.read<ScanProvider>().clearCurrentSession();
                  context.read<CustomizationProvider>().resetCustomization();
                  context.read<OrderProvider>().clearCurrentOrder();
                  context.go('/home');
                },
                icon: const Icon(Icons.home_rounded,
                    color: AppTheme.textSecondary),
                label: const Text('Back to Home',
                    style: TextStyle(color: AppTheme.textSecondary)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppTheme.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
