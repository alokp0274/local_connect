// features/auth/screens/splash_screen.dart
//
// Animated splash with mesh background, elastic logo reveal, and tagline fade.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

/// Full-screen splash — logo scale + tagline, then navigate to login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedMeshBackground(
        type: BackgroundType.mesh,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rounded square logo with gradient
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppTheme.softGlow,
                    ),
                    child: const Center(
                      child: Text(
                        'LC',
                        style: TextStyle(
                          color: AppTheme.textOnAccent,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms)
                  .then(delay: 600.ms)
                  .shimmer(
                    duration: 1200.ms,
                    color: Colors.white.withAlpha(40),
                  ),

              const SizedBox(height: 28),

              // App name
              Text(
                    'LocalConnect',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      letterSpacing: -1,
                    ),
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOut),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Your city. Your experts.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
