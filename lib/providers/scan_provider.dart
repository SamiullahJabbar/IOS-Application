import 'package:flutter/material.dart';
import '../models/scan_model.dart';
import '../services/scan_service.dart';

class ScanProvider extends ChangeNotifier {
  String? _selectedBodyPart;
  ScanModel? _currentScan;
  List<ScanModel> _userScans = [];
  bool _isScanning = false;
  double _scanProgress = 0.0;
  bool _isProcessing = false;
  final List<String> _capturedImages = [];

  String? get selectedBodyPart => _selectedBodyPart;
  ScanModel? get currentScan => _currentScan;
  List<ScanModel> get userScans => _userScans;
  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  bool get isProcessing => _isProcessing;
  List<String> get capturedImages => _capturedImages;
  String? get primaryImage =>
      _capturedImages.isNotEmpty ? _capturedImages.last : null;

  void selectBodyPart(String bodyPart) {
    _selectedBodyPart = bodyPart;
    _capturedImages.clear();
    _currentScan = null;
    _scanProgress = 0.0;
    _isProcessing = false;
    _isScanning = false;
    notifyListeners();
  }

  void startScanning() {
    _isScanning = true;
    _scanProgress = 0.0;
    _capturedImages.clear();
    notifyListeners();
  }

  void updateProgress(double progress) {
    _scanProgress = progress;
    notifyListeners();
  }

  void startProcessing() {
    _isProcessing = true;
    _isScanning = false;
    notifyListeners();
  }

  void addCapturedImage(String path) {
    _capturedImages.add(path);
    notifyListeners();
  }

  Future<ScanModel> completeScan(String userId) async {
    _isProcessing = false;

    final scan = await ScanService.saveScan(
      bodyPart: _selectedBodyPart!,
      modelFilePath: primaryImage ?? '',
      userId: userId,
    );

    _currentScan = scan;
    await loadUserScans(userId);
    notifyListeners();
    return scan;
  }

  Future<void> loadUserScans(String userId) async {
    _userScans = await ScanService.getUserScans(userId);
    notifyListeners();
  }

  void clearCurrentSession() {
    _selectedBodyPart = null;
    _currentScan = null;
    _isScanning = false;
    _scanProgress = 0.0;
    _isProcessing = false;
    _capturedImages.clear();
    notifyListeners();
  }

  void setCurrentScan(ScanModel scan) {
    _currentScan = scan;
    _selectedBodyPart = scan.bodyPart;
    notifyListeners();
  }
}
