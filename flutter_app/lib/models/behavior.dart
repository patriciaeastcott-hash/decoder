/// Behavior model for the offline behavior/trait library

import 'package:equatable/equatable.dart';

/// Main library container
class BehaviorLibrary extends Equatable {
  final String version;
  final String lastUpdated;
  final int totalBehaviors;
  final List<BehaviorCategory> categories;
  final LibraryMetadata? metadata;

  const BehaviorLibrary({
    required this.version,
    required this.lastUpdated,
    required this.totalBehaviors,
    required this.categories,
    this.metadata,
  });

  factory BehaviorLibrary.fromJson(Map<String, dynamic> json) {
    return BehaviorLibrary(
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: json['last_updated'] as String? ?? '',
      totalBehaviors: json['total_behaviors'] as int? ?? 0,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((c) => BehaviorCategory.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? LibraryMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'last_updated': lastUpdated,
      'total_behaviors': totalBehaviors,
      'categories': categories.map((c) => c.toJson()).toList(),
      'metadata': metadata?.toJson(),
    };
  }

  /// Get all behaviors in a flat list
  List<Behavior> get allBehaviors {
    final behaviors = <Behavior>[];
    for (final category in categories) {
      for (final subcategory in category.subcategories) {
        behaviors.addAll(subcategory.behaviors);
      }
    }
    return behaviors;
  }

  /// Search behaviors by keyword
  List<Behavior> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return allBehaviors.where((behavior) {
      return behavior.name.toLowerCase().contains(lowercaseQuery) ||
          behavior.definition.toLowerCase().contains(lowercaseQuery) ||
          behavior.examples.any((e) => e.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get behavior by ID
  Behavior? getBehaviorById(String id) {
    for (final category in categories) {
      for (final subcategory in category.subcategories) {
        for (final behavior in subcategory.behaviors) {
          if (behavior.id == id) return behavior;
        }
      }
    }
    return null;
  }

  /// Get category names
  List<String> get categoryNames =>
      categories.map((c) => c.category).toList();

  @override
  List<Object?> get props =>
      [version, lastUpdated, totalBehaviors, categories, metadata];
}

/// Category containing subcategories
class BehaviorCategory extends Equatable {
  final String id;
  final String category;
  final String description;
  final String icon;
  final List<BehaviorSubcategory> subcategories;

  const BehaviorCategory({
    required this.id,
    required this.category,
    required this.description,
    this.icon = 'psychology',
    required this.subcategories,
  });

  factory BehaviorCategory.fromJson(Map<String, dynamic> json) {
    return BehaviorCategory(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'psychology',
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((s) => BehaviorSubcategory.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'icon': icon,
      'subcategories': subcategories.map((s) => s.toJson()).toList(),
    };
  }

  /// Get total behavior count in this category
  int get behaviorCount {
    return subcategories.fold(0, (sum, sub) => sum + sub.behaviors.length);
  }

  @override
  List<Object?> get props => [id, category, description, icon, subcategories];
}

/// Subcategory containing behaviors
class BehaviorSubcategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<Behavior> behaviors;

  const BehaviorSubcategory({
    required this.id,
    required this.name,
    required this.description,
    required this.behaviors,
  });

  factory BehaviorSubcategory.fromJson(Map<String, dynamic> json) {
    return BehaviorSubcategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      behaviors: (json['behaviors'] as List<dynamic>?)
              ?.map((b) => Behavior.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'behaviors': behaviors.map((b) => b.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, description, behaviors];
}

/// Individual behavior definition
class Behavior extends Equatable {
  final String id;
  final String name;
  final String definition;
  final List<String> examples;
  final List<String> healthyIndicators;
  final List<String> unhealthyIndicators;
  final String frequencyNote;

  const Behavior({
    required this.id,
    required this.name,
    required this.definition,
    this.examples = const [],
    this.healthyIndicators = const [],
    this.unhealthyIndicators = const [],
    this.frequencyNote = '',
  });

  factory Behavior.fromJson(Map<String, dynamic> json) {
    return Behavior(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      healthyIndicators: (json['healthy_indicators'] as List<dynamic>?)
              ?.map((h) => h as String)
              .toList() ??
          [],
      unhealthyIndicators: (json['unhealthy_indicators'] as List<dynamic>?)
              ?.map((u) => u as String)
              .toList() ??
          [],
      frequencyNote: json['frequency_note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'definition': definition,
      'examples': examples,
      'healthy_indicators': healthyIndicators,
      'unhealthy_indicators': unhealthyIndicators,
      'frequency_note': frequencyNote,
    };
  }

  /// Determine if this is a generally healthy or unhealthy behavior
  BehaviorNature get nature {
    if (unhealthyIndicators.isEmpty ||
        (unhealthyIndicators.length == 1 &&
            unhealthyIndicators.first.toLowerCase().contains('none'))) {
      return BehaviorNature.healthy;
    }
    if (healthyIndicators.isEmpty ||
        (healthyIndicators.length == 1 &&
            healthyIndicators.first.toLowerCase().contains('none'))) {
      return BehaviorNature.unhealthy;
    }
    return BehaviorNature.contextDependent;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        definition,
        examples,
        healthyIndicators,
        unhealthyIndicators,
        frequencyNote,
      ];

  @override
  String toString() => 'Behavior(id: $id, name: $name)';
}

/// Classification of behavior nature
enum BehaviorNature {
  healthy,
  unhealthy,
  contextDependent,
}

extension BehaviorNatureExtension on BehaviorNature {
  String get displayName {
    switch (this) {
      case BehaviorNature.healthy:
        return 'Generally Healthy';
      case BehaviorNature.unhealthy:
        return 'Generally Unhealthy';
      case BehaviorNature.contextDependent:
        return 'Context Dependent';
    }
  }

  String get accessibilityLabel {
    switch (this) {
      case BehaviorNature.healthy:
        return 'This behavior is generally healthy and constructive';
      case BehaviorNature.unhealthy:
        return 'This behavior is generally unhealthy or harmful';
      case BehaviorNature.contextDependent:
        return 'This behavior can be healthy or unhealthy depending on context';
    }
  }
}

/// Library metadata including sources and resources
class LibraryMetadata extends Equatable {
  final List<String> sources;
  final String disclaimer;
  final Map<String, String> australianResources;

  const LibraryMetadata({
    this.sources = const [],
    this.disclaimer = '',
    this.australianResources = const {},
  });

  factory LibraryMetadata.fromJson(Map<String, dynamic> json) {
    return LibraryMetadata(
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          [],
      disclaimer: json['disclaimer'] as String? ?? '',
      australianResources:
          (json['australian_resources'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as String)) ??
              {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sources': sources,
      'disclaimer': disclaimer,
      'australian_resources': australianResources,
    };
  }

  @override
  List<Object?> get props => [sources, disclaimer, australianResources];
}

/// Extension for accessibility
extension BehaviorAccessibility on Behavior {
  String get accessibilityLabel {
    return '$name: $definition';
  }

  String get accessibilityHint {
    return 'Tap to view examples, healthy and unhealthy indicators';
  }

  String get fullAccessibilityDescription {
    final buffer = StringBuffer();
    buffer.writeln('$name');
    buffer.writeln('Definition: $definition');

    if (examples.isNotEmpty) {
      buffer.writeln('Examples: ${examples.join(", ")}');
    }

    if (healthyIndicators.isNotEmpty) {
      buffer.writeln('Healthy when: ${healthyIndicators.join(", ")}');
    }

    if (unhealthyIndicators.isNotEmpty) {
      buffer.writeln('Unhealthy when: ${unhealthyIndicators.join(", ")}');
    }

    if (frequencyNote.isNotEmpty) {
      buffer.writeln('Note: $frequencyNote');
    }

    return buffer.toString();
  }
}

extension BehaviorCategoryAccessibility on BehaviorCategory {
  String get accessibilityLabel {
    return '$category with ${behaviorCount} behaviors';
  }

  String get accessibilityHint {
    return 'Tap to explore $description';
  }
}
