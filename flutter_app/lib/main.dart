/// Text Decoder MVP — Digital ABCs AI App
///
/// A cross-platform app for analyzing conversations, understanding
/// communication patterns, and building better relationships.
///
/// Supported platforms:
/// - iOS (Apple App Store)
/// - Android (Google Play Store)
/// - Web (Progressive Web App)
/// - Windows (Microsoft Store)
/// - macOS (Mac App Store)
/// - Linux (Desktop)
///
/// Compliant with:
/// - Australian Privacy Act 1988
/// - International AI Standards (ISO/IEC 42001)
/// - WCAG 2.1 AAA Accessibility
/// - Apple App Store Review Guidelines
/// - Google Play Developer Program Policies
/// - Microsoft Store Policies
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

import 'firebase_options.dart';

import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/behavior_library_provider.dart';
import 'services/storage_service.dart';
import 'services/accessibility_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'utils/platform_utils.dart';

final _logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (works on all platforms)
  await Hive.initFlutter();

  // Initialize Firebase only on supported platforms
  if (PlatformUtils.supportsFirebase) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _logger.i('Firebase initialized on ${PlatformUtils.platformName}');
    } catch (e) {
      _logger.w('Firebase initialization failed: $e');
      // App continues without Firebase — auth will use email-only fallback
    }
  } else {
    _logger.i(
      'Firebase not supported on ${PlatformUtils.platformName}. '
      'Using email authentication only.',
    );
  }

  // Initialize storage service
  final storageService = StorageService();
  await storageService.initialize();

  // Mobile: set system UI overlay style
  if (PlatformUtils.isMobile) {
    // Allow all orientations — tablets need landscape
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(
    TextDecoderApp(storageService: storageService),
  );
}

class TextDecoderApp extends StatelessWidget {
  final StorageService storageService;

  const TextDecoderApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<StorageService>.value(value: storageService),
        Provider<AccessibilityService>(
          create: (_) => AccessibilityService(),
        ),

        // State providers
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(
            storageService: context.read<StorageService>(),
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(
            storageService: context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ConversationProvider(
            storageService: context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            storageService: context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BehaviorLibraryProvider()..loadLibrary(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Text Decoder',
            debugShowCheckedModeBanner: false,

            // Theme configuration with Digital ABCs branding + accessibility
            theme: AppTheme.lightTheme(
              highContrast: settings.highContrastMode,
              fontSize: settings.fontSizeMultiplier,
            ),
            darkTheme: AppTheme.darkTheme(
              highContrast: settings.highContrastMode,
              fontSize: settings.fontSizeMultiplier,
            ),
            themeMode: settings.themeMode,

            // Accessibility configuration
            builder: (context, child) {
              return MediaQuery(
                // Apply text scaling for accessibility
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.fontSizeMultiplier),
                ),
                child: AccessibilityWrapper(
                  reduceMotion: settings.reduceMotion,
                  screenReaderEnabled: settings.screenReaderOptimized,
                  child: child!,
                ),
              );
            },

            // Entry point
            home: const SplashScreen(),

            // Keyboard shortcuts for desktop (Escape for quick exit, etc.)
            shortcuts: {
              ...WidgetsApp.defaultShortcuts,
              // Ctrl+Q / Cmd+Q for quick exit on desktop
              if (PlatformUtils.isDesktop)
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ):
                    const _QuickExitIntent(),
            },
            actions: {
              ...WidgetsApp.defaultActions,
              _QuickExitIntent: CallbackAction<_QuickExitIntent>(
                onInvoke: (_) {
                  final appState = context.read<AppStateProvider>();
                  final settingsProvider = context.read<SettingsProvider>();
                  if (settingsProvider.quickExitEnabled) {
                    appState.triggerQuickExit();
                  }
                  return null;
                },
              ),
            },
          );
        },
      ),
    );
  }
}

/// Intent for quick exit keyboard shortcut (desktop)
class _QuickExitIntent extends Intent {
  const _QuickExitIntent();
}

/// Wrapper widget for accessibility features
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final bool reduceMotion;
  final bool screenReaderEnabled;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.reduceMotion = false,
    this.screenReaderEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Text Decoder Application',
      child: child,
    );
  }
}
