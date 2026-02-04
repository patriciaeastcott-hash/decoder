/// Speaker model for conversation participants
library;

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'speaker.g.dart';

@HiveType(typeId: 1)
class Speaker extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final bool isUser;

  @HiveField(5)
  final String? profileId;

  @HiveField(6)
  final String? avatarUrl;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final Map<String, dynamic>? metadata;

  @HiveField(10)
  final bool isVerified;

  const Speaker({
    required this.id,
    required this.name,
    this.displayName,
    this.colorValue = 0xFF6200EE,
    this.isUser = false,
    this.profileId,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    this.isVerified = false,
  });

  Color get color => Color(colorValue);

  String get effectiveName => displayName ?? name;

  Speaker copyWith({
    String? id,
    String? name,
    String? displayName,
    int? colorValue,
    bool? isUser,
    String? profileId,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    bool? isVerified,
  }) {
    return Speaker(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      colorValue: colorValue ?? this.colorValue,
      isUser: isUser ?? this.isUser,
      profileId: profileId ?? this.profileId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String?,
      colorValue: json['color_value'] as int? ?? 0xFF6200EE,
      isUser: json['is_user'] as bool? ?? false,
      profileId: json['profile_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'color_value': colorValue,
      'is_user': isUser,
      'profile_id': profileId,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
      'is_verified': isVerified,
    };
  }

  /// Generate a speaker from AI identification
  factory Speaker.fromAIIdentification(
    String identifier, {
    bool isUser = false,
  }) {
    final now = DateTime.now();
    return Speaker(
      id: 'speaker_${now.millisecondsSinceEpoch}',
      name: identifier,
      displayName: identifier,
      colorValue: _generateColorForName(identifier),
      isUser: isUser,
      createdAt: now,
      updatedAt: now,
    );
  }

  static int _generateColorForName(String name) {
    // Generate a consistent color based on the name
    final colors = [
      0xFF6200EE, // Purple
      0xFF03DAC5, // Teal
      0xFFFF5722, // Deep Orange
      0xFF4CAF50, // Green
      0xFF2196F3, // Blue
      0xFFE91E63, // Pink
      0xFF9C27B0, // Deep Purple
      0xFF00BCD4, // Cyan
      0xFFFF9800, // Orange
      0xFF795548, // Brown
    ];

    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        colorValue,
        isUser,
        profileId,
        avatarUrl,
        createdAt,
        updatedAt,
        isVerified,
      ];

  @override
  String toString() {
    return 'Speaker(id: $id, name: $effectiveName, isUser: $isUser)';
  }
}

/// Extension for accessibility
extension SpeakerAccessibility on Speaker {
  String get accessibilityLabel {
    final userLabel = isUser ? ', this is you' : '';
    return '$effectiveName$userLabel';
  }

  String get accessibilityHint {
    return 'Tap to view $effectiveName\'s profile and communication patterns';
  }
}

/// Predefined speaker colors for selection
class SpeakerColors {
  static const List<int> availableColors = [
    0xFF6200EE, // Purple
    0xFF03DAC5, // Teal
    0xFFFF5722, // Deep Orange
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFFE91E63, // Pink
    0xFF9C27B0, // Deep Purple
    0xFF00BCD4, // Cyan
    0xFFFF9800, // Orange
    0xFF795548, // Brown
    0xFF607D8B, // Blue Grey
    0xFFCDDC39, // Lime
  ];

  static String getColorName(int colorValue) {
    switch (colorValue) {
      case 0xFF6200EE:
        return 'Purple';
      case 0xFF03DAC5:
        return 'Teal';
      case 0xFFFF5722:
        return 'Deep Orange';
      case 0xFF4CAF50:
        return 'Green';
      case 0xFF2196F3:
        return 'Blue';
      case 0xFFE91E63:
        return 'Pink';
      case 0xFF9C27B0:
        return 'Deep Purple';
      case 0xFF00BCD4:
        return 'Cyan';
      case 0xFFFF9800:
        return 'Orange';
      case 0xFF795548:
        return 'Brown';
      case 0xFF607D8B:
        return 'Blue Grey';
      case 0xFFCDDC39:
        return 'Lime';
      default:
        return 'Custom';
    }
  }
}
