// features/provider_mode/screens/provider_lead_inbox_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Incoming leads/requests inbox for the provider to accept or decline.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import 'package:local_connect/features/provider_mode/models/lead_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/provider_mode/data/provider_dummy_data.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/provider_mode/screens/provider_lead_detail_screen.dart';

class ProviderLeadInboxScreen extends StatefulWidget {
  const ProviderLeadInboxScreen({super.key});
  @override
  State<ProviderLeadInboxScreen> createState() =>
      _ProviderLeadInboxScreenState();
}

class _ProviderLeadInboxScreenState extends State<ProviderLeadInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ServiceLead> get _pendingLeads =>
      dummyLeads.where((l) => l.status == LeadStatus.pending).toList();
  List<ServiceLead> get _acceptedLeads =>
      dummyLeads.where((l) => l.status == LeadStatus.accepted).toList();
  List<ServiceLead> get _allLeads => dummyLeads;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                            'Lead Inbox',
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${_pendingLeads.length} new requests',
                            style: tt.bodySmall?.copyWith(
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms),
              const SizedBox(height: 12),

              // Tabs
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: GlassContainer(
                  padding: const EdgeInsets.all(4),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppTheme.tealGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textMuted,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    dividerHeight: 0,
                    tabs: [
                      Tab(text: 'New (${_pendingLeads.length})'),
                      Tab(text: 'Accepted (${_acceptedLeads.length})'),
                      Tab(text: 'All (${_allLeads.length})'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Filter chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  children: ['All', 'Urgent', 'Nearby', 'High Budget'].map((f) {
                    final selected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _filter = f);
                        },
                        child: AnimatedContainer(
                          duration: AppTheme.durationFast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.accentTeal.withAlpha(25)
                                : AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.accentTeal
                                  : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.accentTeal
                                  : AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: _isLoading
                    ? _buildSkeleton(pad)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLeadList(_pendingLeads, pad),
                          _buildLeadList(_acceptedLeads, pad),
                          _buildLeadList(_allLeads, pad),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadList(List<ServiceLead> leads, double pad) {
    if (leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppTheme.textMuted.withAlpha(80),
            ),
            const SizedBox(height: 12),
            const Text(
              'No leads yet',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay online to receive new requests',
              style: TextStyle(
                color: AppTheme.textMuted.withAlpha(150),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: leads.length,
      itemBuilder: (context, i) => _LeadCard(
        lead: leads[i],
        index: i,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProviderLeadDetailScreen(lead: leads[i]),
          ),
        ),
        onAccept: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Lead accepted!'),
              backgroundColor: AppTheme.accentTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(double pad) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, 20),
      itemCount: 4,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: AppTheme.surfaceCard,
          highlightColor: AppTheme.surfaceElevated,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadCard extends StatefulWidget {
  final ServiceLead lead;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onAccept;

  const _LeadCard({
    required this.lead,
    required this.index,
    required this.onTap,
    required this.onAccept,
  });

  @override
  State<_LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<_LeadCard> {
  bool _pressed = false;

  Color get _urgencyColor {
    switch (widget.lead.urgency) {
      case LeadUrgency.urgent:
        return AppTheme.accentCoral;
      case LeadUrgency.normal:
        return AppTheme.accentBlue;
      case LeadUrgency.flexible:
        return AppTheme.accentTeal;
    }
  }

  String get _urgencyLabel {
    switch (widget.lead.urgency) {
      case LeadUrgency.urgent:
        return 'URGENT';
      case LeadUrgency.normal:
        return 'NORMAL';
      case LeadUrgency.flexible:
        return 'FLEXIBLE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final lead = widget.lead;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.985 : 1,
            duration: const Duration(milliseconds: 100),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(isCompact ? 12 : 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: lead.urgency == LeadUrgency.urgent
                      ? AppTheme.accentCoral.withAlpha(60)
                      : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top: Service + Urgency
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _urgencyColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                        ),
                        child: Icon(
                          Icons.work_outline_rounded,
                          color: _urgencyColor,
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${lead.customerName} \u2022 ${lead.timePosted}',
                              style: tt.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _urgencyColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          _urgencyLabel,
                          style: TextStyle(
                            color: _urgencyColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Meta row
                  Wrap(
                    spacing: isCompact ? 8 : 12,
                    runSpacing: 6,
                    children: [
                      _MetaChip(
                        Icons.location_on_rounded,
                        '${lead.area}, ${lead.pincode}',
                        AppTheme.accentTeal,
                      ),
                      _MetaChip(
                        Icons.route_rounded,
                        lead.distance,
                        AppTheme.accentBlue,
                      ),
                      if (lead.budget != null)
                        _MetaChip(
                          Icons.currency_rupee_rounded,
                          lead.budget!,
                          AppTheme.accentGold,
                        ),
                      _MetaChip(
                        Icons.star_rounded,
                        '${lead.customerRating}',
                        AppTheme.accentGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (lead.notes != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        lead.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Action Row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onAccept,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.tealGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Accept',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withAlpha(18),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                              border: Border.all(
                                color: AppTheme.accentBlue.withAlpha(60),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.visibility_rounded,
                                  color: AppTheme.accentBlue,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'View',
                                  style: TextStyle(
                                    color: AppTheme.accentBlue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
        .animate(delay: (widget.index * 60).ms)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.05);
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _MetaChip(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) {
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
