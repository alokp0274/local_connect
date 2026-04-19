// features/settings/screens/help_support_screen.dart
// Feature: App Settings & Legal
//
// Help & support center with FAQ, contact, and ticket creation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    _FAQ('How do I book a service?', 'Browse or search for a service, select a provider, choose a time slot, and confirm your booking on the checkout page.'),
    _FAQ('How do I cancel a booking?', 'Go to Bookings \u2192 select the booking \u2192 tap Cancel. Cancellation is free up to 2 hours before the scheduled time.'),
    _FAQ('Are providers verified?', 'All providers with a blue verified badge have been ID- and background-checked by our team.'),
    _FAQ('How does payment work?', 'You can pay online via UPI, card, or wallet, or choose Cash on Service at the time of booking.'),
    _FAQ('How can I become a provider?', 'Tap the "Add Partner" tab and fill in the registration form. Our team will review and approve your profile.'),
    _FAQ('How do I get a refund?', 'Refunds are processed within 3-5 business days for cancellations within the eligible window.'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0,
        title: Text('Help & Support', style: tt.headlineMedium),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
          children: [
            // Hero support card
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              gradient: AppTheme.primarySubtleGradient,
              border: Border.all(color: AppTheme.accentGold.withAlpha(60)),
              child: Column(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: AppTheme.accentGold.withAlpha(25), shape: BoxShape.circle),
                  child: const Icon(Icons.headset_mic_rounded, size: 30, color: AppTheme.accentGold),
                ),
                const SizedBox(height: 14),
                Text("We're here to help", style: tt.headlineMedium),
                const SizedBox(height: 4),
                Text('Get support 24/7', style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _SupportAction(icon: Icons.chat_rounded, label: 'Live Chat', color: AppTheme.accentTeal,
                    onTap: () => _showSnack(context, 'Live chat starting...'))),
                  const SizedBox(width: 10),
                  Expanded(child: _SupportAction(icon: Icons.email_outlined, label: 'Email', color: AppTheme.accentBlue,
                    onTap: () => _launchUrl('mailto:support@localconnect.app'))),
                  const SizedBox(width: 10),
                  Expanded(child: _SupportAction(icon: Icons.phone_rounded, label: 'Call', color: AppTheme.accentGold,
                    onTap: () => _launchUrl('tel:+911234567890'))),
                ]),
              ]),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),

            const SizedBox(height: 20),
            // Quick Actions
            Row(children: [
              Expanded(child: _QuickHelpTile(icon: Icons.bug_report_outlined, title: 'Report Issue', color: AppTheme.accentCoral,
                onTap: () => _showSnack(context, 'Issue reported'))),
              const SizedBox(width: 10),
              Expanded(child: _QuickHelpTile(icon: Icons.feedback_outlined, title: 'Feedback', color: AppTheme.accentPurple,
                onTap: () => _showSnack(context, 'Feedback submitted'))),
            ]).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 24),
            Text('Frequently Asked Questions', style: tt.headlineMedium?.copyWith(fontSize: 17)),
            const SizedBox(height: 12),
            ...List.generate(_faqs.length, (i) {
              final faq = _faqs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  iconColor: AppTheme.accentGold, collapsedIconColor: AppTheme.textMuted,
                  title: Text(faq.question, style: tt.titleMedium),
                  children: [Text(faq.answer, style: tt.bodyMedium)],
                ),
              ).animate(delay: (200 + i * 60).ms).fadeIn(duration: 280.ms);
            }),
          ],
        ),
      ),
    );
  }

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: AppTheme.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
    ));
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _SupportAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _SupportAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(18), borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withAlpha(50), width: 0.5),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _QuickHelpTile extends StatelessWidget {
  final IconData icon; final String title; final Color color; final VoidCallback onTap;
  const _QuickHelpTile({required this.icon, required this.title, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard, borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _FAQ {
  final String question; final String answer;
  const _FAQ(this.question, this.answer);
}
