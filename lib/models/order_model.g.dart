// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 3;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      orderId: fields[0] as String,
      bodyPart: fields[1] as String,
      colorValue: fields[2] as int,
      material: fields[3] as String,
      pattern: fields[4] as String,
      personalizationText: fields[5] as String,
      fitType: fields[6] as String,
      strapStyle: fields[7] as String,
      shippingName: fields[8] as String,
      shippingAddress: fields[9] as String,
      shippingCity: fields[10] as String,
      shippingCountry: fields[11] as String,
      shippingZip: fields[12] as String,
      paymentStatus: fields[13] as String,
      orderDate: fields[14] as DateTime,
      totalAmount: fields[15] as double,
      userId: fields[16] as String,
      scanId: fields[17] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.bodyPart)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.material)
      ..writeByte(4)
      ..write(obj.pattern)
      ..writeByte(5)
      ..write(obj.personalizationText)
      ..writeByte(6)
      ..write(obj.fitType)
      ..writeByte(7)
      ..write(obj.strapStyle)
      ..writeByte(8)
      ..write(obj.shippingName)
      ..writeByte(9)
      ..write(obj.shippingAddress)
      ..writeByte(10)
      ..write(obj.shippingCity)
      ..writeByte(11)
      ..write(obj.shippingCountry)
      ..writeByte(12)
      ..write(obj.shippingZip)
      ..writeByte(13)
      ..write(obj.paymentStatus)
      ..writeByte(14)
      ..write(obj.orderDate)
      ..writeByte(15)
      ..write(obj.totalAmount)
      ..writeByte(16)
      ..write(obj.userId)
      ..writeByte(17)
      ..write(obj.scanId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
