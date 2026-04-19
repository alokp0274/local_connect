// features/rewards/screens/membership_tiers_screen.dart
// Feature: Rewards, Wallet & Loyalty
//
// Membership tier comparison (Bronze, Silver, Gold, Platinum).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/rewards/data/rewards_dummy_data.dart';
import 'package:local_connect/features/rewards/models/rewards_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  MEMBERSHIP TIERS SCREEN
// ─────────────────────────────────────────────────────────

class MembershipTiersScreen extends StatelessWidget {
  const MembershipTiersScreen({super.key});

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
                        child: Text(
                          'Membership Tiers',
                          style: tt.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                // ── Current Status ──
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                  child: GlassContainer(
                    padding: EdgeInsets.all(isCompact ? 16 : 20),
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
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.softGlow,
                          ),
                          child: Icon(
                            userTier.icon,
                            color: AppTheme.textOnAccent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You are a ${userTier.label} Member',
                          style: tt.headlineMedium?.copyWith(
                            fontSize: isCompact ? 18 : 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$userTotalPoints points earned',
                          style: tt.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$pointsToNextTier pts to Elite',
                                        style: tt.labelSmall?.copyWith(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '${((userTotalPoints / MembershipTier.elite.minPoints) * 100).round()}%',
                                        style: tt.labelSmall?.copyWith(
                                          color: AppTheme.accentGold,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull,
                                    ),
                                    child: LinearProgressIndicator(
                                      value:
                                          userTotalPoints /
                                          MembershipTier.elite.minPoints,
                                      backgroundColor: AppTheme.surfaceElevated,
                                      valueColor: const AlwaysStoppedAnimation(
                                        AppTheme.accentGold,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),

                // ── Tier Progress Path ──
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tier Journey',
                        style: tt.headlineMedium?.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 14),
                      _TierCard(
                        tier: MembershipTier.silver,
                        isActive: userTier == MembershipTier.silver,
                        isCompleted:
                            userTier.index > MembershipTier.silver.index,
                        benefits: const [
                          TierBenefit(
                            title: 'Basic reward points',
                            icon: Icons.star_outline_rounded,
                          ),
                          TierBenefit(
                            title: 'Standard support',
                            icon: Icons.headset_mic_rounded,
                          ),
                          TierBenefit(
                            title: 'Access to daily rewards',
                            icon: Icons.today_rounded,
                          ),
                        ],
                        color: const Color(0xFFB0B8D4),
                        index: 0,
                      ),
                      _TierCard(
                        tier: MembershipTier.gold,
                        isActive: userTier == MembershipTier.gold,
                        isCompleted: userTier.index > MembershipTier.gold.index,
                        benefits: const [
                          TierBenefit(
                            title: '15% OFF exclusive offers',
                            icon: Icons.local_offer_rounded,
                          ),
                          TierBenefit(
                            title: 'Priority support',
                            icon: Icons.support_agent_rounded,
                          ),
                          TierBenefit(
                            title: '2x cashback weekends',
                            icon: Icons.savings_rounded,
                          ),
                          TierBenefit(
                            title: 'Free monthly inspection',
                            icon: Icons.home_repair_service_rounded,
                          ),
                        ],
                        color: AppTheme.accentGold,
                        index: 1,
                      ),
                      _TierCard(
                        tier: MembershipTier.elite,
                        isActive: userTier == MembershipTier.elite,
                        isCompleted: false,
                        benefits: const [
                          TierBenefit(
                            title: 'Premium providers first',
                            icon: Icons.verified_rounded,
                          ),
                          TierBenefit(
                            title: 'Exclusive VIP deals',
                            icon: Icons.diamond_rounded,
                          ),
                          TierBenefit(
                            title: '24/7 VIP support',
                            icon: Icons.support_agent_rounded,
                          ),
                          TierBenefit(
                            title: '5x reward multiplier',
                            icon: Icons.auto_awesome_rounded,
                          ),
                          TierBenefit(
                            title: 'Free cancellations',
                            icon: Icons.cancel_rounded,
                          ),
                        ],
                        color: AppTheme.accentPurple,
                        index: 2,
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

class _TierCard extends StatelessWidget {
  final MembershipTier tier;
  final bool isActive;
  final bool isCompleted;
  final List<TierBenefit> benefits;
  final Color color;
  final int index;

  const _TierCard({
    required this.tier,
    required this.isActive,
    required this.isCompleted,
    required this.benefits,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? color.withAlpha(12) : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: isActive
                  ? color.withAlpha(80)
                  : isCompleted
                  ? AppTheme.accentTeal.withAlpha(40)
                  : AppTheme.border,
              width: isActive ? 1.2 : 0.5,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: color.withAlpha(20), blurRadius: 16)]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isActive || isCompleted
                          ? LinearGradient(
                              colors: [color, color.withAlpha(180)],
                            )
                          : null,
                      color: isActive || isCompleted
                          ? null
                          : AppTheme.surfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tier.icon,
                      color: isActive || isCompleted
                          ? Colors.white
                          : AppTheme.textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tier.label,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isActive ? color : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color, color.withAlpha(180)],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                                child: const Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withAlpha(20),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                                child: const Text(
                                  '\u2713 COMPLETED',
                                  style: TextStyle(
                                    color: AppTheme.accentTeal,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tier.minPoints}+ points required',
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: benefits
                    .map(
                      (b) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(8),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          border: Border.all(
                            color: color.withAlpha(25),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              b.icon,
                              color: isActive || isCompleted
                                  ? color
                                  : AppTheme.textMuted,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                b.title,
                                style: TextStyle(
                                  color: isActive || isCompleted
                                      ? AppTheme.textPrimary
                                      : AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        )
        .animate(delay: (200 + index * 80).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.06);
  }
}
