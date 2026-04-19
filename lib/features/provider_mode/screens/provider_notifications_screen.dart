// features/provider_mode/screens/provider_notifications_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Provider-specific notification feed (leads, payments, updates).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/provider_mode/data/provider_dummy_data.dart';
import 'package:local_connect/features/provider_mode/models/lead_model.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({super.key});
  @override
  State<ProviderNotificationsScreen> createState() =>
      _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState
    extends State<ProviderNotificationsScreen> {
  late List<ProviderNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(dummyProviderNotifications);
  }

  void _markAllRead() {
    HapticFeedback.selectionClick();
    setState(() {
      _notifications = _notifications
          .map(
            (n) => ProviderNotification(
              id: n.id,
              title: n.title,
              body: n.body,
              time: n.time,
              type: n.type,
              isRead: true,
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(tt, pad, unread),
              Expanded(
                child: _notifications.isEmpty
                    ? _buildEmptyState(tt)
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(pad, 12, pad, 32),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _notifications.length,
                        itemBuilder: (_, i) =>
                            _buildNotifCard(_notifications[i], tt, i),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme tt, double pad, int unread) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              padding: const EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
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
                Text(
                  'Notifications',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCoral,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (unread > 0)
            GestureDetector(
              onTap: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppTheme.accentTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildEmptyState(TextTheme tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.textMuted.withAlpha(80),
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: tt.titleMedium?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(ProviderNotification notif, TextTheme tt, int index) {
    final color = _notifColor(notif.type);
    final icon = _notifIcon(notif.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? AppTheme.surfaceCard : color.withAlpha(8),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: notif.isRead ? AppTheme.border : color.withAlpha(40),
          width: notif.isRead ? 0.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(notif.isRead ? 10 : 20),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: notif.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          fontSize: 13,
                          color: notif.isRead
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (!notif.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif.body,
                  style: TextStyle(
                    color: notif.isRead
                        ? AppTheme.textMuted
                        : AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      notif.time,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(12),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        _notifTypeLabel(notif.type),
                        style: TextStyle(
                          color: color.withAlpha(180),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (100 + index * 40).ms).fadeIn(duration: 250.ms);
  }

  Color _notifColor(ProviderNotifType type) {
    switch (type) {
      case ProviderNotifType.lead:
        return AppTheme.accentTeal;
      case ProviderNotifType.message:
        return AppTheme.accentBlue;
      case ProviderNotifType.review:
        return AppTheme.accentGold;
      case ProviderNotifType.demand:
        return AppTheme.accentCoral;
      case ProviderNotifType.ranking:
        return AppTheme.accentPurple;
      case ProviderNotifType.system:
        return AppTheme.textMuted;
    }
  }

  IconData _notifIcon(ProviderNotifType type) {
    switch (type) {
      case ProviderNotifType.lead:
        return Icons.person_add_alt_1_rounded;
      case ProviderNotifType.message:
        return Icons.chat_bubble_outline_rounded;
      case ProviderNotifType.review:
        return Icons.star_outline_rounded;
      case ProviderNotifType.demand:
        return Icons.local_fire_department_rounded;
      case ProviderNotifType.ranking:
        return Icons.leaderboard_outlined;
      case ProviderNotifType.system:
        return Icons.info_outline_rounded;
    }
  }

  String _notifTypeLabel(ProviderNotifType type) {
    switch (type) {
      case ProviderNotifType.lead:
        return 'Lead';
      case ProviderNotifType.message:
        return 'Message';
      case ProviderNotifType.review:
        return 'Review';
      case ProviderNotifType.demand:
        return 'Demand';
      case ProviderNotifType.ranking:
        return 'Ranking';
      case ProviderNotifType.system:
        return 'System';
    }
  }
}
