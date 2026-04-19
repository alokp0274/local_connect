// features/rewards/screens/reward_notifications_screen.dart
// Feature: Rewards, Wallet & Loyalty
//
// Notifications related to rewards, points earned, and offers.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/rewards/data/rewards_dummy_data.dart';
import 'package:local_connect/features/rewards/models/rewards_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  REWARD NOTIFICATIONS SCREEN
// ─────────────────────────────────────────────────────────

class RewardNotificationsScreen extends StatelessWidget {
  const RewardNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    final unread = rewardNotifications.where((n) => !n.isRead).length;

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
                        child: Row(
                          children: [
                            Text('Reward Alerts', style: tt.headlineMedium),
                            if (unread > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.accentCoral,
                                      Color(0xFFFF9B6B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  '$unread new',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Notification List ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _NotificationTile(
                      notification: rewardNotifications[i],
                      index: i,
                    ),
                    childCount: rewardNotifications.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final RewardNotification notification;
  final int index;
  const _NotificationTile({required this.notification, required this.index});

  (IconData, Color) get _typeStyle {
    switch (notification.type) {
      case RewardNotifType.pointsEarned:
        return (Icons.star_rounded, AppTheme.accentGold);
      case RewardNotifType.badgeUnlocked:
        return (Icons.emoji_events_rounded, AppTheme.accentPurple);
      case RewardNotifType.tierUpgrade:
        return (Icons.workspace_premium_rounded, AppTheme.accentTeal);
      case RewardNotifType.cashback:
        return (Icons.savings_rounded, AppTheme.accentTeal);
      case RewardNotifType.offer:
        return (Icons.local_offer_rounded, AppTheme.accentCoral);
      case RewardNotifType.streak:
        return (Icons.local_fire_department_rounded, AppTheme.accentCoral);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (icon, color) = _typeStyle;

    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppTheme.surfaceCard
                : color.withAlpha(8),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: notification.isRead
                  ? AppTheme.border
                  : color.withAlpha(40),
              width: notification.isRead ? 0.5 : 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: !notification.isRead
                      ? LinearGradient(colors: [color, color.withAlpha(180)])
                      : null,
                  color: notification.isRead ? AppTheme.surfaceElevated : null,
                  shape: BoxShape.circle,
                  boxShadow: !notification.isRead
                      ? [BoxShadow(color: color.withAlpha(30), blurRadius: 8)]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: !notification.isRead
                      ? Colors.white
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
                      notification.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                        color: notification.isRead
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: tt.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.time,
                      style: TextStyle(
                        color: AppTheme.textMuted.withAlpha(120),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withAlpha(180)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        )
        .animate(delay: (150 + index * 50).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.02);
  }
}
