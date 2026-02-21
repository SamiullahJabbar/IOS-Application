import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/premium_card.dart';

class BodyPartSelectionScreen extends StatelessWidget {
  const BodyPartSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyParts = [
      BodyPartItem(
        name: 'Hand',
        urduName: 'Haath',
        description: 'Ungliyaan, hathelee aur kalai — full hand scan',
        icon: Icons.back_hand_rounded,
        color: const Color(0xFF3B82F6),
      ),
      BodyPartItem(
        name: 'Knee',
        urduName: 'Ghutna',
        description: 'Ghutne ki joint aur aas paas ka area',
        icon: Icons.accessibility_new_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      BodyPartItem(
        name: 'Ankle',
        urduName: 'Tokhna',
        description: 'Tokhna aur paaon ka nichla hissa',
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFFEC4899),
      ),
      BodyPartItem(
        name: 'Shoulder',
        urduName: 'Kandha',
        description: 'Kandhe ki joint aur upar ka arm',
        icon: Icons.sports_martial_arts_rounded,
        color: const Color(0xFFF59E0B),
      ),
      BodyPartItem(
        name: 'Elbow',
        urduName: 'Kohni',
        description: 'Kohni ki joint aur forearm',
        icon: Icons.sports_handball_rounded,
        color: const Color(0xFF22C55E),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Select Body Part'),
      ),
      body: SafeArea(
        child: Consumer<ScanProvider>(
          builder: (context, scanProvider, _) {
            return Column(
              children: [
                const SizedBox(height: AppTheme.spacingMd),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg),
                  child: Text(
                    'Choose the body part you want to scan',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: AppTheme.spacingLg),

                // Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg),
                    child: Column(
                      children: [
                        // First row - 2 cards
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildBodyPartCard(
                                  context,
                                  bodyParts[0],
                                  scanProvider,
                                  0,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: _buildBodyPartCard(
                                  context,
                                  bodyParts[1],
                                  scanProvider,
                                  1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingMd),

                        // Second row - 2 cards
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildBodyPartCard(
                                  context,
                                  bodyParts[2],
                                  scanProvider,
                                  2,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: _buildBodyPartCard(
                                  context,
                                  bodyParts[3],
                                  scanProvider,
                                  3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingMd),

                        // Third row - 1 card centered
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: _buildBodyPartCard(
                                context,
                                bodyParts[4],
                                scanProvider,
                                4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: GradientButton(
                    text: 'Continue to Scan',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: scanProvider.selectedBodyPart != null
                        ? () => context.go('/scan')
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodyPartCard(
    BuildContext context,
    BodyPartItem item,
    ScanProvider provider,
    int index,
  ) {
    final isSelected = provider.selectedBodyPart == item.name;

    return PremiumCard(
      isSelected: isSelected,
      onTap: () => provider.selectBodyPart(item.name),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: isSelected ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              item.icon,
              color: isSelected ? item.color : item.color.withValues(alpha: 0.7),
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.urduName,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn(duration: 400.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }
}

class BodyPartItem {
  final String name;
  final String urduName;
  final String description;
  final IconData icon;
  final Color color;

  BodyPartItem({
    required this.name,
    required this.urduName,
    required this.description,
    required this.icon,
    required this.color,
  });
}
