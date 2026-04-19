// features/home/widgets/pincode_ecosystem.dart
// Feature: Home & Dashboard
//
// Pincode-based local ecosystem banner showing nearby stats and services.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  PINCODE ECOSYSTEM — Dynamic local sections
// ─────────────────────────────────────────────────────────

/// Provides computed local sections based on a pincode.
class PincodeEcosystem {
  final String pincode;
  PincodeEcosystem(this.pincode);

  List<ServiceProvider> get _allLocal =>
      dummyProviders.where((p) => p.servesPincode(pincode)).toList();

  List<ServiceProvider> get topRated {
    final list = [..._allLocal]..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(8).toList();
  }

  List<ServiceProvider> get availableNow =>
      _allLocal.where((p) => p.isOnline).take(8).toList();

  List<ServiceProvider> get fastestResponders {
    final list = _allLocal.where((p) => p.responseTimeMinutes > 0).toList()
      ..sort((a, b) => a.responseTimeMinutes.compareTo(b.responseTimeMinutes));
    return list.take(8).toList();
  }

  List<ServiceProvider> get trustedByFamilies {
    final list =
        _allLocal.where((p) => p.hiredNearbyCount >= 5 || p.isVerified).toList()
          ..sort((a, b) => b.hiredNearbyCount.compareTo(a.hiredNearbyCount));
    return list.take(8).toList();
  }

  List<ServiceProvider> get popularThisWeek {
    final list = [..._allLocal]
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return list.take(8).toList();
  }

  Map<String, int> get trendingServices {
    final counts = <String, int>{};
    for (final p in _allLocal) {
      counts[p.service] = (counts[p.service] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(6));
  }

  int get totalAvailable => _allLocal.length;
  int get onlineCount => _allLocal.where((p) => p.isOnline).length;

  /// Recently contacted (simulated).
  List<ServiceProvider> get recentlyContacted => _allLocal.take(3).toList();

  /// Reconnect suggestion.
  ServiceProvider? get reconnectSuggestion =>
      _allLocal.isNotEmpty ? _allLocal.first : null;
}

// ─────────────────────────────────────────────────────────
//  HORIZONTAL PROVIDER RAIL — Reusable for ecosystem sections
// ─────────────────────────────────────────────────────────

class EcosystemProviderRail extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ServiceProvider> items;
  final ValueChanged<ServiceProvider> onTapItem;
  final VoidCallback? onSeeAll;
  final Color? accentColor;

