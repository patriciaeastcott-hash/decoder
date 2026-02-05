// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speaker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpeakerAdapter extends TypeAdapter<Speaker> {
  @override
  final int typeId = 1;

  @override
  Speaker read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Speaker(
      id: fields[0] as String,
      name: fields[1] as String,
      displayName: fields[2] as String?,
      colorValue: fields[3] as int,
      isUser: fields[4] as bool,
      profileId: fields[5] as String?,
      avatarUrl: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      metadata: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Speaker obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.isUser)
      ..writeByte(5)
      ..write(obj.profileId)
      ..writeByte(6)
      ..write(obj.avatarUrl)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
