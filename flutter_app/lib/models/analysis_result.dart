/// Analysis result model from AI conversation analysis

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'analysis_result.g.dart';

@HiveType(typeId: 4)
class AnalysisResult extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String summary;

  @HiveField(3)
  final PowerDynamics? powerDynamics;

  @HiveField(4)
  final List<SpeakerAnalysis> speakerAnalyses;

  @HiveField(5)
  final RelationshipDynamics? relationshipDynamics;

  @HiveField(6)
  final ManipulationCheck? manipulationCheck;

  @HiveField(7)
  final List<ActionableInsight> actionableInsights;

  @HiveField(8)
  final int conversationHealthScore;

  @HiveField(9)
  final List<String> followUpQuestions;

  @HiveField(10)
  final DateTime analyzedAt;

  @HiveField(11)
  final Map<String, dynamic>? rawResponse;

  const AnalysisResult({
    required this.id,
    required this.conversationId,
    required this.summary,
    this.powerDynamics,
    this.speakerAnalyses = const [],
    this.relationshipDynamics,
    this.manipulationCheck,
    this.actionableInsights = const [],
    this.conversationHealthScore = 0,
    this.followUpQuestions = const [],
    required this.analyzedAt,
    this.rawResponse,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String? ??
          'analysis_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: json['conversation_id'] as String? ?? '',
      summary: json['summary'] as String? ?? 'Analysis complete.',
      powerDynamics: json['power_dynamics'] != null
          ? PowerDynamics.fromJson(json['power_dynamics'] as Map<String, dynamic>)
          : null,
      speakerAnalyses: (json['speaker_analyses'] as List<dynamic>?)
              ?.map((s) => SpeakerAnalysis.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      relationshipDynamics: json['relationship_dynamics'] != null
          ? RelationshipDynamics.fromJson(
              json['relationship_dynamics'] as Map<String, dynamic>)
          : null,
      manipulationCheck: json['manipulation_check'] != null
          ? ManipulationCheck.fromJson(
              json['manipulation_check'] as Map<String, dynamic>)
          : null,
      actionableInsights: (json['actionable_insights'] as List<dynamic>?)
              ?.map((i) => ActionableInsight.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      conversationHealthScore:
          json['conversation_health_score'] as int? ?? 50,
      followUpQuestions: (json['follow_up_questions'] as List<dynamic>?)
              ?.map((q) => q as String)
              .toList() ??
          [],
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.parse(json['analyzed_at'] as String)
          : DateTime.now(),
      rawResponse: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'summary': summary,
      'power_dynamics': powerDynamics?.toJson(),
      'speaker_analyses': speakerAnalyses.map((s) => s.toJson()).toList(),
      'relationship_dynamics': relationshipDynamics?.toJson(),
      'manipulation_check': manipulationCheck?.toJson(),
      'actionable_insights': actionableInsights.map((i) => i.toJson()).toList(),
      'conversation_health_score': conversationHealthScore,
      'follow_up_questions': followUpQuestions,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  AnalysisResult copyWith({
    String? id,
    String? conversationId,
    String? summary,
    PowerDynamics? powerDynamics,
    List<SpeakerAnalysis>? speakerAnalyses,
    RelationshipDynamics? relationshipDynamics,
    ManipulationCheck? manipulationCheck,
    List<ActionableInsight>? actionableInsights,
    int? conversationHealthScore,
    List<String>? followUpQuestions,
    DateTime? analyzedAt,
    Map<String, dynamic>? rawResponse,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      summary: summary ?? this.summary,
      powerDynamics: powerDynamics ?? this.powerDynamics,
      speakerAnalyses: speakerAnalyses ?? this.speakerAnalyses,
      relationshipDynamics: relationshipDynamics ?? this.relationshipDynamics,
      manipulationCheck: manipulationCheck ?? this.manipulationCheck,
      actionableInsights: actionableInsights ?? this.actionableInsights,
      conversationHealthScore:
          conversationHealthScore ?? this.conversationHealthScore,
      followUpQuestions: followUpQuestions ?? this.followUpQuestions,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      rawResponse: rawResponse ?? this.rawResponse,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        summary,
        powerDynamics,
        speakerAnalyses,
        relationshipDynamics,
        manipulationCheck,
        actionableInsights,
        conversationHealthScore,
        followUpQuestions,
        analyzedAt,
      ];
}

@HiveType(typeId: 5)
class PowerDynamics extends Equatable {
  @HiveField(0)
  final String assessment;

  @HiveField(1)
  final List<String> indicators;

  @HiveField(2)
  final int balanceScore;

  const PowerDynamics({
    required this.assessment,
    this.indicators = const [],
    this.balanceScore = 5,
  });

  factory PowerDynamics.fromJson(Map<String, dynamic> json) {
    return PowerDynamics(
      assessment: json['assessment'] as String? ?? '',
      indicators: (json['indicators'] as List<dynamic>?)
              ?.map((i) => i as String)
              .toList() ??
          [],
      balanceScore: json['balance_score'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessment': assessment,
      'indicators': indicators,
      'balance_score': balanceScore,
    };
  }

  @override
  List<Object?> get props => [assessment, indicators, balanceScore];
}

@HiveType(typeId: 6)
class SpeakerAnalysis extends Equatable {
  @HiveField(0)
  final String speakerId;

  @HiveField(1)
  final String speakerName;

  @HiveField(2)
  final CommunicationStyle? communicationStyle;

  @HiveField(3)
  final EmotionalPatterns? emotionalPatterns;

  @HiveField(4)
  final AttachmentIndicators? attachmentIndicators;

  @HiveField(5)
  final List<BehaviorExhibited> behaviorsExhibited;

  @HiveField(6)
  final List<String> strengths;

  @HiveField(7)
  final List<String> growthAreas;

  @HiveField(8)
  final List<String> redFlags;

  @HiveField(9)
  final List<String> greenFlags;

  const SpeakerAnalysis({
    required this.speakerId,
    required this.speakerName,
    this.communicationStyle,
    this.emotionalPatterns,
    this.attachmentIndicators,
    this.behaviorsExhibited = const [],
    this.strengths = const [],
    this.growthAreas = const [],
    this.redFlags = const [],
    this.greenFlags = const [],
  });

  factory SpeakerAnalysis.fromJson(Map<String, dynamic> json) {
    return SpeakerAnalysis(
      speakerId: json['speaker_id'] as String? ?? json['speaker'] as String? ?? '',
      speakerName: json['speaker'] as String? ?? json['speaker_name'] as String? ?? '',
      communicationStyle: json['communication_style'] != null
          ? CommunicationStyle.fromJson(
              json['communication_style'] as Map<String, dynamic>)
          : null,
      emotionalPatterns: json['emotional_patterns'] != null
          ? EmotionalPatterns.fromJson(
              json['emotional_patterns'] as Map<String, dynamic>)
          : null,
      attachmentIndicators: json['attachment_indicators'] != null
          ? AttachmentIndicators.fromJson(
              json['attachment_indicators'] as Map<String, dynamic>)
          : null,
      behaviorsExhibited: (json['behaviors_exhibited'] as List<dynamic>?)
              ?.map((b) => BehaviorExhibited.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          [],
      growthAreas: (json['growth_areas'] as List<dynamic>?)
              ?.map((g) => g as String)
              .toList() ??
          [],
      redFlags: (json['red_flags'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
      greenFlags: (json['green_flags'] as List<dynamic>?)
              ?.map((g) => g as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker_id': speakerId,
      'speaker': speakerName,
      'communication_style': communicationStyle?.toJson(),
      'emotional_patterns': emotionalPatterns?.toJson(),
      'attachment_indicators': attachmentIndicators?.toJson(),
      'behaviors_exhibited': behaviorsExhibited.map((b) => b.toJson()).toList(),
      'strengths': strengths,
      'growth_areas': growthAreas,
      'red_flags': redFlags,
      'green_flags': greenFlags,
    };
  }

  @override
  List<Object?> get props => [
        speakerId,
        speakerName,
        communicationStyle,
        emotionalPatterns,
        attachmentIndicators,
        behaviorsExhibited,
        strengths,
        growthAreas,
        redFlags,
        greenFlags,
      ];
}

@HiveType(typeId: 7)
class CommunicationStyle extends Equatable {
  @HiveField(0)
  final String primary;

  @HiveField(1)
  final List<String> examples;

  @HiveField(2)
  final int effectivenessScore;

  const CommunicationStyle({
    required this.primary,
    this.examples = const [],
    this.effectivenessScore = 5,
  });

  factory CommunicationStyle.fromJson(Map<String, dynamic> json) {
    return CommunicationStyle(
      primary: json['primary'] as String? ?? 'Unknown',
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      effectivenessScore: json['effectiveness_score'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'examples': examples,
      'effectiveness_score': effectivenessScore,
    };
  }

  @override
  List<Object?> get props => [primary, examples, effectivenessScore];
}

@HiveType(typeId: 8)
class EmotionalPatterns extends Equatable {
  @HiveField(0)
  final String regulationLevel;

  @HiveField(1)
  final List<String> triggersObserved;

  @HiveField(2)
  final List<String> copingMechanisms;

  const EmotionalPatterns({
    required this.regulationLevel,
    this.triggersObserved = const [],
    this.copingMechanisms = const [],
  });

  factory EmotionalPatterns.fromJson(Map<String, dynamic> json) {
    return EmotionalPatterns(
      regulationLevel: json['regulation_level'] as String? ?? 'Unknown',
      triggersObserved: (json['triggers_observed'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      copingMechanisms: (json['coping_mechanisms'] as List<dynamic>?)
              ?.map((c) => c as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regulation_level': regulationLevel,
      'triggers_observed': triggersObserved,
      'coping_mechanisms': copingMechanisms,
    };
  }

  @override
  List<Object?> get props => [regulationLevel, triggersObserved, copingMechanisms];
}

@HiveType(typeId: 9)
class AttachmentIndicators extends Equatable {
  @HiveField(0)
  final String likelyStyle;

  @HiveField(1)
  final List<String> evidence;

  const AttachmentIndicators({
    required this.likelyStyle,
    this.evidence = const [],
  });

  factory AttachmentIndicators.fromJson(Map<String, dynamic> json) {
    return AttachmentIndicators(
      likelyStyle: json['likely_style'] as String? ?? 'Unknown',
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likely_style': likelyStyle,
      'evidence': evidence,
    };
  }

  @override
  List<Object?> get props => [likelyStyle, evidence];
}

@HiveType(typeId: 10)
class BehaviorExhibited extends Equatable {
  @HiveField(0)
  final String behaviorId;

  @HiveField(1)
  final String behaviorName;

  @HiveField(2)
  final List<String> examples;

  @HiveField(3)
  final String frequency;

  @HiveField(4)
  final String impact;

  const BehaviorExhibited({
    required this.behaviorId,
    required this.behaviorName,
    this.examples = const [],
    this.frequency = 'occasional',
    this.impact = 'neutral',
  });

  factory BehaviorExhibited.fromJson(Map<String, dynamic> json) {
    return BehaviorExhibited(
      behaviorId: json['behavior_id'] as String? ?? '',
      behaviorName: json['behavior_name'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      frequency: json['frequency'] as String? ?? 'occasional',
      impact: json['impact'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'behavior_id': behaviorId,
      'behavior_name': behaviorName,
      'examples': examples,
      'frequency': frequency,
      'impact': impact,
    };
  }

  @override
  List<Object?> get props => [behaviorId, behaviorName, examples, frequency, impact];
}

@HiveType(typeId: 11)
class RelationshipDynamics extends Equatable {
  @HiveField(0)
  final String overallHealth;

  @HiveField(1)
  final List<String> patterns;

  @HiveField(2)
  final String conflictStyle;

  @HiveField(3)
  final String resolutionPotential;

  const RelationshipDynamics({
    required this.overallHealth,
    this.patterns = const [],
    this.conflictStyle = '',
    this.resolutionPotential = 'medium',
  });

  factory RelationshipDynamics.fromJson(Map<String, dynamic> json) {
    return RelationshipDynamics(
      overallHealth: json['overall_health'] as String? ?? 'Unknown',
      patterns: (json['patterns'] as List<dynamic>?)
              ?.map((p) => p as String)
              .toList() ??
          [],
      conflictStyle: json['conflict_style'] as String? ?? '',
      resolutionPotential: json['resolution_potential'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_health': overallHealth,
      'patterns': patterns,
      'conflict_style': conflictStyle,
      'resolution_potential': resolutionPotential,
    };
  }

  @override
  List<Object?> get props =>
      [overallHealth, patterns, conflictStyle, resolutionPotential];
}

@HiveType(typeId: 12)
class ManipulationCheck extends Equatable {
  @HiveField(0)
  final bool detected;

  @HiveField(1)
  final List<String> types;

  @HiveField(2)
  final List<String> examples;

  @HiveField(3)
  final String severity;

  const ManipulationCheck({
    this.detected = false,
    this.types = const [],
    this.examples = const [],
    this.severity = 'none',
  });

  factory ManipulationCheck.fromJson(Map<String, dynamic> json) {
    return ManipulationCheck(
      detected: json['detected'] as bool? ?? false,
      types: (json['types'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      severity: json['severity'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detected': detected,
      'types': types,
      'examples': examples,
      'severity': severity,
    };
  }

  @override
  List<Object?> get props => [detected, types, examples, severity];
}

@HiveType(typeId: 13)
class ActionableInsight extends Equatable {
  @HiveField(0)
  final String forSpeaker;

  @HiveField(1)
  final String insight;

  @HiveField(2)
  final String suggestion;

  @HiveField(3)
  final String expectedOutcome;

  const ActionableInsight({
    required this.forSpeaker,
    required this.insight,
    required this.suggestion,
    this.expectedOutcome = '',
  });

  factory ActionableInsight.fromJson(Map<String, dynamic> json) {
    return ActionableInsight(
      forSpeaker: json['for_speaker'] as String? ?? 'both',
      insight: json['insight'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      expectedOutcome: json['expected_outcome'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'for_speaker': forSpeaker,
      'insight': insight,
      'suggestion': suggestion,
      'expected_outcome': expectedOutcome,
    };
  }

  @override
  List<Object?> get props => [forSpeaker, insight, suggestion, expectedOutcome];
}

/// Extension for accessibility
extension AnalysisResultAccessibility on AnalysisResult {
  String get accessibilityLabel {
    return 'Conversation analysis with health score of $conversationHealthScore out of 100. $summary';
  }

  String get accessibilityHint {
    return 'Swipe through sections to explore detailed insights for each speaker';
  }
}
