// features/profile/screens/favorites_screen.dart
// Feature: User Profile & Account
//
// Compact premium favorites list with reduced card height.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/features/provider/screens/provider_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<ServiceProvider> _favorites;
  final Set<String> _favoriteIds = <String>{};
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _favorites = dummyProviders.where((p) => p.rating >= 4.5).toList();
    _favoriteIds.addAll(_favorites.map((e) => e.id));
  }

  List<String> get _categories {
    final cats = _favorites.map((p) => p.service).toSet().toList();
    return ['All', ...cats];
  }

  List<ServiceProvider> get _filteredFavorites {
    if (_selectedCategory == 'All') return _favorites;
    return _favorites.where((p) => p.service == _selectedCategory).toList();
  }

  void _removeFav(ServiceProvider provider) {
    setState(() {
      _favorites.remove(provider);
      _favoriteIds.remove(provider.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${provider.name} removed from favorites'),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.accentGold,
          onPressed: () => setState(() {
            _favorites.add(provider);
            _favoriteIds.add(provider.id);
          }),
        ),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final filtered = _filteredFavorites;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Favorites'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${_favorites.length} saved',
                style: tt.labelSmall?.copyWith(color: AppTheme.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: Column(
          children: [
            // ── Category Filter Chips ──
            if (_favorites.isNotEmpty)
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final selected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                        child: AnimatedContainer(
                          duration: AppTheme.durationFast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.accentGold.withAlpha(25)
                                : AppTheme.surfaceCard,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.accentGold
                                  : AppTheme.border,
                              width: 0.7,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.accentGold
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 8),

            // ── Provider List ──
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(tt)
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(pad, 4, pad, 100),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return _CompactFavoriteCard(
                          provider: p,
                          index: index,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProviderDetailScreen(provider: p),
                            ),
                          ),
                          onCallTap: () => _makeCall(p.phone),
                          onBookTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.selectSlot,
                            arguments: {'providerName': p.name},
                          ),
                          onRemoveTap: () => _removeFav(p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme tt) {
    return Center(
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.accentCoral.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border_rounded,
                    size: 40, color: AppTheme.accentCoral),
              ),
              const SizedBox(height: 16),
              Text('No favorites yet', style: tt.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Save providers you like for quick access',
                style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.95, 0.95)),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COMPACT FAVORITE CARD — Reduced height, premium feel
// ═══════════════════════════════════════════════════════

class _CompactFavoriteCard extends StatefulWidget {
  final ServiceProvider provider;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onCallTap;
  final VoidCallback onBookTap;
  final VoidCallback onRemoveTap;

  const _CompactFavoriteCard({
    required this.provider,
    required this.index,
    required this.onTap,
    required this.onCallTap,
    required this.onBookTap,
    required this.onRemoveTap,
  });

  @override
  State<_CompactFavoriteCard> createState() => _CompactFavoriteCardState();
}

class _CompactFavoriteCardState extends State<_CompactFavoriteCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;

    return GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                child: Row(
                  children: [
                    // ── Avatar ──
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldSubtleGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Text(
                              p.name.isNotEmpty
                                  ? p.name[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (p.isOnline)
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryDeep,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ── Info ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (p.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded,
                                    color: AppTheme.accentBlue, size: 14),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.service,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 13,
                                  color: AppTheme.accentGold),
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
                              const Icon(Icons.location_on_outlined,
                                  size: 12,
                                  color: AppTheme.textMuted),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  p.distance,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Action Buttons ──
                    Column(
                      children: [
                        _MiniAction(
                          icon: Icons.call_rounded,
                          color: AppTheme.accentTeal,
                          onTap: widget.onCallTap,
                        ),
                        const SizedBox(height: 6),
                        _MiniAction(
                          icon: Icons.calendar_today_rounded,
                          color: AppTheme.accentGold,
                          onTap: widget.onBookTap,
                        ),
                        const SizedBox(height: 6),
                        _MiniAction(
                          icon: Icons.favorite_rounded,
                          color: AppTheme.accentCoral,
                          onTap: widget.onRemoveTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 40).ms)
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.03);
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 32,
        height: 28,
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withAlpha(50), width: 0.5),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}
