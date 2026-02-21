// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customization_model.dart';

class CustomizationModelAdapter extends TypeAdapter<CustomizationModel> {
  @override
  final int typeId = 2;

  @override
  CustomizationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomizationModel(
      colorValue: fields[0] as int,
      material: fields[1] as String,
      pattern: fields[2] as String,
      personalizationText: fields[3] as String,
      fitType: fields[4] as String,
      strapStyle: fields[5] as String,
      scanId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomizationModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.colorValue)
      ..writeByte(1)
      ..write(obj.material)
      ..writeByte(2)
      ..write(obj.pattern)
      ..writeByte(3)
      ..write(obj.personalizationText)
      ..writeByte(4)
      ..write(obj.fitType)
      ..writeByte(5)
      ..write(obj.strapStyle)
      ..writeByte(6)
      ..write(obj.scanId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomizationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
