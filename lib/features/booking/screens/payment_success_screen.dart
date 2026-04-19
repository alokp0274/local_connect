// features/booking/screens/payment_success_screen.dart
// Feature: Booking & Payment Flow
//
// Payment confirmation screen with animated success state and booking ID.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        type: BackgroundType.mesh,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 20, pad, 24),
            child: Column(
              children: [
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentTeal.withAlpha(30),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          duration: 1200.ms,
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                        ),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.tealGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.tealGlow,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ).animate().scale(
                      begin: const Offset(0, 0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Booking Confirmed', style: tt.displayMedium)
                    .animate(delay: 180.ms)
                    .fadeIn(duration: 260.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Your service professional has been notified and your booking is secured.',
                  textAlign: TextAlign.center,
                  style: tt.bodyLarge,
                ).animate(delay: 280.ms).fadeIn(duration: 260.ms),
                const SizedBox(height: 18),
                GlassContainer(
                  padding: const EdgeInsets.all(14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: Column(
                    children: const [
                      _SummaryLine(label: 'Booking ID', value: 'BK-2026-001'),
                      _SummaryLine(label: 'Provider', value: 'Rajesh Kumar'),
                      _SummaryLine(label: 'Time', value: 'Tomorrow • 10:00 AM'),
                      _SummaryLine(
                        label: 'Total Paid',
                        value: '₹973',
                        highlight: true,
                      ),
                    ],
                  ),
                ).animate(delay: 360.ms).fadeIn(duration: 300.ms),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.mainShell,
                      (route) => false,
                    ),
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Go to Bookings'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.mainShell,
                      (route) => false,
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Book Another Service'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryLine({
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
        children: [
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: highlight ? AppTheme.accentGold : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
