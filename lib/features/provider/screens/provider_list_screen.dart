// features/provider/screens/provider_list_screen.dart
// Feature: Provider Browsing & Details
//
// Browsable list of providers in a category or area with sorting.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/category_icons.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/shared/widgets/provider_card.dart';
import 'package:local_connect/features/chat/screens/chat_detail_screen.dart';
import 'package:local_connect/features/provider/screens/provider_detail_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final String category;
  final String pincode;

  const ProviderListScreen({
    super.key,
    required this.category,
    required this.pincode,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGrid = false;
  bool _isLoading = true;
  bool _verifiedOnly = false;
  bool _onlineOnly = false;
  String _sortBy = 'Top Rated';
  final Set<String> _favoriteIds = <String>{};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  List<ServiceProvider> get _baseProviders {
    return dummyProviders.where((p) {
      return p.service.toLowerCase() == widget.category.toLowerCase();
    }).toList();
  }

  double _distanceValue(ServiceProvider provider) {
    final value = provider.distance.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(value) ?? 99;
  }

  int _priceValue(ServiceProvider provider) {
    final match = RegExp(r'\d+').firstMatch(provider.pricing);
    return int.tryParse(match?.group(0) ?? '9999') ?? 9999;
  }

  int _responseMinutes(ServiceProvider provider) {
    final rating = provider.rating;
    if (rating >= 4.8) return 5;
    if (rating >= 4.5) return 10;
    if (rating >= 4.0) return 18;
    return 30;
  }

  List<ServiceProvider> get _filteredProviders {
    var list = _baseProviders.where((p) {
      final matchesSearch =
          _searchController.text.trim().isEmpty ||
          p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.city.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.service.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      final matchesPincode = p.servesPincode(widget.pincode);
      final matchesVerified = !_verifiedOnly || p.isVerified;
      final matchesOnline = !_onlineOnly || p.isOnline;

      return matchesSearch &&
          matchesVerified &&
          matchesOnline &&
          matchesPincode;
    }).toList();

    switch (_sortBy) {
      case 'Top Rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Nearest':
        list.sort((a, b) => _distanceValue(a).compareTo(_distanceValue(b)));
        break;
      case 'Lowest Price':
        list.sort((a, b) => _priceValue(a).compareTo(_priceValue(b)));
        break;
      case 'Fastest Response':
        list.sort((a, b) => _responseMinutes(a).compareTo(_responseMinutes(b)));
        break;
      case 'Most Experienced':
        list.sort((a, b) {
          final ea =
              int.tryParse(a.experience.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final eb =
              int.tryParse(b.experience.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return eb.compareTo(ea);
        });
        break;
    }

    return list;
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openDetail(ServiceProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderDetailScreen(provider: provider),
      ),
    );
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

  void _toggleFavorite(ServiceProvider provider) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_favoriteIds.contains(provider.id)) {
        _favoriteIds.remove(provider.id);
      } else {
        _favoriteIds.add(provider.id);
      }
    });
  }

  Future<void> _openSortSheet() async {
    final options = [
      'Top Rated',
      'Nearest',
      'Lowest Price',
      'Fastest Response',
      'Most Experienced',
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort by',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ...options.map(
                (opt) => ListTile(
                  onTap: () => Navigator.pop(context, opt),
                  leading: Icon(
                    _sortBy == opt
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: _sortBy == opt
                        ? AppTheme.accentGold
                        : AppTheme.textMuted,
                  ),
                  title: Text(
                    opt,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _sortBy = selected);
    }
  }

  Future<void> _openFilterSheet() async {
    var verified = _verifiedOnly;
    var online = _onlineOnly;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Providers',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: verified,
                    activeThumbColor: AppTheme.accentGold,
                    title: const Text(
                      'Verified only',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    onChanged: (v) => setModal(() => verified = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: online,
                    activeThumbColor: AppTheme.accentTeal,
                    title: const Text(
                      'Available now',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    onChanged: (v) => setModal(() => online = v),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _verifiedOnly = verified;
                          _onlineOnly = online;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final providers = _filteredProviders;
    final gradient = CategoryIcons.getCategoryGradient(widget.category);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.accentGold,
          backgroundColor: AppTheme.surface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: 170,
                pinned: true,
                backgroundColor: AppTheme.surface,
                foregroundColor: Colors.white,
                title: Text(widget.category),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(gradient: gradient),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 20,
                          bottom: 28,
                          child: Icon(
                            CategoryIcons.getIcon(widget.category),
                            size: 92,
                            color: Colors.white.withAlpha(40),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 22,
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                            child: Text(
                              'Serving PIN ${widget.pincode}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeader(
                  minHeight: 118,
                  maxHeight: 118,
                  child: Container(
                    color: AppTheme.background.withAlpha(240),
                    padding: EdgeInsets.fromLTRB(pad, 10, pad, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search providers in ${widget.category}',
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: AppTheme.accentGold,
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                        ? IconButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {});
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: AppTheme.textMuted,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _TopActionIcon(
                              icon: Icons.tune_rounded,
                              active: _verifiedOnly || _onlineOnly,
                              onTap: _openFilterSheet,
                            ),
                            const SizedBox(width: 8),
                            _TopActionIcon(
                              icon: Icons.swap_vert_rounded,
                              active: true,
                              onTap: _openSortSheet,
                            ),
                            const SizedBox(width: 8),
                            _TopActionIcon(
                              icon: _isGrid
                                  ? Icons.view_list_rounded
                                  : Icons.grid_view_rounded,
                              active: true,
                              onTap: () => setState(() => _isGrid = !_isGrid),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${providers.length} results',
                              style: tt.labelLarge?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _sortBy,
                              style: tt.labelSmall?.copyWith(
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    children: [
                      _FilterChip(
                        label: 'All',
                        active: !_verifiedOnly && !_onlineOnly,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _verifiedOnly = false;
                            _onlineOnly = false;
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Verified',
                        active: _verifiedOnly,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _verifiedOnly = !_verifiedOnly);
                        },
                      ),
                      _FilterChip(
                        label: 'Available Now',
                        active: _onlineOnly,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _onlineOnly = !_onlineOnly);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Shimmer.fromColors(
                          baseColor: AppTheme.surfaceCard,
                          highlightColor: AppTheme.surfaceElevated,
                          child: Container(
                            height: 166,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMD,
                              ),
                            ),
                          ),
                        ),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (providers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 56,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text('No providers found', style: tt.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Try changing filters or search terms.',
                            style: tt.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_isGrid)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 20),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final provider = providers[index];
                      return _ProviderGridTile(
                        provider: provider,
                        isFavorite: _favoriteIds.contains(provider.id),
                        onFavorite: () => _toggleFavorite(provider),
                        onTap: () => _openDetail(provider),
                      );
                    }, childCount: providers.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.74,
                        ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 22),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final provider = providers[index];
                      return ProviderCard(
                        provider: provider,
                        index: index,
                        isFavorite: _favoriteIds.contains(provider.id),
                        onFavoriteTap: () => _toggleFavorite(provider),
                        onTap: () => _openDetail(provider),
                        onCallTap: () => _makeCall(provider.phone),
                        onChatTap: () => _openChat(provider),
                        onBookTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.selectSlot,
                          arguments: {'providerName': provider.name},
                        ),
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
}

class _TopActionIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TopActionIcon({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: 42,
        height: 42,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        color: active ? AppTheme.surfaceElevated : AppTheme.glassDark,
        child: Icon(
          icon,
          color: active ? AppTheme.accentGold : AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.primaryGradient : null,
            color: active ? null : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: active
                ? null
                : Border.all(color: AppTheme.border, width: 0.5),
            boxShadow: active ? AppTheme.softGlow : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppTheme.textOnAccent : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideX(begin: 0.08);
  }
}

class _ProviderGridTile extends StatelessWidget {
  final ServiceProvider provider;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _ProviderGridTile({
    required this.provider,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  String get _trustLabel {
    if (provider.hiredNearbyCount > 0) {
      return '${provider.hiredNearbyCount} hired nearby';
    }
    if (provider.rating >= 4.5) return 'Top rated';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'provider-avatar-${provider.id}',
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primarySubtleGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      border: provider.isVerified
                          ? Border.all(
                              color: AppTheme.accentBlue.withAlpha(100),
                              width: 1.2,
                            )
                          : null,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Text(
                            provider.name.isNotEmpty
                                ? provider.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (provider.isOnline)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.accentTeal,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.background,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? AppTheme.accentCoral
                        : AppTheme.textMuted,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (provider.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppTheme.accentBlue,
                    size: 13,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              provider.service,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppTheme.accentGold,
                  size: 12,
                ),
                const SizedBox(width: 3),
                Text(
                  '${provider.rating.toStringAsFixed(1)} (${provider.reviewCount})',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.route_rounded,
                  size: 10,
                  color: AppTheme.accentBlue,
                ),
                const SizedBox(width: 2),
                Text(
                  provider.distance,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (_trustLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withAlpha(12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: AppTheme.accentTeal.withAlpha(30),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_rounded,
                      size: 10,
                      color: AppTheme.accentTeal,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        _trustLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('View'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeader extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const _StickyHeader({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeader oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}
