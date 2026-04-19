// features/provider_mode/screens/provider_reviews_received_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Reviews and ratings received from customers.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderReviewsReceivedScreen extends StatelessWidget {
  const ProviderReviewsReceivedScreen({super.key});

  static const _overallRating = 4.7;
  static const _totalReviews = 89;
  static const _starBreakdown = [
    {'stars': 5, 'count': 58, 'pct': 0.65},
    {'stars': 4, 'count': 19, 'pct': 0.21},
    {'stars': 3, 'count': 7, 'pct': 0.08},
    {'stars': 2, 'count': 3, 'pct': 0.034},
    {'stars': 1, 'count': 2, 'pct': 0.022},
  ];

  static const _topQualities = [
    {'label': 'On-time', 'icon': Icons.timer_outlined, 'votes': 72},
    {'label': 'Professional', 'icon': Icons.handshake_outlined, 'votes': 65},
    {'label': 'Fair Price', 'icon': Icons.currency_rupee_rounded, 'votes': 58},
    {
      'label': 'Clean Work',
      'icon': Icons.cleaning_services_outlined,
      'votes': 44,
    },
  ];

  static const _reviews = [
    {
      'name': 'Priya S.',
      'rating': 5.0,
      'time': '2 days ago',
      'text':
          'Excellent work! Fixed the leaking pipe within an hour. Very professional and clean work. Highly recommended.',
      'service': 'Pipe Repair',
    },
    {
      'name': 'Rahul M.',
      'rating': 5.0,
      'time': '5 days ago',
      'text':
          'Great service, came on time and finished the job quickly. Fair pricing too.',
      'service': 'Tap Installation',
    },
    {
      'name': 'Anita K.',
      'rating': 4.0,
      'time': '1 week ago',
      'text':
          'Good work overall. Took a bit longer than expected but the quality was excellent.',
      'service': 'Bathroom Plumbing',
    },
    {
      'name': 'Vikram J.',
      'rating': 5.0,
      'time': '1 week ago',
      'text':
          'Very reliable and honest. Fixed a complex issue that others couldn\'t.',
      'service': 'Water Heater',
    },
    {
      'name': 'Sunita D.',
      'rating': 4.0,
      'time': '2 weeks ago',
      'text': 'Nice person, good quality work. Would hire again.',
      'service': 'Kitchen Sink',
    },
  ];

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
                      _buildRatingSummary(tt),
                      const SizedBox(height: 20),
                      _buildStarBreakdown(tt),
                      const SizedBox(height: 20),
                      _buildTopQualities(tt),
                      const SizedBox(height: 20),
                      _buildReviewsList(tt),
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
              'Reviews Received',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildRatingSummary(TextTheme tt) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      gradient: LinearGradient(
        colors: [
          AppTheme.accentGold.withAlpha(15),
          AppTheme.accentGold.withAlpha(5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _overallRating.toStringAsFixed(1),
                style: tt.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) {
                  final full = i < _overallRating.floor();
                  final half =
                      i == _overallRating.floor() && _overallRating % 1 >= 0.5;
                  return Icon(
                    full
                        ? Icons.star_rounded
                        : half
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                    color: AppTheme.accentGold,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$_totalReviews reviews',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildMiniBar('5\u2605', 0.65, AppTheme.accentGold),
                const SizedBox(height: 4),
                _buildMiniBar('4\u2605', 0.21, AppTheme.accentGold),
                const SizedBox(height: 4),
                _buildMiniBar('3\u2605', 0.08, AppTheme.accentTeal),
                const SizedBox(height: 4),
                _buildMiniBar('2\u2605', 0.034, AppTheme.accentCoral),
                const SizedBox(height: 4),
                _buildMiniBar('1\u2605', 0.022, AppTheme.accentCoral),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildMiniBar(String label, double pct, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppTheme.surfaceCard,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarBreakdown(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Breakdown',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        ...List.generate(_starBreakdown.length, (i) {
          final b = _starBreakdown[i];
          final stars = b['stars'] as int;
          final count = b['count'] as int;
          final pct = b['pct'] as double;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Row(
                    children: [
                      Text(
                        '$stars',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.accentGold,
                        size: 14,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.surfaceCard,
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.accentGold,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$count',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate(delay: 150.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildTopQualities(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Praised Qualities',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_topQualities.length, (i) {
            final q = _topQualities[i];
            final colors = [
              AppTheme.accentTeal,
              AppTheme.accentBlue,
              AppTheme.accentGold,
              AppTheme.accentPurple,
            ];
            final c = colors[i % colors.length];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.withAlpha(15),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: c.withAlpha(40)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(q['icon'] as IconData, color: c, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${q['label']}',
                    style: TextStyle(
                      color: c,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${q['votes']})',
                    style: TextStyle(
                      color: c.withAlpha(150),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildReviewsList(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reviews',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        ...List.generate(_reviews.length, (i) {
          final r = _reviews[i];
          final rating = r['rating'] as double;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: AppTheme.border, width: 0.5),
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
                        gradient: AppTheme.tealGradient,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (r['name'] as String).substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
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
                            '${r['name']}',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${r['service']} \u2022 ${r['time']}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppTheme.accentGold,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${r['text']}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate(delay: (250 + i * 60).ms).fadeIn(duration: 280.ms);
        }),
      ],
    );
  }
}
