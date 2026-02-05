import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_decoder/utils/platform_utils.dart';

void main() {
  group('PlatformUtils', () {
    test('isWeb returns bool', () {
      // kIsWeb is a compile-time constant
      expect(PlatformUtils.isWeb, isA<bool>());
    });

    test('platformName returns non-empty string', () {
      expect(PlatformUtils.platformName, isNotEmpty);
    });

    test('platform detection is mutually exclusive on non-web', () {
      if (!PlatformUtils.isWeb) {
        final platforms = [
          PlatformUtils.isIOS,
          PlatformUtils.isAndroid,
          PlatformUtils.isMacOS,
          PlatformUtils.isWindows,
          PlatformUtils.isLinux,
        ];
        // Exactly one should be true
        expect(platforms.where((p) => p).length, equals(1));
      }
    });

    test('isMobile means iOS or Android', () {
      if (PlatformUtils.isMobile) {
        expect(
          PlatformUtils.isIOS || PlatformUtils.isAndroid,
          isTrue,
        );
      }
    });

    test('isDesktop means macOS, Windows, or Linux', () {
      if (PlatformUtils.isDesktop) {
        expect(
          PlatformUtils.isMacOS ||
              PlatformUtils.isWindows ||
              PlatformUtils.isLinux,
          isTrue,
        );
      }
    });

    test('supportsFirebase is true for mobile/web/macOS', () {
      final expected = PlatformUtils.isIOS ||
          PlatformUtils.isAndroid ||
          PlatformUtils.isWeb ||
          PlatformUtils.isMacOS;
      expect(PlatformUtils.supportsFirebase, equals(expected));
    });

    test('supportsHapticFeedback only on mobile', () {
      expect(
        PlatformUtils.supportsHapticFeedback,
        equals(PlatformUtils.isMobile),
      );
    });

    test('supportsSystemNavigatorPop only on Android', () {
      expect(
        PlatformUtils.supportsSystemNavigatorPop,
        equals(PlatformUtils.isAndroid),
      );
    });

    test('privacyPolicyUrl is non-empty', () {
      expect(PlatformUtils.privacyPolicyUrl, isNotEmpty);
    });

    test('termsOfServiceUrl is non-empty', () {
      expect(PlatformUtils.termsOfServiceUrl, isNotEmpty);
    });

    test('deviceFormFactor returns valid value', () {
      expect(PlatformUtils.deviceFormFactor, isA<DeviceFormFactor>());
    });
  });
}
