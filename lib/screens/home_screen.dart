import 'dart:convert';
import 'dart:ui';
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
    final scanProv = context.read<ScanProvider>();
    final orderProv = context.read<OrderProvider>();
    await authProvider.loadCurrentUser();
    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id;
      await scanProv.loadUserScans(userId);
      await orderProv.loadUserOrders(userId);
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
      backgroundColor: const Color(0xFF060A14),
      body: SafeArea(
        child: _currentIndex == 0
            ? _buildHomeTab()
            : _currentIndex == 1
                ? _buildScansTab()
                : _currentIndex == 2
                    ? _buildOrdersTab()
                    : _buildProfileTab(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Modern Bottom Navigation Bar ──────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard_rounded, label: 'Home'),
      _NavItem(icon: Icons.radar_outlined, activeIcon: Icons.radar_rounded, label: 'Scans'),
      _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Orders'),
      _NavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1122),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = _currentIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryBlue.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? items[index].activeIcon : items[index].icon,
                      color: isActive
                          ? AppTheme.primaryBlue
                          : Colors.white.withValues(alpha: 0.35),
                      size: 22,
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Text(
                        items[index].label,
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HOME TAB
  // ═══════════════════════════════════════════════════════════════════
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          firstName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    // Avatar with status dot
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.3),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              firstName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF060A14),
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // ─── Start New Scan CTA ───────────────────
                _buildScanCTA(),

                const SizedBox(height: 20),

                // ─── Stats Row ────────────────────────────
                _buildStatsRow(),

                const SizedBox(height: 20),

                // ─── Quick Actions ────────────────────────
                _buildQuickActions(),

                const SizedBox(height: 24),

                // ─── Recent Scans ─────────────────────────
                _buildSectionHeader('Recent Scans', Icons.history_rounded),
                const SizedBox(height: 12),
                _buildRecentScans(),

                const SizedBox(height: 24),

                // ─── Pro Tips ─────────────────────────────
                _buildProTips(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Scan CTA Card ─────────────────────────────────────────────────
  Widget _buildScanCTA() {
    return GestureDetector(
      onTap: () => context.go('/select-part'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.25),
                  const Color(0xFF7C3AED).withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                // Scan icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.sensors_rounded,
                    color: Color(0xFF60A5FA),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start New Scan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scan your body part with LiDAR precision',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 450.ms, delay: 150.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 450.ms,
        );
  }

  // ─── Stats Row ─────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.radar_rounded,
          iconColor: const Color(0xFF60A5FA),
          value: '$_scanCount',
          label: 'Total Scans',
          bgColor: const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.inventory_2_rounded,
          iconColor: const Color(0xFF34D399),
          value: '$_orderCount',
          label: 'Orders',
          bgColor: const Color(0xFF22C55E),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFFBBF24),
          value: '0',
          label: 'Pending',
          bgColor: const Color(0xFFF59E0B),
        ),
      ],
    ).animate().fadeIn(duration: 450.ms, delay: 300.ms);
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: bgColor.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Quick Actions ─────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction('New Scan', Icons.sensors_rounded, const Color(0xFF3B82F6), 'scan'),
      _QuickAction('3D Model', Icons.view_in_ar_rounded, const Color(0xFF7C3AED), 'model'),
      _QuickAction('History', Icons.timeline_rounded, const Color(0xFFF59E0B), 'history'),
      _QuickAction('Support', Icons.support_agent_rounded, const Color(0xFF22C55E), 'support'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions', Icons.bolt_rounded),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  switch (action.route) {
                    case 'scan':
                      context.go('/select-part');
                      break;
                    case 'model':
                      context.go('/model');
                      break;
                    case 'history':
                      setState(() => _currentIndex = 1); // Switch to Scans tab
                      break;
                    case 'support':
                      _showSupportDialog();
                      break;
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: action != actions.last ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: action.color.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(action.icon, color: action.color, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 450.ms, delay: 400.ms);
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: Color(0xFF22C55E), size: 22),
            SizedBox(width: 10),
            Text('Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help? Contact us:',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
            const SizedBox(height: 14),
            _supportRow(Icons.email_rounded, 'support@bodyscanpro.com'),
            const SizedBox(height: 8),
            _supportRow(Icons.phone_rounded, '+1 (800) 123-4567'),
            const SizedBox(height: 8),
            _supportRow(Icons.chat_bubble_rounded, 'Live chat available 9AM-5PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  Widget _supportRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.4)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ─── Section Header ────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ─── Recent Scans ──────────────────────────────────────────────────
  Widget _buildRecentScans() {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, _) {
        if (scanProvider.userScans.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.radar_rounded,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No scans yet',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start your first body scan!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: scanProvider.userScans.take(5).map((scan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  scanProvider.setCurrentScan(scan);
                  context.go('/model');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getBodyPartIcon(scan.bodyPart),
                          color: const Color(0xFF60A5FA),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.bodyPart,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${scan.scanDate.day}/${scan.scanDate.month}/${scan.scanDate.year}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    ).animate().fadeIn(duration: 450.ms, delay: 500.ms);
  }

  // ─── Pro Tips Carousel ─────────────────────────────────────────────
  Widget _buildProTips() {
    final tips = [
      _Tip(
        'Optimal Scanning',
        'Hold your device 30-50cm from the body part for the best LiDAR depth accuracy.',
        Icons.tips_and_updates_rounded,
        const Color(0xFFF59E0B),
      ),
      _Tip(
        'Perfect Fit Guarantee',
        'Our 3D-printed braces are custom-molded from your scan data for a perfect fit.',
        Icons.verified_rounded,
        const Color(0xFF22C55E),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pro Tips', Icons.lightbulb_outline_rounded),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tip.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: tip.color.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tip.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(tip.icon, color: tip.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.45),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    ).animate().fadeIn(duration: 450.ms, delay: 600.ms);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SCANS TAB
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildScansTab() {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Scans',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: scanProvider.userScans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.radar_rounded,
                                size: 56,
                                color: Colors.white.withValues(alpha: 0.12)),
                            const SizedBox(height: 14),
                            Text('No scans yet',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: scanProvider.userScans.length,
                        itemBuilder: (context, index) {
                          final scan = scanProvider.userScans[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () {
                                scanProvider.setCurrentScan(scan);
                                context.go('/model');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        _getBodyPartIcon(scan.bodyPart),
                                        color: const Color(0xFF60A5FA),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(scan.bodyPart,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                          Text(
                                            '${scan.scanDate.day}/${scan.scanDate.month}/${scan.scanDate.year} · ${scan.status}',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.35),
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        size: 14),
                                  ],
                                ),
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

  // ═══════════════════════════════════════════════════════════════════
  //  ORDERS TAB
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildOrdersTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: orderProvider.userOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_rounded,
                                size: 56,
                                color: Colors.white.withValues(alpha: 0.12)),
                            const SizedBox(height: 14),
                            Text('No orders yet',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: orderProvider.userOrders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.userOrders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.07),
                                ),
                              ),
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
                                              fontSize: 14,
                                              color: Colors.white)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF22C55E)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          order.paymentStatus.toUpperCase(),
                                          style: const TextStyle(
                                              color: Color(0xFF34D399),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${order.bodyPart} · ${order.material}',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                        fontSize: 13),
                                  ),
                                  Text(
                                    '\$${order.totalAmount.toStringAsFixed(2)} · ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.3),
                                        fontSize: 12),
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

  // ═══════════════════════════════════════════════════════════════════
  //  PROFILE TAB
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final name = user?.fullName ?? 'User';
        final email = user?.email ?? '';
        final phone = user?.phone ?? '';
        final hasImage = user?.profileImageBase64 != null &&
            user!.profileImageBase64!.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3B82F6),
                                Color(0xFF7C3AED)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.3),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: Center(
                            child: hasImage
                                ? ClipOval(
                                    child: Image.memory(
                                      _decodeBase64(
                                          user.profileImageBase64!),
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    name[0].toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showEditProfileDialog(auth),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF060A14),
                                    width: 2),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 14),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 16),

              // Stats
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _profileStat('$_scanCount', 'Scans',
                        const Color(0xFF3B82F6)),
                    Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.08)),
                    _profileStat('$_orderCount', 'Orders',
                        const Color(0xFF22C55E)),
                    Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.08)),
                    _profileStat(
                        user?.createdAt != null
                            ? '${DateTime.now().difference(user!.createdAt).inDays}d'
                            : '0d',
                        'Member',
                        const Color(0xFFF59E0B)),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

              const SizedBox(height: 20),

              // Menu items
              _profileMenuItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                subtitle: 'Update name, phone, avatar',
                color: const Color(0xFF3B82F6),
                onTap: () => _showEditProfileDialog(auth),
              ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

              const SizedBox(height: 10),

              _profileMenuItem(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                subtitle: 'Update your password',
                color: const Color(0xFF7C3AED),
                onTap: () => _showChangePasswordDialog(auth),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              const SizedBox(height: 10),

              _profileMenuItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                subtitle: 'Manage push notifications',
                color: const Color(0xFFF59E0B),
                onTap: () => _showSnackBar('Coming soon!'),
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

              const SizedBox(height: 10),

              _profileMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                subtitle: 'FAQ, contact, feedback',
                color: const Color(0xFF22C55E),
                onTap: () => _showSupportDialog(),
              ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

              const SizedBox(height: 10),

              _profileMenuItem(
                icon: Icons.info_outline_rounded,
                label: 'About',
                subtitle: 'App version 1.0.0',
                color: Colors.white.withValues(alpha: 0.5),
                onTap: () => _showSnackBar('Body Scan Pro v1.0.0'),
              ).animate().fadeIn(duration: 400.ms, delay: 650.ms),

              const SizedBox(height: 24),

              // Logout
              GradientButton(
                text: 'Logout',
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/login');
                },
              ).animate().fadeIn(duration: 400.ms, delay: 750.ms),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _profileStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
      ],
    );
  }

  Widget _profileMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2), size: 20),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF141824),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showEditProfileDialog(AuthProvider auth) {
    final nameController =
        TextEditingController(text: auth.currentUser?.fullName ?? '');
    final phoneController =
        TextEditingController(text: auth.currentUser?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.person_outline_rounded,
                color: Color(0xFF3B82F6), size: 22),
            SizedBox(width: 10),
            Text('Edit Profile',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () async {
              final success = await auth.updateProfile(
                fullName: nameController.text.trim().isNotEmpty
                    ? nameController.text.trim()
                    : null,
                phone: phoneController.text.trim().isNotEmpty
                    ? phoneController.text.trim()
                    : null,
              );
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                _showSnackBar(success
                    ? 'Profile updated!'
                    : 'Failed to update profile');
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(AuthProvider auth) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded,
                color: Color(0xFF7C3AED), size: 22),
            SizedBox(width: 10),
            Text('Change Password',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogTextField(currentController, 'Current Password',
                obscure: true),
            const SizedBox(height: 12),
            _dialogTextField(newController, 'New Password',
                obscure: true),
            const SizedBox(height: 12),
            _dialogTextField(confirmController, 'Confirm New Password',
                obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () async {
              if (newController.text != confirmController.text) {
                _showSnackBar('Passwords do not match');
                return;
              }
              if (newController.text.length < 6) {
                _showSnackBar('Password must be at least 6 characters');
                return;
              }
              final success = await auth.changePassword(
                currentPassword: currentController.text,
                newPassword: newController.text,
              );
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                _showSnackBar(success
                    ? 'Password changed!'
                    : auth.errorMessage ?? 'Failed to change password');
              }
            },
            child: const Text('Update',
                style: TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED)),
        ),
      ),
    );
  }

  static _decodeBase64(String base64Str) {
    return base64Decode(base64Str);
  }

  // ─── Body Part Icons ───────────────────────────────────────────────
  IconData _getBodyPartIcon(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'hand':
        return Icons.front_hand_rounded;
      case 'knee':
        return Icons.airline_seat_legroom_extra_rounded;
      case 'ankle':
        return Icons.do_not_step_rounded;
      case 'shoulder':
        return Icons.accessibility_new_rounded;
      case 'elbow':
        return Icons.switch_access_shortcut_rounded;
      default:
        return Icons.radar_rounded;
    }
  }
}

// ─── Helper Models ───────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String? route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}

class _Tip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  const _Tip(this.title, this.description, this.icon, this.color);
}
