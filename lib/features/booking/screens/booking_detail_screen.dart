// features/booking/screens/booking_detail_screen.dart
// Feature: Booking & Payment Flow
//
// Single booking detail view with status timeline, provider info, and actions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/category_icons.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late int _timelineProgress;

  @override
  void initState() {
    super.initState();
    _timelineProgress = _statusToProgress(widget.booking['status'] as String);
  }

  int _statusToProgress(String status) {
    switch (status) {
      case 'pending':
        return 1;
      case 'confirmed':
        return 2;
      case 'in-progress':
        return 4;
      case 'completed':
        return 5;
      case 'cancelled':
        return 0;
      default:
        return 1;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppTheme.accentTeal;
      case 'pending':
        return AppTheme.accentGold;
      case 'in-progress':
        return AppTheme.accentBlue;
      case 'completed':
        return AppTheme.accentTeal;
      case 'cancelled':
        return AppTheme.accentCoral;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final status = booking['status'] as String;
    final statusColor = _statusColor(status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Booking Detail'),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 120),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              gradient: AppTheme.surfaceGradient,
              child: Column(
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'booking-${booking['id']}',
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: CategoryIcons.getCategoryGradient(
                              booking['service'] as String,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: Icon(
                            CategoryIcons.getIcon(booking['service'] as String),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['providerName'] as String,
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking['service'] as String,
                              style: tt.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Booking ID: ${booking['id']}',
                              style: tt.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(24),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          border: Border.all(color: statusColor.withAlpha(90)),
                        ),
                        child: Text(
                          status.replaceAll('-', ' ').toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Date/Time',
                    value: '${booking['date']} • ${booking['time']}',
                  ),
                  _SummaryRow(
                    label: 'Address',
                    value:
                        booking['address'] as String? ??
                        '42, MG Road, Sector 14',
                  ),
                  _SummaryRow(
                    label: 'Price',
                    value: booking['price'] as String,
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: 'Service Timeline',
              subtitle: 'Real-time job progression',
            ),
            const SizedBox(height: 10),
            GlassContainer(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _TimelineStep(
                    title: 'Request Sent',
                    index: 1,
                    current: _timelineProgress,
                  ),
                  _TimelineStep(
                    title: 'Confirmed',
                    index: 2,
                    current: _timelineProgress,
                  ),
                  _TimelineStep(
                    title: 'On The Way',
                    index: 3,
                    current: _timelineProgress,
                  ),
                  _TimelineStep(
                    title: 'Service Started',
                    index: 4,
                    current: _timelineProgress,
                  ),
                  _TimelineStep(
                    title: 'Completed',
                    index: 5,
                    current: _timelineProgress,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: 'Details',
              subtitle: 'Booking and payment information',
            ),
            const SizedBox(height: 10),
            GlassContainer(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Service Package',
                    value: booking['package'] as String? ?? 'Standard Repair',
                  ),
                  _SummaryRow(
                    label: 'Notes',
                    value: booking['notes'] as String? ?? 'No additional notes',
                  ),
                  _SummaryRow(
                    label: 'Payment Method',
                    value: booking['payment'] as String? ?? 'UPI',
                  ),
                  _SummaryRow(
                    label: 'Invoice Summary',
                    value: '${booking['price']} + ₹29 fees',
                    highlight: true,
                  ),
                  _SummaryRow(
                    label: 'Contact Provider',
                    value: booking['providerName'] as String,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: GlassContainer(
            padding: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            gradient: AppTheme.surfaceGradient,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bottomActions(context, booking, status),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _bottomActions(
    BuildContext context,
    Map<String, dynamic> booking,
    String status,
  ) {
    if (status == 'completed') {
      return [
        _BottomButton(
          text: 'Rebook',
          icon: Icons.refresh_rounded,
          color: AppTheme.accentGold,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.selectSlot,
            arguments: {'providerName': booking['providerName']},
          ),
        ),
        _BottomButton(
          text: 'Invoice',
          icon: Icons.receipt_long_rounded,
          color: AppTheme.accentBlue,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.invoice,
            arguments: {'bookingId': booking['id']},
          ),
        ),
      ];
    }

    if (status == 'cancelled') {
      return [
        _BottomButton(
          text: 'Rebook',
          icon: Icons.refresh_rounded,
          color: AppTheme.accentGold,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.selectSlot,
            arguments: {'providerName': booking['providerName']},
          ),
        ),
      ];
    }

    return [
      _BottomButton(
        text: 'Reschedule',
        icon: Icons.update_rounded,
        color: AppTheme.accentBlue,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.selectSlot,
          arguments: {'providerName': booking['providerName']},
        ),
      ),
      _BottomButton(
        text: 'Cancel',
        icon: Icons.cancel_rounded,
        color: AppTheme.accentCoral,
        onTap: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cancellation request submitted')),
          );
        },
      ),
      _BottomButton(
        text: 'Download Invoice',
        icon: Icons.download_rounded,
        color: AppTheme.accentGold,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.invoice,
          arguments: {'bookingId': booking['id']},
        ),
      ),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.headlineMedium),
        const SizedBox(height: 2),
        Text(subtitle, style: tt.labelSmall),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: highlight ? AppTheme.accentGold : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final int index;
  final int current;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.index,
    required this.current,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final done = current >= index;
    final activeColor = done ? AppTheme.accentGold : AppTheme.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: AppTheme.durationMedium,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done ? AppTheme.accentGold : AppTheme.surfaceDivider,
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppTheme.textOnAccent,
                      size: 13,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: done ? AppTheme.accentGold : AppTheme.surfaceDivider,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              title,
              style: TextStyle(
                color: activeColor,
                fontWeight: done ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BottomButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withAlpha(24),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withAlpha(110), width: 0.7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
