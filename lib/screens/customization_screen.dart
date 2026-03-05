import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/customization_provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/premium_card.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final customProvider = context.read<CustomizationProvider>();
    _textController.text = customProvider.personalizationText;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    final customProvider = context.read<CustomizationProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Pick a Color',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: customProvider.selectedColor,
            onColorChanged: (color) {
              customProvider.setColor(color);
            },
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done',
                style: TextStyle(color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Product';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/model'),
        ),
        title: Text('Customize $bodyPart'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Live Preview Card
            Consumer<CustomizationProvider>(
              builder: (context, custom, _) {
                return Container(
                  height: 200,
                  margin: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusXl),
                          child: CustomPaint(
                            painter:
                                _PatternPainter(custom.selectedColor),
                          ),
                        ),
                      ),
                      // Center icon with selected color
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: custom.selectedColor.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: custom.selectedColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _getBodyPartIcon(bodyPart),
                                size: 40,
                                color: custom.selectedColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              custom.selectedMaterial,
                              style: TextStyle(
                                color: custom.selectedColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (custom.personalizationText.isNotEmpty)
                              Text(
                                custom.personalizationText,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Price tag
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackground.withValues(alpha: 0.8),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            '\$${custom.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms);
              },
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: AppTheme.textTertiary,
                indicatorColor: AppTheme.primaryBlue,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Color'),
                  Tab(text: 'Material'),
                  Tab(text: 'Design'),
                  Tab(text: 'More'),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildColorTab(),
                  _buildMaterialTab(),
                  _buildDesignTab(),
                  _buildMoreTab(),
                ],
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: GradientButton(
                text: 'View 360° Preview',
                icon: Icons.threed_rotation_rounded,
                onPressed: () => context.go('/preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTab() {
    final presetColors = [
      const Color(0xFF2563EB),
      const Color(0xFF3B82F6),
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF22C55E),
      const Color(0xFF06B6D4),
      const Color(0xFFF97316),
      const Color(0xFF8B5CF6),
      const Color(0xFF14B8A6),
      const Color(0xFFE11D48),
      Colors.white,
      Colors.black,
      const Color(0xFF6B7280),
      const Color(0xFF1E3A5F),
      const Color(0xFF4A0E8F),
      const Color(0xFF831843),
      const Color(0xFF713F12),
      const Color(0xFF064E3B),
    ];

    return Consumer<CustomizationProvider>(
      builder: (context, custom, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: presetColors.map((color) {
                  final isSelected =
                      custom.selectedColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () => custom.setColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              // Custom color button
              OutlinedButton.icon(
                onPressed: _showColorPicker,
                icon: const Icon(Icons.color_lens_rounded,
                    color: AppTheme.primaryBlue),
                label: const Text('Custom Color (RGB)',
                    style: TextStyle(color: AppTheme.primaryBlue)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppTheme.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialTab() {
    return Consumer<CustomizationProvider>(
      builder: (context, custom, _) {
        final materialIcons = {
          'Leather': Icons.layers_rounded,
          'Silicone': Icons.water_drop_rounded,
          'Carbon Fiber': Icons.grid_4x4_rounded,
          'Fabric': Icons.texture_rounded,
          'Neoprene': Icons.science_rounded,
        };

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg),
          itemCount: custom.materials.length,
          itemBuilder: (context, index) {
            final material = custom.materials[index];
            final isSelected = custom.selectedMaterial == material;
            final price = custom.materialPrices[material] ?? 0;

            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: PremiumCard(
                isSelected: isSelected,
                onTap: () => custom.setMaterial(material),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isSelected
                                ? AppTheme.primaryBlue
                                : AppTheme.textTertiary)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd),
                      ),
                      child: Icon(
                        materialIcons[material] ??
                            Icons.layers_rounded,
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isSelected
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '\$$price',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primaryBlue, size: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesignTab() {
    return Consumer<CustomizationProvider>(
      builder: (context, custom, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pattern selection
              const Text(
                'Pattern',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: custom.patterns.map((pattern) {
                  final isSelected = custom.selectedPattern == pattern;
                  return ChoiceChip(
                    label: Text(pattern),
                    selected: isSelected,
                    onSelected: (_) => custom.setPattern(pattern),
                    selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    backgroundColor: AppTheme.cardBackground,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.cardBorder,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Personalization text
              const Text(
                'Personalization',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              const Text(
                'Add your name or initials',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _textController,
                maxLength: 15,
                onChanged: (value) =>
                    custom.setPersonalizationText(value),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Enter text (max 15 chars)',
                  prefixIcon: Icon(Icons.text_fields_rounded,
                      color: AppTheme.textTertiary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreTab() {
    return Consumer<CustomizationProvider>(
      builder: (context, custom, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fit Type
              const Text(
                'Fit Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: custom.fitTypes.map((fit) {
                  final isSelected = custom.selectedFitType == fit;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => custom.setFitType(fit),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                                : AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : AppTheme.cardBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              fit,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Strap Style
              const Text(
                'Strap Style',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              ...custom.strapStyles.map((strap) {
                final isSelected = custom.selectedStrapStyle == strap;
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: PremiumCard(
                    isSelected: isSelected,
                    onTap: () => custom.setStrapStyle(strap),
                    child: Row(
                      children: [
                        Icon(
                          strap == 'Velcro'
                              ? Icons.view_agenda_rounded
                              : strap == 'Buckle'
                                  ? Icons.lock_rounded
                                  : Icons.circle_outlined,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.textTertiary,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        Text(
                          strap,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppTheme.primaryBlue, size: 22),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

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

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width + size.height; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(0, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
