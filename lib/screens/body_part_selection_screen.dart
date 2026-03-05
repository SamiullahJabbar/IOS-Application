import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/gradient_button.dart';

class BodyPartSelectionScreen extends StatelessWidget {
  const BodyPartSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyParts = [
      _BodyPart('Hand', 'Full hand & wrist scan', Icons.front_hand_rounded, const Color(0xFF3B82F6)),
      _BodyPart('Knee', 'Knee joint & surrounding', Icons.airline_seat_legroom_extra_rounded, const Color(0xFF8B5CF6)),
      _BodyPart('Ankle', 'Ankle & lower foot area', Icons.do_not_step_rounded, const Color(0xFFEC4899)),
      _BodyPart('Shoulder', 'Shoulder joint & upper arm', Icons.accessibility_new_rounded, const Color(0xFFF59E0B)),
      _BodyPart('Elbow', 'Elbow joint & forearm', Icons.switch_access_shortcut_rounded, const Color(0xFF22C55E)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF060A14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Select Body Part',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Consumer<ScanProvider>(
          builder: (context, scanProvider, _) {
            return Column(
              children: [
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Choose the body part you want to scan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Row 1
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _buildCard(context, bodyParts[0], scanProvider, 0)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildCard(context, bodyParts[1], scanProvider, 1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Row 2
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _buildCard(context, bodyParts[2], scanProvider, 2)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildCard(context, bodyParts[3], scanProvider, 3)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Row 3 - centered
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.44,
                              child: _buildCard(context, bodyParts[4], scanProvider, 4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GradientButton(
                    text: 'Continue to Scan',
                    icon: Icons.sensors_rounded,
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

  Widget _buildCard(BuildContext context, _BodyPart item, ScanProvider provider, int index) {
    final isSelected = provider.selectedBodyPart == item.name;

    return GestureDetector(
      onTap: () => provider.selectBodyPart(item.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? item.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.07),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: isSelected ? item.color : item.color.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn(duration: 400.ms).slideY(
          begin: 0.15,
          end: 0,
          duration: 400.ms,
        );
  }
}

class _BodyPart {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  const _BodyPart(this.name, this.description, this.icon, this.color);
}
