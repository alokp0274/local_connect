// features/provider_mode/widgets/provider_mode_content.dart
// Feature: Provider Mode (Business Dashboard)
//
// Provider mode content widget for the profile screen's provider tab.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/account_mode.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/provider_mode/screens/provider_dashboard_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_lead_inbox_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_availability_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_service_areas_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_business_profile_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_reviews_received_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_earnings_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_insights_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_notifications_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_achievements_screen.dart';
import 'package:local_connect/features/jobs/screens/open_jobs_screen.dart';

// ─────────────────────────────────────────────────────────
//  PROVIDER MODE PROFILE CONTENT
//  Shown inside ProfileScreen when AccountMode.provider
// ─────────────────────────────────────────────────────────

class ProviderModeContent extends StatefulWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;

  const ProviderModeContent({
    super.key,
    required this.onEditProfile,
    required this.onSettings,
  });

  @override
  State<ProviderModeContent> createState() => _ProviderModeContentState();
}

class _ProviderModeContentState extends State<ProviderModeContent> {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Provider Hero ──
        _buildProviderHero(tt, pad, isCompact),
        const SizedBox(height: 16),

        // ── Stats Cards ──
        _buildStatsGrid(tt, pad, isCompact),
        const SizedBox(height: 20),

        // ── Quick Actions ──
        _buildQuickActions(tt, pad, isCompact),
        const SizedBox(height: 20),

        // ── Lead Requests ──
        _buildLeadRequests(tt, pad, isCompact),
        const SizedBox(height: 20),

