// features/auth/screens/forgot_password_screen.dart
// Feature: Authentication & Onboarding
//
// Forgot password screen – collects email to send OTP for password reset.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/app_button.dart';
import 'package:local_connect/shared/widgets/app_text_field.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

/// Forgot password screen — email input + send OTP.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushNamed(
      context,
      AppRoutes.otpVerification,
      arguments: _emailCtrl.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: AnimatedMeshBackground(
        type: BackgroundType.mesh,
        subtle: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Illustration
                Center(
                  child:
                      Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.heroGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 40,
                              color: AppTheme.accentGold,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            curve: Curves.easeOut,
                          ),
                ),
                const SizedBox(height: 28),
                Text('Forgot Password?', style: tt.displayMedium)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.15),
                const SizedBox(height: 6),
                Text(
                  "Enter the email address linked to your account and we'll send you a one-time password.",
                  style: tt.bodyLarge,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email address',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter your email';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Send OTP',
                  isLoading: _loading,
                  onTap: _sendOtp,
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to Sign In',
                      style: tt.labelLarge?.copyWith(
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
