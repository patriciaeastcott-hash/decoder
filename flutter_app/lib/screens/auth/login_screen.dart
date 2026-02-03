/// Login screen with Google, Apple, and Email authentication

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../../utils/accessibility_utils.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showEmailForm = false;
  bool _isSignUp = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  // Logo and title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.psychology_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AccessibleHeading(
                          text: 'Text Decoder',
                          level: 1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to sync your data',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Error message
                  if (auth.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: auth.clearError,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_showEmailForm)
                    _buildEmailForm(auth)
                  else
                    _buildSocialButtons(auth),

                  const SizedBox(height: 24),

                  // Skip sign in
                  Center(
                    child: TextButton(
                      onPressed: () => _navigateToHome(),
                      child: const Text('Continue without signing in'),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Privacy note
                  Text(
                    'Your conversations stay on your device. '
                    'Sign in only enables optional cloud sync.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialButtons(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google Sign In
        _SocialSignInButton(
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          onPressed: auth.isLoading
              ? null
              : () async {
                  final success = await auth.signInWithGoogle();
                  if (success && mounted) _navigateToHome();
                },
          isLoading: auth.isLoading,
        ),

        const SizedBox(height: 12),

        // Apple Sign In (iOS only)
        if (Platform.isIOS) ...[
          _SocialSignInButton(
            icon: Icons.apple,
            label: 'Continue with Apple',
            onPressed: auth.isLoading
                ? null
                : () async {
                    final success = await auth.signInWithApple();
                    if (success && mounted) _navigateToHome();
                  },
            isLoading: auth.isLoading,
            isApple: true,
          ),
          const SizedBox(height: 12),
        ],

        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 12),

        // Email Sign In
        OutlinedButton.icon(
          onPressed: () => setState(() => _showEmailForm = true),
          icon: const Icon(Icons.email_outlined),
          label: const Text('Continue with Email'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _showEmailForm = false;
              _isSignUp = false;
            }),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ),

        const SizedBox(height: 16),

        // Name field (sign up only)
        if (_isSignUp) ...[
          AccessibleTextField(
            controller: _nameController,
            labelText: 'Name',
            hintText: 'Enter your name',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
        ],

        // Email field
        AccessibleTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          required: true,
        ),

        const SizedBox(height: 16),

        // Password field
        AccessibleTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: _isSignUp ? 'Create a password' : 'Enter your password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          required: true,
        ),

        const SizedBox(height: 24),

        // Submit button
        ElevatedButton(
          onPressed: auth.isLoading ? null : _handleEmailSubmit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isSignUp ? 'Create Account' : 'Sign In'),
        ),

        const SizedBox(height: 16),

        // Toggle sign up / sign in
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign in'
                  : "Don't have an account? Sign up",
            ),
          ),
        ),

        // Forgot password
        if (!_isSignUp)
          Center(
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: const Text('Forgot password?'),
            ),
          ),
      ],
    );
  }

  Future<void> _handleEmailSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    bool success;

    if (_isSignUp) {
      success = await auth.createAccount(
        email: email,
        password: password,
        displayName: name.isNotEmpty ? name : null,
      );
    } else {
      success = await auth.signInWithEmail(
        email: email,
        password: password,
      );
    }

    if (success && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordResetEmail(email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Password reset email sent'
                : auth.error ?? 'Failed to send reset email',
          ),
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isApple;

  const _SocialSignInButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isApple = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor:
              isApple ? (isDark ? Colors.white : Colors.black) : null,
          foregroundColor:
              isApple ? (isDark ? Colors.black : Colors.white) : null,
        ),
      ),
    );
  }
}
