import 'package:hive/hive.dart';

part 'customization_model.g.dart';

@HiveType(typeId: 2)
class CustomizationModel extends HiveObject {
  @HiveField(0)
  final int colorValue; // Color stored as int

  @HiveField(1)
  final String material; // Leather, Silicone, Carbon Fiber, Fabric, Neoprene

  @HiveField(2)
  final String pattern; // Plain, Stripes, Geometric, Carbon Weave

  @HiveField(3)
  final String personalizationText; // Custom name/initials

  @HiveField(4)
  final String fitType; // Soft, Medium, Firm

  @HiveField(5)
  final String strapStyle; // Velcro, Buckle, Slip-on

  @HiveField(6)
  final String scanId;

  CustomizationModel({
    required this.colorValue,
    required this.material,
    required this.pattern,
    required this.personalizationText,
    required this.fitType,
    required this.strapStyle,
    required this.scanId,
  });
}
