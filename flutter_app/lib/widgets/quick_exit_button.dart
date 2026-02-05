/// Quick exit button widget for safety features
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

/// Floating quick exit button that appears when enabled in settings
class QuickExitButton extends StatelessWidget {
  const QuickExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.quickExitEnabled) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: 16,
          bottom: 80,
          child: Semantics(
            label: 'Quick exit button. Tap to immediately close the app',
            button: true,
            child: FloatingActionButton.small(
              heroTag: 'quick_exit',
              backgroundColor: Colors.red,
              onPressed: () => _handleQuickExit(context),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _handleQuickExit(BuildContext context) {
    final appState = context.read<AppStateProvider>();
    appState.quickExit();
  }
}

/// Quick exit app bar action
class QuickExitAction extends StatelessWidget {
  const QuickExitAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.quickExitEnabled) {
          return const SizedBox.shrink();
        }

        return Semantics(
          label: 'Quick exit',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleQuickExit(context),
            tooltip: 'Quick exit',
          ),
        );
      },
    );
  }

  void _handleQuickExit(BuildContext context) {
    final appState = context.read<AppStateProvider>();
    appState.quickExit();
  }
}

/// Quick exit banner that shows at top of screen
class QuickExitBanner extends StatelessWidget {
  const QuickExitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.quickExitEnabled) {
          return const SizedBox.shrink();
        }

        return Semantics(
          label: 'Tap anywhere on this bar to quickly exit the app',
          button: true,
          child: GestureDetector(
            onTap: () => _handleQuickExit(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tap here to exit quickly',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleQuickExit(BuildContext context) {
    final appState = context.read<AppStateProvider>();
    appState.quickExit();
  }
}

/// Gesture detector wrapper that triggers quick exit on shake or specific gesture
class QuickExitGestureDetector extends StatelessWidget {
  final Widget child;
  final int tapCount;

  const QuickExitGestureDetector({
    super.key,
    required this.child,
    this.tapCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.quickExitEnabled) {
          return child;
        }

        return _MultiTapDetector(
          requiredTaps: tapCount,
          onMultiTap: () => _handleQuickExit(context),
          child: child,
        );
      },
    );
  }

  void _handleQuickExit(BuildContext context) {
    final appState = context.read<AppStateProvider>();
    appState.quickExit();
  }
}

class _MultiTapDetector extends StatefulWidget {
  final Widget child;
  final int requiredTaps;
  final VoidCallback onMultiTap;

  static const Duration timeout = Duration(seconds: 1);

  const _MultiTapDetector({
    required this.child,
    required this.requiredTaps,
    required this.onMultiTap,
  });

  @override
  State<_MultiTapDetector> createState() => _MultiTapDetectorState();
}

class _MultiTapDetectorState extends State<_MultiTapDetector> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();

    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) > _MultiTapDetector.timeout) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      widget.onMultiTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
