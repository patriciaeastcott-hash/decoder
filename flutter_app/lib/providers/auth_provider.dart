/// Auth provider for managing authentication state
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  StreamSubscription<User?>? _authSubscription;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? _error;
  String? get error => _error;

  bool get isAuthenticated => _user != null;

  /// Whether Firebase auth is available on this platform
  bool get isFirebaseAvailable => _authService.isFirebaseAvailable;

  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;
  String? get userPhotoUrl => _user?.photoURL;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authService.initialize();
    _initAuthListener();
    _isInitialized = true;
    notifyListeners();
  }

  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((user) async {
      _user = user;
      _error = null;

      if (user != null) {
        // Get and set the auth token for API calls
        final token = await _authService.getIdToken();
        if (token != null) {
          _apiService.setAuthToken(token);
        }
      } else {
        _apiService.clearAuthToken();
      }

      notifyListeners();
    });
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithGoogle();

    _setLoading(false);

    if (result.isSuccess) {
      return true;
    } else if (!result.isCancelled) {
      _setError(result.error ?? 'Failed to sign in with Google');
    }

    return false;
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithApple();

    _setLoading(false);

    if (result.isSuccess) {
      return true;
    } else if (!result.isCancelled) {
      _setError(result.error ?? 'Failed to sign in with Apple');
    }

    return false;
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      _setError(result.error ?? 'Failed to sign in');
      return false;
    }
  }

  /// Create account with email and password
  Future<bool> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.createAccountWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    _setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      _setError(result.error ?? 'Failed to create account');
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.sendPasswordResetEmail(email);

    _setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      _setError(result.error ?? 'Failed to send password reset email');
      return false;
    }
  }

  /// Update display name
  Future<bool> updateDisplayName(String displayName) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.updateDisplayName(displayName);

    _setLoading(false);

    if (result.isSuccess) {
      // Reload user to get updated info
      await _user?.reload();
      _user = _authService.currentUser;
      notifyListeners();
      return true;
    } else {
      _setError(result.error ?? 'Failed to update display name');
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      _setError(result.error ?? 'Failed to change password');
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.deleteAccount();

    _setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      _setError(result.error ?? 'Failed to delete account');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  /// Refresh auth token
  Future<String?> refreshToken() async {
    final token = await _authService.getIdToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
    return token;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear any displayed error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Get accessibility label for auth state
  String get accessibilityLabel {
    if (isLoading) {
      return 'Loading, please wait';
    }
    if (isAuthenticated) {
      return 'Signed in as ${userDisplayName ?? userEmail}';
    }
    return 'Not signed in';
  }
}
