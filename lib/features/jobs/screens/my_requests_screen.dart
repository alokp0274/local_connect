// features/jobs/screens/my_requests_screen.dart
// Feature: Job Posts & Service Requests
//
// User's posted service requests with status tracking.

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
import 'package:local_connect/features/jobs/screens/request_detail_screen.dart';

// ─────────────────────────────────────────────────────────
//  MY REQUESTS SCREEN — User's posted job requests
// ─────────────────────────────────────────────────────────

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['Active', 'In Progress', 'Completed', 'Closed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  JobStatus _statusForTab(int index) {
    switch (index) {
      case 0:
        return JobStatus.active;
      case 1:
        return JobStatus.inProgress;
      case 2:
        return JobStatus.completed;
      case 3:
        return JobStatus.closed;
      default:
        return JobStatus.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryDeep,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PostRequestScreen())),
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.textOnAccent,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Post New',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
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
                      child: Text('My Requests', style: tt.headlineMedium),
                    ),
                    // Post count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withAlpha(20),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        '${dummyJobPosts.length} total',
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // ── Tab bar ──
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceInput,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppTheme.textOnAccent,
                    unselectedLabelColor: AppTheme.textMuted,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    dividerHeight: 0,
                    splashFactory: NoSplash.splashFactory,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
              ),

              // ── Content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    _tabs.length,
                    (i) => _buildTab(i, pad),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int tabIndex, double pad) {
    final status = _statusForTab(tabIndex);
    final jobs = getJobsByStatus(status);

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              color: AppTheme.textMuted.withAlpha(80),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No ${_tabs[tabIndex].toLowerCase()} requests',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Post a new request to get started',
              style: TextStyle(
                color: AppTheme.textMuted.withAlpha(120),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return RefreshIndicator(
      color: AppTheme.accentGold,
      backgroundColor: AppTheme.surfaceCard,
      onRefresh: () async =>
          await Future<void>.delayed(const Duration(seconds: 1)),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(pad, 14, pad, 80),
        itemCount: jobs.length,
        itemBuilder: (context, i) => _JobRequestCard(job: jobs[i], index: i),
      ),
    );
  }
}

class _JobRequestCard extends StatefulWidget {
  final JobPost job;
  final int index;
  const _JobRequestCard({required this.job, required this.index});

  @override
  State<_JobRequestCard> createState() => _JobRequestCardState();
}

class _JobRequestCardState extends State<_JobRequestCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final j = widget.job;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RequestDetailScreen(jobPost: j),
              ),
            );
          },
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
                  color: j.status == JobStatus.active
                      ? j.urgency.color.withAlpha(40)
                      : AppTheme.glassBorderLight,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: title + status ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          j.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: j.status.color.withAlpha(18),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          border: Border.all(
                            color: j.status.color.withAlpha(50),
                          ),
                        ),
                        child: Text(
                          j.status.label,
                          style: TextStyle(
                            color: j.status.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Meta row ──
                  Wrap(
                    spacing: isCompact ? 8 : 12,
                    runSpacing: 4,
                    children: [
                      _chipMeta(
                        Icons.category_rounded,
                        j.category,
                        AppTheme.accentGold,
                      ),
                      _chipMeta(
                        Icons.location_on_rounded,
                        '${j.area}, ${j.pincode}',
                        AppTheme.accentTeal,
                      ),
                      _chipMeta(
                        j.urgency.icon,
                        j.urgency.label,
                        j.urgency.color,
                      ),
                      _chipMeta(
                        Icons.schedule_rounded,
                        j.timePosted,
                        AppTheme.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Bottom row: applications + budget + actions ──
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApplicationsScreen(jobPost: j),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withAlpha(15),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                            border: Border.all(
                              color: AppTheme.accentBlue.withAlpha(40),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.people_rounded,
                                color: AppTheme.accentBlue,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${j.applicationCount} applied',
                                style: const TextStyle(
                                  color: AppTheme.accentBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (j.budget != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            j.budget!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.accentGoldLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (100 + widget.index * 60).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03);
  }

  Widget _chipMeta(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