  const EcosystemProviderRail({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onTapItem,
    this.onSeeAll,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: tt.headlineMedium?.copyWith(fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: tt.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'See all',
                      style: tt.labelLarge?.copyWith(
                        color: accentColor ?? AppTheme.accentGold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 122,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: pad),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) => _EcoProviderCard(
                provider: items[index],
                index: index,
                onTap: () => onTapItem(items[index]),
                accentColor: accentColor,
              ),
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _EcoProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final int index;
  final VoidCallback onTap;
  final Color? accentColor;

  const _EcoProviderCard({
    required this.provider,
    required this.index,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW < 360 ? 190.0 : 220.0;
    final p = provider;

    return GestureDetector(
          onTap: onTap,
          child: GlassContainer(
            width: cardW,
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldSubtleGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      if (p.isOnline)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryDeep,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (p.isVerified) ...[
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppTheme.accentBlue,
                              size: 12,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.service,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            p.rating.toString(),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.distance,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (p.hiredNearbyCount > 0) ...[
                        const SizedBox(height: 3),
                        Text(
                          '${p.hiredNearbyCount} hired nearby',
                          style: TextStyle(
                            color: accentColor ?? AppTheme.accentTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 45).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.08);
  }
}

// ─────────────────────────────────────────────────────────
//  TRENDING SERVICES SECTION
// ─────────────────────────────────────────────────────────

class TrendingServicesSection extends StatelessWidget {
  final String pincode;
  final Map<String, int> services;
  final ValueChanged<String> onTapService;

  const TrendingServicesSection({
    super.key,
    required this.pincode,
    required this.services,
    required this.onTapService,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending in $pincode',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 2),
          Text('Most searched services near you', style: tt.labelSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services.entries.toList().asMap().entries.map((entry) {
              final i = entry.key;
              final svc = entry.value;
              return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTapService(svc.key);
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            color: AppTheme.accentGold,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            svc.key,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withAlpha(20),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Text(
                              '${svc.value}',
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (i * 50).ms)
                  .fadeIn(duration: 250.ms)
                  .slideX(begin: 0.05);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  LOCAL TRUST SIGNAL BAR
// ─────────────────────────────────────────────────────────

class LocalTrustBar extends StatelessWidget {
  final String pincode;
  final int totalProviders;
  final int onlineCount;

  const LocalTrustBar({
    super.key,
    required this.pincode,
    required this.totalProviders,
    required this.onlineCount,
  });

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final signals = [
      _TrustSignal(
        'Trusted by ${(totalProviders * 3).clamp(10, 99)} homes near you',
        Icons.home_rounded,
        AppTheme.accentTeal,
      ),
      _TrustSignal(
        '$onlineCount providers online now',
        Icons.circle,
        AppTheme.accentTeal,
      ),
      _TrustSignal(
        'Rated by users in $pincode',
        Icons.star_rounded,
        AppTheme.accentGold,
      ),
      _TrustSignal(
        'Popular near your locality',
        Icons.trending_up_rounded,
        AppTheme.accentCoral,
      ),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final s = signals[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: s.color.withAlpha(12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: s.color.withAlpha(40), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.icon, size: 12, color: s.color),
                const SizedBox(width: 5),
                Text(
                  s.label,
                  style: TextStyle(
                    color: s.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate(delay: (i * 60).ms).fadeIn(duration: 250.ms);
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: signals.length,
      ),
    );
  }
}

class _TrustSignal {
  final String label;
  final IconData icon;
  final Color color;
  const _TrustSignal(this.label, this.icon, this.color);
}

// ─────────────────────────────────────────────────────────
//  RETENTION SECTION — Recently Contacted + Reconnect
// ─────────────────────────────────────────────────────────

class RetentionSection extends StatelessWidget {
  final ServiceProvider? reconnectProvider;
  final List<ServiceProvider> recentlyContacted;
  final ValueChanged<ServiceProvider> onTapProvider;
  final VoidCallback? onReconnect;

  const RetentionSection({
    super.key,
    this.reconnectProvider,
    required this.recentlyContacted,
    required this.onTapProvider,
    this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    if (reconnectProvider == null && recentlyContacted.isEmpty) {
      return const SizedBox.shrink();
    }
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Reconnect',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 2),
          Text('Continue with your last experts', style: tt.labelSmall),
          const SizedBox(height: 12),
          // Reconnect card
          if (reconnectProvider != null)
            GestureDetector(
              onTap: () => onTapProvider(reconnectProvider!),
              child: GlassContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                color: AppTheme.accentGold.withAlpha(8),
                border: Border.all(color: AppTheme.accentGold.withAlpha(50)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldSubtleGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Center(
                        child: Text(
                          reconnectProvider!.name[0],
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reconnectProvider!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reconnectProvider!.service,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onReconnect?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          boxShadow: AppTheme.goldGlow,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: 14,
                              color: AppTheme.textOnAccent,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Reconnect',
                              style: TextStyle(
                                color: AppTheme.textOnAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
          if (reconnectProvider != null && recentlyContacted.length > 1)
            const SizedBox(height: 10),
          // Recently contacted chips
          if (recentlyContacted.length > 1)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentlyContacted
                  .skip(1)
                  .take(4)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    return GestureDetector(
                      onTap: () => onTapProvider(p),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldSubtleGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  p.name[0],
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              p.name.split(' ').first,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (i * 50).ms).fadeIn(duration: 200.ms);
                  })
                  .toList(),
            ),
        ],
      ),
    );
  }
}
