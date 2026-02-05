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
  });

  group('WindowSizeClass', () {
    test('has all expected values', () {
      expect(WindowSizeClass.values, contains(WindowSizeClass.compact));
      expect(WindowSizeClass.values, contains(WindowSizeClass.medium));
      expect(WindowSizeClass.values, contains(WindowSizeClass.expanded));
      expect(WindowSizeClass.values, contains(WindowSizeClass.large));
    });
  });

  group('ResponsiveHelper', () {
    test('getWindowSizeClass returns compact for narrow widths', () {
      expect(
        ResponsiveHelper.getWindowSizeClass(400),
        equals(WindowSizeClass.compact),
      );
    });

    test('getWindowSizeClass returns medium for tablet widths', () {
      expect(
        ResponsiveHelper.getWindowSizeClass(700),
        equals(WindowSizeClass.medium),
      );
    });

    test('getWindowSizeClass returns expanded for desktop widths', () {
      expect(
        ResponsiveHelper.getWindowSizeClass(1000),
        equals(WindowSizeClass.expanded),
      );
    });

    test('getWindowSizeClass returns large for wide screens', () {
      expect(
        ResponsiveHelper.getWindowSizeClass(1400),
        equals(WindowSizeClass.large),
      );
    });

    test('showBottomNav for compact only', () {
      expect(ResponsiveHelper.showBottomNav(400), isTrue);
      expect(ResponsiveHelper.showBottomNav(800), isFalse);
    });

    test('showNavigationRail for medium/expanded', () {
      expect(ResponsiveHelper.showNavigationRail(400), isFalse);
      expect(ResponsiveHelper.showNavigationRail(800), isTrue);
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
  });

  group('ResponsiveContentWrapper', () {
    testWidgets('constrains width on wide screens', (tester) async {
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
