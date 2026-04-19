// features/jobs/screens/request_detail_screen.dart
// Feature: Job Posts & Service Requests
//
// Detailed view of a single posted request with timeline and actions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/jobs/data/job_post_data.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/jobs/screens/applications_screen.dart';
import 'package:local_connect/features/jobs/screens/post_request_screen.dart';

class RequestDetailScreen extends StatefulWidget {
  final JobPost jobPost;
  const RequestDetailScreen({super.key, required this.jobPost});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late JobPost _job;

  @override
  void initState() {
    super.initState();
    _job = widget.jobPost;
  }

  List<JobApplication> get _applications => getApplicationsForJob(_job.id);

  void _closeRequest() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        title: const Text(
          'Close Request?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will close the request and stop accepting new applications.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _job = _job.copyWith(status: JobStatus.closed);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.surfaceCard,
                  content: Text(
                    'Request closed',
                    style: TextStyle(color: AppTheme.accentTeal),
                  ),
                ),
              );
            },
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.accentCoral),
            ),
          ),
        ],
      ),
    );
  }

  void _repostRequest() {
    HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PostRequestScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final apps = _applications;

    return Scaffold(
      backgroundColor: AppTheme.primaryDeep,
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
                      child: Text('Request Details', style: tt.headlineMedium),
                    ),
                    if (_job.status == JobStatus.active ||
                        _job.status == JobStatus.inProgress)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        color: AppTheme.surfaceCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                        ),
                        onSelected: (v) {
                          if (v == 'close') _closeRequest();
                          if (v == 'repost') _repostRequest();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'close',
                            child: Text(
                              'Close Request',
                              style: TextStyle(color: AppTheme.accentCoral),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'repost',
                            child: Text(
                              'Repost',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // ── Content ──
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.accentGold,
                  backgroundColor: AppTheme.surfaceCard,
                  onRefresh: () async =>
                      await Future<void>.delayed(const Duration(seconds: 1)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(tt),
                        const SizedBox(height: 16),
                        _buildDescription(tt),
                        const SizedBox(height: 16),
                        _buildDetailsGrid(tt),
                        const SizedBox(height: 16),
                        _buildStatusTimeline(tt),
                        const SizedBox(height: 20),
                        _buildApplicationsSection(tt, apps),
                        const SizedBox(height: 20),
                        if (_job.status != JobStatus.closed) _buildActions(tt),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme tt) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      border: Border.all(color: _job.urgency.color.withAlpha(40), width: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _job.urgency.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(
                  _job.urgency.icon,
                  color: _job.urgency.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _job.title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _metaChip(
                      Icons.category_rounded,
                      _job.category,
                      AppTheme.accentGold,
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
                  color: _job.status.color.withAlpha(18),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: _job.status.color.withAlpha(50)),
                ),
                child: Text(
                  _job.status.label,
                  style: TextStyle(
                    color: _job.status.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _metaChip(
                Icons.location_on_rounded,
                '${_job.area}, ${_job.pincode}',
                AppTheme.accentTeal,
              ),
              _metaChip(
                Icons.schedule_rounded,
                _job.timePosted,
                AppTheme.textMuted,
              ),
              _metaChip(
                _job.urgency.icon,
                _job.urgency.label,
                _job.urgency.color,
              ),
              if (_job.budget != null)
                _metaChip(
                  Icons.currency_rupee_rounded,
                  _job.budget!,
                  AppTheme.accentGoldLight,
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04);
  }

  Widget _buildDescription(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(color: AppTheme.glassBorderLight, width: 0.5),
          ),
          child: Text(
            _job.description,
            style: tt.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildDetailsGrid(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _infoTile(
              Icons.calendar_today_rounded,
              'Preferred Date',
              _job.preferredDate,
              AppTheme.accentBlue,
            ),
            const SizedBox(width: 10),
            _infoTile(
              Icons.access_time_rounded,
              'Preferred Time',
              _job.preferredTime,
              AppTheme.accentPurple,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _infoTile(
              Icons.contact_phone_rounded,
              'Contact',
              _job.contactPreference,
              AppTheme.accentTeal,
            ),
            const SizedBox(width: 10),
            _infoTile(
              Icons.people_rounded,
              'Applications',
              '${_job.applicationCount}',
              AppTheme.accentBlue,
            ),
          ],
        ),
      ],
    ).animate(delay: 150.ms).fadeIn(duration: 300.ms);
  }

  Widget _infoTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: AppTheme.glassBorderLight, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(TextTheme tt) {
    final steps = <_TimelineStep>[
      _TimelineStep(
        'Request Posted',
        _job.timePosted,
        true,
        AppTheme.accentTeal,
      ),
      if (_job.applicationCount > 0)
        _TimelineStep(
          'Applications Received',
          '${_job.applicationCount} providers applied',
          true,
          AppTheme.accentBlue,
        ),
      if (_job.status == JobStatus.inProgress ||
          _job.status == JobStatus.completed)
        _TimelineStep(
          'Work In Progress',
          'Provider started work',
          true,
          AppTheme.accentGold,
        ),
      if (_job.status == JobStatus.completed)
        _TimelineStep('Completed', 'Job finished', true, AppTheme.accentTeal),
      if (_job.status == JobStatus.closed)
        _TimelineStep('Closed', 'Request closed', true, AppTheme.textMuted),
      if (_job.status == JobStatus.active)
        _TimelineStep(
          'Awaiting Selection',
          'Review applications & select provider',
          false,
          AppTheme.accentGold,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Timeline',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: step.done
                          ? step.color.withAlpha(30)
                          : AppTheme.surfaceInput,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.done ? step.color : AppTheme.glassBorder,
                        width: 1.5,
                      ),
                    ),
                    child: step.done
                        ? Icon(Icons.check_rounded, size: 14, color: step.color)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: step.done
                          ? step.color.withAlpha(40)
                          : AppTheme.glassBorderLight,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          color: step.done
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    ).animate(delay: 200.ms).fadeIn(duration: 350.ms);
  }

  Widget _buildApplicationsSection(TextTheme tt, List<JobApplication> apps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Applications',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            if (apps.isNotEmpty)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicationsScreen(jobPost: _job),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (apps.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: AppTheme.glassBorderLight, width: 0.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_search_rounded,
                  color: AppTheme.textMuted.withAlpha(80),
                  size: 36,
                ),
                const SizedBox(height: 10),
                const Text(
                  'No applications yet',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Providers will see your request and apply shortly',
                  style: TextStyle(
                    color: AppTheme.textMuted.withAlpha(120),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...apps.take(3).map((a) => _miniAppCard(a)),
      ],
    ).animate(delay: 250.ms).fadeIn(duration: 300.ms);
  }

  Widget _miniAppCard(JobApplication a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: a.status == ApplicationStatus.accepted
              ? AppTheme.accentTeal.withAlpha(40)
              : AppTheme.glassBorderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.goldSubtleGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Center(
              child: Text(
                a.providerInitial,
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 14,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (a.providerVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppTheme.accentTeal,
                        size: 13,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 11,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${a.providerRating}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      a.providerDistance,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            a.priceOffer,
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: a.status.color.withAlpha(15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              a.status.label,
              style: TextStyle(
                color: a.status.color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(TextTheme tt) {
    return Column(
      children: [
        if (_job.applicationCount > 0)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ApplicationsScreen(jobPost: _job),
                  ),
                );
              },
              icon: const Icon(Icons.people_rounded, size: 18),
              label: Text('View All Applications (${_job.applicationCount})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.textOnAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (_job.status == JobStatus.active) ...[
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _closeRequest,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentCoral,
                      side: const BorderSide(color: AppTheme.accentCoral),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _repostRequest,
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('Repost'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentTeal,
                    side: const BorderSide(color: AppTheme.accentTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate(delay: 300.ms).fadeIn(duration: 300.ms);
  }

  Widget _metaChip(IconData icon, String text, Color color) {
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

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool done;
  final Color color;
  const _TimelineStep(this.title, this.subtitle, this.done, this.color);
}
