// features/jobs/screens/request_work_detail_screen.dart
// Feature: Jobs & Requests
//
// Detail screen for a single ServiceRequest.
// Shows full description, applicants list, and accept/apply actions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/models/request_model.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class RequestWorkDetailScreen extends StatelessWidget {
  final ServiceRequest request;

  const RequestWorkDetailScreen({super.key, required this.request});

  Future<void> _makeCall(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(pad, 12, pad, 100),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Request Info Card ──
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.border.withAlpha(80)),
            boxShadow: AppTheme.cardShadow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + urgency row
                Row(
                  children: [
                    _StatusChip(
                      label: request.statusLabel,
                      color: _statusColor,
                    ),
                    if (request.urgency != RequestUrgency.normal) ...[
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: request.urgencyLabel,
                        color: _urgencyColor,
                        icon: request.urgency == RequestUrgency.emergency
                            ? Icons.warning_rounded
                            : Icons.schedule_rounded,
                      ),
                    ],
                    const Spacer(),
                    Text(
                      request.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(request.title, style: tt.headlineMedium),
                const SizedBox(height: 8),

                // Description
                Text(
                  request.description,
                  style: tt.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Meta info grid
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    if (request.budgetRange.isNotEmpty)
                      _MetaItem(
                        icon: Icons.payments_outlined,
                        label: 'Budget',
                        value: request.budgetRange,
                      ),
                    _MetaItem(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: request.address.isNotEmpty
                          ? request.address
                          : 'PIN ${request.pincode}',
                    ),
                    _MetaItem(
                      icon: Icons.access_time_rounded,
                      label: 'Posted',
                      value: timeago.format(request.createdAt),
                    ),
                    if (request.scheduledDate != null)
                      _MetaItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Scheduled',
                        value: _formatDate(request.scheduledDate!),
                      ),
                    if (!request.isMyRequest)
                      _MetaItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Posted by',
                        value: request.postedByName,
                      ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 280.ms),

          const SizedBox(height: 20),

          // ── Applicants Section (only for my requests) ──
          if (request.isMyRequest && request.applicants.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Applicants',
                  style: tt.headlineMedium?.copyWith(fontSize: 17),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    '${request.applicantCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...request.applicants.asMap().entries.map((entry) {
              final index = entry.key;
              final applicant = entry.value;
              final isAssigned = request.assignedProviderId == applicant.id;
              return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ApplicantCard(
                      applicant: applicant,
                      isAssigned: isAssigned,
                      onCall: () => _makeCall(context, applicant.phone),
                      onAccept: isAssigned
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Accepted ${applicant.name} for this request',
                                  ),
                                ),
                              );
                            },
                    ),
                  )
                  .animate(delay: (index * 50).ms)
                  .fadeIn(duration: 260.ms)
                  .slideY(begin: 0.04);
            }),
          ],

          // ── Apply Button (only for accepting work) ──
          if (!request.isMyRequest && request.isOpen) ...[
            const SizedBox(height: 10),
            _ApplySection(),
          ],

          // ── No applicants message ──
          if (request.isMyRequest && request.applicants.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      color: AppTheme.textMuted,
                      size: 32,
                    ),
                    const SizedBox(height: 10),
                    Text('Waiting for applicants', style: tt.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Professionals in your area will apply soon.',
                      style: tt.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (request.status) {
      case RequestStatus.open:
        return AppTheme.success;
      case RequestStatus.inProgress:
        return AppTheme.accentBlue;
      case RequestStatus.completed:
        return AppTheme.textMuted;
      case RequestStatus.cancelled:
        return AppTheme.error;
    }
  }

  Color get _urgencyColor {
    switch (request.urgency) {
      case RequestUrgency.normal:
        return AppTheme.textMuted;
      case RequestUrgency.urgent:
        return AppTheme.warning;
      case RequestUrgency.emergency:
        return AppTheme.urgent;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

// ─────────────────────────────────────────────────────────
//  STATUS CHIP
// ─────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _StatusChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  META ITEM
// ─────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.textMuted),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  APPLICANT CARD
// ─────────────────────────────────────────────────────────

class _ApplicantCard extends StatelessWidget {
  final RequestApplicant applicant;
  final bool isAssigned;
  final VoidCallback onCall;
  final VoidCallback? onAccept;

  const _ApplicantCard({
    required this.applicant,
    required this.isAssigned,
    required this.onCall,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      border: Border.all(
        color: isAssigned
            ? AppTheme.success.withAlpha(60)
            : AppTheme.border.withAlpha(80),
      ),
      gradient: isAssigned
          ? LinearGradient(
              colors: [
                AppTheme.success.withAlpha(8),
                AppTheme.success.withAlpha(3),
              ],
            )
          : null,
      boxShadow: AppTheme.cardShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Center(
                  child: Text(
                    applicant.name.isNotEmpty
                        ? applicant.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            applicant.name,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (applicant.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: AppTheme.accentBlue,
                          ),
                        ],
                        if (isAssigned) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withAlpha(15),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: const Text(
                              'Assigned',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${applicant.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${applicant.reviewCount})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          applicant.experience,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                applicant.pricing,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentGold,
                ),
              ),
            ],
          ),

          // Message
          if (applicant.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                '"${applicant.message}"',
                style: tt.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // Meta row
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Text(
                  '${applicant.jobsCompleted} jobs done',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '~${applicant.responseTimeMinutes} min response',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  timeago.format(applicant.appliedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          if (!isAssigned) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call_outlined, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  APPLY SECTION — For "Accept Work" tab detail view
// ─────────────────────────────────────────────────────────

class _ApplySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      gradient: AppTheme.primarySubtleGradient,
      border: Border.all(color: AppTheme.accentGold.withAlpha(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interested in this job?',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Send your quote and a short message to the requester.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application submitted successfully!'),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
