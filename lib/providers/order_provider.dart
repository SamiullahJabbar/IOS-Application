import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _userOrders = [];
  OrderModel? _currentOrder;
  bool _isProcessing = false;

  List<OrderModel> get userOrders => _userOrders;
  OrderModel? get currentOrder => _currentOrder;
  bool get isProcessing => _isProcessing;

  Future<void> loadUserOrders(String userId) async {
    _userOrders = await OrderService.getUserOrders(userId);
    notifyListeners();
  }

  Future<OrderModel> createOrder({
    required String bodyPart,
    required int colorValue,
    required String material,
    required String pattern,
    required String personalizationText,
    required String fitType,
    required String strapStyle,
    required String shippingName,
    required String shippingAddress,
    required String shippingCity,
    required String shippingCountry,
    required String shippingZip,
    required double totalAmount,
    required String userId,
    required String scanId,
  }) async {
    _isProcessing = true;
    notifyListeners();

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    final order = await OrderService.createOrder(
      bodyPart: bodyPart,
      colorValue: colorValue,
      material: material,
      pattern: pattern,
      personalizationText: personalizationText,
      fitType: fitType,
      strapStyle: strapStyle,
      shippingName: shippingName,
      shippingAddress: shippingAddress,
      shippingCity: shippingCity,
      shippingCountry: shippingCountry,
      shippingZip: shippingZip,
      totalAmount: totalAmount,
      userId: userId,
      scanId: scanId,
    );

    _currentOrder = order;
    _isProcessing = false;
    await loadUserOrders(userId);
    notifyListeners();
    return order;
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}
