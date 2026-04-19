// features/auth/screens/register_screen.dart
// Feature: Authentication & Onboarding
//
// Registration screen with name, email, password, and terms acceptance.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

/// Premium dark register screen matching the login design.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
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
                      const SizedBox(height: 16),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.textPrimary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceCard,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Create account', style: tt.displayMedium)
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.2, curve: Curves.easeOut),
                      const SizedBox(height: 4),
                      Text('Join LocalConnect today', style: tt.bodyLarge),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          labelStyle: TextStyle(color: AppTheme.textMuted),
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: AppTheme.textMuted),
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter your email'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          labelStyle: TextStyle(color: AppTheme.textMuted),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().length < 10
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: const TextStyle(color: AppTheme.textPrimary),
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
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText),
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().length < 6
                            ? 'Use at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      // Submit
                      SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSM,
                                ),
                                boxShadow: AppTheme.softGlow,
                              ),
                              child: ElevatedButton(
                                onPressed: _continue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSM,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Create Account',
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: tt.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Sign in'),
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
