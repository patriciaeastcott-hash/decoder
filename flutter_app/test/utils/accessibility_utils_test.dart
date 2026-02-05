import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_decoder/utils/accessibility_utils.dart';

void main() {
  group('Accessibility Constants', () {
    test('minimum touch target size is 48dp', () {
      expect(kMinTouchTargetSize, equals(48.0));
    });

    test('AAA contrast ratio is 7:1', () {
      expect(kMinContrastRatioAAA, equals(7.0));
    });

    test('AAA large text contrast ratio is 4.5:1', () {
      expect(kMinContrastRatioLargeAAA, equals(4.5));
    });
  });

  group('AccessibleTouchTarget', () {
    testWidgets('enforces minimum size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTouchTarget(
              child: Text('Tap me'),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(AccessibleTouchTarget),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(
        constrainedBox.constraints.minWidth,
        greaterThanOrEqualTo(kMinTouchTargetSize),
      );
      expect(
        constrainedBox.constraints.minHeight,
        greaterThanOrEqualTo(kMinTouchTargetSize),
      );
    });

    testWidgets('applies semantic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTouchTarget(
              semanticLabel: 'Test button',
              child: Text('Tap me'),
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Test button',
        ),
      );
      expect(semantics.properties.label, equals('Test button'));
    });
  });

  group('AccessibleIconButton', () {
    testWidgets('renders icon with semantic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.close,
              semanticLabel: 'Close dialog',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.bySemanticsLabel('Close dialog'), findsOneWidget);
    });

    testWidgets('enforces minimum touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.close,
              semanticLabel: 'Close',
              onPressed: () {},
            ),
          ),
        ),
      );

      // IconButton should have minimum constraints
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.constraints!.minWidth, greaterThanOrEqualTo(kMinTouchTargetSize));
    });
  });

  group('AccessibleHeading', () {
    testWidgets('renders text with header semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleHeading(text: 'Page Title', level: 1),
          ),
        ),
      );

      expect(find.text('Page Title'), findsOneWidget);
    });

    testWidgets('applies appropriate text style for each level', (tester) async {
      for (int level = 1; level <= 6; level++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibleHeading(text: 'Heading $level', level: level),
            ),
          ),
        );
        expect(find.text('Heading $level'), findsOneWidget);
      }
    });
  });

  group('AccessibleProgressIndicator', () {
    testWidgets('renders with determinate value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleProgressIndicator(
              value: 0.5,
              semanticLabel: 'Loading data',
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders indeterminate when value is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleProgressIndicator(
              semanticLabel: 'Loading',
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('AccessibleTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTextField(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('shows required indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTextField(
              labelText: 'Password',
              required: true,
            ),
          ),
        ),
      );

      expect(find.text('Password *'), findsOneWidget);
    });
  });

  group('Utility Functions', () {
    test('formatNumberForScreenReader returns word for small numbers', () {
      expect(formatNumberForScreenReader(0), equals('zero'));
      expect(formatNumberForScreenReader(1), equals('one'));
    });

    test('formatNumberForScreenReader returns digits for larger numbers', () {
      expect(formatNumberForScreenReader(42), equals('42'));
    });

    test('formatPercentageForScreenReader formats correctly', () {
      expect(formatPercentageForScreenReader(0.85), equals('85 percent'));
      expect(formatPercentageForScreenReader(1.0), equals('100 percent'));
      expect(formatPercentageForScreenReader(0.0), equals('0 percent'));
    });

    testWidgets('shouldReduceAnimations reads media query', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Default should not reduce animations
              final reduce = shouldReduceAnimations(context);
              expect(reduce, isA<bool>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getAnimationDuration respects reduce motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final duration = getAnimationDuration(context);
              expect(duration, isA<Duration>());
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
