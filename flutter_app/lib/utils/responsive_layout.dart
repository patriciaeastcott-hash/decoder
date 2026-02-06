/// Responsive layout utilities for adaptive UI across all form factors.
///
/// Breakpoints follow Material Design 3 responsive guidelines:
/// - Compact (phone): < 600px
/// - Medium (tablet portrait, foldable): 600-839px
/// - Expanded (tablet landscape, desktop): 840-1199px
/// - Large (desktop): 1200-1599px
/// - Extra large (wide desktop): >= 1600px
///
/// Layout patterns:
/// - Phone: Bottom navigation bar, single-column
/// - Tablet: Navigation rail, two-column master-detail
/// - Desktop: Persistent navigation drawer, multi-column

import 'package:flutter/material.dart';

// ============================================
// Breakpoints
// ============================================

class Breakpoints {
  Breakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double large = 1600;

  /// Content max width for readability (WCAG guideline)
  static const double maxContentWidth = 960;

  /// Max width for dialogs on large screens
  static const double maxDialogWidth = 560;

  /// Max width for forms on large screens
  static const double maxFormWidth = 480;
}

// ============================================
// Window size class (Material Design 3)
// ============================================

enum WindowSizeClass {
  compact, // Phone portrait
  medium, // Phone landscape, tablet portrait, foldable
  expanded, // Tablet landscape, small desktop
  large, // Desktop
  extraLarge, // Wide desktop
}

extension WindowSizeClassExtension on WindowSizeClass {
  bool get isCompact => this == WindowSizeClass.compact;
  bool get isMediumOrLarger => index >= WindowSizeClass.medium.index;
  bool get isExpandedOrLarger => index >= WindowSizeClass.expanded.index;
  bool get isLargeOrLarger => index >= WindowSizeClass.large.index;

  /// Standard padding for this window size
  double get horizontalPadding {
    switch (this) {
      case WindowSizeClass.compact:
        return 16;
      case WindowSizeClass.medium:
        return 24;
      case WindowSizeClass.expanded:
        return 32;
      case WindowSizeClass.large:
      case WindowSizeClass.extraLarge:
        return 48;
    }
  }

  /// Number of columns in a standard grid
  int get gridColumns {
    switch (this) {
      case WindowSizeClass.compact:
        return 4;
      case WindowSizeClass.medium:
        return 8;
      case WindowSizeClass.expanded:
      case WindowSizeClass.large:
      case WindowSizeClass.extraLarge:
        return 12;
    }
  }
}

// ============================================
// Responsive helper - determines current window class
// ============================================

class ResponsiveHelper {
  ResponsiveHelper._();

  static WindowSizeClass getWindowSizeClass(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return getWindowSizeClassFromWidth(width);
  }

  static WindowSizeClass getWindowSizeClassFromWidth(double width) {
    if (width < Breakpoints.compact) return WindowSizeClass.compact;
    if (width < Breakpoints.medium) return WindowSizeClass.medium;
    if (width < Breakpoints.expanded) return WindowSizeClass.expanded;
    if (width < Breakpoints.large) return WindowSizeClass.large;
    return WindowSizeClass.extraLarge;
  }

  /// Whether to show bottom navigation (compact) vs rail/drawer
  static bool showBottomNav(BuildContext context) {
    return getWindowSizeClass(context).isCompact;
  }

  /// Whether to show navigation rail (medium/expanded)
  static bool showNavigationRail(BuildContext context) {
    final sizeClass = getWindowSizeClass(context);
    return sizeClass == WindowSizeClass.medium ||
        sizeClass == WindowSizeClass.expanded;
  }

  /// Whether to show navigation drawer (large+)
  static bool showNavigationDrawer(BuildContext context) {
    return getWindowSizeClass(context).isLargeOrLarger;
  }

  /// Whether to use a two-pane master-detail layout
  static bool showMasterDetail(BuildContext context) {
    return getWindowSizeClass(context).isExpandedOrLarger;
  }
}

// ============================================
// Responsive scaffold - adaptive navigation
// ============================================

class ResponsiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final List<Widget> bodies;
  final Widget? floatingActionButton;
  final String? title;

  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.bodies,
    this.floatingActionButton,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final windowClass = ResponsiveHelper.getWindowSizeClass(context);

    // Compact: bottom navigation bar (phone)
    if (windowClass.isCompact) {
      return Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: bodies,
        ),
        bottomNavigationBar: Semantics(
          label: 'Main navigation',
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
          ),
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    // Medium/Expanded: navigation rail (tablet/small desktop)
    if (windowClass == WindowSizeClass.medium ||
        windowClass == WindowSizeClass.expanded) {
      return Scaffold(
        body: Row(
          children: [
            Semantics(
              label: 'Main navigation',
              child: NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                extended: windowClass == WindowSizeClass.expanded,
                labelType: windowClass == WindowSizeClass.medium
                    ? NavigationRailLabelType.selected
                    : NavigationRailLabelType.none,
                leading: windowClass == WindowSizeClass.expanded
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          title ?? 'Text Decoder',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      )
                    : null,
                destinations: destinations.map((d) {
                  return NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  );
                }).toList(),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: bodies,
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    // Large/Extra large: persistent navigation drawer (desktop)
    return Scaffold(
      body: Row(
        children: [
          Semantics(
            label: 'Main navigation',
            child: NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                  child: Text(
                    title ?? 'Text Decoder',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 0, 28, 16),
                  child: Text('Digital ABCs AI App'),
                ),
                const Divider(indent: 28, endIndent: 28),
                ...destinations.map((d) {
                  return NavigationDrawerDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  );
                }),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: bodies,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

// ============================================
// Responsive content wrapper - constrains width
// ============================================

/// Constrains content width for readability on large screens.
/// Centres content and adds appropriate padding per breakpoint.
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final windowClass = ResponsiveHelper.getWindowSizeClass(context);
    final effectiveMaxWidth = maxWidth ?? Breakpoints.maxContentWidth;
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: windowClass.horizontalPadding,
          vertical: 16,
        );

    // On compact screens, just add padding
    if (windowClass.isCompact) {
      return Padding(
        padding: effectivePadding,
        child: child,
      );
    }

    // On larger screens, constrain width and centre
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

// ============================================
// Responsive grid
// ============================================

/// Adaptive grid that adjusts columns based on screen width
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double minChildWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.minChildWidth = 300,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minChildWidth).floor().clamp(1, 4);
        final childWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: childWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================
// Responsive dialog
// ============================================

/// Shows a dialog that adapts to screen size.
/// On desktop/tablet, constrains width. On phone, uses full-width.
Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? maxWidth,
}) {
  final windowClass = ResponsiveHelper.getWindowSizeClass(context);

  if (windowClass.isCompact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: builder,
    );
  }

  return showDialog<T>(
    context: context,
    builder: (context) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? Breakpoints.maxDialogWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: builder(context),
          ),
        ),
      );
    },
  );
}
