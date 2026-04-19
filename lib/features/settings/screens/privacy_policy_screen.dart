// features/settings/screens/privacy_policy_screen.dart
// Feature: App Settings & Legal
//
// Privacy policy display screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    _PpSection(Icons.info_outline_rounded, 'Information We Collect',
      'We collect information you provide directly (name, email, phone, address) and usage data automatically (device info, location, app interactions).'),
    _PpSection(Icons.psychology_rounded, 'How We Use Your Data',
      'Your data is used to provide and improve our services, personalize your experience, process payments, and communicate relevant updates.'),
    _PpSection(Icons.share_rounded, 'Data Sharing',
      'We share data only with service providers you book, payment processors, and as required by law. We never sell your personal information.'),
    _PpSection(Icons.security_rounded, 'Data Security',
      'We use industry-standard encryption, secure servers, and regular security audits to protect your information.'),
    _PpSection(Icons.cookie_rounded, 'Cookies & Tracking',
      'We use analytics tools to understand usage patterns and improve the app. You can opt out of non-essential tracking in Settings.'),
    _PpSection(Icons.tune_rounded, 'Your Rights',
      'You can access, update, or delete your personal data at any time. Contact us to exercise your rights under applicable data protection laws.'),
    _PpSection(Icons.child_care_rounded, "Children's Privacy",
      'LocalConnect is not intended for users under 13. We do not knowingly collect data from children.'),
    _PpSection(Icons.update_rounded, 'Policy Updates',
      'We may update this policy periodically. Material changes will be communicated via in-app notification or email.'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0,
        title: Text('Privacy Policy', style: tt.headlineMedium),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            Text('Last Updated: January 1, 2025', style: tt.labelMedium?.copyWith(color: AppTheme.accentGold)),
            const SizedBox(height: 4),
            Text('Your privacy is important to us. This policy explains how we handle your data.', style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: 18),
            ...List.generate(_sections.length, (i) {
              final s = _sections[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppTheme.accentGold.withAlpha(20), borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
                      child: Icon(s.icon, color: AppTheme.accentGold, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(s.body, style: tt.bodyMedium?.copyWith(height: 1.6)),
                    ])),
                  ]),
                ),
              ).animate(delay: Duration(milliseconds: 80 + i * 50)).fadeIn(duration: 280.ms).slideY(begin: 0.04);
            }),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              gradient: AppTheme.primarySubtleGradient,
              border: Border.all(color: AppTheme.accentGold.withAlpha(40)),
              child: Row(children: [
                const Icon(Icons.email_outlined, color: AppTheme.accentGold, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Questions? Contact us at privacy@localconnect.app', style: tt.bodyMedium?.copyWith(color: AppTheme.accentGold, fontWeight: FontWeight.w500))),
              ]),
            ).animate(delay: 600.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PpSection {
  final IconData icon; final String title; final String body;
  const _PpSection(this.icon, this.title, this.body);
}
