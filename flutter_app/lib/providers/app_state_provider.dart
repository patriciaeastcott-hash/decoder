/// App state provider for global application state

import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService _storageService;

  AppStateProvider({required StorageService storageService})
      : _storageService = storageService;

  // ============================================
  // INITIALIZATION STATE
  // ============================================

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isOnboardingComplete = false;
  bool get isOnboardingComplete => _isOnboardingComplete;

  // ============================================
  // LOADING STATES
  // ============================================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadingMessage;
  String? get loadingMessage => _loadingMessage;

  // ============================================
  // ERROR STATE
  // ============================================

  String? _error;
  String? get error => _error;

  bool get hasError => _error != null;

  // ============================================
  // CONNECTIVITY
  // ============================================

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // ============================================
  // QUICK EXIT
  // ============================================

  bool _quickExitTriggered = false;
  bool get quickExitTriggered => _quickExitTriggered;

  // ============================================
  // NAVIGATION STATE
  // ============================================

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  String? _currentConversationId;
  String? get currentConversationId => _currentConversationId;

  String? _currentProfileId;
  String? get currentProfileId => _currentProfileId;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    setLoading(true, message: 'Initializing app...');

    try {
      // Check onboarding status
      _isOnboardingComplete = _storageService.getSetting<bool>(
            'onboarding_complete',
            defaultValue: false,
          ) ??
          false;

      // Clean up expired profiles
      await _storageService.cleanupExpiredProfiles();

      _isInitialized = true;
      clearError();
    } catch (e) {
      setError('Failed to initialize app: $e');
    } finally {
      setLoading(false);
    }

    notifyListeners();
  }

  // ============================================
  // LOADING
  // ============================================

  void setLoading(bool loading, {String? message}) {
    _isLoading = loading;
    _loadingMessage = loading ? message : null;
    notifyListeners();
  }

  // ============================================
  // ERROR HANDLING
  // ============================================

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================
  // CONNECTIVITY
  // ============================================

  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  // ============================================
  // ONBOARDING
  // ============================================

  Future<void> completeOnboarding() async {
    await _storageService.saveSetting('onboarding_complete', true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await _storageService.saveSetting('onboarding_complete', false);
    _isOnboardingComplete = false;
    notifyListeners();
  }

  // ============================================
  // QUICK EXIT
  // ============================================

  /// Trigger quick exit - immediately closes app and clears recent apps
  void triggerQuickExit() {
    _quickExitTriggered = true;
    notifyListeners();

    // In Flutter, we can't directly control app exit behavior
    // The actual exit logic will be handled in the UI layer
    // using SystemNavigator.pop() or similar
  }

  void resetQuickExit() {
    _quickExitTriggered = false;
    notifyListeners();
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setCurrentConversation(String? id) {
    _currentConversationId = id;
    notifyListeners();
  }

  void setCurrentProfile(String? id) {
    _currentProfileId = id;
    notifyListeners();
  }

  void clearNavigation() {
    _currentConversationId = null;
    _currentProfileId = null;
    notifyListeners();
  }

  // ============================================
  // ACCESSIBILITY
  // ============================================

  String get accessibilityStateLabel {
    if (_isLoading) {
      return _loadingMessage ?? 'Loading';
    }
    if (hasError) {
      return 'Error: $_error';
    }
    if (!_isOnline) {
      return 'Offline mode';
    }
    return 'Ready';
  }
}
