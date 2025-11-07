// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreferenceModelAdapter extends TypeAdapter<PreferenceModel> {
  @override
  final int typeId = 0;

  @override
  PreferenceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PreferenceModel(
      id: fields[0] as String,
      teamId: fields[1] as int,
      teamName: fields[2] as String,
      customName: fields[3] as String,
      logoUrl: fields[4] as String,
      city: fields[5] as String,
      country: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PreferenceModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.teamId)
      ..writeByte(2)
      ..write(obj.teamName)
      ..writeByte(3)
      ..write(obj.customName)
      ..writeByte(4)
      ..write(obj.logoUrl)
      ..writeByte(5)
      ..write(obj.city)
      ..writeByte(6)
      ..write(obj.country)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferenceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
