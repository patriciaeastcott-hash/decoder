/// Behavior library provider for offline behavior/trait library
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/behavior.dart';
import '../services/api_service.dart';

class BehaviorLibraryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  BehaviorLibrary? _library;
  BehaviorLibrary? get library => _library;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool get isLoaded => _library != null;

  int get totalBehaviors => _library?.totalBehaviors ?? 0;

  List<BehaviorCategory> get categories => _library?.categories ?? [];

  /// Load the behavior library (from bundled asset or API)
  Future<void> loadLibrary() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from bundled asset first (offline support)
      _library = await _loadFromAsset();

      if (_library == null) {
        // Fall back to API if asset not available
        final result = await _apiService.fetchBehaviorLibrary();
        if (result.isSuccess && result.data != null) {
          _library = result.data;
        }
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load behavior library: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BehaviorLibrary?> _loadFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/behavior_library.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return BehaviorLibrary.fromJson(json);
    } catch (e) {
      // Asset not found or invalid, will fall back to API
      return null;
    }
  }

  /// Search behaviors by keyword
  List<Behavior> search(String query) {
    if (_library == null || query.isEmpty) return [];
    return _library!.search(query);
  }

  /// Get behavior by ID
  Behavior? getBehaviorById(String id) {
    return _library?.getBehaviorById(id);
  }

  /// Get all behaviors in a flat list
  List<Behavior> get allBehaviors => _library?.allBehaviors ?? [];

  /// Get category by ID
  BehaviorCategory? getCategoryById(String id) {
    return categories.where((c) => c.id == id).firstOrNull;
  }

  /// Get behaviors by nature (healthy/unhealthy/context-dependent)
  List<Behavior> getBehaviorsByNature(BehaviorNature nature) {
    return allBehaviors.where((b) => b.nature == nature).toList();
  }

  /// Get healthy behaviors
  List<Behavior> get healthyBehaviors =>
      getBehaviorsByNature(BehaviorNature.healthy);

  /// Get unhealthy behaviors
  List<Behavior> get unhealthyBehaviors =>
      getBehaviorsByNature(BehaviorNature.unhealthy);

  /// Get behaviors by category name
  List<Behavior> getBehaviorsByCategory(String categoryName) {
    final cat = categories.where((c) => c.category == categoryName).firstOrNull;
    if (cat == null) return [];
    return cat.subcategories.expand((s) => s.behaviors).toList();
  }

  /// Search behaviors by keyword (alias for search)
  List<Behavior> searchBehaviors(String query) => search(query);

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String get accessibilityStateLabel {
    if (_isLoading) return 'Loading behavior library';
    if (_error != null) return 'Error loading library';
    return '$totalBehaviors behaviors available in ${categories.length} categories';
  }
}
