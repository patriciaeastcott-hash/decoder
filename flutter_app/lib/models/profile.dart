/// Profile model for speaker profiles built over time

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 14)
class Profile extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final bool isUserProfile;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final DateTime? expiresAt;

  @HiveField(7)
  final int retentionMonths;

  @HiveField(8)
  final List<String> conversationIds;

  @HiveField(9)
  final ProfileAnalysis? analysis;

  @HiveField(10)
  final ProfileSummary? summary;

  @HiveField(11)
  final Map<String, dynamic>? metadata;

  const Profile({
    required this.id,
    required this.name,
    this.displayName,
    this.isUserProfile = false,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.retentionMonths = 12,
    this.conversationIds = const [],
    this.analysis,
    this.summary,
    this.metadata,
  });

  /// Number of conversations associated with this profile
  int get conversationCount => conversationIds.length;

  /// Check if profile has enough data for meaningful analysis
  bool get hasEnoughDataForAnalysis => conversationIds.length >= 3;

  /// Days until expiry
  int? get daysUntilExpiry {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  Profile copyWith({
    String? id,
    String? name,
    String? displayName,
    bool? isUserProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    int? retentionMonths,
    List<String>? conversationIds,
    ProfileAnalysis? analysis,
    ProfileSummary? summary,
    Map<String, dynamic>? metadata,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      isUserProfile: isUserProfile ?? this.isUserProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      retentionMonths: retentionMonths ?? this.retentionMonths,
      conversationIds: conversationIds ?? this.conversationIds,
      analysis: analysis ?? this.analysis,
      summary: summary ?? this.summary,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String?,
      isUserProfile: json['is_user_profile'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      retentionMonths: json['retention_months'] as int? ?? 12,
      conversationIds: (json['conversation_ids'] as List<dynamic>?)
              ?.map((c) => c as String)
              .toList() ??
          [],
      analysis: json['analysis'] != null
          ? ProfileAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] != null
          ? ProfileSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'is_user_profile': isUserProfile,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'retention_months': retentionMonths,
      'conversation_ids': conversationIds,
      'analysis': analysis?.toJson(),
      'summary': summary?.toJson(),
      'metadata': metadata,
    };
  }

  /// Create a new profile for a speaker
  factory Profile.forSpeaker(String speakerId, String name, {int retentionMonths = 12}) {
    final now = DateTime.now();
    return Profile(
      id: 'profile_$speakerId',
      name: name,
      isUserProfile: false,
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(Duration(days: retentionMonths * 30)),
      retentionMonths: retentionMonths,
    );
  }

  /// Create user's self profile
  factory Profile.forUser(String userId, String name) {
    final now = DateTime.now();
    return Profile(
      id: 'profile_user_$userId',
      name: name,
      isUserProfile: true,
      createdAt: now,
      updatedAt: now,
      retentionMonths: 0, // User profile doesn't expire
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        isUserProfile,
        createdAt,
        updatedAt,
        expiresAt,
        retentionMonths,
        conversationIds,
        analysis,
        summary,
      ];

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, conversations: ${conversationIds.length})';
  }
}

@HiveType(typeId: 15)
class ProfileAnalysis extends Equatable {
  @HiveField(0)
  final String profileSummary;

  @HiveField(1)
  final CommunicationProfile? communicationProfile;

  @HiveField(2)
  final EmotionalProfile? emotionalProfile;

  @HiveField(3)
  final BehavioralPatterns? behavioralPatterns;

  @HiveField(4)
  final AttachmentProfile? attachmentProfile;

  @HiveField(5)
  final ConflictProfile? conflictProfile;

  @HiveField(6)
  final List<ProfileStrength> strengths;

  @HiveField(7)
  final List<GrowthOpportunity> growthOpportunities;

  @HiveField(8)
  final CommunicationRecommendations? communicationRecommendations;

  @HiveField(9)
  final List<String> redFlagsSummary;

  @HiveField(10)
  final List<String> greenFlagsSummary;

  @HiveField(11)
  final String overallAssessment;

