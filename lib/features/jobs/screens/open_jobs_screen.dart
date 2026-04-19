// features/jobs/screens/open_jobs_screen.dart
// Feature: Job Posts & Service Requests
//
// Browse open job postings from users looking for service providers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/jobs/data/job_post_data.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/jobs/widgets/apply_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────
//  OPEN JOBS SCREEN — Provider browses nearby job posts
// ─────────────────────────────────────────────────────────

class OpenJobsScreen extends StatefulWidget {
  const OpenJobsScreen({super.key});

  @override
  State<OpenJobsScreen> createState() => _OpenJobsScreenState();
}

class _OpenJobsScreenState extends State<OpenJobsScreen> {
  String _selectedCategory = 'All';
  final String _userPincode = '400001'; // Mock current provider pincode

  List<JobPost> get _filteredJobs {
    final nearby = getNearbyOpenJobs(_userPincode);
    if (_selectedCategory == 'All') return nearby;
    return nearby.where((j) => j.category == _selectedCategory).toList();
  }

  Set<String> get _availableCategories {
    final nearby = getNearbyOpenJobs(_userPincode);
    return {'All', ...nearby.map((j) => j.category)};
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final jobs = _filteredJobs;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── App bar ──
              Padding(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open Jobs Near You',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'PIN $_userPincode area',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withAlpha(18),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        '${jobs.length} jobs',
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // ── Category filter ──
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
                  separatorBuilder: (context2, i2) => const SizedBox(width: 6),
                  itemCount: _availableCategories.length,
                  itemBuilder: (context, i) {
                    final cat = _availableCategories.elementAt(i);
                    final active = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = cat);
                      },
                      child: AnimatedContainer(
                        duration: AppTheme.durationFast,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: active ? AppTheme.primarySubtleGradient : null,
                          color: active ? null : AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: active
                                  ? AppTheme.accentGold
                                  : AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // ── Jobs list ──
              Expanded(
                child: jobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.work_off_rounded,
                              color: AppTheme.textMuted.withAlpha(70),
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No open jobs found',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Check back soon for new requests',
                              style: TextStyle(
                                color: AppTheme.textMuted.withAlpha(120),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(pad, 4, pad, 24),
                        itemCount: jobs.length,
                        itemBuilder: (context, i) => _OpenJobCard(
                          job: jobs[i],
                          index: i,
                          onApply: () => _showApply(jobs[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApply(JobPost job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ApplyBottomSheet(jobPost: job),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  OPEN JOB CARD
// ─────────────────────────────────────────────────────────

class _OpenJobCard extends StatefulWidget {
  final JobPost job;
  final int index;
  final VoidCallback onApply;
  const _OpenJobCard({
    required this.job,
    required this.index,
    required this.onApply,
  });

  @override
  State<_OpenJobCard> createState() => _OpenJobCardState();
}

class _OpenJobCardState extends State<_OpenJobCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.985 : 1,
            duration: AppTheme.durationFast,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isCompact ? 12 : 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: j.urgency == JobUrgency.urgent
                      ? AppTheme.accentCoral.withAlpha(40)
                      : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: poster + time ──
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusXS,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            j.postedByInitial,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              j.postedBy,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.schedule_rounded,
                        color: AppTheme.textMuted,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        j.timePosted,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Title ──
                  Text(
                    j.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ── Description preview ──
                  Text(
                    j.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Meta chips ──
                  Wrap(
                    spacing: isCompact ? 6 : 10,
                    runSpacing: 4,
                    children: [
                      _metaChip(
                        Icons.category_rounded,
                        j.category,
                        AppTheme.accentGold,
                      ),
                      _metaChip(
                        Icons.location_on_rounded,
                        '${j.area}, ${j.pincode}',
                        AppTheme.accentTeal,
                      ),
                      _metaChip(
                        j.urgency.icon,
                        j.urgency.label,
                        j.urgency.color,
                      ),
                      if (j.budget != null)
                        _metaChip(
                          Icons.payments_rounded,
                          j.budget!,
                          AppTheme.accentGold,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Action row ──
                  Row(
                    children: [
                      // Apply button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            widget.onApply();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Apply Now',
                                style: TextStyle(
                                  color: AppTheme.textOnAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chat
                      GestureDetector(
                        onTap: () => HapticFeedback.selectionClick(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withAlpha(12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                            border: Border.all(
                              color: AppTheme.accentBlue.withAlpha(35),
                            ),
                          ),
                          child: const Icon(
                            Icons.chat_rounded,
                            color: AppTheme.accentBlue,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Call
                      GestureDetector(
                        onTap: () => HapticFeedback.selectionClick(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withAlpha(12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                            border: Border.all(
                              color: AppTheme.accentTeal.withAlpha(35),
                            ),
                          ),
                          child: const Icon(
                            Icons.call_rounded,
                            color: AppTheme.accentTeal,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (80 + widget.index * 60).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.04);
  }

  Widget _metaChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
