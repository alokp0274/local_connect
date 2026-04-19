// features/jobs/screens/request_success_screen.dart
// Feature: Job Posts & Service Requests
//
// Success confirmation after posting a service request.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/jobs/screens/my_requests_screen.dart';

// ─────────────────────────────────────────────────────────
//  REQUEST SUCCESS SCREEN
// ─────────────────────────────────────────────────────────

class RequestSuccessScreen extends StatelessWidget {
  final JobPost jobPost;
  const RequestSuccessScreen({super.key, required this.jobPost});

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
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Success Icon ──
                Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.tealGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.tealGlow,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    )
                    .animate()
                    .scale(
                      duration: 600.ms,
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: 28),

                Text(
                  'Request Posted!',
                  style: tt.displayMedium?.copyWith(fontSize: 26),
                  textAlign: TextAlign.center,
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 10),

                Text(
                  'Nearby providers will see your request\nand start applying soon.',
                  style: tt.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // ── Request Summary Card ──
                GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(
                        color: AppTheme.accentTeal.withAlpha(40),
                        width: 0.5,
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Service',
                            value: jobPost.category,
                          ),
                          _SummaryRow(label: 'Title', value: jobPost.title),
                          _SummaryRow(
                            label: 'Area',
                            value: '${jobPost.area}, ${jobPost.pincode}',
                          ),
                          _SummaryRow(
                            label: 'Urgency',
                            value: jobPost.urgency.label,
                          ),
                          if (jobPost.budget != null)
                            _SummaryRow(
                              label: 'Budget',
                              value: jobPost.budget!,
                            ),
                        ],
                      ),
                    )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1),

                const Spacer(flex: 2),

                // ── Actions ──
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MyRequestsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text('View My Requests'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Back to Home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ),
                ).animate(delay: 650.ms).fadeIn(duration: 400.ms),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