  @HiveField(12)
  final DateTime analyzedAt;

  const ProfileAnalysis({
    required this.profileSummary,
    this.communicationProfile,
    this.emotionalProfile,
    this.behavioralPatterns,
    this.attachmentProfile,
    this.conflictProfile,
    this.strengths = const [],
    this.growthOpportunities = const [],
    this.communicationRecommendations,
    this.redFlagsSummary = const [],
    this.greenFlagsSummary = const [],
    this.overallAssessment = '',
    required this.analyzedAt,
  });

  factory ProfileAnalysis.fromJson(Map<String, dynamic> json) {
    return ProfileAnalysis(
      profileSummary: json['profile_summary'] as String? ?? '',
      communicationProfile: json['communication_profile'] != null
          ? CommunicationProfile.fromJson(
              json['communication_profile'] as Map<String, dynamic>)
          : null,
      emotionalProfile: json['emotional_profile'] != null
          ? EmotionalProfile.fromJson(
              json['emotional_profile'] as Map<String, dynamic>)
          : null,
      behavioralPatterns: json['behavioral_patterns'] != null
          ? BehavioralPatterns.fromJson(
              json['behavioral_patterns'] as Map<String, dynamic>)
          : null,
      attachmentProfile: json['attachment_profile'] != null
          ? AttachmentProfile.fromJson(
              json['attachment_profile'] as Map<String, dynamic>)
          : null,
      conflictProfile: json['conflict_profile'] != null
          ? ConflictProfile.fromJson(
              json['conflict_profile'] as Map<String, dynamic>)
          : null,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((s) => ProfileStrength.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      growthOpportunities: (json['growth_opportunities'] as List<dynamic>?)
              ?.map((g) => GrowthOpportunity.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      communicationRecommendations: json['communication_recommendations'] != null
          ? CommunicationRecommendations.fromJson(
              json['communication_recommendations'] as Map<String, dynamic>)
          : null,
      redFlagsSummary: (json['red_flags_summary'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
      greenFlagsSummary: (json['green_flags_summary'] as List<dynamic>?)
              ?.map((g) => g as String)
              .toList() ??
          [],
      overallAssessment: json['overall_assessment'] as String? ?? '',
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.parse(json['analyzed_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_summary': profileSummary,
      'communication_profile': communicationProfile?.toJson(),
      'emotional_profile': emotionalProfile?.toJson(),
      'behavioral_patterns': behavioralPatterns?.toJson(),
      'attachment_profile': attachmentProfile?.toJson(),
      'conflict_profile': conflictProfile?.toJson(),
      'strengths': strengths.map((s) => s.toJson()).toList(),
      'growth_opportunities': growthOpportunities.map((g) => g.toJson()).toList(),
      'communication_recommendations': communicationRecommendations?.toJson(),
      'red_flags_summary': redFlagsSummary,
      'green_flags_summary': greenFlagsSummary,
      'overall_assessment': overallAssessment,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        profileSummary,
        communicationProfile,
        emotionalProfile,
        behavioralPatterns,
        attachmentProfile,
        conflictProfile,
        strengths,
        growthOpportunities,
        communicationRecommendations,
        redFlagsSummary,
        greenFlagsSummary,
        overallAssessment,
        analyzedAt,
      ];
}

@HiveType(typeId: 16)
class ProfileSummary extends Equatable {
  @HiveField(0)
  final String dominantCommunicationStyle;

  @HiveField(1)
  final String attachmentStyle;

  @HiveField(2)
  final String emotionalRegulation;

  @HiveField(3)
  final int overallHealthScore;

  @HiveField(4)
  final List<String> topBehaviors;

  @HiveField(5)
  final DateTime lastUpdated;

  const ProfileSummary({
    this.dominantCommunicationStyle = 'Unknown',
    this.attachmentStyle = 'Unknown',
    this.emotionalRegulation = 'Unknown',
    this.overallHealthScore = 50,
    this.topBehaviors = const [],
    required this.lastUpdated,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      dominantCommunicationStyle:
          json['dominant_communication_style'] as String? ?? 'Unknown',
      attachmentStyle: json['attachment_style'] as String? ?? 'Unknown',
      emotionalRegulation: json['emotional_regulation'] as String? ?? 'Unknown',
      overallHealthScore: json['overall_health_score'] as int? ?? 50,
      topBehaviors: (json['top_behaviors'] as List<dynamic>?)
              ?.map((b) => b as String)
              .toList() ??
          [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dominant_communication_style': dominantCommunicationStyle,
      'attachment_style': attachmentStyle,
      'emotional_regulation': emotionalRegulation,
      'overall_health_score': overallHealthScore,
      'top_behaviors': topBehaviors,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        dominantCommunicationStyle,
        attachmentStyle,
        emotionalRegulation,
        overallHealthScore,
        topBehaviors,
        lastUpdated,
      ];
}

// Supporting classes for ProfileAnalysis

@HiveType(typeId: 17)
class CommunicationProfile extends Equatable {
  @HiveField(0)
  final String dominantStyle;

  @HiveField(1)
  final List<String> secondaryStyles;

  @HiveField(2)
  final String styleConsistency;

  @HiveField(3)
  final String adaptability;

  const CommunicationProfile({
    required this.dominantStyle,
    this.secondaryStyles = const [],
    this.styleConsistency = '',
    this.adaptability = '',
  });

  factory CommunicationProfile.fromJson(Map<String, dynamic> json) {
    return CommunicationProfile(
      dominantStyle: json['dominant_style'] as String? ?? 'Unknown',
      secondaryStyles: (json['secondary_styles'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          [],
      styleConsistency: json['style_consistency'] as String? ?? '',
      adaptability: json['adaptability'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dominant_style': dominantStyle,
      'secondary_styles': secondaryStyles,
      'style_consistency': styleConsistency,
      'adaptability': adaptability,
    };
  }

  @override
  List<Object?> get props =>
      [dominantStyle, secondaryStyles, styleConsistency, adaptability];
}

@HiveType(typeId: 18)
class EmotionalProfile extends Equatable {
  @HiveField(0)
  final String baselineRegulation;

  @HiveField(1)
  final List<String> commonTriggers;

  @HiveField(2)
  final List<String> healthyCopingStrategies;

  @HiveField(3)
  final List<String> unhealthyCopingStrategies;

  @HiveField(4)
  final String emotionalIntelligenceIndicators;

  const EmotionalProfile({
    required this.baselineRegulation,
    this.commonTriggers = const [],
    this.healthyCopingStrategies = const [],
    this.unhealthyCopingStrategies = const [],
    this.emotionalIntelligenceIndicators = '',
  });

  factory EmotionalProfile.fromJson(Map<String, dynamic> json) {
    return EmotionalProfile(
      baselineRegulation: json['baseline_regulation'] as String? ?? 'Unknown',
      commonTriggers: (json['common_triggers'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      healthyCopingStrategies:
          (json['coping_strategies']?['healthy'] as List<dynamic>?)
                  ?.map((s) => s as String)
                  .toList() ??
              [],
      unhealthyCopingStrategies:
          (json['coping_strategies']?['unhealthy'] as List<dynamic>?)
                  ?.map((s) => s as String)
                  .toList() ??
              [],
      emotionalIntelligenceIndicators:
          json['emotional_intelligence_indicators'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseline_regulation': baselineRegulation,
      'common_triggers': commonTriggers,
      'coping_strategies': {
        'healthy': healthyCopingStrategies,
        'unhealthy': unhealthyCopingStrategies,
      },
      'emotional_intelligence_indicators': emotionalIntelligenceIndicators,
    };
  }

  @override
  List<Object?> get props => [
        baselineRegulation,
        commonTriggers,
        healthyCopingStrategies,
        unhealthyCopingStrategies,
        emotionalIntelligenceIndicators,
      ];
}

@HiveType(typeId: 19)
class BehavioralPatterns extends Equatable {
  @HiveField(0)
  final List<FrequentBehavior> frequentBehaviors;

  @HiveField(1)
  final List<String> rareBehaviors;

  @HiveField(2)
  final String evolvingPatterns;

  const BehavioralPatterns({
    this.frequentBehaviors = const [],
    this.rareBehaviors = const [],
    this.evolvingPatterns = '',
  });

  factory BehavioralPatterns.fromJson(Map<String, dynamic> json) {
    return BehavioralPatterns(
      frequentBehaviors: (json['frequent_behaviors'] as List<dynamic>?)
              ?.map((b) => FrequentBehavior.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      rareBehaviors: (json['rare_behaviors'] as List<dynamic>?)
              ?.map((b) => b as String)
              .toList() ??
          [],
      evolvingPatterns: json['evolving_patterns'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequent_behaviors': frequentBehaviors.map((b) => b.toJson()).toList(),
      'rare_behaviors': rareBehaviors,
      'evolving_patterns': evolvingPatterns,
    };
  }

  @override
  List<Object?> get props => [frequentBehaviors, rareBehaviors, evolvingPatterns];
}

@HiveType(typeId: 20)
class FrequentBehavior extends Equatable {
  @HiveField(0)
  final String behavior;

  @HiveField(1)
  final String frequency;

  @HiveField(2)
  final String contexts;

  @HiveField(3)
  final String impact;

  const FrequentBehavior({
    required this.behavior,
    this.frequency = '',
    this.contexts = '',
    this.impact = '',
  });

  factory FrequentBehavior.fromJson(Map<String, dynamic> json) {
    return FrequentBehavior(
      behavior: json['behavior'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      contexts: json['contexts'] as String? ?? '',
      impact: json['impact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'behavior': behavior,
      'frequency': frequency,
      'contexts': contexts,
      'impact': impact,
    };
  }

  @override
  List<Object?> get props => [behavior, frequency, contexts, impact];
}

@HiveType(typeId: 21)
class AttachmentProfile extends Equatable {
  @HiveField(0)
  final String primaryStyle;

  @HiveField(1)
  final List<String> triggersForInsecurity;

  @HiveField(2)
  final List<String> secureBaseBehaviors;

  const AttachmentProfile({
    required this.primaryStyle,
    this.triggersForInsecurity = const [],
    this.secureBaseBehaviors = const [],
  });

  factory AttachmentProfile.fromJson(Map<String, dynamic> json) {
    return AttachmentProfile(
      primaryStyle: json['primary_style'] as String? ?? 'Unknown',
      triggersForInsecurity:
          (json['triggers_for_insecurity'] as List<dynamic>?)
                  ?.map((t) => t as String)
                  .toList() ??
              [],
      secureBaseBehaviors: (json['secure_base_behaviors'] as List<dynamic>?)
              ?.map((b) => b as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_style': primaryStyle,
      'triggers_for_insecurity': triggersForInsecurity,
      'secure_base_behaviors': secureBaseBehaviors,
    };
  }

  @override
  List<Object?> get props =>
      [primaryStyle, triggersForInsecurity, secureBaseBehaviors];
}

@HiveType(typeId: 22)
class ConflictProfile extends Equatable {
  @HiveField(0)
  final String approach;

  @HiveField(1)
  final List<String> strengthsInConflict;

  @HiveField(2)
  final List<String> challengesInConflict;

  @HiveField(3)
  final String resolutionPatterns;

  const ConflictProfile({
    required this.approach,
    this.strengthsInConflict = const [],
    this.challengesInConflict = const [],
    this.resolutionPatterns = '',
  });

  factory ConflictProfile.fromJson(Map<String, dynamic> json) {
    return ConflictProfile(
      approach: json['approach'] as String? ?? '',
      strengthsInConflict: (json['strengths_in_conflict'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          [],
      challengesInConflict: (json['challenges_in_conflict'] as List<dynamic>?)
              ?.map((c) => c as String)
              .toList() ??
          [],
      resolutionPatterns: json['resolution_patterns'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approach': approach,
      'strengths_in_conflict': strengthsInConflict,
      'challenges_in_conflict': challengesInConflict,
      'resolution_patterns': resolutionPatterns,
    };
  }

  @override
  List<Object?> get props =>
      [approach, strengthsInConflict, challengesInConflict, resolutionPatterns];
}

@HiveType(typeId: 23)
class ProfileStrength extends Equatable {
  @HiveField(0)
  final String strength;

  @HiveField(1)
  final String evidence;

  @HiveField(2)
  final String impact;

  const ProfileStrength({
    required this.strength,
    this.evidence = '',
    this.impact = '',
  });

  factory ProfileStrength.fromJson(Map<String, dynamic> json) {
    return ProfileStrength(
      strength: json['strength'] as String? ?? '',
      evidence: json['evidence'] as String? ?? '',
      impact: json['impact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strength': strength,
      'evidence': evidence,
      'impact': impact,
    };
  }

  @override
  List<Object?> get props => [strength, evidence, impact];
}

@HiveType(typeId: 24)
class GrowthOpportunity extends Equatable {
  @HiveField(0)
  final String area;

  @HiveField(1)
  final String currentPattern;

  @HiveField(2)
  final String suggestedGrowth;

  @HiveField(3)
  final String resources;

  const GrowthOpportunity({
    required this.area,
    this.currentPattern = '',
    this.suggestedGrowth = '',
    this.resources = '',
  });

  factory GrowthOpportunity.fromJson(Map<String, dynamic> json) {
    return GrowthOpportunity(
      area: json['area'] as String? ?? '',
      currentPattern: json['current_pattern'] as String? ?? '',
      suggestedGrowth: json['suggested_growth'] as String? ?? '',
      resources: json['resources'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'current_pattern': currentPattern,
      'suggested_growth': suggestedGrowth,
      'resources': resources,
    };
  }

  @override
  List<Object?> get props => [area, currentPattern, suggestedGrowth, resources];
}

@HiveType(typeId: 25)
class CommunicationRecommendations extends Equatable {
  @HiveField(0)
  final List<String> bestApproaches;

  @HiveField(1)
  final List<String> topicsToApproachCarefully;

  @HiveField(2)
  final List<String> conflictResolutionStrategies;

  @HiveField(3)
  final String relationshipPotential;

  const CommunicationRecommendations({
    this.bestApproaches = const [],
    this.topicsToApproachCarefully = const [],
    this.conflictResolutionStrategies = const [],
    this.relationshipPotential = '',
  });

  factory CommunicationRecommendations.fromJson(Map<String, dynamic> json) {
    return CommunicationRecommendations(
      bestApproaches: (json['best_approaches_with_them'] as List<dynamic>?)
              ?.map((a) => a as String)
              .toList() ??
          [],
      topicsToApproachCarefully:
          (json['topics_to_approach_carefully'] as List<dynamic>?)
                  ?.map((t) => t as String)
                  .toList() ??
              [],
      conflictResolutionStrategies:
          (json['conflict_resolution_strategies'] as List<dynamic>?)
                  ?.map((s) => s as String)
                  .toList() ??
              [],
      relationshipPotential: json['relationship_potential'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'best_approaches_with_them': bestApproaches,
      'topics_to_approach_carefully': topicsToApproachCarefully,
      'conflict_resolution_strategies': conflictResolutionStrategies,
      'relationship_potential': relationshipPotential,
    };
  }

  @override
  List<Object?> get props => [
        bestApproaches,
        topicsToApproachCarefully,
        conflictResolutionStrategies,
        relationshipPotential,
      ];
}

/// Extension for accessibility
extension ProfileAccessibility on Profile {
  String get accessibilityLabel {
    final userLabel = isUserProfile ? 'Your self-profile' : 'Profile for $name';
    return '$userLabel with ${conversationIds.length} analyzed conversations';
  }

  String get accessibilityHint {
    if (!hasEnoughDataForAnalysis) {
      return 'Add more conversations to enable detailed profile analysis';
    }
    return 'Tap to view detailed psychological profile and communication recommendations';
  }
}
