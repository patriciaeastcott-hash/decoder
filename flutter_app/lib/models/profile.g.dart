// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 14;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      id: fields[0] as String,
      name: fields[1] as String,
      displayName: fields[2] as String?,
      isUserProfile: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      expiresAt: fields[6] as DateTime?,
      retentionMonths: fields[7] as int,
      conversationIds: (fields[8] as List).cast<String>(),
      analysis: fields[9] as ProfileAnalysis?,
      summary: fields[10] as ProfileSummary?,
      metadata: (fields[11] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.isUserProfile)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.expiresAt)
      ..writeByte(7)
      ..write(obj.retentionMonths)
      ..writeByte(8)
      ..write(obj.conversationIds)
      ..writeByte(9)
      ..write(obj.analysis)
      ..writeByte(10)
      ..write(obj.summary)
      ..writeByte(11)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfileAnalysisAdapter extends TypeAdapter<ProfileAnalysis> {
  @override
  final int typeId = 15;

  @override
  ProfileAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileAnalysis(
      profileSummary: fields[0] as String,
      communicationProfile: fields[1] as CommunicationProfile?,
      emotionalProfile: fields[2] as EmotionalProfile?,
      behavioralPatterns: fields[3] as BehavioralPatterns?,
      attachmentProfile: fields[4] as AttachmentProfile?,
      conflictProfile: fields[5] as ConflictProfile?,
      strengths: (fields[6] as List).cast<ProfileStrength>(),
      growthOpportunities: (fields[7] as List).cast<GrowthOpportunity>(),
      communicationRecommendations: fields[8] as CommunicationRecommendations?,
      redFlagsSummary: (fields[9] as List).cast<String>(),
      greenFlagsSummary: (fields[10] as List).cast<String>(),
      overallAssessment: fields[11] as String,
      analyzedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileAnalysis obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.profileSummary)
      ..writeByte(1)
      ..write(obj.communicationProfile)
      ..writeByte(2)
      ..write(obj.emotionalProfile)
      ..writeByte(3)
      ..write(obj.behavioralPatterns)
      ..writeByte(4)
      ..write(obj.attachmentProfile)
      ..writeByte(5)
      ..write(obj.conflictProfile)
      ..writeByte(6)
      ..write(obj.strengths)
      ..writeByte(7)
      ..write(obj.growthOpportunities)
      ..writeByte(8)
      ..write(obj.communicationRecommendations)
      ..writeByte(9)
      ..write(obj.redFlagsSummary)
      ..writeByte(10)
      ..write(obj.greenFlagsSummary)
      ..writeByte(11)
      ..write(obj.overallAssessment)
      ..writeByte(12)
      ..write(obj.analyzedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfileSummaryAdapter extends TypeAdapter<ProfileSummary> {
  @override
  final int typeId = 16;

  @override
  ProfileSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileSummary(
      dominantCommunicationStyle: fields[0] as String,
      attachmentStyle: fields[1] as String,
      emotionalRegulation: fields[2] as String,
      overallHealthScore: fields[3] as int,
      topBehaviors: (fields[4] as List).cast<String>(),
      lastUpdated: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileSummary obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dominantCommunicationStyle)
      ..writeByte(1)
      ..write(obj.attachmentStyle)
      ..writeByte(2)
      ..write(obj.emotionalRegulation)
      ..writeByte(3)
      ..write(obj.overallHealthScore)
      ..writeByte(4)
      ..write(obj.topBehaviors)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommunicationProfileAdapter extends TypeAdapter<CommunicationProfile> {
  @override
  final int typeId = 17;

  @override
  CommunicationProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunicationProfile(
      dominantStyle: fields[0] as String,
      secondaryStyles: (fields[1] as List).cast<String>(),
      styleConsistency: fields[2] as String,
      adaptability: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CommunicationProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dominantStyle)
      ..writeByte(1)
      ..write(obj.secondaryStyles)
      ..writeByte(2)
      ..write(obj.styleConsistency)
      ..writeByte(3)
      ..write(obj.adaptability);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmotionalProfileAdapter extends TypeAdapter<EmotionalProfile> {
  @override
  final int typeId = 18;

  @override
  EmotionalProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionalProfile(
      baselineRegulation: fields[0] as String,
      commonTriggers: (fields[1] as List).cast<String>(),
      healthyCopingStrategies: (fields[2] as List).cast<String>(),
      unhealthyCopingStrategies: (fields[3] as List).cast<String>(),
      emotionalIntelligenceIndicators: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionalProfile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.baselineRegulation)
      ..writeByte(1)
      ..write(obj.commonTriggers)
      ..writeByte(2)
      ..write(obj.healthyCopingStrategies)
      ..writeByte(3)
      ..write(obj.unhealthyCopingStrategies)
      ..writeByte(4)
      ..write(obj.emotionalIntelligenceIndicators);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionalProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BehavioralPatternsAdapter extends TypeAdapter<BehavioralPatterns> {
  @override
  final int typeId = 19;

  @override
  BehavioralPatterns read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BehavioralPatterns(
      frequentBehaviors: (fields[0] as List).cast<FrequentBehavior>(),
      rareBehaviors: (fields[1] as List).cast<String>(),
      evolvingPatterns: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BehavioralPatterns obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.frequentBehaviors)
      ..writeByte(1)
      ..write(obj.rareBehaviors)
      ..writeByte(2)
      ..write(obj.evolvingPatterns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BehavioralPatternsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FrequentBehaviorAdapter extends TypeAdapter<FrequentBehavior> {
  @override
  final int typeId = 20;

  @override
  FrequentBehavior read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FrequentBehavior(
      behavior: fields[0] as String,
      frequency: fields[1] as String,
      contexts: fields[2] as String,
      impact: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FrequentBehavior obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.behavior)
      ..writeByte(1)
      ..write(obj.frequency)
      ..writeByte(2)
      ..write(obj.contexts)
      ..writeByte(3)
      ..write(obj.impact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrequentBehaviorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttachmentProfileAdapter extends TypeAdapter<AttachmentProfile> {
  @override
  final int typeId = 21;

  @override
  AttachmentProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttachmentProfile(
      primaryStyle: fields[0] as String,
      triggersForInsecurity: (fields[1] as List).cast<String>(),
      secureBaseBehaviors: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AttachmentProfile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.primaryStyle)
      ..writeByte(1)
      ..write(obj.triggersForInsecurity)
      ..writeByte(2)
      ..write(obj.secureBaseBehaviors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConflictProfileAdapter extends TypeAdapter<ConflictProfile> {
  @override
  final int typeId = 22;

  @override
  ConflictProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConflictProfile(
      approach: fields[0] as String,
      strengthsInConflict: (fields[1] as List).cast<String>(),
      challengesInConflict: (fields[2] as List).cast<String>(),
      resolutionPatterns: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConflictProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.approach)
      ..writeByte(1)
      ..write(obj.strengthsInConflict)
      ..writeByte(2)
      ..write(obj.challengesInConflict)
      ..writeByte(3)
      ..write(obj.resolutionPatterns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfileStrengthAdapter extends TypeAdapter<ProfileStrength> {
  @override
  final int typeId = 23;

  @override
  ProfileStrength read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileStrength(
      strength: fields[0] as String,
      evidence: fields[1] as String,
      impact: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileStrength obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.strength)
      ..writeByte(1)
      ..write(obj.evidence)
      ..writeByte(2)
      ..write(obj.impact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileStrengthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GrowthOpportunityAdapter extends TypeAdapter<GrowthOpportunity> {
  @override
  final int typeId = 24;

  @override
  GrowthOpportunity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthOpportunity(
      area: fields[0] as String,
      currentPattern: fields[1] as String,
      suggestedGrowth: fields[2] as String,
      resources: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthOpportunity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.area)
      ..writeByte(1)
      ..write(obj.currentPattern)
      ..writeByte(2)
      ..write(obj.suggestedGrowth)
      ..writeByte(3)
      ..write(obj.resources);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthOpportunityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommunicationRecommendationsAdapter
    extends TypeAdapter<CommunicationRecommendations> {
  @override
  final int typeId = 25;

  @override
  CommunicationRecommendations read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommunicationRecommendations(
      bestApproaches: (fields[0] as List).cast<String>(),
      topicsToApproachCarefully: (fields[1] as List).cast<String>(),
      conflictResolutionStrategies: (fields[2] as List).cast<String>(),
      relationshipPotential: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CommunicationRecommendations obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bestApproaches)
      ..writeByte(1)
      ..write(obj.topicsToApproachCarefully)
      ..writeByte(2)
      ..write(obj.conflictResolutionStrategies)
      ..writeByte(3)
      ..write(obj.relationshipPotential);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunicationRecommendationsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
