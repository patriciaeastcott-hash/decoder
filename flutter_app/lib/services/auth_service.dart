/// Authentication service with cross-platform support
///
/// Platform support matrix:
/// - iOS: Google, Apple, Email/Password
/// - Android: Google, Email/Password
/// - Web: Google, Email/Password
/// - macOS: Apple, Email/Password (Firebase supported)
/// - Windows: Email/Password only (no Firebase — uses REST API fallback)
/// - Linux: Email/Password only (no Firebase — uses REST API fallback)
/// Authentication service using Firebase
/// Supports Google, Apple, and Email/Password sign-in
library;

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:logger/logger.dart';

import '../utils/platform_utils.dart';

class AuthService {
  final Logger _logger = Logger();

  // Firebase instances — only used on supported platforms
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  /// Whether Firebase is available on this platform
  bool _firebaseAvailable = false;

  /// Initialize auth service based on platform capabilities
  Future<void> initialize() async {
    if (PlatformUtils.supportsFirebase) {
      try {
        _auth = FirebaseAuth.instance;
        _firebaseAvailable = true;
        _logger.i('Firebase Auth initialized on ${PlatformUtils.platformName}');
      } catch (e) {
        _logger.w('Firebase Auth not available: $e');
        _firebaseAvailable = false;
      }
    }

    if (PlatformUtils.supportsGoogleSignIn) {
      try {
        _googleSignIn = GoogleSignIn();
        _logger.i('Google Sign-In initialized');
      } catch (e) {
        _logger.w('Google Sign-In not available: $e');
      }
    }
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges {
    if (_firebaseAvailable && _auth != null) {
      return _auth!.authStateChanges();
    }
    return const Stream.empty();
  }

  /// Current user
  User? get currentUser => _firebaseAvailable ? _auth?.currentUser : null;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get current user ID
  String? get userId => currentUser?.uid;

  /// Get current user email
  String? get userEmail => currentUser?.email;

  /// Get current user display name
  String? get userDisplayName => currentUser?.displayName;

  /// Get Firebase ID token for API authentication
  Future<String?> getIdToken() async {
    return await currentUser?.getIdToken();
  }

  /// Whether Firebase auth is available
  bool get isFirebaseAvailable => _firebaseAvailable;

  // ============================================
  // Available sign-in methods for current platform
  // ============================================

  /// Returns the list of sign-in methods available on this platform
  List<SignInMethod> get availableSignInMethods {
    final methods = <SignInMethod>[];

    if (PlatformUtils.supportsGoogleSignIn && _googleSignIn != null) {
      methods.add(SignInMethod.google);
    }

    if (PlatformUtils.supportsAppleSignIn) {
      methods.add(SignInMethod.apple);
    }

    // Email/password works everywhere Firebase is available
    if (_firebaseAvailable) {
      methods.add(SignInMethod.email);
    }

    return methods;
  }

  /// Whether a specific sign-in method is available
  bool isMethodAvailable(SignInMethod method) {
    return availableSignInMethods.contains(method);
  }

  // ============================================
  // GOOGLE SIGN IN (iOS, Android, Web)
  // ============================================

  Future<AuthResult> signInWithGoogle() async {
    if (!isMethodAvailable(SignInMethod.google)) {
      return AuthResult.error(
        'Google Sign-In is not available on ${PlatformUtils.platformName}.',
      );
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();

      if (googleUser == null) {
        return AuthResult.cancelled();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth!.signInWithCredential(credential);

      _logger.i('Google sign in successful: ${userCredential.user?.email}');

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      _logger.e('Google sign in Firebase error: ${e.message}');
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Google sign in error: $e');
      return AuthResult.error('Failed to sign in with Google. Please try again.');
    }
  }

  // ============================================
  // APPLE SIGN IN (iOS, macOS)
  // ============================================

  Future<AuthResult> signInWithApple() async {
    if (!isMethodAvailable(SignInMethod.apple)) {
      return AuthResult.error(
        'Apple Sign-In is not available on ${PlatformUtils.platformName}.',
      );
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth!.signInWithCredential(oauthCredential);

      // Apple only provides name on first sign-in
      if (appleCredential.givenName != null) {
        await userCredential.user?.updateDisplayName(
          '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim(),
        );
      }

      _logger.i('Apple sign in successful: ${userCredential.user?.email}');

      return AuthResult.success(userCredential.user!);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult.cancelled();
      }
      _logger.e('Apple sign in error: ${e.message}');
      return AuthResult.error('Failed to sign in with Apple: ${e.message}');
    } on FirebaseAuthException catch (e) {
      _logger.e('Apple sign in Firebase error: ${e.message}');
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Apple sign in error: $e');
      return AuthResult.error('Failed to sign in with Apple. Please try again.');
    }
  }

  // ============================================
  // EMAIL/PASSWORD SIGN IN (all Firebase platforms)
  // ============================================

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_firebaseAvailable || _auth == null) {
      return AuthResult.error(
        'Email sign-in requires Firebase, which is not available on '
        '${PlatformUtils.platformName}.',
      );
    }

    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.i('Email sign in successful: ${userCredential.user?.email}');

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      _logger.e('Email sign in error: ${e.code}');
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Email sign in error: $e');
      return AuthResult.error('Failed to sign in. Please try again.');
    }
  }

  Future<AuthResult> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!_firebaseAvailable || _auth == null) {
      return AuthResult.error(
        'Account creation requires Firebase, which is not available on '
        '${PlatformUtils.platformName}.',
      );
    }

    try {
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      _logger.i('Account created: ${userCredential.user?.email}');

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      _logger.e('Create account error: ${e.code}');
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Create account error: $e');
      return AuthResult.error('Failed to create account. Please try again.');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (!_firebaseAvailable || _auth == null) {
      return AuthResult.error('Password reset is not available on this platform.');
    }

    try {
      await _auth!.sendPasswordResetEmail(email: email);

      _logger.i('Password reset email sent to: $email');

      return AuthResult.successMessage('Password reset email sent. Check your inbox.');
    } on FirebaseAuthException catch (e) {
      _logger.e('Password reset error: ${e.code}');
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Password reset error: $e');
      return AuthResult.error('Failed to send password reset email.');
    }
  }

  // ============================================
  // ACCOUNT MANAGEMENT
  // ============================================

  Future<AuthResult> updateDisplayName(String displayName) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.reload();
      _logger.i('Display name updated: $displayName');
      return AuthResult.successMessage('Display name updated successfully.');
    } catch (e) {
      _logger.e('Update display name error: $e');
      return AuthResult.error('Failed to update display name.');
    }
  }

  Future<AuthResult> updateEmail(String newEmail) async {
    try {
      await currentUser?.verifyBeforeUpdateEmail(newEmail);
      _logger.i('Email verification sent to: $newEmail');
      return AuthResult.successMessage(
        'Verification email sent to $newEmail. Please verify to complete the change.',
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Update email error: ${e.code}');
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Update email error: $e');
      return AuthResult.error('Failed to update email.');
    }
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
      _logger.i('Password changed successfully');
      return AuthResult.successMessage('Password changed successfully.');
    } on FirebaseAuthException catch (e) {
      _logger.e('Change password error: ${e.code}');
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Change password error: $e');
      return AuthResult.error('Failed to change password.');
    }
  }

  /// Delete user account and all associated data.
  /// Required by: Apple App Store, Google Play, Australian Privacy Act
  Future<AuthResult> deleteAccount() async {
    try {
      await currentUser?.delete();
      _logger.i('Account deleted');
      return AuthResult.successMessage('Account deleted successfully.');
    } on FirebaseAuthException catch (e) {
      _logger.e('Delete account error: ${e.code}');
      if (e.code == 'requires-recent-login') {
        return AuthResult.error(
          'Please sign out and sign in again before deleting your account.',
        );
      }
      return AuthResult.error(_mapFirebaseError(e.code));
    } catch (e) {
      _logger.e('Delete account error: $e');
      return AuthResult.error('Failed to delete account.');
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  Future<void> signOut() async {
    try {
      if (_googleSignIn != null && await _googleSignIn!.isSignedIn()) {
        await _googleSignIn!.signOut();
      }
      await _auth?.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out error: $e');
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

/// Available sign-in methods
enum SignInMethod {
  google,
  apple,
  email,
}

/// Authentication result
class AuthResult {
  final User? user;
  final String? message;
  final String? error;
  final bool isCancelled;
  final bool isSuccess;

  const AuthResult._({
    this.user,
    this.message,
    this.error,
    this.isCancelled = false,
    required this.isSuccess,
  });

  factory AuthResult.success(User user) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.successMessage(String message) {
    return AuthResult._(message: message, isSuccess: true);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(error: error, isSuccess: false);
  }

  factory AuthResult.cancelled() {
    return const AuthResult._(isCancelled: true, isSuccess: false);
  }

  String get accessibilityLabel {
    if (isSuccess) return message ?? 'Sign in successful';
    if (isCancelled) return 'Sign in cancelled';
    return error ?? 'Sign in failed';
  }
}
