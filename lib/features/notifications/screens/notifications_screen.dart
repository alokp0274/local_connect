// features/notifications/screens/notifications_screen.dart
// Feature: Notifications Center
//
// Central notification feed with categories and read/unread state.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppTheme.accentGold, fontSize: 13),
            ),
          ),
        ],
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            // Today section
            Text(
              'Today',
              style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            _NotificationTile(
              icon: Icons.check_circle_rounded,
              iconColor: AppTheme.accentTeal,
              title: 'Booking Confirmed',
              subtitle:
                  'Your booking with Rajesh Kumar has been confirmed for tomorrow at 10:00 AM.',
              time: '2 min ago',
              isUnread: true,
              index: 0,
            ),
            _NotificationTile(
              icon: Icons.chat_rounded,
              iconColor: AppTheme.accentGold,
              title: 'New Message',
              subtitle:
                  'Vikram Singh sent you a message about your upcoming service.',
              time: '1 hr ago',
              isUnread: true,
              index: 1,
            ),
            _NotificationTile(
              icon: Icons.star_rounded,
              iconColor: AppTheme.accentGold,
              title: 'Rate Your Experience',
              subtitle:
                  'How was your service with Cool Care Services? Leave a review!',
              time: '3 hrs ago',
              isUnread: false,
              index: 2,
            ),

            const SizedBox(height: 20),
            Text(
              'Earlier',
              style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            _NotificationTile(
              icon: Icons.local_offer_rounded,
              iconColor: AppTheme.accentCoral,
              title: '20% Off on Cleaning',
              subtitle:
                  'Book a deep cleaning service today and get 20% off. Limited time offer!',
              time: 'Yesterday',
              isUnread: false,
              index: 3,
            ),
            _NotificationTile(
              icon: Icons.person_add_rounded,
              iconColor: AppTheme.accentPurple,
              title: 'New Provider Nearby',
              subtitle:
                  'Glamour Studio is now available in your area. Check them out!',
              time: '2 days ago',
              isUnread: false,
              index: 4,
            ),
            _NotificationTile(
              icon: Icons.payments_rounded,
              iconColor: AppTheme.accentTeal,
              title: 'Payment Successful',
              subtitle:
                  'Your payment of ₹2,500 to Cool Care Services was successful.',
              time: '3 days ago',
              isUnread: false,
              index: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;
  final int index;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? AppTheme.accentGold.withAlpha(8)
                : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: isUnread
                ? Border.all(color: AppTheme.accentGold.withAlpha(40))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(icon, color: iconColor, size: 22),
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
                            title,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: tt.bodyMedium?.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(time, style: tt.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05);
  }
}
