// features/home/screens/micro_zone_screen.dart
// Feature: Home & Dashboard
//
// Micro-zone view showing hyper-local providers within a pincode area.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/shared/widgets/provider_card.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/features/chat/screens/chat_detail_screen.dart';
import 'package:local_connect/features/provider/screens/provider_detail_screen.dart';

class MicroZoneScreen extends StatefulWidget {
  final String category;
  final String pincode;
  const MicroZoneScreen({
    super.key,
    required this.category,
    required this.pincode,
  });
  @override
  State<MicroZoneScreen> createState() => _MicroZoneScreenState();
}

class _MicroZoneScreenState extends State<MicroZoneScreen> {
  final Set<String> _favoriteIds = {};
  String _sort = 'best';

  List<ServiceProvider> get _providers {
    var list = dummyProviders
        .where(
          (p) =>
              p.service.toLowerCase().contains(widget.category.toLowerCase()) &&
              p.servesPincode(widget.pincode),
        )
        .toList();
    // Broaden if too few
    if (list.length < 2) {
      final broader = dummyProviders
          .where(
            (p) =>
                p.service.toLowerCase().contains(widget.category.toLowerCase()),
          )
          .toList();
      for (final p in broader) {
        if (!list.any((e) => e.id == p.id)) list.add(p);
      }
    }
    switch (_sort) {
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'nearest':
        list.sort((a, b) {
          final ad =
              double.tryParse(a.distance.replaceAll(RegExp(r'[^\d.]'), '')) ??
              999;
          final bd =
              double.tryParse(b.distance.replaceAll(RegExp(r'[^\d.]'), '')) ??
              999;
          return ad.compareTo(bd);
        });
      case 'fastest':
        list.sort((a, b) {
          final at = a.responseTimeMinutes > 0 ? a.responseTimeMinutes : 99;
          final bt = b.responseTimeMinutes > 0 ? b.responseTimeMinutes : 99;
          return at.compareTo(bt);
        });
      default:
        list.sort((a, b) {
          var scoreA =
              a.rating * 10 + (a.isOnline ? 20 : 0) + (a.isVerified ? 10 : 0);
          var scoreB =
              b.rating * 10 + (b.isOnline ? 20 : 0) + (b.isVerified ? 10 : 0);
          return scoreB.compareTo(scoreA);
        });
    }
    return list;
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openChat(ServiceProvider provider) {
    var thread = activeChats.cast<ChatThread?>().firstWhere(
      (t) => t!.provider.id == provider.id,
      orElse: () => null,
    );
    if (thread == null) {
      thread = ChatThread(provider: provider, messages: []);
      activeChats.add(thread);
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatDetailScreen(thread: thread!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;
    final providers = _providers;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Top bar
              SliverToBoxAdapter(
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
                              '${widget.category} in ${widget.pincode}',
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${providers.length} providers found',
                              style: tt.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // Sort chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 14, pad, 8),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _sortChip('Best Match', 'best'),
                        const SizedBox(width: 8),
                        _sortChip('Top Rated', 'rating'),
                        const SizedBox(width: 8),
                        _sortChip('Nearest', 'nearest'),
                        const SizedBox(width: 8),
                        _sortChip('Fastest', 'fastest'),
                      ],
                    ),
                  ),
                ),
              ),

              // Local trust banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 4, pad, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withAlpha(10),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      border: Border.all(
                        color: AppTheme.accentTeal.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.accentTeal,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Showing best ${widget.category.toLowerCase()} experts serving PIN ${widget.pincode}',
                            style: const TextStyle(
                              color: AppTheme.accentTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 150.ms).fadeIn(duration: 280.ms),
                ),
              ),

              // Provider list
              if (providers.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 40, pad, 40),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            color: AppTheme.textMuted,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No ${widget.category} providers found',
                            style: tt.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try a different pincode or category',
                            style: tt.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 0, pad, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = providers[index];
                      return ProviderCard(
                        provider: p,
                        index: index,
                        isFavorite: _favoriteIds.contains(p.id),
                        onFavoriteTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (_favoriteIds.contains(p.id)) {
                              _favoriteIds.remove(p.id);
                            } else {
                              _favoriteIds.add(p.id);
                            }
                          });
                        },
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProviderDetailScreen(provider: p),
                          ),
                        ),
                        onCallTap: () => _makeCall(p.phone),
                        onChatTap: () => _openChat(p),
                        onBookTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pushNamed(
                            context,
                            AppRoutes.selectSlot,
                            arguments: {'providerName': p.name},
                          );
                        },
                      );
                    }, childCount: providers.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final active = _sort == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _sort = value);
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          color: active ? null : AppTheme.glassDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: active
              ? null
              : Border.all(color: AppTheme.border, width: 0.5),
          boxShadow: active ? AppTheme.softGlow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppTheme.textOnAccent : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