        // ── Provider Menu ──
        _buildProviderMenu(tt, pad),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProviderHero(TextTheme tt, double pad, bool isCompact) {
    final am = accountMode;
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
        child: Row(
          children: [
            // Avatar
            Container(
              width: isCompact ? 56 : 64,
              height: isCompact ? 56 : 64,
              decoration: BoxDecoration(
                gradient: AppTheme.tealGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                boxShadow: AppTheme.tealGlow,
              ),
              child: Center(
                child: Text(
                  am.providerName.isNotEmpty
                      ? am.providerName[0].toUpperCase()
                      : 'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: isCompact ? 22 : 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          am.providerName.isEmpty
                              ? 'Your Business'
                              : am.providerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withAlpha(25),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          border: Border.all(
                            color: AppTheme.accentTeal.withAlpha(80),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: AppTheme.accentTeal,
                              size: 11,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: AppTheme.accentTeal,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    am.providerService.isEmpty
                        ? 'Service Provider'
                        : am.providerService,
                    style: tt.bodySmall?.copyWith(
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Availability toggle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => accountMode.toggleAvailability());
                    },
                    child: AnimatedContainer(
                      duration: AppTheme.durationFast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: am.providerAvailable
                            ? AppTheme.accentTeal.withAlpha(20)
                            : AppTheme.glassDark,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        border: Border.all(
                          color: am.providerAvailable
                              ? AppTheme.accentTeal.withAlpha(80)
                              : AppTheme.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: AppTheme.durationFast,
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: am.providerAvailable
                                  ? AppTheme.accentTeal
                                  : AppTheme.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            am.providerAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: am.providerAvailable
                                  ? AppTheme.accentTeal
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),
    );
  }

  Widget _buildStatsGrid(TextTheme tt, double pad, bool isCompact) {
    final am = accountMode;
    final stats = [
      _StatItem(
        'Leads',
        '${am.leadsReceived}',
        Icons.trending_up_rounded,
        AppTheme.accentTeal,
      ),
      _StatItem(
        'Chats',
        '${am.activeChats}',
        Icons.chat_rounded,
        AppTheme.accentBlue,
      ),
      _StatItem(
        'Rating',
        '${am.providerRating}',
        Icons.star_rounded,
        AppTheme.accentGold,
      ),
      _StatItem(
        'Earnings',
        am.earnings,
        Icons.account_balance_wallet_rounded,
        AppTheme.accentPurple,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: isCompact ? 1.6 : 1.8,
        children: List.generate(stats.length, (i) {
          final s = stats[i];
          return GlassContainer(
                padding: EdgeInsets.all(isCompact ? 12 : 14),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: s.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: Icon(s.icon, color: s.color, size: 16),
                        ),
                        const Spacer(),
                        Text(
                          s.label,
                          style: tt.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.value,
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: isCompact ? 18 : 20,
                        color: s.color,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: (200 + i * 60).ms)
              .fadeIn(duration: 300.ms)
              .scale(
                begin: const Offset(0.93, 0.93),
                curve: Curves.easeOutBack,
              );
        }),
      ),
    );
  }

  Widget _buildQuickActions(TextTheme tt, double pad, bool isCompact) {
    final actions = [
      _ProviderAction(
        'Dashboard',
        Icons.dashboard_rounded,
        AppTheme.accentTeal,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProviderDashboardScreen()),
        ),
      ),
      _ProviderAction(
        'View Leads',
        Icons.people_alt_rounded,
        AppTheme.accentCoral,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProviderLeadInboxScreen()),
        ),
      ),
      _ProviderAction(
        'Availability',
        Icons.schedule_rounded,
        AppTheme.accentGold,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProviderAvailabilityScreen()),
        ),
      ),
      _ProviderAction(
        'Earnings',
        Icons.account_balance_wallet_rounded,
        AppTheme.accentPurple,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProviderEarningsScreen()),
        ),
      ),
      _ProviderAction(
        'Notifications',
        Icons.notifications_outlined,
        AppTheme.accentBlue,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderNotificationsScreen(),
          ),
        ),
      ),
      _ProviderAction(
        'Reviews',
        Icons.star_outline_rounded,
        AppTheme.accentGold,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderReviewsReceivedScreen(),
          ),
        ),
      ),
      _ProviderAction(
        'Browse Jobs',
        Icons.work_outline_rounded,
        AppTheme.accentCoral,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OpenJobsScreen()),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
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
            childAspectRatio: isCompact ? 0.95 : 1.05,
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: a.color.withAlpha(20),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                            child: Icon(a.icon, color: a.color, size: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelLarge?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (350 + i * 50).ms)
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

  Widget _buildLeadRequests(TextTheme tt, double pad, bool isCompact) {
    final leads = [
      _LeadRequest(
        'Need ${accountMode.providerService.isEmpty ? "plumber" : accountMode.providerService.toLowerCase()} in 110001',
        'Ankit M.',
        '2 min ago',
        AppTheme.accentCoral,
      ),
      _LeadRequest(
        'Urgent ${accountMode.providerService.isEmpty ? "repair" : accountMode.providerService.toLowerCase()} near Rajiv Chowk',
        'Priya S.',
        '15 min ago',
        AppTheme.accentGold,
      ),
      _LeadRequest(
        'Looking for professional service in 110003',
        'Rahul K.',
        '1 hour ago',
        AppTheme.accentBlue,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Lead Requests',
                style: tt.headlineMedium?.copyWith(fontSize: 17),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentCoral.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${leads.length} new',
                  style: const TextStyle(
                    color: AppTheme.accentCoral,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
                  padding: EdgeInsets.all(isCompact ? 12 : 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: i == 0
                          ? AppTheme.accentCoral.withAlpha(60)
                          : AppTheme.border,
                      width: i == 0 ? 0.8 : 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: lead.color.withAlpha(18),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                lead.customerName[0],
                                style: TextStyle(
                                  color: lead.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lead.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${lead.customerName} \u2022 ${lead.time}',
                                  style: tt.labelSmall?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _leadActionChip('Accept', AppTheme.accentTeal, true),
                          const SizedBox(width: 8),
                          _leadActionChip('Chat', AppTheme.accentBlue, false),
                          const SizedBox(width: 8),
                          _leadActionChip('Call', AppTheme.accentGold, false),
                        ],
                      ),
                    ],
                  ),
                )
                .animate(delay: (500 + i * 80).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.04);
          }),
        ],
      ),
    );
  }

  Widget _leadActionChip(String label, Color color, bool primary) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: primary
              ? LinearGradient(colors: [color, color.withAlpha(180)])
              : null,
          color: primary ? null : color.withAlpha(15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: primary ? null : Border.all(color: color.withAlpha(60)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: primary ? Colors.white : color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderMenu(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business',
            style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          _ProviderMenuItem(
            icon: Icons.business_rounded,
            title: 'Edit Business Profile',
            color: AppTheme.accentTeal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProviderBusinessProfileScreen(),
              ),
            ),
          ),
          _ProviderMenuItem(
            icon: Icons.map_rounded,
            title: 'Service Areas',
            subtitle: '${accountMode.providerPincodes.length} areas',
            color: AppTheme.accentBlue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProviderServiceAreasScreen(),
              ),
            ),
          ),
          _ProviderMenuItem(
            icon: Icons.schedule_rounded,
            title: 'Working Hours',
            color: AppTheme.accentGold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProviderAvailabilityScreen(),
              ),
            ),
          ),
          _ProviderMenuItem(
            icon: Icons.analytics_rounded,
            title: 'Performance',
            subtitle: 'View insights',
            color: AppTheme.accentPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProviderInsightsScreen()),
            ),
          ),
          _ProviderMenuItem(
            icon: Icons.military_tech_rounded,
            title: 'Achievements',
            subtitle: '3 of 8 earned',
            color: AppTheme.accentCoral,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProviderAchievementsScreen(),
              ),
            ),
          ),
          _ProviderMenuItem(
            icon: Icons.work_outline_rounded,
            title: 'Browse Open Jobs',
            subtitle: 'Apply to nearby requests',
            color: AppTheme.accentGold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OpenJobsScreen()),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Support',
            style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          _ProviderMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            color: AppTheme.accentTeal,
            onTap: widget.onSettings,
          ),
          _ProviderMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Provider Help',
            color: AppTheme.accentBlue,
            onTap: () => HapticFeedback.selectionClick(),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _ProviderAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ProviderAction(this.label, this.icon, this.color, this.onTap);
}

class _LeadRequest {
  final String description;
  final String customerName;
  final String time;
  final Color color;
  const _LeadRequest(
    this.description,
    this.customerName,
    this.time,
    this.color,
  );
}

class _ProviderMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProviderMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ProviderMenuItem> createState() => _ProviderMenuItemState();
}

class _ProviderMenuItemState extends State<_ProviderMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.surfaceElevated : AppTheme.glassDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: _hovered ? AppTheme.glassBorder : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: widget.color, size: 22),
          title: Text(widget.title, style: tt.titleMedium),
          subtitle: widget.subtitle != null
              ? Text(
                  widget.subtitle!,
                  style: tt.labelSmall?.copyWith(
                    color: widget.color,
                    fontSize: 11,
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMuted,
          ),
          onTap: widget.onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
        ),
      ),
    );
  }
}
