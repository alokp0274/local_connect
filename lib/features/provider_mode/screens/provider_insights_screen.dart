// features/provider_mode/screens/provider_insights_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Business analytics dashboard with performance metrics and trends.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/provider_mode/data/provider_dummy_data.dart';
import 'package:local_connect/features/provider_mode/models/lead_model.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderInsightsScreen extends StatelessWidget {
  const ProviderInsightsScreen({super.key});

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
              _buildHeader(tt, pad, context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(tt),
                      const SizedBox(height: 20),
                      _buildInsightsList(tt),
                      const SizedBox(height: 20),
                      _buildTips(tt),
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

  Widget _buildHeader(TextTheme tt, double pad, BuildContext context) {
    return Padding(
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
            child: Text(
              'Growth Insights',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildSummaryCards(TextTheme tt) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Profile Views',
            value: '142',
            change: '+12%',
            color: AppTheme.accentTeal,
            icon: Icons.visibility_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Search Rank',
            value: '#3',
            change: '\u2191 2 spots',
            color: AppTheme.accentGold,
            icon: Icons.leaderboard_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Response Rate',
            value: '94%',
            change: 'Excellent',
            color: AppTheme.accentBlue,
            icon: Icons.speed_outlined,
          ),
        ),
      ],
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildInsightsList(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Insights',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        ...List.generate(dummyInsights.length, (i) {
          final insight = dummyInsights[i];
          final color = _insightColor(insight.type);
          final iconData = _insightIcon(insight.icon);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withAlpha(8),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: color.withAlpha(30)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Icon(iconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              insight.title,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Text(
                              _insightTypeLabel(insight.type),
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.subtitle,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: (150 + i * 60).ms).fadeIn(duration: 280.ms);
        }),
      ],
    );
  }

  Widget _buildTips(TextTheme tt) {
    final tips = [
      {
        'title': 'Respond faster to leads',
        'desc': 'Providers who respond within 5 min get 3x more jobs',
        'icon': Icons.flash_on_rounded,
      },
      {
        'title': 'Add more work photos',
        'desc': 'Profiles with 5+ photos get 40% more views',
        'icon': Icons.photo_library_outlined,
      },
      {
        'title': 'Expand your service area',
        'desc': 'Adding 2 more pincodes could increase leads by 25%',
        'icon': Icons.map_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Growth Tips',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        ...List.generate(tips.length, (i) {
          final tip = tips[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Icon(
                    tip['icon'] as IconData,
                    color: AppTheme.accentPurple,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tip['title']}',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${tip['desc']}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
              ],
            ),
          ).animate(delay: (350 + i * 60).ms).fadeIn(duration: 280.ms);
        }),
      ],
    );
  }

  Color _insightColor(InsightType type) {
    switch (type) {
      case InsightType.growth:
        return AppTheme.accentTeal;
      case InsightType.tip:
        return AppTheme.accentPurple;
      case InsightType.achievement:
        return AppTheme.accentGold;
      case InsightType.demand:
        return AppTheme.accentCoral;
    }
  }

  IconData _insightIcon(String icon) {
    switch (icon) {
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'lightbulb':
        return Icons.lightbulb_outline_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'chart':
        return Icons.bar_chart_rounded;
      default:
        return Icons.insights_rounded;
    }
  }

  String _insightTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.growth:
        return 'GROWTH';
      case InsightType.tip:
        return 'TIP';
      case InsightType.achievement:
        return 'ACHIEVEMENT';
      case InsightType.demand:
        return 'DEMAND';
    }
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.change,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: color.withAlpha(180),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
