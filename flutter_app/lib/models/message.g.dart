// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 0;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      text: fields[1] as String,
      speakerId: fields[2] as String,
      speakerName: fields[3] as String?,
      timestamp: fields[4] as DateTime?,
      confidenceScore: fields[5] as double,
      reasoning: fields[6] as String?,
      isVerified: fields[7] as bool,
      orderIndex: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.speakerId)
      ..writeByte(3)
      ..write(obj.speakerName)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.confidenceScore)
      ..writeByte(6)
      ..write(obj.reasoning)
      ..writeByte(7)
      ..write(obj.isVerified)
      ..writeByte(8)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
