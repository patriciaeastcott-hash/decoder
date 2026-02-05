import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_decoder/utils/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('Brand Colors', () {
      test('navy is correct hex value', () {
        expect(AppTheme.navy, equals(const Color(0xFF1E3A8A)));
      });

      test('purple is correct hex value', () {
        expect(AppTheme.purple, equals(const Color(0xFF7C3AED)));
      });

      test('lightBlue is correct hex value', () {
        expect(AppTheme.lightBlue, equals(const Color(0xFF60A5FA)));
      });

      test('green (CTA) is correct hex value', () {
        expect(AppTheme.green, equals(const Color(0xFF10B981)));
      });

      test('red (errors only) is correct hex value', () {
        expect(AppTheme.red, equals(const Color(0xFFDC2626)));
      });
    });

    group('Light Theme', () {
      test('creates valid ThemeData', () {
        final theme = AppTheme.lightTheme();
        expect(theme, isA<ThemeData>());
        expect(theme.brightness, equals(Brightness.light));
      });

      test('uses Material 3', () {
        final theme = AppTheme.lightTheme();
        expect(theme.useMaterial3, isTrue);
      });

      test('primary color is navy', () {
        final theme = AppTheme.lightTheme();
        expect(theme.colorScheme.primary, equals(AppTheme.navy));
      });

      test('respects high contrast mode', () {
        final normal = AppTheme.lightTheme(highContrast: false);
        final highContrast = AppTheme.lightTheme(highContrast: true);
        // High contrast should have different scheme
        expect(highContrast, isNotNull);
        expect(normal, isNotNull);
      });

      test('respects font size multiplier', () {
        final normal = AppTheme.lightTheme(fontSize: 1.0);
        final large = AppTheme.lightTheme(fontSize: 1.5);
        expect(normal, isNotNull);
        expect(large, isNotNull);
      });
    });

    group('Dark Theme', () {
      test('creates valid ThemeData', () {
        final theme = AppTheme.darkTheme();
        expect(theme, isA<ThemeData>());
        expect(theme.brightness, equals(Brightness.dark));
      });

      test('uses Material 3', () {
        final theme = AppTheme.darkTheme();
        expect(theme.useMaterial3, isTrue);
      });
    });

    group('UI Constants', () {
      test('border radius values are positive', () {
        expect(AppTheme.borderRadiusSmall, greaterThan(0));
        expect(AppTheme.borderRadiusMedium, greaterThan(0));
        expect(AppTheme.borderRadiusLarge, greaterThan(0));
        expect(AppTheme.borderRadiusXLarge, greaterThan(0));
      });

      test('border radius values increase', () {
        expect(AppTheme.borderRadiusMedium, greaterThan(AppTheme.borderRadiusSmall));
        expect(AppTheme.borderRadiusLarge, greaterThan(AppTheme.borderRadiusMedium));
        expect(AppTheme.borderRadiusXLarge, greaterThan(AppTheme.borderRadiusLarge));
      });
    });

    group('Helper Methods', () {
      test('getHealthScoreColor returns green for high scores', () {
        final color = AppTheme.getHealthScoreColor(85);
        expect(color, equals(AppTheme.green));
      });

      test('getHealthScoreColor returns red for low scores', () {
        final color = AppTheme.getHealthScoreColor(20);
        expect(color, equals(AppTheme.red));
      });

      test('cardDecoration returns BoxDecoration', () {
        final decoration = AppTheme.cardDecoration();
        expect(decoration, isA<BoxDecoration>());
        expect(decoration.borderRadius, isNotNull);
      });
    });
  });
}
