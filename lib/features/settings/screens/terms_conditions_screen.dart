// features/settings/screens/terms_conditions_screen.dart
// Feature: App Settings & Legal
//
// Terms and conditions display screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const _sections = [
    _TcSection('1. Acceptance of Terms',
      'By accessing or using LocalConnect, you agree to be bound by these terms. If you do not agree, please do not use the app.'),
    _TcSection('2. Use of Service',
      'LocalConnect provides a platform to connect users with local service providers. We do not perform services ourselves. Providers are independent professionals.'),
    _TcSection('3. User Accounts',
      'You are responsible for maintaining the confidentiality of your account credentials. Notify us immediately of any unauthorized use.'),
    _TcSection('4. Payments',
      'All payments are processed securely. Refund policies depend on the cancellation window. Service fees are non-refundable after completion.'),
    _TcSection('5. Cancellation Policy',
      'Free cancellation is available up to 2 hours before the scheduled service. Late cancellations may incur a fee of up to 25% of the booking value.'),
    _TcSection('6. Privacy',
      'Your use of LocalConnect is also governed by our Privacy Policy. We collect, store, and use data as described therein.'),
    _TcSection('7. Prohibited Conduct',
      'Users must not misuse the platform. Harassment, fraudulent bookings, fake reviews, and unauthorized data collection are strictly prohibited.'),
    _TcSection('8. Limitation of Liability',
      'LocalConnect is not liable for any damages arising from your use of the platform or services provided by third-party professionals.'),
    _TcSection('9. Modifications',
      'We reserve the right to modify these terms at any time. Continued use after modifications constitutes acceptance of updated terms.'),
    _TcSection('10. Governing Law',
      'These terms are governed by the laws of India. Any disputes will be resolved in the courts of Bangalore, Karnataka.'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0,
        title: Text('Terms & Conditions', style: tt.headlineMedium),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            Text('Effective Date: January 1, 2025', style: tt.labelMedium?.copyWith(color: AppTheme.accentGold)),
            const SizedBox(height: 4),
            Text('Please read these terms carefully before using LocalConnect.', style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: 18),
            ...List.generate(_sections.length, (i) {
              final s = _sections[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.title, style: tt.titleMedium?.copyWith(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(s.body, style: tt.bodyMedium?.copyWith(height: 1.6)),
                  ]),
                ),
              ).animate(delay: Duration(milliseconds: 80 + i * 50)).fadeIn(duration: 280.ms);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TcSection {
  final String title; final String body;
  const _TcSection(this.title, this.body);
}
