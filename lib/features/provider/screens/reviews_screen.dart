// features/provider/screens/reviews_screen.dart
// Feature: Provider Browsing & Details
//
// Full reviews list for a provider with rating breakdown and filters.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

class ReviewsScreen extends StatelessWidget {
  final ServiceProvider provider;

  const ReviewsScreen({super.key, required this.provider});

  double get _averageRating {
    if (provider.reviews.isEmpty) return provider.rating;
    final sum = provider.reviews.fold<double>(0, (s, r) => s + r.rating);
    return sum / provider.reviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in provider.reviews) {
      final key = r.rating.round().clamp(1, 5);
      dist[key] = dist[key]! + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final avg = _averageRating;
    final dist = _ratingDistribution;
    final total = provider.reviews.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Reviews (${provider.reviewCount})'),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.all(pad),
          children: [
            // Average rating card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        avg.toStringAsFixed(1),
                        style: tt.displayLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < avg.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppTheme.accentGold,
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text('$total reviews', style: tt.labelSmall),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final count = dist[star] ?? 0;
                        final pct = total > 0 ? count / total : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$star',
                                style: tt.labelSmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: AppTheme.surfaceElevated,
                                    color: AppTheme.accentGold,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '$count',
                                  style: tt.labelSmall,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),

            // Write review button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.rate_review_rounded,
                  color: AppTheme.accentGold,
                ),
                label: const Text(
                  'Write a Review',
                  style: TextStyle(color: AppTheme.accentGold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentGold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Reviews list
            ...provider.reviews.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.surfaceElevated,
                              child: Text(
                                r.reviewerInitials,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.reviewerName,
                                    style: tt.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(r.createdAt),
                                    style: tt.labelSmall,
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
                                const SizedBox(width: 4),
                                Text(
                                  r.rating.toStringAsFixed(1),
                                  style: tt.titleMedium?.copyWith(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(r.comment, style: tt.bodyMedium),
                      ],
                    ),
                  )
                  .animate(delay: Duration(milliseconds: 80 * i))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05);
            }),
          ],
        ),
      ),
    );
  }
}
