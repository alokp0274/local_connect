// features/rewards/screens/streaks_badges_screen.dart
// Feature: Rewards, Wallet & Loyalty
//
// Streaks, badges, and gamification progress tracker.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/rewards/data/rewards_dummy_data.dart';
import 'package:local_connect/features/rewards/models/rewards_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  STREAKS & BADGES SCREEN
// ─────────────────────────────────────────────────────────

class StreaksBadgesScreen extends StatelessWidget {
  const StreaksBadgesScreen({super.key});

  static const _weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    final earnedBadges = userBadges.where((b) => b.earned).toList();
    final lockedBadges = userBadges.where((b) => !b.earned).toList();

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
                          'Streaks & Badges',
                          style: tt.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Streak Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    gradient: const LinearGradient(
                      colors: [Color(0x1AFF6B6B), Color(0x0AFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppTheme.accentCoral.withAlpha(60),
                      width: 0.8,
                    ),
                    child: Column(
                      children: [
                        // Fire icon + streak count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.accentCoral,
                                    Color(0xFFFF9B6B),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentCoral.withAlpha(60),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userStreak.currentStreak} Day Streak!',
                                  style: tt.headlineMedium?.copyWith(
                                    fontSize: 22,
                                    color: AppTheme.accentCoral,
                                  ),
                                ),
                                Text(
                                  'Longest: ${userStreak.longestStreak} days  •  ${userStreak.totalCheckIns} check-ins',
                                  style: tt.labelSmall?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Weekly tracker
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) {
                            final completed = userStreak.weekDays[i];
                            return Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: completed
                                        ? const LinearGradient(
                                            colors: [
                                              AppTheme.accentCoral,
                                              Color(0xFFFF9B6B),
                                            ],
                                          )
                                        : null,
                                    color: completed
                                        ? null
                                        : AppTheme.surfaceElevated,
                                    shape: BoxShape.circle,
                                    border: !completed
                                        ? Border.all(
                                            color: AppTheme.border,
                                            width: 0.5,
                                          )
                                        : null,
                                    boxShadow: completed
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.accentCoral
                                                  .withAlpha(40),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    completed
                                        ? Icons.check_rounded
                                        : Icons.circle_outlined,
                                    color: completed
                                        ? Colors.white
                                        : AppTheme.textMuted,
                                    size: completed ? 18 : 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _weekLabels[i],
                                  style: TextStyle(
                                    color: completed
                                        ? AppTheme.textPrimary
                                        : AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCoral.withAlpha(14),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                            border: Border.all(
                              color: AppTheme.accentCoral.withAlpha(30),
                            ),
                          ),
                          child: Text(
                            'Keep it up! 4 more days for a streak badge 🎯',
                            style: tt.labelSmall?.copyWith(
                              color: AppTheme.accentCoral,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
              ),

              // ── Earned Badges ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 24, pad, 10),
                  child: Row(
                    children: [
                      Text(
                        'Earned Badges',
                        style: tt.headlineMedium?.copyWith(fontSize: 17),
                      ),
                      const SizedBox(width: 8),
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
                        child: Text(
                          '${earnedBadges.length}',
                          style: const TextStyle(
                            color: AppTheme.accentTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        _BadgeTile(badge: earnedBadges[i], delay: i),
                    childCount: earnedBadges.length,
                  ),
                ),
              ),

              // ── In Progress ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 24, pad, 10),
                  child: Row(
                    children: [
                      Text(
                        'In Progress',
                        style: tt.headlineMedium?.copyWith(fontSize: 17),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted.withAlpha(30),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          '${lockedBadges.length}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        _InProgressTile(badge: lockedBadges[i], delay: i),
                    childCount: lockedBadges.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge Grid Tile ──
class _BadgeTile extends StatelessWidget {
  final RewardBadge badge;
  final int delay;
  const _BadgeTile({required this.badge, required this.delay});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassContainer(
          padding: const EdgeInsets.all(10),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: badge.color.withAlpha(50), width: 0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badge.color, badge.color.withAlpha(180)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: badge.color.withAlpha(40), blurRadius: 10),
                  ],
                ),
                child: Icon(badge.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                badge.title,
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                badge.subtitle,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
        .animate(delay: (200 + delay * 80).ms)
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }
}

// ── In Progress Tile ──
class _InProgressTile extends StatelessWidget {
  final RewardBadge badge;
  final int delay;
  const _InProgressTile({required this.badge, required this.delay});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badge.color.withAlpha(14),
                  shape: BoxShape.circle,
                  border: Border.all(color: badge.color.withAlpha(30)),
                ),
                child: Icon(
                  badge.icon,
                  color: badge.color.withAlpha(120),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      badge.progressLabel ?? 'In progress',
                      style: tt.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: LinearProgressIndicator(
                        value: badge.progress,
                        backgroundColor: AppTheme.surfaceElevated,
                        valueColor: AlwaysStoppedAnimation(
                          badge.color.withAlpha(180),
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(badge.progress * 100).round()}%',
                style: TextStyle(
                  color: badge.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        )
        .animate(delay: (300 + delay * 80).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03);
  }
}
