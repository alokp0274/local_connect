// features/profile/screens/my_reviews_screen.dart
// Feature: User Profile & Account
//
// Reviews written by the current user across all providers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});
  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final Map<int, int> _helpfulCounts = {};

  List<_UserReview> get _userReviews {
    final reviews = <_UserReview>[];
    for (final p in dummyProviders) {
      if (p.reviews.isNotEmpty) {
        final r = p.reviews.first;
        reviews.add(_UserReview(providerName: p.name, service: p.service, review: r));
      }
      if (reviews.length >= 6) break;
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final reviews = _userReviews;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0,
        title: const Text('My Reviews'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('${reviews.length} reviews', style: tt.labelSmall?.copyWith(color: AppTheme.textMuted))),
          ),
        ],
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: reviews.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: AppTheme.accentGold.withAlpha(15), shape: BoxShape.circle),
                    child: const Icon(Icons.rate_review_outlined, size: 40, color: AppTheme.accentGold),
                  ),
                  const SizedBox(height: 16),
                  Text('No reviews yet', style: tt.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Your reviews will appear here', style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted)),
                ]).animate().fadeIn(duration: 400.ms),
              )
            : ListView.builder(
                padding: EdgeInsets.all(pad),
                itemCount: reviews.length,
                itemBuilder: (context, i) {
                  final item = reviews[i];
                  final r = item.review;
                  final helpful = _helpfulCounts[i] ?? 0;
                  return GlassContainer(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withAlpha(25),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            ),
                            child: Center(child: Text(
                              item.providerName.isNotEmpty ? item.providerName[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppTheme.accentGold, fontSize: 18, fontWeight: FontWeight.w700),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item.providerName, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(item.service, style: tt.labelSmall?.copyWith(color: AppTheme.textMuted, fontSize: 11)),
                          ])),
                          Text(timeago.format(r.createdAt), style: tt.labelSmall?.copyWith(color: AppTheme.textMuted, fontSize: 10)),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: List.generate(5, (si) {
                          return Icon(
                            si < r.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: AppTheme.accentGold, size: 18,
                          );
                        })),
                        const SizedBox(height: 8),
                        Text(r.comment, style: tt.bodyMedium),
                        const SizedBox(height: 12),
                        Row(children: [
                          GestureDetector(
                            onTap: () { HapticFeedback.selectionClick(); setState(() => _helpfulCounts[i] = helpful + 1); },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.thumb_up_alt_outlined, color: AppTheme.textMuted, size: 13),
                                const SizedBox(width: 5),
                                Text('Helpful${helpful > 0 ? ' ($helpful)' : ''}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                              ]),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue.withAlpha(15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.edit_outlined, color: AppTheme.accentBlue, size: 13),
                                SizedBox(width: 4),
                                Text('Edit', style: TextStyle(color: AppTheme.accentBlue, fontSize: 11, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCoral.withAlpha(15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.delete_outline_rounded, color: AppTheme.accentCoral, size: 13),
                                SizedBox(width: 4),
                                Text('Delete', style: TextStyle(color: AppTheme.accentCoral, fontSize: 11, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ).animate(delay: (i * 80).ms).fadeIn(duration: 250.ms).slideY(begin: 0.08);
                },
              ),
      ),
    );
  }
}

class _UserReview {
  final String providerName; final String service; final ProviderReview review;
  const _UserReview({required this.providerName, required this.service, required this.review});
}
