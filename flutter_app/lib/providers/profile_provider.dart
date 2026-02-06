/// Profile provider for managing speaker profiles and analysis
library;

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService = ApiService();

  ProfileProvider({required StorageService storageService})
      : _storageService = storageService;

  // ============================================
  // STATE
  // ============================================

  List<Profile> _profiles = [];
  List<Profile> get profiles => _profiles;

  List<Profile> get speakerProfiles =>
      _profiles.where((p) => !p.isUserProfile).toList();

  Profile? _userProfile;
  Profile? get userProfile => _userProfile;

  Profile? _currentProfile;
  Profile? get currentProfile => _currentProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  // Self profile analysis
  SelfProfileAnalysis? _selfProfileAnalysis;
  SelfProfileAnalysis? get selfProfileAnalysis => _selfProfileAnalysis;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> loadProfiles() async {
    _setLoading(true);

    try {
      _profiles = await _storageService.getAllProfiles();
      _userProfile = _profiles.where((p) => p.isUserProfile).firstOrNull;
      _clearError();
    } catch (e) {
      _setError('Failed to load profiles: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // PROFILE CRUD
  // ============================================

  /// Create a new speaker profile
  Future<Profile?> createProfile({
    required String name,
    int retentionMonths = 12,
  }) async {
    _setLoading(true);

    try {
      final profile = Profile.forSpeaker(
        DateTime.now().millisecondsSinceEpoch.toString(),
        name,
        retentionMonths: retentionMonths,
      );

      await _storageService.saveProfile(profile);
      _profiles.add(profile);
      _clearError();
      notifyListeners();
      return profile;
    } catch (e) {
      _setError('Failed to create profile: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Create or get user's self profile
  Future<Profile?> createUserProfile({
    required String userId,
    required String name,
  }) async {
    // Check if user profile already exists
    if (_userProfile != null) return _userProfile;

    _setLoading(true);

    try {
      final profile = Profile.forUser(userId, name);
      await _storageService.saveProfile(profile);
      _profiles.add(profile);
      _userProfile = profile;
      _clearError();
      notifyListeners();
      return profile;
    } catch (e) {
      _setError('Failed to create user profile: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific profile
  Future<Profile?> getProfile(String id) async {
    // Check local list first
    final local = _profiles.where((p) => p.id == id).firstOrNull;
    if (local != null) {
      _currentProfile = local;
      notifyListeners();
      return local;
    }

    // Load from storage
    final profile = await _storageService.getProfile(id);
    if (profile != null) {
      _currentProfile = profile;
      notifyListeners();
    }
    return profile;
  }

  /// Update a profile
  Future<bool> updateProfile(Profile profile) async {
    try {
      final updated = profile.copyWith(updatedAt: DateTime.now());
      await _storageService.saveProfile(updated);

      // Update local list
      final index = _profiles.indexWhere((p) => p.id == profile.id);
      if (index >= 0) {
        _profiles[index] = updated;
      }

      if (_currentProfile?.id == profile.id) {
        _currentProfile = updated;
      }

      if (profile.isUserProfile) {
        _userProfile = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  /// Delete a profile
  Future<bool> deleteProfile(String id) async {
    try {
      await _storageService.deleteProfile(id);
      _profiles.removeWhere((p) => p.id == id);

      if (_currentProfile?.id == id) {
        _currentProfile = null;
      }

      if (_userProfile?.id == id) {
        _userProfile = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete profile: $e');
      return false;
    }
  }

  /// Delete all profiles
  Future<bool> deleteAllProfiles() async {
    try {
      await _storageService.deleteAllProfiles();
      _profiles.clear();
      _currentProfile = null;
      _userProfile = null;
      _selfProfileAnalysis = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete profiles: $e');
      return false;
    }
  }

  // ============================================
  // CONVERSATION LINKING
  // ============================================

  /// Link a conversation to a profile
  Future<bool> linkConversation({
    required String profileId,
    required String conversationId,
  }) async {
    final profile = await getProfile(profileId);
    if (profile == null) return false;

    if (profile.conversationIds.contains(conversationId)) {
      return true; // Already linked
    }

    final updatedConversationIds = [
      ...profile.conversationIds,
      conversationId,
    ];

    return updateProfile(profile.copyWith(
      conversationIds: updatedConversationIds,
    ));
  }

  /// Unlink a conversation from a profile
  Future<bool> unlinkConversation({
    required String profileId,
    required String conversationId,
  }) async {
    final profile = await getProfile(profileId);
    if (profile == null) return false;

    final updatedConversationIds = profile.conversationIds
        .where((id) => id != conversationId)
        .toList();

    return updateProfile(profile.copyWith(
      conversationIds: updatedConversationIds,
    ));
  }

  // ============================================
  // PROFILE ANALYSIS
  // ============================================

  /// Analyze a speaker profile
  Future<bool> analyzeProfile({
    required Profile profile,
    required List<Conversation> conversations,
  }) async {
    if (conversations.length < 3) {
      _setError('Need at least 3 conversations for meaningful analysis');
      return false;
    }

    _isAnalyzing = true;
    notifyListeners();

    try {
      final result = await _apiService.analyzeProfile(
        profile: profile,
        conversations: conversations,
      );

      if (!result.isSuccess) {
        _setError(result.error ?? 'Profile analysis failed');
        return false;
      }

      // Create summary from analysis
      final summary = ProfileSummary(
        dominantCommunicationStyle:
            result.data!.communicationProfile?.dominantStyle ?? 'Unknown',
        attachmentStyle:
            result.data!.attachmentProfile?.primaryStyle ?? 'Unknown',
        emotionalRegulation:
            result.data!.emotionalProfile?.baselineRegulation ?? 'Unknown',
        overallHealthScore: 50, // Calculate from analysis
        topBehaviors: result.data!.behavioralPatterns?.frequentBehaviors
                .take(5)
                .map((b) => b.behavior)
                .toList() ??
            [],
        lastUpdated: DateTime.now(),
      );

      final updated = profile.copyWith(
        analysis: result.data,
        summary: summary,
        updatedAt: DateTime.now(),
      );

      await updateProfile(updated);
      _clearError();
      return true;
    } catch (e) {
      _setError('Profile analysis failed: $e');
      return false;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analyze user's self profile
  Future<bool> analyzeSelfProfile({
    required List<Conversation> conversations,
    required String userName,
  }) async {
    if (conversations.isEmpty) {
      _setError('Need at least 1 conversation for self-analysis');
      return false;
    }

    _isAnalyzing = true;
    notifyListeners();

    try {
      final result = await _apiService.analyzeSelfProfile(
        conversations: conversations,
        userName: userName,
      );

      if (!result.isSuccess) {
        _setError(result.error ?? 'Self-profile analysis failed');
        return false;
      }

      _selfProfileAnalysis = result.data;

      // Update user profile if exists
      if (_userProfile != null) {
        final summary = ProfileSummary(
          dominantCommunicationStyle: 'See detailed analysis',
          attachmentStyle: 'See detailed analysis',
          emotionalRegulation: 'See detailed analysis',
          overallHealthScore: 50,
          topBehaviors: const [],
          lastUpdated: DateTime.now(),
        );

        await updateProfile(_userProfile!.copyWith(summary: summary));
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Self-profile analysis failed: $e');
      return false;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // ============================================
  // PROFILE RETENTION
  // ============================================

  /// Update retention period for a profile
  Future<bool> updateRetentionPeriod({
    required String profileId,
    required int months,
  }) async {
    final profile = await getProfile(profileId);
    if (profile == null) return false;

    DateTime? newExpiresAt;
    if (months > 0) {
      newExpiresAt = DateTime.now().add(Duration(days: months * 30));
    }

    return updateProfile(profile.copyWith(
      retentionMonths: months,
      expiresAt: newExpiresAt,
    ));
  }

  /// Clean up expired profiles
  Future<int> cleanupExpiredProfiles() async {
    return await _storageService.cleanupExpiredProfiles();
  }

  // ============================================
  // FIND/MATCH PROFILES
  // ============================================

  /// Find profile by speaker name
  Profile? findProfileByName(String name) {
    return _profiles.where((p) =>
        p.name.toLowerCase() == name.toLowerCase() ||
        (p.displayName?.toLowerCase() == name.toLowerCase())
    ).firstOrNull;
  }

  /// Get profiles that need more data
  List<Profile> getProfilesNeedingData() {
    return speakerProfiles
        .where((p) => !p.hasEnoughDataForAnalysis)
        .toList();
  }

  /// Get profiles due for re-analysis (analysis older than 30 days)
  List<Profile> getProfilesDueForAnalysis() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return speakerProfiles
        .where((p) =>
            p.analysis == null ||
            p.analysis!.analyzedAt.isBefore(thirtyDaysAgo))
        .toList();
  }

  // ============================================
  // HELPERS
  // ============================================

  void setCurrentProfile(Profile? profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  void clearCurrentProfile() {
    _currentProfile = null;
    notifyListeners();
  }

  void clearSelfProfileAnalysis() {
    _selfProfileAnalysis = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================
  // ACCESSIBILITY
  // ============================================

  String get accessibilityStateLabel {
    if (_isLoading) return 'Loading profiles';
    if (_isAnalyzing) return 'Analyzing profile';
    if (error != null) return 'Error: $error';
    return '${speakerProfiles.length} speaker profiles available';
  }
}
