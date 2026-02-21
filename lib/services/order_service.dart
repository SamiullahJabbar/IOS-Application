import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';

class OrderService {
  static const String _orderBoxName = 'orders';

  static Future<Box<OrderModel>> _getOrderBox() async {
    if (!Hive.isBoxOpen(_orderBoxName)) {
      return await Hive.openBox<OrderModel>(_orderBoxName);
    }
    return Hive.box<OrderModel>(_orderBoxName);
  }

  static Future<OrderModel> createOrder({
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
    final box = await _getOrderBox();

    final order = OrderModel(
      orderId: 'ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}',
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
      paymentStatus: 'paid',
      orderDate: DateTime.now(),
      totalAmount: totalAmount,
      userId: userId,
      scanId: scanId,
    );

    await box.put(order.orderId, order);
    return order;
  }

  static Future<List<OrderModel>> getUserOrders(String userId) async {
    final box = await _getOrderBox();
    return box.values.where((order) => order.userId == userId).toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  static Future<int> getOrderCount(String userId) async {
    final box = await _getOrderBox();
    return box.values.where((order) => order.userId == userId).length;
  }

  static Future<OrderModel?> getOrder(String orderId) async {
    final box = await _getOrderBox();
    return box.get(orderId);
  }
}
