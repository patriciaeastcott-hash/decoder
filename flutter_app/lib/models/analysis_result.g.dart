// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisResultAdapter extends TypeAdapter<AnalysisResult> {
  @override
  final int typeId = 4;

  @override
  AnalysisResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisResult(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      summary: fields[2] as String,
      powerDynamics: fields[3] as PowerDynamics?,
      speakerAnalyses: (fields[4] as List).cast<SpeakerAnalysis>(),
      relationshipDynamics: fields[5] as RelationshipDynamics?,
      manipulationCheck: fields[6] as ManipulationCheck?,
      actionableInsights: (fields[7] as List).cast<ActionableInsight>(),
      conversationHealthScore: fields[8] as int,
      followUpQuestions: (fields[9] as List).cast<String>(),
      analyzedAt: fields[10] as DateTime,
      rawResponse: (fields[11] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisResult obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.powerDynamics)
      ..writeByte(4)
      ..write(obj.speakerAnalyses)
      ..writeByte(5)
      ..write(obj.relationshipDynamics)
      ..writeByte(6)
      ..write(obj.manipulationCheck)
      ..writeByte(7)
      ..write(obj.actionableInsights)
      ..writeByte(8)
      ..write(obj.conversationHealthScore)
      ..writeByte(9)
      ..write(obj.followUpQuestions)
      ..writeByte(10)
      ..write(obj.analyzedAt)
      ..writeByte(11)
      ..write(obj.rawResponse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PowerDynamicsAdapter extends TypeAdapter<PowerDynamics> {
  @override
  final int typeId = 5;

  @override
  PowerDynamics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PowerDynamics(
      assessment: fields[0] as String,
      indicators: (fields[1] as List).cast<String>(),
      balanceScore: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PowerDynamics obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.assessment)
      ..writeByte(1)
      ..write(obj.indicators)
      ..writeByte(2)
      ..write(obj.balanceScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PowerDynamicsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpeakerAnalysisAdapter extends TypeAdapter<SpeakerAnalysis> {
  @override
  final int typeId = 6;

  @override
  SpeakerAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpeakerAnalysis(
      speakerId: fields[0] as String,
      speakerName: fields[1] as String,
      communicationStyle: fields[2] as CommunicationStyle?,
      emotionalPatterns: fields[3] as EmotionalPatterns?,
      attachmentIndicators: fields[4] as AttachmentIndicators?,
      behaviorsExhibited: (fields[5] as List).cast<BehaviorExhibited>(),
      strengths: (fields[6] as List).cast<String>(),
      growthAreas: (fields[7] as List).cast<String>(),
      redFlags: (fields[8] as List).cast<String>(),
      greenFlags: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SpeakerAnalysis obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.speakerId)
      ..writeByte(1)
      ..write(obj.speakerName)
      ..writeByte(2)
      ..write(obj.communicationStyle)
      ..writeByte(3)
      ..write(obj.emotionalPatterns)
      ..writeByte(4)
      ..write(obj.attachmentIndicators)
      ..writeByte(5)
      ..write(obj.behaviorsExhibited)
      ..writeByte(6)
      ..write(obj.strengths)
      ..writeByte(7)
      ..write(obj.growthAreas)
      ..writeByte(8)
      ..write(obj.redFlags)
      ..writeByte(9)
      ..write(obj.greenFlags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeakerAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommunicationStyleAdapter extends TypeAdapter<CommunicationStyle> {
  @override
  final int typeId = 7;

  @override
  CommunicationStyle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunicationStyle(
      primary: fields[0] as String,
      examples: (fields[1] as List).cast<String>(),
      effectivenessScore: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CommunicationStyle obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.primary)
      ..writeByte(1)
      ..write(obj.examples)
      ..writeByte(2)
      ..write(obj.effectivenessScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmotionalPatternsAdapter extends TypeAdapter<EmotionalPatterns> {
  @override
  final int typeId = 8;

  @override
  EmotionalPatterns read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionalPatterns(
      regulationLevel: fields[0] as String,
      triggersObserved: (fields[1] as List).cast<String>(),
      copingMechanisms: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, EmotionalPatterns obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.regulationLevel)
      ..writeByte(1)
      ..write(obj.triggersObserved)
      ..writeByte(2)
      ..write(obj.copingMechanisms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionalPatternsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttachmentIndicatorsAdapter extends TypeAdapter<AttachmentIndicators> {
  @override
  final int typeId = 9;

  @override
  AttachmentIndicators read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttachmentIndicators(
      likelyStyle: fields[0] as String,
      evidence: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AttachmentIndicators obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.likelyStyle)
      ..writeByte(1)
      ..write(obj.evidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentIndicatorsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BehaviorExhibitedAdapter extends TypeAdapter<BehaviorExhibited> {
  @override
  final int typeId = 10;

  @override
  BehaviorExhibited read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BehaviorExhibited(
      behaviorId: fields[0] as String,
      behaviorName: fields[1] as String,
      examples: (fields[2] as List).cast<String>(),
      frequency: fields[3] as String,
      impact: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BehaviorExhibited obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.behaviorId)
      ..writeByte(1)
      ..write(obj.behaviorName)
      ..writeByte(2)
      ..write(obj.examples)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.impact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BehaviorExhibitedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RelationshipDynamicsAdapter extends TypeAdapter<RelationshipDynamics> {
  @override
  final int typeId = 11;

  @override
  RelationshipDynamics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RelationshipDynamics(
      overallHealth: fields[0] as String,
      patterns: (fields[1] as List).cast<String>(),
      conflictStyle: fields[2] as String,
      resolutionPotential: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RelationshipDynamics obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.overallHealth)
      ..writeByte(1)
      ..write(obj.patterns)
      ..writeByte(2)
      ..write(obj.conflictStyle)
      ..writeByte(3)
      ..write(obj.resolutionPotential);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationshipDynamicsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ManipulationCheckAdapter extends TypeAdapter<ManipulationCheck> {
  @override
  final int typeId = 12;

  @override
  ManipulationCheck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManipulationCheck(
      detected: fields[0] as bool,
      types: (fields[1] as List).cast<String>(),
      examples: (fields[2] as List).cast<String>(),
      severity: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ManipulationCheck obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.detected)
      ..writeByte(1)
      ..write(obj.types)
      ..writeByte(2)
      ..write(obj.examples)
      ..writeByte(3)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManipulationCheckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActionableInsightAdapter extends TypeAdapter<ActionableInsight> {
  @override
  final int typeId = 13;

  @override
  ActionableInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActionableInsight(
      forSpeaker: fields[0] as String,
      insight: fields[1] as String,
      suggestion: fields[2] as String,
      expectedOutcome: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActionableInsight obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.forSpeaker)
      ..writeByte(1)
      ..write(obj.insight)
      ..writeByte(2)
      ..write(obj.suggestion)
      ..writeByte(3)
      ..write(obj.expectedOutcome);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionableInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
