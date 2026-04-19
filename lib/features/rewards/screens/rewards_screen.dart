// features/rewards/screens/rewards_screen.dart
// Feature: Rewards, Wallet & Loyalty
//
// Rewards hub with points balance, available rewards, and redemption.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/rewards/data/rewards_dummy_data.dart';
import 'package:local_connect/features/rewards/models/rewards_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/rewards/screens/membership_tiers_screen.dart';
import 'package:local_connect/features/rewards/screens/streaks_badges_screen.dart';
import 'package:local_connect/features/rewards/screens/referral_screen.dart';
import 'package:local_connect/features/rewards/screens/reward_notifications_screen.dart';

// ─────────────────────────────────────────────────────────
//  REWARDS CENTER — Premium loyalty hub
// ─────────────────────────────────────────────────────────

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  final Set<String> _redeemedIds = {};

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(
                child: Padding(
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
                        child: Text('Rewards Center', style: tt.headlineMedium),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RewardNotificationsScreen(),
                          ),
                        ),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.accentGold,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Hero Card ──
              SliverToBoxAdapter(child: _buildHeroCard(tt, pad, screenW)),
              // ── Quick Nav ──
              SliverToBoxAdapter(child: _buildQuickNav(tt, pad)),
              // ── Earn More Points ──
              SliverToBoxAdapter(child: _buildEarnSection(tt, pad)),
              // ── Redeem Rewards ──
              SliverToBoxAdapter(child: _buildRedeemSection(tt, pad, screenW)),
              // ── Recent Activity ──
              SliverToBoxAdapter(child: _buildActivitySection(tt, pad)),
              // ── Exclusive Benefits ──
              SliverToBoxAdapter(child: _buildBenefitsSection(tt, pad)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(TextTheme tt, double pad, double screenW) {
    final isCompact = screenW < 360;
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withAlpha(
                    (40 * _glowCtrl.value).round(),
                  ),
                  blurRadius: 30 + 15 * _glowCtrl.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: GlassContainer(
          padding: EdgeInsets.all(isCompact ? 16 : 22),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          gradient: AppTheme.primarySubtleGradient,
          border: Border.all(
            color: AppTheme.accentGold.withAlpha(80),
            width: 0.8,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Reward Points',
                          style: tt.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$userTotalPoints',
                          style: tt.displayLarge?.copyWith(
                            fontSize: isCompact ? 36 : 44,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MembershipTiersScreen(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  userTier.icon,
                                  color: AppTheme.textOnAccent,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${userTier.label} Member',
                                  style: const TextStyle(
                                    color: AppTheme.textOnAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppTheme.textOnAccent,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: isCompact ? 60 : 72,
                    height: isCompact ? 60 : 72,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softGlow,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.textOnAccent,
                      size: isCompact ? 30 : 36,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$pointsToNextTier pts to Elite',
                        style: tt.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '$userTotalPoints/${MembershipTier.elite.minPoints}',
                        style: tt.labelSmall?.copyWith(
                          color: AppTheme.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: LinearProgressIndicator(
                      value: userTotalPoints / MembershipTier.elite.minPoints,
                      backgroundColor: AppTheme.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.accentGold,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08);
  }

  Widget _buildQuickNav(TextTheme tt, double pad) {
    final items = [
      _NavItem(
        'Tiers',
        Icons.workspace_premium_rounded,
        AppTheme.accentGold,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MembershipTiersScreen()),
        ),
      ),
      _NavItem(
        'Badges',
        Icons.military_tech_rounded,
        AppTheme.accentTeal,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const StreaksBadgesScreen())),
      ),
      _NavItem(
        'Referral',
        Icons.people_rounded,
        AppTheme.accentBlue,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReferralScreen())),
      ),
      _NavItem(
        'Alerts',
        Icons.notifications_rounded,
        AppTheme.accentCoral,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RewardNotificationsScreen()),
        ),
      ),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 18, pad, 0),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Expanded(
            child:
                GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        item.onTap();
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: i < items.length - 1 ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: item.color.withAlpha(15),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          border: Border.all(
                            color: item.color.withAlpha(40),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(item.icon, color: item.color, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate(delay: (200 + i * 50).ms)
                    .fadeIn(duration: 250.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      curve: Curves.easeOutBack,
                    ),
          );
        }),
      ),
    );
  }

  Widget _buildEarnSection(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Earn More Points',
                style: tt.headlineMedium?.copyWith(fontSize: 17),
              ),
              const Spacer(),
              Text(
                '${earnRules.where((e) => e.completed).length}/${earnRules.length} done',
                style: tt.labelSmall?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(earnRules.length, (i) {
            final rule = earnRules[i];
            return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: rule.completed
                        ? rule.color.withAlpha(10)
                        : AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: rule.completed
                        ? Border.all(
                            color: rule.color.withAlpha(40),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: rule.color.withAlpha(rule.completed ? 25 : 15),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                        ),
                        child: Icon(
                          rule.icon,
                          color: rule.completed
                              ? rule.color
                              : AppTheme.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rule.title,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: rule.completed
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rule.subtitle,
                              style: tt.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: rule.completed
                              ? AppTheme.accentTeal.withAlpha(20)
                              : AppTheme.accentGold.withAlpha(15),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          rule.completed
                              ? '\u2713 ${rule.points} pts'
                              : '+${rule.points} pts',
                          style: TextStyle(
                            color: rule.completed
                                ? AppTheme.accentTeal
                                : AppTheme.accentGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: (300 + i * 40).ms)
                .fadeIn(duration: 250.ms)
                .slideX(begin: -0.03);
          }),
        ],
      ),
    );
  }

  Widget _buildRedeemSection(TextTheme tt, double pad, double screenW) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redeem Rewards',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: redeemableRewards.length,
              itemBuilder: (_, i) {
                final r = redeemableRewards[i];
                final redeemed = _redeemedIds.contains(r.id);
                final canAfford = userTotalPoints >= r.pointsCost;
                return Container(
                      width: screenW < 360 ? 200 : 220,
                      margin: EdgeInsets.only(
                        right: i < redeemableRewards.length - 1 ? 12 : 0,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: r.color.withAlpha(12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: r.color.withAlpha(40),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: r.color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSM,
                                  ),
                                ),
                                child: Icon(r.icon, color: r.color, size: 18),
                              ),
                              const Spacer(),
                              if (r.tag.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: r.color.withAlpha(20),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    r.tag,
                                    style: TextStyle(
                                      color: r.color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            r.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: redeemed || !canAfford
                                ? null
                                : () {
                                    HapticFeedback.mediumImpact();
                                    setState(() => _redeemedIds.add(r.id));
                                    _showSnack(
                                      '${r.title} redeemed for ${r.pointsCost} points!',
                                    );
                                  },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: redeemed
                                    ? null
                                    : canAfford
                                    ? LinearGradient(
                                        colors: [
                                          r.color,
                                          r.color.withAlpha(180),
                                        ],
                                      )
                                    : null,
                                color: redeemed || !canAfford
                                    ? AppTheme.surfaceElevated
                                    : null,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSM,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  redeemed
                                      ? 'Redeemed'
                                      : '${r.pointsCost} pts \u2022 Redeem',
                                  style: TextStyle(
                                    color: redeemed
                                        ? AppTheme.textMuted
                                        : canAfford
                                        ? Colors.white
                                        : AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: (400 + i * 60).ms)
                    .fadeIn(duration: 280.ms)
                    .slideX(begin: 0.08);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(TextTheme tt, double pad) {
    final count = rewardActivities.length > 5 ? 5 : rewardActivities.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Rewards Activity',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 12),
          ...List.generate(count, (i) {
            final a = rewardActivities[i];
            final color = _activityColor(a.type);
            final icon = _activityIcon(a.type);
            return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(
                      color: AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.subtitle,
                              style: tt.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (a.points != 0)
                            Text(
                              a.points > 0
                                  ? '+${a.points} pts'
                                  : '${a.points} pts',
                              style: TextStyle(
                                color: a.points > 0
                                    ? AppTheme.accentTeal
                                    : AppTheme.accentCoral,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            a.time,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate(delay: (500 + i * 40).ms)
                .fadeIn(duration: 250.ms)
                .slideX(begin: -0.03);
          }),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(TextTheme tt, double pad) {
    const benefits = [
      _BenefitItem(
        'Gold Exclusive Offers',
        '15% OFF on all services',
        Icons.local_offer_rounded,
        AppTheme.accentGold,
      ),
      _BenefitItem(
        'Priority Booking',
        'Get served before others',
        Icons.speed_rounded,
        AppTheme.accentTeal,
      ),
      _BenefitItem(
        'Free Inspections',
        'Once per month as Gold',
        Icons.home_repair_service_rounded,
        AppTheme.accentBlue,
      ),
      _BenefitItem(
        'Cashback Boost',
        '2x cashback on weekends',
        Icons.savings_rounded,
        AppTheme.accentPurple,
      ),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Gold Benefits',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: List.generate(benefits.length, (i) {
              final b = benefits[i];
              return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: b.color.withAlpha(10),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      border: Border.all(
                        color: b.color.withAlpha(30),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(b.icon, color: b.color, size: 22),
                        const Spacer(),
                        Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: (600 + i * 50).ms)
                  .fadeIn(duration: 280.ms)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    curve: Curves.easeOutBack,
                  );
            }),
          ),
        ],
      ),
    );
  }

  Color _activityColor(RewardActivityType type) {
    switch (type) {
      case RewardActivityType.earned:
        return AppTheme.accentTeal;
      case RewardActivityType.redeemed:
        return AppTheme.accentCoral;
      case RewardActivityType.bonus:
        return AppTheme.accentGold;
      case RewardActivityType.levelUp:
        return AppTheme.accentPurple;
    }
  }

  IconData _activityIcon(RewardActivityType type) {
    switch (type) {
      case RewardActivityType.earned:
        return Icons.add_circle_rounded;
      case RewardActivityType.redeemed:
        return Icons.redeem_rounded;
      case RewardActivityType.bonus:
        return Icons.card_giftcard_rounded;
      case RewardActivityType.levelUp:
        return Icons.upgrade_rounded;
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _NavItem(this.label, this.icon, this.color, this.onTap);
}

class _BenefitItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _BenefitItem(this.title, this.subtitle, this.icon, this.color);
}
