// features/jobs/screens/applications_screen.dart
// Feature: Job Posts & Service Requests
//
// Applications received on a job post from providers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/jobs/data/job_post_data.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  APPLICATIONS SCREEN — View applications for a job post
// ─────────────────────────────────────────────────────────

class ApplicationsScreen extends StatefulWidget {
  final JobPost jobPost;
  const ApplicationsScreen({super.key, required this.jobPost});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String _sortBy = 'rating'; // rating / price / distance

  List<JobApplication> get _applications {
    final apps = getApplicationsForJob(widget.jobPost.id);
    switch (_sortBy) {
      case 'price':
        apps.sort((a, b) => a.priceOffer.compareTo(b.priceOffer));
        break;
      case 'distance':
        apps.sort((a, b) => a.providerDistance.compareTo(b.providerDistance));
        break;
      default:
        apps.sort((a, b) => b.providerRating.compareTo(a.providerRating));
    }
    return apps;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final j = widget.jobPost;
    final apps = _applications;

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
                            'Applications',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            j.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        color: AppTheme.accentBlue.withAlpha(18),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        '${apps.length} applied',
                        style: const TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // ── Job summary card ──
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: Row(
                    children: [
                      _miniChip(
                        Icons.category_rounded,
                        j.category,
                        AppTheme.accentGold,
                      ),
                      const SizedBox(width: 10),
                      _miniChip(
                        Icons.location_on_rounded,
                        j.area,
                        AppTheme.accentTeal,
                      ),
                      const SizedBox(width: 10),
                      _miniChip(
                        j.urgency.icon,
                        j.urgency.label,
                        j.urgency.color,
                      ),
                      const Spacer(),
                      if (j.budget != null)
                        Text(
                          j.budget!,
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Sort bar ──
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
                child: Row(
                  children: [
                    const Text(
                      'Sort by',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    _sortChip('Rating', 'rating'),
                    const SizedBox(width: 6),
                    _sortChip('Price', 'price'),
                    const SizedBox(width: 6),
                    _sortChip('Distance', 'distance'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Applications list ──
              Expanded(
                child: apps.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search_rounded,
                              color: AppTheme.textMuted.withAlpha(70),
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No applications yet',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Providers will apply soon',
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
                        itemCount: apps.length,
                        itemBuilder: (context, i) =>
                            _ApplicationCard(app: apps[i], index: i),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final active = _sortBy == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _sortBy = value);
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primarySubtleGradient : null,
          color: active ? null : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accentGold : AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  APPLICATION CARD
// ─────────────────────────────────────────────────────────

class _ApplicationCard extends StatefulWidget {
  final JobApplication app;
  final int index;
  const _ApplicationCard({required this.app, required this.index});

  @override
  State<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<_ApplicationCard> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isCompact ? 12 : 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: a.status == ApplicationStatus.accepted
                  ? AppTheme.accentTeal.withAlpha(50)
                  : AppTheme.border,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Provider info row ──
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primarySubtleGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: Center(
                      child: Text(
                        a.providerInitial,
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                a.providerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (a.providerVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppTheme.accentTeal,
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.providerService,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: a.status.color.withAlpha(18),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: a.status.color.withAlpha(50)),
                    ),
                    child: Text(
                      a.status.label,
                      style: TextStyle(
                        color: a.status.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Stats row ──
              Wrap(
                spacing: isCompact ? 8 : 14,
                runSpacing: 6,
                children: [
                  _stat(
                    Icons.star_rounded,
                    '${a.providerRating}',
                    AppTheme.accentGold,
                  ),
                  _stat(
                    Icons.reviews_rounded,
                    '${a.providerReviewCount} reviews',
                    AppTheme.textMuted,
                  ),
                  _stat(
                    Icons.location_on_rounded,
                    '${a.providerDistance} km',
                    AppTheme.accentTeal,
                  ),
                  _stat(
                    Icons.work_history_rounded,
                    '${a.providerExperience} yrs',
                    AppTheme.accentPurple,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Price + ETA row ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primarySubtleGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      a.priceOffer,
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.schedule_rounded,
                    color: AppTheme.textMuted,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    a.eta,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  if (a.canStartNow) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withAlpha(18),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: const Text(
                        'Can start now',
                        style: TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // ── Message ──
              if (a.message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                  ),
                  child: Text(
                    '"${a.message}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // ── Action buttons ──
              if (a.status == ApplicationStatus.pending)
                _buildPendingActions()
              else
                Row(
                  children: [
                    _actionChip(
                      Icons.chat_rounded,
                      'Chat',
                      AppTheme.accentBlue,
                      () {},
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      Icons.call_rounded,
                      'Call',
                      AppTheme.accentTeal,
                      () {},
                    ),
                    const Spacer(),
                    Text(
                      a.appliedTime,
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
        .animate(delay: (80 + widget.index * 60).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.03);
  }

  Widget _buildPendingActions() {
    if (!_showActions) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _showActions = true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: const Center(
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      color: AppTheme.textOnAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _actionChip(Icons.chat_rounded, 'Chat', AppTheme.accentBlue, () {}),
          const SizedBox(width: 8),
          _actionChip(Icons.call_rounded, 'Call', AppTheme.accentTeal, () {}),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: AppTheme.accentTeal.withAlpha(30)),
      ),
      child: Column(
        children: [
          const Text(
            'Accept this application?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.surfaceCard,
                        content: Text(
                          '${widget.app.providerName} accepted!',
                          style: const TextStyle(color: AppTheme.accentTeal),
                        ),
                      ),
                    );
                    setState(() => _showActions = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.tealGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: const Center(
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          color: AppTheme.textOnAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showActions = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05);
  }

  Widget _stat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _actionChip(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withAlpha(35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
