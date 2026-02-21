import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/scan_model.dart';

class ScanService {
  static const String _scanBoxName = 'scans';

  static Future<Box<ScanModel>> _getScanBox() async {
    if (!Hive.isBoxOpen(_scanBoxName)) {
      return await Hive.openBox<ScanModel>(_scanBoxName);
    }
    return Hive.box<ScanModel>(_scanBoxName);
  }

  static Future<ScanModel> saveScan({
    required String bodyPart,
    required String modelFilePath,
    required String userId,
  }) async {
    final box = await _getScanBox();

    final scan = ScanModel(
      scanId: const Uuid().v4(),
      bodyPart: bodyPart,
      scanDate: DateTime.now(),
      modelFilePath: modelFilePath,
      status: 'complete',
      userId: userId,
    );

    await box.put(scan.scanId, scan);
    return scan;
  }

  static Future<List<ScanModel>> getUserScans(String userId) async {
    final box = await _getScanBox();
    return box.values.where((scan) => scan.userId == userId).toList()
      ..sort((a, b) => b.scanDate.compareTo(a.scanDate));
  }

  static Future<ScanModel?> getScan(String scanId) async {
    final box = await _getScanBox();
    return box.get(scanId);
  }

  static Future<int> getScanCount(String userId) async {
    final box = await _getScanBox();
    return box.values.where((scan) => scan.userId == userId).length;
  }

  static Future<void> deleteScan(String scanId) async {
    final box = await _getScanBox();
    await box.delete(scanId);
  }
}
