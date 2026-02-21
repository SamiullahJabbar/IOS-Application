import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/order_provider.dart';
import '../services/scan_service.dart';
import '../services/order_service.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/premium_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _scanCount = 0;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadCurrentUser();
    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id;
      await context.read<ScanProvider>().loadUserScans(userId);
      await context.read<OrderProvider>().loadUserOrders(userId);
      final scanCount = await ScanService.getScanCount(userId);
      final orderCount = await OrderService.getOrderCount(userId);
      if (mounted) {
        setState(() {
          _scanCount = scanCount;
          _orderCount = orderCount;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: _currentIndex == 0
            ? _buildHomeTab()
            : _currentIndex == 1
                ? _buildScansTab()
                : _currentIndex == 2
                    ? _buildOrdersTab()
                    : _buildProfileTab(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.cardBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_in_ar_rounded),
              label: 'Scans',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.currentUser?.fullName ?? 'User';
        final firstName = userName.split(' ').first;

        return RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          firstName,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    ),
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Center(
                        child: Text(
                          firstName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppTheme.spacingXl),

                // Start New Scan CTA
                PremiumCard(
                  gradient: AppTheme.scanGradient,
                  onTap: () => context.go('/select-part'),
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start New Scan',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scan your body part with LiDAR precision',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: const Icon(
                          Icons.view_in_ar_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                    ),

                const SizedBox(height: AppTheme.spacingLg),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: PremiumCard(
                        child: Column(
                          children: [
                            const Icon(Icons.view_in_ar_rounded,
                                color: AppTheme.primaryBlue, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              '$_scanCount',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Text(
                              'Total Scans',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: PremiumCard(
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_bag_rounded,
                                color: AppTheme.success, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              '$_orderCount',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Text(
                              'Orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                const SizedBox(height: AppTheme.spacingLg),

                // Recent Scans
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                const SizedBox(height: AppTheme.spacingMd),

                Consumer<ScanProvider>(
                  builder: (context, scanProvider, _) {
                    if (scanProvider.userScans.isEmpty) {
                      return PremiumCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingXl),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.view_in_ar_rounded,
                                  size: 48,
                                  color: AppTheme.textTertiary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AppTheme.spacingMd),
                                const Text(
                                  'No scans yet',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Start your first body scan!',
                                  style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: scanProvider.userScans
                          .take(5)
                          .map((scan) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppTheme.spacingSm),
                                child: PremiumCard(
                                  onTap: () {
                                    scanProvider.setCurrentScan(scan);
                                    context.go('/model');
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusMd),
                                        ),
                                        child: Icon(
                                          _getBodyPartIcon(scan.bodyPart),
                                          color: AppTheme.primaryBlue,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: AppTheme.spacingMd),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              scan.bodyPart,
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              '${scan.scanDate.day}/${scan.scanDate.month}/${scan.scanDate.year}',
                                              style: const TextStyle(
                                                color: AppTheme.textTertiary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppTheme.textTertiary,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScansTab() {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Scans',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppTheme.spacingLg),
              Expanded(
                child: scanProvider.userScans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.view_in_ar_rounded,
                                size: 64,
                                color: AppTheme.textTertiary.withValues(alpha: 0.5)),
                            const SizedBox(height: AppTheme.spacingMd),
                            const Text('No scans yet',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 18)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: scanProvider.userScans.length,
                        itemBuilder: (context, index) {
                          final scan = scanProvider.userScans[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppTheme.spacingSm),
                            child: PremiumCard(
                              onTap: () {
                                scanProvider.setCurrentScan(scan);
                                context.go('/model');
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd),
                                    ),
                                    child: Icon(
                                      _getBodyPartIcon(scan.bodyPart),
                                      color: AppTheme.primaryBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingMd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(scan.bodyPart,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16)),
                                        Text(
                                          '${scan.scanDate.day}/${scan.scanDate.month}/${scan.scanDate.year} · ${scan.status}',
                                          style: const TextStyle(
                                              color: AppTheme.textTertiary,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AppTheme.textTertiary),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Orders',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppTheme.spacingLg),
              Expanded(
                child: orderProvider.userOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_rounded,
                                size: 64,
                                color: AppTheme.textTertiary.withValues(alpha: 0.5)),
                            const SizedBox(height: AppTheme.spacingMd),
                            const Text('No orders yet',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 18)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: orderProvider.userOrders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.userOrders[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppTheme.spacingSm),
                            child: PremiumCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(order.orderId,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.success
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusFull),
                                        ),
                                        child: Text(
                                          order.paymentStatus.toUpperCase(),
                                          style: const TextStyle(
                                              color: AppTheme.success,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${order.bodyPart} · ${order.material}',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    '\$${order.totalAmount.toStringAsFixed(2)} · ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                                    style: const TextStyle(
                                        color: AppTheme.textTertiary,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacingXl),

              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Center(
                  child: Text(
                    (auth.currentUser?.fullName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              Text(
                auth.currentUser?.fullName ?? 'User',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                auth.currentUser?.email ?? '',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 15),
              ),

              const SizedBox(height: AppTheme.spacingXxl),

              // Stats
              PremiumCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('$_scanCount',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Scans',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.cardBorder),
                    Column(
                      children: [
                        Text('$_orderCount',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Orders',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Logout
              GradientButton(
                text: 'Logout',
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/login');
                },
              ),

              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        );
      },
    );
  }

  IconData _getBodyPartIcon(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'hand':
        return Icons.back_hand_rounded;
      case 'knee':
        return Icons.accessibility_new_rounded;
      case 'ankle':
        return Icons.directions_walk_rounded;
      case 'shoulder':
        return Icons.sports_martial_arts_rounded;
      case 'elbow':
        return Icons.sports_handball_rounded;
      default:
        return Icons.view_in_ar_rounded;
    }
  }
}
