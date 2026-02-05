import 'package:flutter_test/flutter_test.dart';
import 'package:text_decoder/services/accessibility_service.dart';

void main() {
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
          AccessibilityService.minimumContrastRatioLargeAAA,
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
      test('formatDateForScreenReader returns readable string', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        final result = service.formatDateForScreenReader(date);
        expect(result, contains('March'));
        expect(result, contains('15'));
        expect(result, contains('2024'));
      });

      test('formatTimeForScreenReader returns readable string', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        final result = service.formatTimeForScreenReader(date);
        expect(result, contains('2'));
        expect(result, contains('30'));
        expect(result, contains('PM'));
      });
    });

    group('Number Formatting', () {
      test('formatNumberForScreenReader handles zero', () {
        expect(service.formatNumberForScreenReader(0), equals('zero'));
      });

      test('formatNumberForScreenReader handles one', () {
        expect(service.formatNumberForScreenReader(1), equals('one'));
      });

      test('formatPercentageForScreenReader formats correctly', () {
        expect(
          service.formatPercentageForScreenReader(0.75),
          equals('75 percent'),
        );
      });
    });

    group('Score Descriptions', () {
      test('getScoreDescription returns high for scores >= 80', () {
        final result = service.getScoreDescription(85);
        expect(result, contains('High'));
      });

      test('getScoreDescription returns moderate for scores 50-79', () {
        final result = service.getScoreDescription(65);
        expect(result, contains('Moderate'));
      });

      test('getScoreDescription returns low for scores < 50', () {
        final result = service.getScoreDescription(30);
        expect(result, contains('Low'));
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
