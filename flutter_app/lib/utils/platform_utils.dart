/// Platform detection utilities for cross-platform compatibility
///
/// Provides safe platform detection that works on all targets:
/// iOS, Android, Web, Windows, macOS, Linux
///
/// Uses kIsWeb for web detection to avoid dart:io crashes on web.
library;

import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

/// App platform categories
enum AppPlatform {
  iOS,
  android,
  web,
  windows,
  macOS,
  linux,
}

/// Device form factor categories
enum DeviceFormFactor {
  phone,
  tablet,
  desktop,
}

/// Platform detection that safely works across all targets.
///
/// NEVER use dart:io Platform directly — it crashes on web.
/// Always use this class instead.
class PlatformUtils {
  PlatformUtils._();

  // ============================================
  // Platform detection
  // ============================================

  static AppPlatform get currentPlatform {
    if (kIsWeb) return AppPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return AppPlatform.iOS;
      case TargetPlatform.android:
        return AppPlatform.android;
      case TargetPlatform.macOS:
        return AppPlatform.macOS;
      case TargetPlatform.windows:
        return AppPlatform.windows;
      case TargetPlatform.linux:
        return AppPlatform.linux;
      case TargetPlatform.fuchsia:
        return AppPlatform.linux; // fallback
    }
  }

  /// True if running in a web browser
  static bool get isWeb => kIsWeb;

  /// True if running on iOS (not web)
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// True if running on Android (not web)
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// True if running on macOS (not web)
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// True if running on Windows (not web)
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// True if running on Linux (not web)
  static bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  // ============================================
  // Platform categories
  // ============================================

  /// True if running on a mobile device (iOS or Android, not web)
  static bool get isMobile => isIOS || isAndroid;

  /// True if running on a desktop OS (Windows, macOS, Linux, not web)
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// True if running on an Apple platform (iOS or macOS, not web)
  static bool get isApplePlatform => isIOS || isMacOS;

  // ============================================
  // Feature availability
  // ============================================

  /// Whether Google Sign-In is available on this platform
  static bool get supportsGoogleSignIn => isIOS || isAndroid || isWeb;

  /// Whether Apple Sign-In is available on this platform
  static bool get supportsAppleSignIn => isIOS || isMacOS;

  /// Whether Firebase is fully supported
  static bool get supportsFirebase => isIOS || isAndroid || isWeb || isMacOS;

  /// Whether haptic feedback is available
  static bool get supportsHapticFeedback => isMobile;

  /// Whether the system tray is available (desktop)
  static bool get supportsSystemTray => isDesktop;

  /// Whether the app can be resized freely (desktop/web)
  static bool get supportsWindowResize => isDesktop || isWeb;

  /// Whether touch input is the primary input method
  static bool get isTouchPrimary => isMobile;

  /// Whether mouse/keyboard is the primary input method
  static bool get isPointerPrimary => isDesktop || isWeb;

  /// Whether the platform supports native file system access
  static bool get supportsNativeFileSystem => !isWeb;

  /// Whether orientation locking makes sense (mobile only)
  static bool get supportsOrientationLock => isMobile;

  /// Whether SystemNavigator.pop() works (Android only)
  static bool get supportsSystemNavigatorPop => isAndroid;

  // ============================================
  // App store identifiers
  // ============================================

  /// The app store this platform targets
  static String get storeName {
    switch (currentPlatform) {
      case AppPlatform.iOS:
        return 'Apple App Store';
      case AppPlatform.android:
        return 'Google Play Store';
      case AppPlatform.web:
        return 'Web';
      case AppPlatform.windows:
        return 'Microsoft Store';
      case AppPlatform.macOS:
        return 'Mac App Store';
      case AppPlatform.linux:
        return 'Linux';
    }
  }

  /// Human-readable platform name
  static String get platformName {
    switch (currentPlatform) {
      case AppPlatform.iOS:
        return 'iOS';
      case AppPlatform.android:
        return 'Android';
      case AppPlatform.web:
        return 'Web';
      case AppPlatform.windows:
        return 'Windows';
      case AppPlatform.macOS:
        return 'macOS';
      case AppPlatform.linux:
        return 'Linux';
    }
  }

  // ============================================
  // App store compliance helpers
  // ============================================

  /// Minimum age rating required (PEGI / ESRB equivalent)
  /// Text Decoder deals with psychological analysis, so 12+ is appropriate
  static int get minimumAgeRating => 12;

  /// Whether the platform requires a privacy policy URL
  static bool get requiresPrivacyPolicyUrl => true; // All stores require it

  /// Whether the platform requires data deletion capability
  static bool get requiresDataDeletion {
    // Apple App Store and Google Play both require this
    return isIOS || isAndroid || isMacOS || isWeb;
  }

  /// Privacy policy URL for Digital ABCs
  static const String privacyPolicyUrl = 'https://digitalabcs.com.au/privacy.html';

  /// Terms of Service URL for Digital ABCs
  static const String termsOfServiceUrl = 'https://digitalabcs.com.au/terms.html';

  /// Support URL
  static const String supportUrl = 'https://digitalabcs.com.au/support.html';
}
