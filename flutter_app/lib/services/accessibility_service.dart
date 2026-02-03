/// Accessibility service for WCAG 2.1 AAA compliance
/// Provides utilities and helpers for accessibility features

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

class AccessibilityService {
  /// WCAG 2.1 AAA minimum contrast ratio for normal text: 7:1
  static const double minimumContrastRatioAAA = 7.0;

  /// WCAG 2.1 AAA minimum contrast ratio for large text: 4.5:1
  static const double minimumContrastRatioLargeTextAAA = 4.5;

  /// Minimum touch target size (48x48 dp) for WCAG 2.1 AAA
  static const double minimumTouchTarget = 48.0;

  /// Check if high contrast mode should be enabled
  bool shouldEnableHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if reduce motion is enabled
  bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Check if screen reader is active
  bool isScreenReaderActive(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Check if bold text is enabled
  bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Get the current text scale factor
  double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Calculate luminance of a color
  double getLuminance(Color color) {
    return color.computeLuminance();
  }

  /// Calculate contrast ratio between two colors
  double getContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = getLuminance(foreground) + 0.05;
    final backgroundLuminance = getLuminance(background) + 0.05;

    return foregroundLuminance > backgroundLuminance
        ? foregroundLuminance / backgroundLuminance
        : backgroundLuminance / foregroundLuminance;
  }

  /// Check if colors meet WCAG AAA contrast requirements
  bool meetsWCAGAAAContrast(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = getContrastRatio(foreground, background);
    final minimumRatio =
        isLargeText ? minimumContrastRatioLargeTextAAA : minimumContrastRatioAAA;
    return ratio >= minimumRatio;
  }

  /// Get a foreground color that meets WCAG AAA against a background
  Color getAccessibleForegroundColor(Color background) {
    final whiteLuminance = getLuminance(Colors.white);
    final blackLuminance = getLuminance(Colors.black);
    final bgLuminance = getLuminance(background);

    final whiteRatio = (whiteLuminance + 0.05) / (bgLuminance + 0.05);
    final blackRatio = (bgLuminance + 0.05) / (blackLuminance + 0.05);

    return whiteRatio > blackRatio ? Colors.white : Colors.black;
  }

  /// Announce a message to screen readers
  void announce(String message, {TextDirection textDirection = TextDirection.ltr}) {
    SemanticsService.announce(message, textDirection);
  }

  /// Generate semantic label for conversation health score
  String getHealthScoreSemanticLabel(int score) {
    final category = _getHealthCategory(score);
    return 'Conversation health score: $score out of 100. This is considered $category.';
  }

  String _getHealthCategory(int score) {
    if (score >= 80) return 'very healthy';
    if (score >= 60) return 'healthy';
    if (score >= 40) return 'moderately healthy';
    if (score >= 20) return 'unhealthy';
    return 'very unhealthy';
  }

  /// Generate semantic label for risk levels
  String getRiskLevelSemanticLabel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 'Low risk. This indicates a generally safe situation.';
      case 'medium':
        return 'Medium risk. Some caution may be warranted.';
      case 'high':
        return 'High risk. This situation requires attention.';
      case 'severe':
        return 'Severe risk. Immediate attention recommended.';
      default:
        return 'Risk level: $level';
    }
  }

  /// Format duration for screen readers
  String formatDurationForScreenReader(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    if (minutes > 0) parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
    if (seconds > 0 && hours == 0) {
      parts.add('$seconds ${seconds == 1 ? 'second' : 'seconds'}');
    }

    return parts.join(' and ');
  }

  /// Format date for screen readers
  String formatDateForScreenReader(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${_getDayName(date.weekday)} at ${_formatTime(date)}';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Create haptic feedback for important actions
  void provideHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.success:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.warning:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.error:
        HapticFeedback.vibrate();
        break;
    }
  }
}

/// Types of haptic feedback
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  success,
  warning,
  error,
}

/// Extension for accessible widgets
extension AccessibleWidget on Widget {
  /// Wrap widget with semantic label
  Widget withSemanticLabel(String label, {String? hint}) {
    return Semantics(
      label: label,
      hint: hint,
      child: this,
    );
  }

  /// Wrap widget as a button with semantic label
  Widget withSemanticButton(String label, {String? hint, VoidCallback? onTap}) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      child: this,
    );
  }

  /// Wrap widget with exclude semantics
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Ensure minimum touch target size
  Widget withMinimumTouchTarget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AccessibilityService.minimumTouchTarget,
        minHeight: AccessibilityService.minimumTouchTarget,
      ),
      child: this,
    );
  }
}

/// Accessible color scheme that meets WCAG AAA
class AccessibleColors {
  // Primary colors with AAA contrast
  static const Color primaryDark = Color(0xFF1A237E); // Indigo 900
  static const Color primaryLight = Color(0xFFE8EAF6); // Indigo 50

  // Text colors
  static const Color textOnLight = Color(0xFF000000); // Pure black for max contrast
  static const Color textOnDark = Color(0xFFFFFFFF); // Pure white for max contrast
  static const Color textSecondaryOnLight = Color(0xFF37474F); // Blue Grey 800
  static const Color textSecondaryOnDark = Color(0xFFB0BEC5); // Blue Grey 200

  // Status colors with AAA contrast
  static const Color successDark = Color(0xFF1B5E20); // Green 900
  static const Color warningDark = Color(0xFFE65100); // Orange 900
  static const Color errorDark = Color(0xFFB71C1C); // Red 900
  static const Color infoDark = Color(0xFF01579B); // Light Blue 900

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Border colors
  static const Color borderLight = Color(0xFF757575);
  static const Color borderDark = Color(0xFFBDBDBD);

  /// Get semantic color for health score
  static Color getHealthScoreColor(int score, {bool isDark = false}) {
    if (score >= 70) {
      return isDark ? const Color(0xFF4CAF50) : successDark;
    } else if (score >= 40) {
      return isDark ? const Color(0xFFFF9800) : warningDark;
    } else {
      return isDark ? const Color(0xFFF44336) : errorDark;
    }
  }

  /// Get semantic color for risk level
  static Color getRiskLevelColor(String level, {bool isDark = false}) {
    switch (level.toLowerCase()) {
      case 'low':
        return isDark ? const Color(0xFF4CAF50) : successDark;
      case 'medium':
        return isDark ? const Color(0xFFFF9800) : warningDark;
      case 'high':
      case 'severe':
        return isDark ? const Color(0xFFF44336) : errorDark;
      default:
        return isDark ? textOnDark : textOnLight;
    }
  }
}

/// Focus management utilities
class FocusHelper {
  /// Request focus on a specific node
  static void requestFocus(FocusNode node) {
    node.requestFocus();
  }

  /// Move focus to next node
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous node
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Unfocus current node
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}

/// Skip link widget for keyboard navigation
class SkipLink extends StatelessWidget {
  final String label;
  final VoidCallback onActivate;

  const SkipLink({
    super.key,
    required this.label,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      focusable: true,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            // Show skip link when focused
          }
        },
        child: InkWell(
          onTap: onActivate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Live region widget for dynamic content updates
class LiveRegion extends StatelessWidget {
  final Widget child;
  final String label;
  final bool polite;

  const LiveRegion({
    super.key,
    required this.child,
    required this.label,
    this.polite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: child,
    );
  }
}
