// features/provider_mode/screens/provider_dashboard_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Provider home dashboard with stats, leads, and earnings overview.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/account_mode.dart';
import 'package:local_connect/features/provider_mode/data/provider_dummy_data.dart';
import 'package:local_connect/features/provider_mode/models/lead_model.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/provider_mode/screens/provider_lead_inbox_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_earnings_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_insights_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_notifications_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_availability_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_service_areas_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_business_profile_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_reviews_received_screen.dart';
import 'package:local_connect/features/jobs/data/job_post_data.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/features/jobs/screens/open_jobs_screen.dart';
import 'package:local_connect/features/jobs/screens/request_detail_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});
  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    accountMode.addListener(_refresh);
  }

  @override
  void dispose() {
    accountMode.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: RefreshIndicator(
          color: AppTheme.accentTeal,
          backgroundColor: AppTheme.surfaceCard,
          onRefresh: () async =>
              await Future<void>.delayed(const Duration(seconds: 1)),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
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
                                'Dashboard',
                                style: tt.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                accountMode.providerName.isNotEmpty
                                    ? accountMode.providerName
                                    : 'Provider',
                                style: tt.bodySmall?.copyWith(
                                  color: AppTheme.accentTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProviderNotificationsScreen(),
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GlassContainer(
                                padding: const EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSM,
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.textPrimary,
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentCoral,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${dummyProviderNotifications.where((n) => !n.isRead).length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                ),
              ),

              // ── Hero Summary ──
              SliverToBoxAdapter(child: _buildHeroSummary(tt, pad, isCompact)),

              // ── Stats Grid ──
              SliverToBoxAdapter(child: _buildStatsGrid(tt, pad, isCompact)),

              // ── Quick Actions ──
              SliverToBoxAdapter(child: _buildQuickActions(tt, pad, isCompact)),

              // ── Nearby Requests ──
              SliverToBoxAdapter(
                child: _buildNearbyRequests(tt, pad, isCompact),
              ),

              // ── Recent Leads Preview ──
              SliverToBoxAdapter(child: _buildLeadsPreview(tt, pad, isCompact)),

              // ── Growth Insights Preview ──
              SliverToBoxAdapter(
                child: _buildInsightsPreview(tt, pad, isCompact),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSummary(TextTheme tt, double pad, bool isCompact) {
    final am = accountMode;
    final newLeads = dummyLeads
        .where((l) => l.status == LeadStatus.pending)
        .length;
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
      child: GlassContainer(
        padding: EdgeInsets.all(isCompact ? 14 : 18),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        gradient: LinearGradient(
          colors: [
            AppTheme.accentTeal.withAlpha(18),
            AppTheme.accentBlue.withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.accentTeal.withAlpha(40)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isCompact ? 48 : 56,
                  height: isCompact ? 48 : 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.tealGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  child: Center(
                    child: Text(
                      am.providerName.isNotEmpty
                          ? am.providerName[0].toUpperCase()
                          : 'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: isCompact ? 20 : 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back${am.providerName.isNotEmpty ? ", ${am.providerName}" : ""}!',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal.withAlpha(20),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppTheme.accentTeal,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  am.providerService.isNotEmpty
                                      ? am.providerService
                                      : 'Professional',
                                  style: const TextStyle(
                                    color: AppTheme.accentTeal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              accountMode.toggleAvailability();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: am.providerAvailable
                                    ? AppTheme.accentTeal.withAlpha(20)
                                    : AppTheme.accentCoral.withAlpha(20),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: am.providerAvailable
                                          ? AppTheme.accentTeal
                                          : AppTheme.accentCoral,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    am.providerAvailable ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      color: am.providerAvailable
                                          ? AppTheme.accentTeal
                                          : AppTheme.accentCoral,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: newLeads > 0
                    ? AppTheme.accentGold.withAlpha(15)
                    : AppTheme.glassDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(
                  color: newLeads > 0
                      ? AppTheme.accentGold.withAlpha(50)
                      : AppTheme.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    newLeads > 0
                        ? Icons.local_fire_department_rounded
                        : Icons.info_outline_rounded,
                    color: newLeads > 0
                        ? AppTheme.accentGold
                        : AppTheme.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      newLeads > 0
                          ? 'You have $newLeads new leads today! High demand in your area.'
                          : 'No new leads right now. Stay online to receive requests.',
                      style: tt.bodySmall?.copyWith(
                        color: newLeads > 0
                            ? AppTheme.accentGold
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildStatsGrid(TextTheme tt, double pad, bool isCompact) {
    final am = accountMode;
    final stats = [
      _StatData(
        'Leads Today',
        '${dummyLeads.where((l) => l.status == LeadStatus.pending).length}',
        Icons.person_add_rounded,
        AppTheme.accentGold,
      ),
      _StatData(
        'Active Chats',
        '${am.activeChats}',
        Icons.chat_rounded,
        AppTheme.accentBlue,
      ),
      _StatData(
        'Jobs Done',
        '${am.jobsCompleted}',
        Icons.check_circle_rounded,
        AppTheme.accentTeal,
      ),
      _StatData(
        'Rating',
        '${am.providerRating}',
        Icons.star_rounded,
        AppTheme.accentGold,
      ),
      _StatData(
        'Profile Views',
        '48',
        Icons.visibility_rounded,
        AppTheme.accentPurple,
      ),
      _StatData(
        'Earnings',
        am.earnings,
        Icons.account_balance_wallet_rounded,
        AppTheme.accentTeal,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
      child: GridView.count(
        crossAxisCount: isCompact ? 2 : 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: isCompact ? 1.5 : 1.4,
        children: List.generate(stats.length, (i) {
          final s = stats[i];
          return GlassContainer(
                padding: EdgeInsets.all(isCompact ? 10 : 12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: s.color.withAlpha(22),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                      ),
                      child: Icon(s.icon, color: s.color, size: 18),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.value,
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: isCompact ? 18 : 20,
                          ),
                        ),
                        Text(
                          s.label,
                          style: tt.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate(delay: (200 + i * 60).ms)
              .fadeIn(duration: 300.ms)
              .scale(
                begin: const Offset(0.92, 0.92),
                curve: Curves.easeOutBack,
              );
        }),
      ),
    );
  }

  Widget _buildQuickActions(TextTheme tt, double pad, bool isCompact) {
    final actions = [
      _ActionData(
        'View Leads',
        Icons.inbox_rounded,
        AppTheme.accentGold,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProviderLeadInboxScreen()),
        ),
      ),
      _ActionData(
        'Earnings',
        Icons.account_balance_wallet_rounded,
        AppTheme.accentTeal,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProviderEarningsScreen()),
        ),
      ),
      _ActionData(
        'Availability',
        Icons.schedule_rounded,
        AppTheme.accentBlue,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProviderAvailabilityScreen()),
        ),
      ),
      _ActionData(
        'Service Areas',
        Icons.location_on_rounded,
        AppTheme.accentPurple,
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProviderServiceAreasScreen()),
        ),
      ),
      _ActionData(
        'Edit Profile',
        Icons.business_rounded,
        AppTheme.accentCoral,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProviderBusinessProfileScreen(),
          ),
        ),
      ),
      _ActionData(
        'My Reviews',
        Icons.star_rounded,
        AppTheme.accentGold,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProviderReviewsReceivedScreen(),
          ),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: isCompact ? 1.0 : 1.15,
            children: List.generate(actions.length, (i) {
              final a = actions[i];
              return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      a.onTap();
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: a.color.withAlpha(22),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                            child: Icon(a.icon, color: a.color, size: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelLarge?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (400 + i * 50).ms)
                  .fadeIn(duration: 280.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    curve: Curves.easeOutBack,
                  );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyRequests(TextTheme tt, double pad, bool isCompact) {
    final nearbyJobs = getNearbyOpenJobs('400001').take(3).toList();
    if (nearbyJobs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nearby Requests',
                  style: tt.headlineMedium?.copyWith(fontSize: 17),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OpenJobsScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Text(
                    'Browse All',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(nearbyJobs.length, (i) {
            final job = nearbyJobs[i];
            final isUrgent = job.urgency == JobUrgency.urgent;
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RequestDetailScreen(jobPost: job),
                ),
              ),
              child:
                  Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(isCompact ? 10 : 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          border: Border.all(
                            color: isUrgent
                                ? AppTheme.accentCoral.withAlpha(60)
                                : AppTheme.border,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    (isUrgent
                                            ? AppTheme.accentCoral
                                            : AppTheme.accentGold)
                                        .withAlpha(20),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSM,
                                ),
                              ),
                              child: Icon(
                                isUrgent
                                    ? Icons.local_fire_department_rounded
                                    : Icons.work_outline_rounded,
                                color: isUrgent
                                    ? AppTheme.accentCoral
                                    : AppTheme.accentGold,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${job.category} \u2022 ${job.pincode} \u2022 ${job.budget}',
                                    style: tt.labelSmall?.copyWith(
                                      color: AppTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCoral.withAlpha(20),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: AppTheme.accentCoral,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      )
                      .animate(delay: (500 + i * 60).ms)
                      .fadeIn(duration: 280.ms)
                      .slideX(begin: -0.04),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeadsPreview(TextTheme tt, double pad, bool isCompact) {
    final leads = dummyLeads
        .where((l) => l.status == LeadStatus.pending)
        .take(3)
        .toList();
    if (leads.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Leads',
                  style: tt.headlineMedium?.copyWith(fontSize: 17),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProviderLeadInboxScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.accentTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(leads.length, (i) {
            final lead = leads[i];
            return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(isCompact ? 10 : 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(
                      color: lead.urgency == LeadUrgency.urgent
                          ? AppTheme.accentCoral.withAlpha(60)
                          : AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _urgencyColor(lead.urgency).withAlpha(20),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: _urgencyColor(lead.urgency),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.serviceNeeded,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${lead.area} \u2022 ${lead.distance} \u2022 ${lead.timePosted}',
                              style: tt.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (lead.urgency == LeadUrgency.urgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCoral.withAlpha(20),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: AppTheme.accentCoral,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      if (lead.budget != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          lead.budget!,
                          style: tt.labelSmall?.copyWith(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
                .animate(delay: (600 + i * 60).ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.04);
          }),
        ],
      ),
    );
  }

  Widget _buildInsightsPreview(TextTheme tt, double pad, bool isCompact) {
    final insights = dummyInsights.take(2).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Growth Insights',
                  style: tt.headlineMedium?.copyWith(fontSize: 17),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProviderInsightsScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.accentPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(insights.length, (i) {
            final ins = insights[i];
            final color = _insightColor(ins.type);
            return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withAlpha(8),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(color: color.withAlpha(40), width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withAlpha(22),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                        ),
                        child: Icon(
                          _insightIcon(ins.icon),
                          color: color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ins.title,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              ins.subtitle,
                              style: tt.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: (700 + i * 80).ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04);
          }),
        ],
      ),
    );
  }

  Color _urgencyColor(LeadUrgency u) {
    switch (u) {
      case LeadUrgency.urgent:
        return AppTheme.accentCoral;
      case LeadUrgency.normal:
        return AppTheme.accentBlue;
      case LeadUrgency.flexible:
        return AppTheme.accentTeal;
    }
  }

  Color _insightColor(InsightType t) {
    switch (t) {
      case InsightType.growth:
        return AppTheme.accentTeal;
      case InsightType.tip:
        return AppTheme.accentBlue;
      case InsightType.achievement:
        return AppTheme.accentGold;
      case InsightType.demand:
        return AppTheme.accentCoral;
    }
  }

  IconData _insightIcon(String name) {
    switch (name) {
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'visibility':
        return Icons.visibility_rounded;
      case 'flash_on':
        return Icons.flash_on_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'verified':
        return Icons.verified_rounded;
      case 'calendar_month':
        return Icons.calendar_month_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }
}

class _StatData {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _ActionData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(this.label, this.icon, this.color, this.onTap);
}
