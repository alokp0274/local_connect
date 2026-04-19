// features/provider_mode/screens/provider_lead_detail_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Detailed view of a single lead with customer info and response actions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/provider_mode/models/lead_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderLeadDetailScreen extends StatelessWidget {
  final ServiceLead lead;
  const ProviderLeadDetailScreen({super.key, required this.lead});

  Color get _urgencyColor {
    switch (lead.urgency) {
      case LeadUrgency.urgent: return AppTheme.accentCoral;
      case LeadUrgency.normal: return AppTheme.accentBlue;
      case LeadUrgency.flexible: return AppTheme.accentTeal;
    }
  }

  String get _urgencyLabel {
    switch (lead.urgency) {
      case LeadUrgency.urgent: return 'URGENT';
      case LeadUrgency.normal: return 'NORMAL';
      case LeadUrgency.flexible: return 'FLEXIBLE';
    }
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
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(10),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Lead Details', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _urgencyColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(color: _urgencyColor.withAlpha(60)),
                      ),
                      child: Text(_urgencyLabel, style: TextStyle(
                        color: _urgencyColor, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service requested
                      GlassContainer(
                        padding: EdgeInsets.all(isCompact ? 14 : 18),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Service Requested', style: tt.labelLarge?.copyWith(color: AppTheme.textMuted)),
                            const SizedBox(height: 8),
                            Text(lead.serviceNeeded, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                            if (lead.notes != null) ...[
                              const SizedBox(height: 10),
                              Text(lead.notes!, style: tt.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                            ],
                          ],
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04),
                      const SizedBox(height: 14),

                      // Customer info
                      GlassContainer(
                        padding: EdgeInsets.all(isCompact ? 14 : 18),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer', style: tt.labelLarge?.copyWith(color: AppTheme.textMuted)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primarySubtleGradient,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                                  ),
                                  child: Center(
                                    child: Text(lead.customerName.isNotEmpty ? lead.customerName[0] : '?',
                                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(lead.customerName, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 14),
                                          const SizedBox(width: 3),
                                          Text('${lead.customerRating}', style: const TextStyle(
                                            color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 10),
                                          Text('${lead.customerJobs} past jobs', style: const TextStyle(
                                            color: AppTheme.textMuted, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04),
                      const SizedBox(height: 14),

                      // Details grid
                      GlassContainer(
                        padding: EdgeInsets.all(isCompact ? 14 : 18),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Details', style: tt.labelLarge?.copyWith(color: AppTheme.textMuted)),
                            const SizedBox(height: 12),
                            _DetailRow(icon: Icons.location_on_rounded, label: 'Location',
                              value: '${lead.area}, PIN ${lead.pincode}', color: AppTheme.accentTeal),
                            _DetailRow(icon: Icons.route_rounded, label: 'Distance',
                              value: '${lead.distance} away', color: AppTheme.accentBlue),
                            _DetailRow(icon: Icons.access_time_rounded, label: 'Posted',
                              value: lead.timePosted, color: AppTheme.accentPurple),
                            if (lead.preferredTime != null)
                              _DetailRow(icon: Icons.schedule_rounded, label: 'Preferred Time',
                                value: lead.preferredTime!, color: AppTheme.accentGold),
                            if (lead.budget != null)
                              _DetailRow(icon: Icons.currency_rupee_rounded, label: 'Budget',
                                value: lead.budget!, color: AppTheme.accentGold),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04),
                    ],
                  ),
                ),
              ),

              // Bottom CTA
              Container(
                padding: EdgeInsets.fromLTRB(pad, 12, pad, 12),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceCard,
                  border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('Lead accepted!', style: TextStyle(color: Colors.white)),
                              backgroundColor: AppTheme.accentTeal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
                            ));
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppTheme.tealGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                              boxShadow: AppTheme.tealGlow,
                            ),
                            child: const Center(
                              child: Text('Accept Lead', style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () { HapticFeedback.lightImpact(); },
                        child: Container(
                          height: 48, width: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withAlpha(18),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            border: Border.all(color: AppTheme.accentBlue.withAlpha(60)),
                          ),
                          child: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.accentBlue, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () { HapticFeedback.lightImpact(); },
                        child: Container(
                          height: 48, width: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withAlpha(18),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            border: Border.all(color: AppTheme.accentGold.withAlpha(60)),
                          ),
                          child: const Icon(Icons.phone_rounded, color: AppTheme.accentGold, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _DetailRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(AppTheme.radiusXS),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                const SizedBox(height: 1),
                Text(value, style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
