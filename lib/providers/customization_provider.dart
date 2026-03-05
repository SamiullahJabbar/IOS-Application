import 'package:flutter/material.dart';

class CustomizationProvider extends ChangeNotifier {
  Color _selectedColor = const Color(0xFF2563EB);
  String _selectedMaterial = 'Leather';
  String _selectedPattern = 'Plain';
  String _personalizationText = '';
  String _selectedFitType = 'Medium';
  String _selectedStrapStyle = 'Velcro';
  double _price = 149.99;

  Color get selectedColor => _selectedColor;
  String get selectedMaterial => _selectedMaterial;
  String get selectedPattern => _selectedPattern;
  String get personalizationText => _personalizationText;
  String get selectedFitType => _selectedFitType;
  String get selectedStrapStyle => _selectedStrapStyle;
  double get price => _price;

  final List<String> materials = [
    'Leather',
    'Silicone',
    'Carbon Fiber',
    'Fabric',
    'Neoprene',
  ];

  final List<String> patterns = [
    'Plain',
    'Stripes',
    'Geometric',
    'Carbon Weave',
  ];

  final List<String> fitTypes = [
    'Soft',
    'Medium',
    'Firm',
  ];

  final List<String> strapStyles = [
    'Velcro',
    'Buckle',
    'Slip-on',
  ];

  final Map<String, double> materialPrices = {
    'Leather': 149.99,
    'Silicone': 89.99,
    'Carbon Fiber': 199.99,
    'Fabric': 79.99,
    'Neoprene': 109.99,
  };

  void setColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void setMaterial(String material) {
    _selectedMaterial = material;
    _price = materialPrices[material] ?? 149.99;
    notifyListeners();
  }

  void setPattern(String pattern) {
    _selectedPattern = pattern;
    notifyListeners();
  }

  void setPersonalizationText(String text) {
    _personalizationText = text;
    notifyListeners();
  }

  void setFitType(String fitType) {
    _selectedFitType = fitType;
    notifyListeners();
  }

  void setStrapStyle(String strapStyle) {
    _selectedStrapStyle = strapStyle;
    notifyListeners();
  }

  void resetCustomization() {
    _selectedColor = const Color(0xFF2563EB);
    _selectedMaterial = 'Leather';
    _selectedPattern = 'Plain';
    _personalizationText = '';
    _selectedFitType = 'Medium';
    _selectedStrapStyle = 'Velcro';
    _price = 149.99;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'colorValue': _selectedColor.toARGB32(),
      'material': _selectedMaterial,
      'pattern': _selectedPattern,
      'personalizationText': _personalizationText,
      'fitType': _selectedFitType,
      'strapStyle': _selectedStrapStyle,
      'price': _price,
    };
  }
}
