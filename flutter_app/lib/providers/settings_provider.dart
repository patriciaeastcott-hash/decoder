/// Settings provider for app configuration
/// Handles theme, accessibility, privacy, and user preferences
library;

import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  SettingsProvider({required StorageService storageService})
      : _storageService = storageService;

  // ============================================
  // THEME SETTINGS
  // ============================================

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _highContrastMode = false;
  bool get highContrastMode => _highContrastMode;

  // ============================================
  // ACCESSIBILITY SETTINGS
  // ============================================

  double _fontSizeMultiplier = 1.0;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  bool _reduceMotion = false;
  bool get reduceMotion => _reduceMotion;

  bool _screenReaderOptimized = false;
  bool get screenReaderOptimized => _screenReaderOptimized;

  bool _hapticFeedbackEnabled = true;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  // ============================================
  // PRIVACY SETTINGS
  // ============================================

  int _dataRetentionMonths = 12;
  int get dataRetentionMonths => _dataRetentionMonths;

  bool _cloudSyncEnabled = false;
  bool get cloudSyncEnabled => _cloudSyncEnabled;

  bool _analyticsEnabled = false;
  bool get analyticsEnabled => _analyticsEnabled;

  // ============================================
  // APP SETTINGS
  // ============================================

  bool _showOnboarding = true;
  bool get showOnboarding => _showOnboarding;

  bool _quickExitEnabled = true;
  bool get quickExitEnabled => _quickExitEnabled;

  String _defaultUserName = '';
  String get defaultUserName => _defaultUserName;

  // ============================================
  // NOTIFICATION SETTINGS
  // ============================================

  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _analysisCompleteNotifications = true;
  bool get analysisCompleteNotifications => _analysisCompleteNotifications;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> initialize() async {
    // Load theme settings
    _themeMode = _stringToThemeMode(
      _storageService.getSetting<String>('theme_mode', defaultValue: 'system'),
    );
    _highContrastMode =
        _storageService.getSetting<bool>('high_contrast', defaultValue: false) ??
            false;

    // Load accessibility settings
    _fontSizeMultiplier =
        _storageService.getSetting<double>('font_size_multiplier',
            defaultValue: 1.0) ??
            1.0;
    _reduceMotion =
        _storageService.getSetting<bool>('reduce_motion', defaultValue: false) ??
            false;
    _screenReaderOptimized =
        _storageService.getSetting<bool>('screen_reader_optimized',
            defaultValue: false) ??
            false;
    _hapticFeedbackEnabled =
        _storageService.getSetting<bool>('haptic_feedback', defaultValue: true) ??
            true;

    // Load privacy settings
    _dataRetentionMonths =
        _storageService.getSetting<int>('data_retention_months',
            defaultValue: 12) ??
            12;
    _cloudSyncEnabled =
        _storageService.getSetting<bool>('cloud_sync_enabled',
            defaultValue: false) ??
            false;
    _analyticsEnabled =
        _storageService.getSetting<bool>('analytics_enabled',
            defaultValue: false) ??
            false;

    // Load app settings
    _showOnboarding =
        _storageService.getSetting<bool>('show_onboarding', defaultValue: true) ??
            true;
    _quickExitEnabled =
        _storageService.getSetting<bool>('quick_exit_enabled',
            defaultValue: true) ??
            true;
    _defaultUserName =
        _storageService.getSetting<String>('default_user_name',
            defaultValue: '') ??
            '';

    // Load notification settings
    _notificationsEnabled =
        _storageService.getSetting<bool>('notifications_enabled',
            defaultValue: false) ??
            false;
    _analysisCompleteNotifications =
        _storageService.getSetting<bool>('analysis_complete_notifications',
            defaultValue: true) ??
            true;

    notifyListeners();
  }

  // ============================================
  // THEME SETTERS
  // ============================================

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storageService.saveSetting('theme_mode', _themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setHighContrastMode(bool enabled) async {
    _highContrastMode = enabled;
    await _storageService.saveSetting('high_contrast', enabled);
    notifyListeners();
  }

  // ============================================
  // ACCESSIBILITY SETTERS
  // ============================================

  Future<void> setFontSizeMultiplier(double multiplier) async {
    // Clamp between 0.8 and 2.0 for accessibility
    _fontSizeMultiplier = multiplier.clamp(0.8, 2.0);
    await _storageService.saveSetting('font_size_multiplier', _fontSizeMultiplier);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool enabled) async {
    _reduceMotion = enabled;
    await _storageService.saveSetting('reduce_motion', enabled);
    notifyListeners();
  }

  Future<void> setScreenReaderOptimized(bool enabled) async {
    _screenReaderOptimized = enabled;
    await _storageService.saveSetting('screen_reader_optimized', enabled);
    notifyListeners();
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    _hapticFeedbackEnabled = enabled;
    await _storageService.saveSetting('haptic_feedback', enabled);
    notifyListeners();
  }

  // ============================================
  // PRIVACY SETTERS
  // ============================================

  Future<void> setDataRetentionMonths(int months) async {
    _dataRetentionMonths = months.clamp(1, 60);
    await _storageService.saveSetting('data_retention_months', _dataRetentionMonths);
    notifyListeners();
  }

  Future<void> setCloudSyncEnabled(bool enabled) async {
    _cloudSyncEnabled = enabled;
    await _storageService.saveSetting('cloud_sync_enabled', enabled);
    notifyListeners();
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    await _storageService.saveSetting('analytics_enabled', enabled);
    notifyListeners();
  }

  // ============================================
  // APP SETTERS
  // ============================================

  Future<void> setShowOnboarding(bool show) async {
    _showOnboarding = show;
    await _storageService.saveSetting('show_onboarding', show);
    notifyListeners();
  }

  Future<void> setQuickExitEnabled(bool enabled) async {
    _quickExitEnabled = enabled;
    await _storageService.saveSetting('quick_exit_enabled', enabled);
    notifyListeners();
  }

  Future<void> setDefaultUserName(String name) async {
    _defaultUserName = name;
    await _storageService.saveSetting('default_user_name', name);
    notifyListeners();
  }

  // ============================================
  // NOTIFICATION SETTERS
  // ============================================

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storageService.saveSetting('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setAnalysisCompleteNotifications(bool enabled) async {
    _analysisCompleteNotifications = enabled;
    await _storageService.saveSetting('analysis_complete_notifications', enabled);
    notifyListeners();
  }

  // ============================================
  // RESET
  // ============================================

  Future<void> resetToDefaults() async {
    await _storageService.resetSettings();
    await initialize();
  }

  // ============================================
  // HELPERS
  // ============================================

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Get accessibility settings summary for screen readers
  String get accessibilitySettingsSummary {
    final settings = <String>[];
    if (_highContrastMode) settings.add('high contrast enabled');
    if (_fontSizeMultiplier != 1.0) {
      settings.add('font size ${(_fontSizeMultiplier * 100).toInt()}%');
    }
    if (_reduceMotion) settings.add('reduced motion enabled');
    if (_screenReaderOptimized) settings.add('screen reader optimized');

    if (settings.isEmpty) return 'Default accessibility settings';
    return 'Accessibility: ${settings.join(', ')}';
  }

  /// Get privacy settings summary
  String get privacySettingsSummary {
    final settings = <String>[];
    settings.add('data retention: $_dataRetentionMonths months');
    if (_cloudSyncEnabled) settings.add('cloud sync enabled');
    if (!_analyticsEnabled) settings.add('analytics disabled');

    return 'Privacy: ${settings.join(', ')}';
  }
}
