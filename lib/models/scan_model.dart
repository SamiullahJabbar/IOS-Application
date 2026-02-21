import 'package:hive/hive.dart';

part 'scan_model.g.dart';

@HiveType(typeId: 1)
class ScanModel extends HiveObject {
  @HiveField(0)
  final String scanId;

  @HiveField(1)
  final String bodyPart;

  @HiveField(2)
  final DateTime scanDate;

  @HiveField(3)
  final String modelFilePath;

  @HiveField(4)
  final String status; // complete / incomplete

  @HiveField(5)
  final String userId;

  ScanModel({
    required this.scanId,
    required this.bodyPart,
    required this.scanDate,
    required this.modelFilePath,
    required this.status,
    required this.userId,
  });
}
