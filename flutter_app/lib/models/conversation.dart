/// Conversation model containing messages and analysis

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'message.dart';
import 'speaker.dart';
import 'analysis_result.dart';

part 'conversation.g.dart';

@HiveType(typeId: 2)
class Conversation extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<Message> messages;

  @HiveField(4)
  final List<Speaker> speakers;

  @HiveField(5)
  final String rawText;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final ConversationStatus status;

  @HiveField(9)
  final AnalysisResult? analysis;

  @HiveField(10)
  final bool speakersVerified;

  @HiveField(11)
  final String? sourceType;

  @HiveField(12)
  final Map<String, dynamic>? metadata;

  const Conversation({
    required this.id,
    required this.title,
    this.description,
    this.messages = const [],
    this.speakers = const [],
    required this.rawText,
    required this.createdAt,
    required this.updatedAt,
    this.status = ConversationStatus.draft,
    this.analysis,
    this.speakersVerified = false,
    this.sourceType,
    this.metadata,
  });

  /// Check if conversation has been analyzed
  bool get isAnalyzed => analysis != null;

  /// Check if all messages have verified speakers
  bool get allMessagesVerified =>
      messages.isNotEmpty && messages.every((m) => m.isVerified);

  /// Get message count
  int get messageCount => messages.length;

  /// Get unique speaker count
  int get speakerCount => speakers.length;

  /// Get conversation health score from analysis
  int? get healthScore => analysis?.conversationHealthScore;

  Conversation copyWith({
    String? id,
    String? title,
    String? description,
    List<Message>? messages,
    List<Speaker>? speakers,
    String? rawText,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConversationStatus? status,
    AnalysisResult? analysis,
    bool? speakersVerified,
    String? sourceType,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      messages: messages ?? this.messages,
      speakers: speakers ?? this.speakers,
      rawText: rawText ?? this.rawText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      speakersVerified: speakersVerified ?? this.speakersVerified,
      sourceType: sourceType ?? this.sourceType,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      speakers: (json['speakers'] as List<dynamic>?)
              ?.map((s) => Speaker.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      rawText: json['raw_text'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConversationStatus.draft,
      ),
      analysis: json['analysis'] != null
          ? AnalysisResult.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
      speakersVerified: json['speakers_verified'] as bool? ?? false,
      sourceType: json['source_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'messages': messages.map((m) => m.toJson()).toList(),
      'speakers': speakers.map((s) => s.toJson()).toList(),
      'raw_text': rawText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.name,
      'analysis': analysis?.toJson(),
      'speakers_verified': speakersVerified,
      'source_type': sourceType,
      'metadata': metadata,
    };
  }

  /// Create a new conversation from raw text
  factory Conversation.fromRawText(String text, {String? title}) {
    final now = DateTime.now();
    return Conversation(
      id: 'conv_${now.millisecondsSinceEpoch}',
      title: title ?? 'Conversation ${now.day}/${now.month}/${now.year}',
      rawText: text,
      createdAt: now,
      updatedAt: now,
      status: ConversationStatus.draft,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        messages,
        speakers,
        rawText,
        createdAt,
        updatedAt,
        status,
        analysis,
        speakersVerified,
        sourceType,
      ];

  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, messages: ${messages.length}, status: ${status.name})';
  }
}

/// Conversation processing status
@HiveType(typeId: 3)
enum ConversationStatus {
  @HiveField(0)
  draft, // Just created, raw text only

  @HiveField(1)
  speakersIdentified, // AI has identified speakers

  @HiveField(2)
  speakersVerified, // User has verified/corrected speakers

  @HiveField(3)
  analyzing, // Analysis in progress

  @HiveField(4)
  analyzed, // Analysis complete

  @HiveField(5)
  error, // Error during processing
}

/// Extension for status display
extension ConversationStatusExtension on ConversationStatus {
  String get displayName {
    switch (this) {
      case ConversationStatus.draft:
        return 'Draft';
      case ConversationStatus.speakersIdentified:
        return 'Speakers Identified';
      case ConversationStatus.speakersVerified:
        return 'Ready for Analysis';
      case ConversationStatus.analyzing:
        return 'Analyzing...';
      case ConversationStatus.analyzed:
        return 'Analysis Complete';
      case ConversationStatus.error:
        return 'Error';
    }
  }

  String get accessibilityLabel {
    switch (this) {
      case ConversationStatus.draft:
        return 'Draft conversation, speakers not yet identified';
      case ConversationStatus.speakersIdentified:
        return 'Speakers identified by AI, awaiting your verification';
      case ConversationStatus.speakersVerified:
        return 'Speakers verified, ready for psychological analysis';
      case ConversationStatus.analyzing:
        return 'Analysis in progress, please wait';
      case ConversationStatus.analyzed:
        return 'Analysis complete, tap to view insights';
      case ConversationStatus.error:
        return 'An error occurred during processing';
    }
  }
}

/// Extension for accessibility
extension ConversationAccessibility on Conversation {
  String get accessibilityLabel {
    return '$title, ${messages.length} messages between ${speakers.length} speakers, status: ${status.displayName}';
  }

  String get accessibilityHint {
    switch (status) {
      case ConversationStatus.draft:
        return 'Tap to identify speakers in this conversation';
      case ConversationStatus.speakersIdentified:
        return 'Tap to verify speaker identification';
      case ConversationStatus.speakersVerified:
        return 'Tap to start psychological analysis';
      case ConversationStatus.analyzing:
        return 'Please wait while analysis completes';
      case ConversationStatus.analyzed:
        return 'Tap to view detailed analysis and insights';
      case ConversationStatus.error:
        return 'Tap to retry or edit conversation';
    }
  }
}
