// features/rewards/screens/referral_screen.dart
// Feature: Rewards, Wallet & Loyalty
//
// Referral program screen with invite link, rewards, and leaderboard.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/rewards/data/rewards_dummy_data.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  REFERRAL PROGRAM SCREEN
// ─────────────────────────────────────────────────────────

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App Bar ──
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Refer & Earn', style: tt.headlineMedium),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                // ── Hero Card ──
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                  child: GlassContainer(
                    padding: EdgeInsets.all(isCompact ? 18 : 24),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    gradient: AppTheme.primarySubtleGradient,
                    border: Border.all(
                      color: AppTheme.accentGold.withAlpha(80),
                      width: 0.8,
                    ),
                    boxShadow: AppTheme.softGlow,
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.softGlow,
                          ),
                          child: const Icon(
                            Icons.people_rounded,
                            color: AppTheme.textOnAccent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Invite Friends & Earn',
                          style: tt.headlineMedium?.copyWith(
                            fontSize: isCompact ? 20 : 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Both you and your friend get \u20b9100 when they complete their first booking!',
                          style: tt.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Referral code box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                            border: Border.all(
                              color: AppTheme.accentGold.withAlpha(60),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  referralCode,
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: isCompact ? 18 : 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    const ClipboardData(text: referralCode),
                                  );
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Referral code copied!'),
                                      backgroundColor: AppTheme.surfaceElevated,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold.withAlpha(20),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSM,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.copy_rounded,
                                    color: AppTheme.accentGold,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Share button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                              boxShadow: AppTheme.softGlow,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Share link copied! Share with friends.',
                                    ),
                                    backgroundColor: AppTheme.surfaceElevated,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: const Text('Share Invite Link'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSM,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),

                // ── Referral Stats ──
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$referralFriendsJoined',
                          label: 'Friends Joined',
                          icon: Icons.group_add_rounded,
                          color: AppTheme.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '$referralBonusEarned pts',
                          label: 'Bonus Earned',
                          icon: Icons.emoji_events_rounded,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                ),

                // ── How It Works ──
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How It Works',
                        style: tt.headlineMedium?.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 14),
                      _StepTile(
                        step: '1',
                        title: 'Share your link',
                        subtitle: 'Copy your code or share via any app',
                        color: AppTheme.accentGold,
                      ),
                      _StepTile(
                        step: '2',
                        title: 'Friend signs up',
                        subtitle: 'They create account using your code',
                        color: AppTheme.accentTeal,
                      ),
                      _StepTile(
                        step: '3',
                        title: 'Friend books service',
                        subtitle: 'They complete their first booking',
                        color: AppTheme.accentBlue,
                      ),
                      _StepTile(
                        step: '4',
                        title: 'Both earn \u20b9100!',
                        subtitle: 'Rewards credited to both wallets',
                        color: AppTheme.accentPurple,
                      ),
                    ],
                  ),
                ),

                // ── Recent Referrals ──
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Referrals',
                        style: tt.headlineMedium?.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 12),
                      _ReferralItem(
                        name: 'Amit Sharma',
                        status: 'Completed booking',
                        points: '+200 pts',
                        color: AppTheme.accentTeal,
                      ),
                      _ReferralItem(
                        name: 'Neha Gupta',
                        status: 'Signed up',
                        points: 'Pending',
                        color: AppTheme.accentGold,
                      ),
                      _ReferralItem(
                        name: 'Rohan Verma',
                        status: 'Completed booking',
                        points: '+200 pts',
                        color: AppTheme.accentTeal,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final Color color;
  const _StepTile({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withAlpha(180)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: tt.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: (300 + int.parse(step) * 60).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: -0.04);
  }
}

class _ReferralItem extends StatelessWidget {
  final String name;
  final String status;
  final String points;
  final Color color;
  const _ReferralItem({
    required this.name,
    required this.status,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: tt.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              points,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
