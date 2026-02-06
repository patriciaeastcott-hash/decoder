// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 2;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      messages: (fields[3] as List).cast<Message>(),
      speakers: (fields[4] as List).cast<Speaker>(),
      rawText: fields[5] as String,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      status: fields[8] as ConversationStatus,
      analysis: fields[9] as AnalysisResult?,
      speakersVerified: fields[10] as bool,
      sourceType: fields[11] as String?,
      metadata: (fields[12] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.messages)
      ..writeByte(4)
      ..write(obj.speakers)
      ..writeByte(5)
      ..write(obj.rawText)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.analysis)
      ..writeByte(10)
      ..write(obj.speakersVerified)
      ..writeByte(11)
      ..write(obj.sourceType)
      ..writeByte(12)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationStatusAdapter extends TypeAdapter<ConversationStatus> {
  @override
  final int typeId = 3;

  @override
  ConversationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConversationStatus.draft;
      case 1:
        return ConversationStatus.speakersIdentified;
      case 2:
        return ConversationStatus.speakersVerified;
      case 3:
        return ConversationStatus.analyzing;
      case 4:
        return ConversationStatus.analyzed;
      case 5:
        return ConversationStatus.error;
      default:
        return ConversationStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, ConversationStatus obj) {
    switch (obj) {
      case ConversationStatus.draft:
        writer.writeByte(0);
        break;
      case ConversationStatus.speakersIdentified:
        writer.writeByte(1);
        break;
      case ConversationStatus.speakersVerified:
        writer.writeByte(2);
        break;
      case ConversationStatus.analyzing:
        writer.writeByte(3);
        break;
      case ConversationStatus.analyzed:
        writer.writeByte(4);
        break;
      case ConversationStatus.error:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
