import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 3)
class OrderModel extends HiveObject {
  @HiveField(0)
  final String orderId;

  @HiveField(1)
  final String bodyPart;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final String material;

  @HiveField(4)
  final String pattern;

  @HiveField(5)
  final String personalizationText;

  @HiveField(6)
  final String fitType;

  @HiveField(7)
  final String strapStyle;

  @HiveField(8)
  final String shippingName;

  @HiveField(9)
  final String shippingAddress;

  @HiveField(10)
  final String shippingCity;

  @HiveField(11)
  final String shippingCountry;

  @HiveField(12)
  final String shippingZip;

  @HiveField(13)
  final String paymentStatus; // paid / pending / failed

  @HiveField(14)
  final DateTime orderDate;

  @HiveField(15)
  final double totalAmount;

  @HiveField(16)
  final String userId;

  @HiveField(17)
  final String scanId;

  OrderModel({
    required this.orderId,
    required this.bodyPart,
    required this.colorValue,
    required this.material,
    required this.pattern,
    required this.personalizationText,
    required this.fitType,
    required this.strapStyle,
    required this.shippingName,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingCountry,
    required this.shippingZip,
    required this.paymentStatus,
    required this.orderDate,
    required this.totalAmount,
    required this.userId,
    required this.scanId,
  });
}
