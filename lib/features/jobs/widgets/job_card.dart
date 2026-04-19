// features/jobs/widgets/job_card.dart
// Feature: Jobs Feed
//
// Reusable social-feed style job post card for the jobs marketplace.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/jobs/models/job_model.dart';

class JobCard extends StatefulWidget {
  final JobPost job;
  final int index;
  final bool isCustomerView; // true = customer's own jobs tab
  final VoidCallback onTap;
  final VoidCallback? onBidTap;
  final VoidCallback? onViewBidsTap;

  const JobCard({
    super.key,
    required this.job,
    required this.index,
    required this.onTap,
    this.isCustomerView = false,
    this.onBidTap,
    this.onViewBidsTap,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final j = widget.job;

    return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2A40), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Poster info row ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: _PosterRow(job: j),
                  ),

                  // ── Category + urgency chips ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _ChipRow(
                      job: j,
                      isCustomerView: widget.isCustomerView,
                    ),
                  ),

                  // ── Title ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      j.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // ── Description ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Text(
                      j.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),

                  // ── Optional photo ──
                  if (j.imageUrl != null && j.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: const Color(0xFF1A2235),
                          child: Image.network(
                            j.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, e, st) => const Center(
                              child: Icon(
                                Icons.image_rounded,
                                color: AppTheme.textMuted,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Location + budget row ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _MetaRow(job: j),
                  ),

                  // ── Divider ──
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Divider(color: Color(0xFF1E2A40), height: 1),
                  ),

                  // ── Engagement row + CTA ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: _EngagementRow(
                      job: j,
                      isCustomerView: widget.isCustomerView,
                      onBidTap: widget.onBidTap,
                      onViewBidsTap: widget.onViewBidsTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 70).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.12, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────
// POSTER INFO ROW
// ─────────────────────────────────────────

class _PosterRow extends StatelessWidget {
  final JobPost job;
  const _PosterRow({required this.job});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withAlpha(60),
                const Color(0xFF6366F1).withAlpha(40),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              job.customerName.isNotEmpty
                  ? job.customerName[0].toUpperCase()
                  : 'C',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
                      job.customerName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFACC15),
                    size: 13,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    job.customerRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFFFACC15),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '• ${job.location.split(',').last.trim()}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  if (job.customerVerified) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withAlpha(22),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppTheme.accentTeal.withAlpha(60),
                          width: 0.5,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppTheme.accentTeal,
                            size: 10,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Verified Customer',
                            style: TextStyle(
                              color: AppTheme.accentTeal,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      job.postedAgo,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Distance badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withAlpha(18),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppTheme.accentBlue,
                size: 11,
              ),
              const SizedBox(width: 3),
              Text(
                '${job.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: AppTheme.accentBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// CHIP ROW — category + urgency
// ─────────────────────────────────────────

class _ChipRow extends StatelessWidget {
  final JobPost job;
  final bool isCustomerView;
  const _ChipRow({required this.job, required this.isCustomerView});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(job.urgency);
    final urgencyLabel = _urgencyLabel(job.urgency);
    final urgencyIcon = _urgencyIcon(job.urgency);

    return Row(
      children: [
        // Category chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withAlpha(20),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppTheme.accentPurple.withAlpha(60),
              width: 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.build_rounded,
                color: AppTheme.accentPurple,
                size: 11,
              ),
              const SizedBox(width: 4),
              Text(
                job.category,
                style: const TextStyle(
                  color: AppTheme.accentPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Urgency chip (skip if flexible)
        if (job.urgency != 'flexible') ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: urgencyColor.withAlpha(22),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: urgencyColor.withAlpha(70), width: 0.6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(urgencyIcon, color: urgencyColor, size: 11),
                const SizedBox(width: 4),
                Text(
                  urgencyLabel,
                  style: TextStyle(
                    color: urgencyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        // Status badge for customer view
        if (isCustomerView) ...[
          const Spacer(),
          _StatusBadge(status: job.status),
        ],
      ],
    );
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'emergency':
        return const Color(0xFFEF4444);
      case 'today':
        return const Color(0xFFFACC15);
      case 'thisWeek':
        return AppTheme.accentBlue;
      default:
        return AppTheme.textMuted;
    }
  }

  String _urgencyLabel(String urgency) {
    switch (urgency) {
      case 'emergency':
        return 'Emergency';
      case 'today':
        return 'Today';
      case 'thisWeek':
        return 'This Week';
      default:
        return 'Flexible';
    }
  }

  IconData _urgencyIcon(String urgency) {
    switch (urgency) {
      case 'emergency':
        return Icons.priority_high_rounded;
      case 'today':
        return Icons.today_rounded;
      case 'thisWeek':
        return Icons.date_range_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }
}

// ─────────────────────────────────────────
// STATUS BADGE (customer view)
// ─────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(70), width: 0.7),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case 'open':
        return const Color(0xFF10B981);
      case 'inProgress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF6B7280);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.textMuted;
    }
  }

  String get _label {
    switch (status) {
      case 'open':
        return 'Open';
      case 'inProgress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

// ─────────────────────────────────────────
// META ROW — location + budget
// ─────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final JobPost job;
  const _MetaRow({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppTheme.textMuted,
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                job.location,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.currency_rupee_rounded,
              color: AppTheme.accentGold,
              size: 13,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                'Budget: ₹${job.budgetMin} – ₹${job.budgetMax}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.accentBlue,
              size: 12,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Preferred: ${job.preferredDate}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// ENGAGEMENT ROW — bids + CTA
// ─────────────────────────────────────────

class _EngagementRow extends StatelessWidget {
  final JobPost job;
  final bool isCustomerView;
  final VoidCallback? onBidTap;
  final VoidCallback? onViewBidsTap;

  const _EngagementRow({
    required this.job,
    required this.isCustomerView,
    this.onBidTap,
    this.onViewBidsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.group_rounded, color: AppTheme.textMuted, size: 15),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${job.bidCount} bids',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.timer_outlined, color: AppTheme.textMuted, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            job.closesIn,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ),
        const Spacer(),
        // CTA
        if (!isCustomerView && job.status == 'open')
          _BidNowButton(onTap: onBidTap),
        if (isCustomerView)
          _ViewBidsButton(bidCount: job.bidCount, onTap: onViewBidsTap),
        if (isCustomerView && job.status == 'completed')
          _RateButton(onTap: onViewBidsTap),
      ],
    );
  }
}

class _BidNowButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _BidNowButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.goldGradient,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(color: AppTheme.accentGold.withAlpha(60), blurRadius: 12),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppTheme.textOnAccent,
              size: 14,
            ),
            SizedBox(width: 6),
            Text(
              'Bid Now',
              style: TextStyle(
                color: AppTheme.textOnAccent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewBidsButton extends StatelessWidget {
  final int bidCount;
  final VoidCallback? onTap;
  const _ViewBidsButton({required this.bidCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.accentBlue.withAlpha(22),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppTheme.accentBlue.withAlpha(80),
            width: 0.7,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.group_rounded,
              color: AppTheme.accentBlue,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              '$bidCount Bids — View All',
              style: const TextStyle(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _RateButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.goldGradient,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, color: AppTheme.textOnAccent, size: 14),
            SizedBox(width: 5),
            Text(
              'Rate Provider',
              style: TextStyle(
                color: AppTheme.textOnAccent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
