// features/provider_mode/screens/provider_achievements_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Badges, milestones, and achievement tracker for the provider.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/rewards/data/rewards_dummy_data.dart';
import 'package:local_connect/features/rewards/models/rewards_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  PROVIDER ACHIEVEMENTS SCREEN
// ─────────────────────────────────────────────────────────

class ProviderAchievementsScreen extends StatelessWidget {
  const ProviderAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    final earned = providerAchievements.where((a) => a.earned).toList();
    final inProgress = providerAchievements.where((a) => !a.earned).toList();

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
                        child: Text(
                          'Provider Achievements',
                          style: tt.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Stats Hero ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    gradient: const LinearGradient(
                      colors: [Color(0x1A5B8DEF), Color(0x0A5B8DEF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppTheme.accentBlue.withAlpha(60),
                      width: 0.8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          value: '${earned.length}',
                          label: 'Earned',
                          color: AppTheme.accentTeal,
                          icon: Icons.emoji_events_rounded,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppTheme.border,
                        ),
                        _StatItem(
                          value: '${inProgress.length}',
                          label: 'In Progress',
                          color: AppTheme.accentBlue,
                          icon: Icons.trending_up_rounded,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppTheme.border,
                        ),
                        _StatItem(
                          value: '${providerAchievements.length}',
                          label: 'Total',
                          color: AppTheme.accentPurple,
                          icon: Icons.military_tech_rounded,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
              ),

              // ── Earned Achievements ──
              if (earned.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 24, pad, 10),
                    child: Text(
                      'Unlocked',
                      style: tt.headlineMedium?.copyWith(fontSize: 17),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _AchievementTile(
                        achievement: earned[i],
                        index: i,
                        isEarned: true,
                      ),
                      childCount: earned.length,
                    ),
                  ),
                ),
              ],

              // ── In Progress ──
              if (inProgress.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 24, pad, 10),
                    child: Text(
                      'In Progress',
                      style: tt.headlineMedium?.copyWith(fontSize: 17),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _AchievementTile(
                        achievement: inProgress[i],
                        index: i,
                        isEarned: false,
                      ),
                      childCount: inProgress.length,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final ProviderAchievement achievement;
  final int index;
  final bool isEarned;
  const _AchievementTile({
    required this.achievement,
    required this.index,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isEarned
                ? achievement.color.withAlpha(8)
                : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: isEarned
                  ? achievement.color.withAlpha(50)
                  : AppTheme.border,
              width: isEarned ? 0.8 : 0.5,
            ),
            boxShadow: isEarned
                ? [
                    BoxShadow(
                      color: achievement.color.withAlpha(12),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isEarned
                      ? LinearGradient(
                          colors: [
                            achievement.color,
                            achievement.color.withAlpha(180),
                          ],
                        )
                      : null,
                  color: isEarned ? null : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  boxShadow: isEarned
                      ? [
                          BoxShadow(
                            color: achievement.color.withAlpha(30),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  achievement.icon,
                  color: isEarned ? Colors.white : AppTheme.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      achievement.subtitle,
                      style: tt.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    if (!isEarned) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          backgroundColor: AppTheme.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation(
                            achievement.color.withAlpha(180),
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isEarned)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        achievement.color,
                        achievement.color.withAlpha(180),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                )
              else
                Text(
                  achievement.progressLabel.isEmpty
                      ? '${(achievement.progress * 100).round()}%'
                      : achievement.progressLabel,
                  style: TextStyle(
                    color: achievement.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        )
        .animate(delay: (200 + index * 60).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03);
  }
}
