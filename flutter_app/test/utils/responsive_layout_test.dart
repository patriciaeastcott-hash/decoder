import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_decoder/utils/responsive_layout.dart';

void main() {
  group('Breakpoints', () {
    test('values are ordered correctly', () {
      expect(Breakpoints.compact, lessThan(Breakpoints.medium));
      expect(Breakpoints.medium, lessThan(Breakpoints.expanded));
      expect(Breakpoints.expanded, lessThan(Breakpoints.large));
    });

    test('maxContentWidth is reasonable', () {
      expect(Breakpoints.maxContentWidth, greaterThan(600));
      expect(Breakpoints.maxContentWidth, lessThan(2000));
    });

    test('maxFormWidth is reasonable', () {
      expect(Breakpoints.maxFormWidth, greaterThan(300));
      expect(Breakpoints.maxFormWidth, lessThan(Breakpoints.maxContentWidth));
    });
  });

  group('WindowSizeClass', () {
    test('has all expected values', () {
      expect(WindowSizeClass.values, contains(WindowSizeClass.compact));
      expect(WindowSizeClass.values, contains(WindowSizeClass.medium));
      expect(WindowSizeClass.values, contains(WindowSizeClass.expanded));
      expect(WindowSizeClass.values, contains(WindowSizeClass.large));
      expect(WindowSizeClass.values, contains(WindowSizeClass.extraLarge));
    });

    test('extensions work correctly', () {
      expect(WindowSizeClass.compact.isCompact, isTrue);
      expect(WindowSizeClass.medium.isCompact, isFalse);
      expect(WindowSizeClass.medium.isMediumOrLarger, isTrue);
      expect(WindowSizeClass.compact.isMediumOrLarger, isFalse);
      expect(WindowSizeClass.expanded.isExpandedOrLarger, isTrue);
      expect(WindowSizeClass.large.isLargeOrLarger, isTrue);
    });
  });

  group('ResponsiveHelper', () {
    test('getWindowSizeClassFromWidth returns compact for narrow widths', () {
      expect(
        ResponsiveHelper.getWindowSizeClassFromWidth(400),
        equals(WindowSizeClass.compact),
      );
    });

    test('getWindowSizeClassFromWidth returns medium for tablet widths', () {
      expect(
        ResponsiveHelper.getWindowSizeClassFromWidth(700),
        equals(WindowSizeClass.medium),
      );
    });

    test('getWindowSizeClassFromWidth returns expanded for desktop widths', () {
      expect(
        ResponsiveHelper.getWindowSizeClassFromWidth(1000),
        equals(WindowSizeClass.expanded),
      );
    });

    test('getWindowSizeClassFromWidth returns large for wide screens', () {
      expect(
        ResponsiveHelper.getWindowSizeClassFromWidth(1400),
        equals(WindowSizeClass.large),
      );
    });

    test('getWindowSizeClassFromWidth returns extraLarge for very wide screens', () {
      expect(
        ResponsiveHelper.getWindowSizeClassFromWidth(1800),
        equals(WindowSizeClass.extraLarge),
      );
    });
  });

  group('ResponsiveScaffold', () {
    testWidgets('renders with bottom nav on narrow screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveScaffold(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              bodies: const [
                Center(child: Text('Home')),
                Center(child: Text('Settings')),
              ],
              title: 'Test',
            ),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('renders with navigation rail on wide screen', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            bodies: const [
              Center(child: Text('Home')),
              Center(child: Text('Settings')),
            ],
            title: 'Test',
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
    });
  });

  group('ResponsiveContentWrapper', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContentWrapper(
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });
  });
}
