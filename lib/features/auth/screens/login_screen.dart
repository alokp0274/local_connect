// features/auth/screens/login_screen.dart
// Feature: Authentication & Onboarding
//
// Login screen with email/password fields, demo login, and social sign-in.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

/// Premium dark login screen with gold accents and glassmorphism.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@localconnect.app');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToLocation() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, AppRoutes.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final screenW = MediaQuery.of(context).size.width;
    final formMaxW = screenW >= 600 ? 420.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        type: BackgroundType.mesh,
        subtle: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formMaxW),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      // Logo badge with glow
                      Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.softGlow,
                            ),
                            child: const Icon(
                              Icons.handshake_rounded,
                              color: AppTheme.textOnAccent,
                              size: 26,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0, 0),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 28),
                      Text('Welcome back', style: tt.displayMedium)
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.15, curve: Curves.easeOut),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue',
                        style: tt.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ).animate(delay: 300.ms).fadeIn(duration: 350.ms),
                      const SizedBox(height: 40),
                      // Glass form container
                      GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLG,
                            ),
                            color: AppTheme.glassDark.withAlpha(80),
                            child: Column(
                              children: [
                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Email address',
                                    labelStyle: TextStyle(
                                      color: AppTheme.textMuted,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                      color: AppTheme.accentGold,
                                    ),
                                  ),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Please enter your email'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscureText,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: const TextStyle(
                                      color: AppTheme.textMuted,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppTheme.accentGold,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscureText = !_obscureText,
                                      ),
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                  ),
                                  validator: (v) =>
                                      v == null || v.trim().length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.forgotPassword,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: tt.labelLarge?.copyWith(
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOut),
                      const SizedBox(height: 28),
                      // Log In button
                      SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                                boxShadow: AppTheme.goldGlow,
                              ),
                              child: ElevatedButton(
                                onPressed: _goToLocation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Log In',
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textOnAccent,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      // Continue as Guest
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          child: OutlinedButton(
                            onPressed: _goToLocation,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSM,
                                ),
                              ),
                            ),
                            child: Text(
                              'Continue as Guest',
                              style: tt.titleMedium?.copyWith(
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ),
                      ).animate(delay: 700.ms).fadeIn(duration: 300.ms),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: tt.bodyMedium),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            ),
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
