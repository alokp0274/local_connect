// features/auth/screens/onboarding_screen.dart
// Feature: Authentication & Onboarding
//
// Multi-step onboarding carousel introducing app features to new users.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

/// Onboarding screen with 3 slides, Skip / Next / Get Started.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final _slides = const [
    _Slide(
      icon: Icons.search_rounded,
      title: 'Discover Local Experts',
      subtitle:
          'Find verified plumbers, electricians, tutors and 50+ services near you.',
    ),
    _Slide(
      icon: Icons.calendar_month_rounded,
      title: 'Book in Seconds',
      subtitle:
          'Pick a slot, confirm and pay — all within the app. No calls needed.',
    ),
    _Slide(
      icon: Icons.verified_rounded,
      title: 'Trusted & Transparent',
      subtitle:
          'Every provider is reviewed by real customers. No hidden charges.',
    ),
  ];

  void _next() {
    if (_current < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isLast = _current == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        type: BackgroundType.mesh,
        child: SafeArea(
          child: Column(
            children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 12),
                  child: TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'Skip',
                      style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
                    ),
                  ),
                ),
              ),
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (_, i) => _buildPage(_slides[i]),
                ),
              ),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _current == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _current == i
                          ? AppTheme.accentGold
                          : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      boxShadow: AppTheme.softGlow,
                    ),
                    child: ElevatedButton(
                      onPressed: _next,
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
                        isLast ? 'Get Started' : 'Next',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_Slide slide) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softGlow,
                ),
                child: Icon(slide.icon, color: AppTheme.accentGold, size: 56),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 40),
          Text(
                slide.title,
                style: tt.displayMedium,
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            slide.subtitle,
            style: tt.bodyLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
