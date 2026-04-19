// features/settings/screens/about_app_screen.dart
// Feature: App Settings & Legal
//
// About screen with app version, credits, and legal links.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0,
        title: Text('About LocalConnect', style: tt.headlineMedium),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(children: [
            // Logo + Version Hero
            GlassContainer(
              padding: const EdgeInsets.all(28),
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              gradient: AppTheme.primarySubtleGradient,
              border: Border.all(color: AppTheme.accentGold.withAlpha(60)),
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    boxShadow: AppTheme.softGlow,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 16),
                Text('LocalConnect', style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Version 2.0.0', style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.accentGold.withAlpha(25), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                  child: const Text('Premium Edition', style: TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ]),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),

            const SizedBox(height: 20),
            _InfoCard(
              icon: Icons.info_outline_rounded, title: 'What is LocalConnect?',
              body: 'LocalConnect is a premium hyper-local service marketplace connecting users with trusted, verified professionals in their neighborhood. From home repairs to beauty services, we make booking fast, safe, and delightful.',
              delay: 100,
            ),
            _InfoCard(
              icon: Icons.favorite_rounded, title: 'Our Mission',
              body: 'To empower local service providers and create a seamless, trustworthy bridge between skilled professionals and the communities they serve.',
              color: AppTheme.accentCoral, delay: 160,
            ),
            _InfoCard(
              icon: Icons.verified_rounded, title: 'Trust & Safety',
              body: 'Every provider is background-verified. Ratings are transparent. Payments are secure. Your safety is our top priority.',
              color: AppTheme.accentTeal, delay: 220,
            ),
            _InfoCard(
              icon: Icons.code_rounded, title: 'Built With',
              body: 'Flutter \u2022 Dart \u2022 Material Design 3 \u2022 Glassmorphism \u2022 Custom Animations \u2022 Made with \u2764\ufe0f in India',
              color: AppTheme.accentBlue, delay: 280,
            ),
            _InfoCard(
              icon: Icons.shield_rounded, title: 'Privacy First',
              body: 'We collect only what is necessary. Your data is encrypted and never shared with third parties without consent.',
              color: AppTheme.accentPurple, delay: 340,
            ),

            const SizedBox(height: 20),
            Text('\u00a9 2025 LocalConnect. All rights reserved.', style: tt.labelSmall?.copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon; final String title; final String body; final Color color; final int delay;
  const _InfoCard({required this.icon, required this.title, required this.body, this.color = AppTheme.accentGold, this.delay = 0});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body, style: tt.bodyMedium?.copyWith(height: 1.5)),
          ])),
        ]),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}
