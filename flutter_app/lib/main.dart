/// Text Decoder MVP
///
/// A cross-platform app for analyzing conversations, understanding
/// communication patterns, and building better relationships.
///
/// Compliant with:
/// - Australian Privacy Act
/// - International AI Standards
/// - WCAG 2.1 AAA Accessibility

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

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
import 'utils/accessibility_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize storage service
  final storageService = StorageService();
  await storageService.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for accessibility
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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

            // Theme configuration with accessibility
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

            // Home screen
            home: const SplashScreen(),

            // Localization (future)
            // localizationsDelegates: [...],
            // supportedLocales: [...],
          );
        },
      ),
    );
  }
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
