// features/jobs/screens/requests_screen.dart
// Feature: Jobs & Requests
//
// Dual-tab Requests screen:
//   Tab 1 — "Request Work"  : requests posted by the current user
//   Tab 2 — "Accept Work"   : open requests from others that the user can apply to

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/request_model.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/jobs/screens/post_request_screen.dart';
import 'package:local_connect/features/jobs/screens/request_work_detail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final myCount = myPostedRequests.length;
    final openCount =
        availableRequests.where((r) => r.status == RequestStatus.open).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 4),
              child: Row(
                children: [
                  Expanded(child: Text('Requests', style: tt.headlineLarge)),
                  _HeaderActionButton(
                    icon: Icons.add_rounded,
                    label: 'Post',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PostRequestScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 280.ms),

            // ── Quick Stats ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 6),
              child: Row(
                children: [
                  _StatChip(
                    label: '$myCount posted',
                    icon: Icons.post_add_rounded,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: '$openCount open',
                    icon: Icons.work_outline_rounded,
                    color: AppTheme.accentTeal,
                  ),
                ],
              ),
            ).animate(delay: 40.ms).fadeIn(duration: 280.ms),

            // ── Tab Bar ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    boxShadow: AppTheme.softGlow,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.textOnAccent,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Request Work'),
                    Tab(text: 'Accept Work'),
                  ],
                ),
              ),
            ).animate(delay: 60.ms).fadeIn(duration: 280.ms),

            // ── Tab Views ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [_RequestWorkTab(), _AcceptWorkTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  TAB 1 — Request Work (my posted requests)
// ─────────────────────────────────────────────────────────

class _RequestWorkTab extends StatelessWidget {
  const _RequestWorkTab();

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final requests = myPostedRequests;

    if (requests.isEmpty) {
      return _EmptyState(
        icon: Icons.post_add_rounded,
        title: 'No requests yet',
        subtitle: 'Post a service request and get quotes from nearby pros.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, 100),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final req = requests[index];
        return _RequestCard(
              request: req,
              showApplicantCount: true,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RequestWorkDetailScreen(request: req),
                  ),
                );
              },
            )
            .animate(delay: (index * 40).ms)
            .fadeIn(duration: 260.ms)
            .slideY(begin: 0.04, curve: Curves.easeOut);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
//  TAB 2 — Accept Work (open requests from others)
// ─────────────────────────────────────────────────────────

class _AcceptWorkTab extends StatelessWidget {
  const _AcceptWorkTab();

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final requests = availableRequests;

    if (requests.isEmpty) {
      return _EmptyState(
        icon: Icons.work_outline_rounded,
        title: 'No open requests',
        subtitle: 'Check back later for service requests in your area.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, 100),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final req = requests[index];
        return _RequestCard(
              request: req,
              showApplicantCount: false,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RequestWorkDetailScreen(request: req),
                  ),
                );
              },
            )
            .animate(delay: (index * 40).ms)
            .fadeIn(duration: 260.ms)
            .slideY(begin: 0.04, curve: Curves.easeOut);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
//  REQUEST CARD — Shared card used in both tabs
// ─────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final bool showApplicantCount;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.showApplicantCount,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.border.withAlpha(80)),
        boxShadow: AppTheme.cardShadow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: category + status + urgency ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                  ),
                  child: Text(
                    request.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
                if (request.urgency != RequestUrgency.normal) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _urgencyColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          request.urgency == RequestUrgency.emergency
                              ? Icons.warning_rounded
                              : Icons.schedule_rounded,
                          size: 11,
                          color: _urgencyColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          request.urgencyLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _urgencyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    request.statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Title ──
            Text(
              request.title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // ── Description preview ──
            Text(
              request.description,
              style: tt.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // ── Meta row: budget + time + applicants ──
            Row(
              children: [
                if (request.budgetRange.isNotEmpty) ...[
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.budgetRange,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  timeago.format(request.createdAt),
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                if (showApplicantCount && request.applicantCount > 0) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withAlpha(12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 13,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.applicantCount} applicant${request.applicantCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!showApplicantCount) ...[
                  const Spacer(),
                  Text(
                    'by ${request.postedByName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  HEADER ACTION BUTTON
// ─────────────────────────────────────────────────────────

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: AppTheme.softGlow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textOnAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textOnAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.accentGold, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: tt.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle, style: tt.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withAlpha(50), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
