/// Authentication service using Firebase
/// Supports Google, Apple, and Email/Password sign-in
library;

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

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

  // ============================================
  // GOOGLE SIGN IN
  // ============================================

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.cancelled();
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

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
  // APPLE SIGN IN
  // ============================================

  /// Sign in with Apple
  Future<AuthResult> signInWithApple() async {
    try {
      // Request Apple credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the Apple credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Apple only provides name on first sign-in, so update profile if available
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
  // EMAIL/PASSWORD SIGN IN
  // ============================================

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
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

  /// Create account with email and password
  Future<AuthResult> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name if provided
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

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

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

  /// Update user display name
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

  /// Update user email
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

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Update password
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

  /// Delete user account
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

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Sign out error: $e');
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Map Firebase error codes to user-friendly messages
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
    return AuthResult._(
      user: user,
      isSuccess: true,
    );
  }

  factory AuthResult.successMessage(String message) {
    return AuthResult._(
      message: message,
      isSuccess: true,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      error: error,
      isSuccess: false,
    );
  }

  factory AuthResult.cancelled() {
    return const AuthResult._(
      isCancelled: true,
      isSuccess: false,
    );
  }

  String get accessibilityLabel {
    if (isSuccess) {
      return message ?? 'Sign in successful';
    }
    if (isCancelled) {
      return 'Sign in cancelled';
    }
    return error ?? 'Sign in failed';
  }
}
