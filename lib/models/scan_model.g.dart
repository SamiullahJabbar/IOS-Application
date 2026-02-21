// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_model.dart';

class ScanModelAdapter extends TypeAdapter<ScanModel> {
  @override
  final int typeId = 1;

  @override
  ScanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanModel(
      scanId: fields[0] as String,
      bodyPart: fields[1] as String,
      scanDate: fields[2] as DateTime,
      modelFilePath: fields[3] as String,
      status: fields[4] as String,
      userId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScanModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.scanId)
      ..writeByte(1)
      ..write(obj.bodyPart)
      ..writeByte(2)
      ..write(obj.scanDate)
      ..writeByte(3)
      ..write(obj.modelFilePath)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
