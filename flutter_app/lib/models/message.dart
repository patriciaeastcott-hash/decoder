/// Message model for individual conversation messages

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String speakerId;

  @HiveField(3)
  final String? speakerName;

  @HiveField(4)
  final DateTime? timestamp;

  @HiveField(5)
  final double confidenceScore;

  @HiveField(6)
  final String? reasoning;

  @HiveField(7)
  final bool isVerified;

  @HiveField(8)
  final int orderIndex;

  const Message({
    required this.id,
    required this.text,
    required this.speakerId,
    this.speakerName,
    this.timestamp,
    this.confidenceScore = 0.0,
    this.reasoning,
    this.isVerified = false,
    this.orderIndex = 0,
  });

  Message copyWith({
    String? id,
    String? text,
    String? speakerId,
    String? speakerName,
    DateTime? timestamp,
    double? confidenceScore,
    String? reasoning,
    bool? isVerified,
    int? orderIndex,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      speakerId: speakerId ?? this.speakerId,
      speakerName: speakerName ?? this.speakerName,
      timestamp: timestamp ?? this.timestamp,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      reasoning: reasoning ?? this.reasoning,
      isVerified: isVerified ?? this.isVerified,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String,
      speakerId: json['speaker_id'] as String? ?? json['speaker'] as String? ?? 'unknown',
      speakerName: json['speaker_name'] as String? ?? json['speaker'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      confidenceScore: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'speaker_id': speakerId,
      'speaker_name': speakerName,
      'timestamp': timestamp?.toIso8601String(),
      'confidence': confidenceScore,
      'reasoning': reasoning,
      'is_verified': isVerified,
      'order_index': orderIndex,
    };
  }

  @override
  List<Object?> get props => [
        id,
        text,
        speakerId,
        speakerName,
        timestamp,
        confidenceScore,
        reasoning,
        isVerified,
        orderIndex,
      ];

  @override
  String toString() {
    return 'Message(id: $id, speaker: $speakerName, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...)';
  }
}

/// Extension for accessibility
extension MessageAccessibility on Message {
  String get accessibilityLabel {
    final speaker = speakerName ?? 'Unknown speaker';
    final time = timestamp != null
        ? ' at ${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}'
        : '';
    return '$speaker said$time: $text';
  }

  String get accessibilityHint {
    if (!isVerified) {
      return 'Speaker identification not verified. Double tap to edit.';
    }
    return 'Speaker verified. Double tap to view options.';
  }
}
