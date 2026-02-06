import 'package:flutter_test/flutter_test.dart';
import 'package:text_decoder/services/accessibility_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AccessibilityService service;

  setUp(() {
    service = AccessibilityService();
  });

  group('AccessibilityService', () {
    group('Contrast Ratio', () {
      test('minimum AAA contrast ratio is 7.0', () {
        expect(AccessibilityService.minimumContrastRatioAAA, equals(7.0));
      });

      test('minimum large text AAA contrast ratio is 4.5', () {
        expect(
          AccessibilityService.minimumContrastRatioLargeTextAAA,
          equals(4.5),
        );
      });
    });

    group('Haptic Feedback', () {
      test('does not throw for any feedback type', () {
        for (final type in HapticFeedbackType.values) {
          expect(
            () => service.provideHapticFeedback(type),
            returnsNormally,
          );
        }
      });
    });

    group('Date Formatting', () {
      test('formatDateForScreenReader returns readable string for old dates', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        final result = service.formatDateForScreenReader(date);
        expect(result, contains('March'));
        expect(result, contains('15'));
        expect(result, contains('2024'));
      });

      test('formatDateForScreenReader returns Today for current date', () {
        final now = DateTime.now();
        final result = service.formatDateForScreenReader(now);
        expect(result, contains('Today'));
      });
    });

    group('Health Score Labels', () {
      test('getHealthScoreSemanticLabel returns label for high scores', () {
        final result = service.getHealthScoreSemanticLabel(85);
        expect(result, contains('85'));
        expect(result, contains('very healthy'));
      });

      test('getHealthScoreSemanticLabel returns label for mid scores', () {
        final result = service.getHealthScoreSemanticLabel(65);
        expect(result, contains('65'));
        expect(result, contains('healthy'));
      });

      test('getHealthScoreSemanticLabel returns label for low scores', () {
        final result = service.getHealthScoreSemanticLabel(15);
        expect(result, contains('15'));
        expect(result, contains('very unhealthy'));
      });
    });

    group('Risk Level Labels', () {
      test('getRiskLevelSemanticLabel for low risk', () {
        final result = service.getRiskLevelSemanticLabel('low');
        expect(result, contains('Low risk'));
      });

      test('getRiskLevelSemanticLabel for high risk', () {
        final result = service.getRiskLevelSemanticLabel('high');
        expect(result, contains('High risk'));
      });
    });

    group('Duration Formatting', () {
      test('formatDurationForScreenReader handles hours and minutes', () {
        final result = service.formatDurationForScreenReader(
          const Duration(hours: 2, minutes: 30),
        );
        expect(result, contains('2 hours'));
        expect(result, contains('30 minutes'));
      });

      test('formatDurationForScreenReader handles seconds', () {
        final result = service.formatDurationForScreenReader(
          const Duration(seconds: 45),
        );
        expect(result, contains('45 seconds'));
      });
    });

    group('Platform Input', () {
      test('isPointerPlatform returns bool', () {
        expect(service.isPointerPlatform, isA<bool>());
      });

      test('isTouchPlatform returns bool', () {
        expect(service.isTouchPlatform, isA<bool>());
      });

      test('getInteractionHint returns appropriate hint', () {
        final hint = service.getInteractionHint(
          touchHint: 'Tap to open',
          pointerHint: 'Click to open',
        );
        expect(hint, isNotEmpty);
        expect(hint, anyOf(equals('Tap to open'), equals('Click to open')));
      });
    });
  });

  group('HapticFeedbackType', () {
    test('has all expected types', () {
      expect(HapticFeedbackType.values.length, greaterThanOrEqualTo(7));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.light));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.medium));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.heavy));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.selection));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.success));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.warning));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.error));
    });
  });
}
