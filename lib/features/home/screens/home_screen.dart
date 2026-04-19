// features/home/screens/home_screen.dart
// Feature: Home & Dashboard
//
// Refined home screen: focused layout, premium category grid,
// compact provider cards, cleaner sections.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/home/widgets/location_selector_sheet.dart';
import 'package:local_connect/features/home/widgets/pincode_ecosystem.dart';
import 'package:local_connect/shared/widgets/provider_card.dart';
import 'package:local_connect/features/chat/screens/chat_detail_screen.dart';
import 'package:local_connect/features/home/screens/micro_zone_screen.dart';
import 'package:local_connect/features/notifications/screens/notifications_screen.dart';
import 'package:local_connect/features/profile/screens/profile_screen.dart';
import 'package:local_connect/features/provider/screens/provider_detail_screen.dart';
import 'package:local_connect/features/provider/screens/provider_list_screen.dart';
import 'package:local_connect/core/utils/category_icons.dart';

class HomeScreen extends StatefulWidget {
  final String pincode;

  const HomeScreen({super.key, required this.pincode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _promoPageController = PageController(viewportFraction: 0.93);
  bool _isLoading = true;
  final Set<String> _favoriteProviderIds = <String>{};
  late String _currentPincode;
  late PincodeEcosystem _ecosystem;

  Timer? _promoTimer;
  Timer? _placeholderTimer;
  int _currentPromoPage = 0;
  int _currentSearchHint = 0;
  int _unreadCount = 3;

  final List<String> _categories = [
    'Plumber',
    'Electrician',
    'AC Repair',
    'Carpenter',
    'Painter',
    'Cleaning',
    'Salon',
    'Tutor',
    'Bike Repair',
    'More',
  ];

  final List<String> _searchHints = const [
    'Search plumbers, electricians, tutors...',
    'Try "AC repair near me"',
    'Find top-rated experts nearby',
  ];

  final List<_PromoBannerModel> _promoBanners = const [
    _PromoBannerModel(
      title: '20% Off First Booking',
      subtitle: 'Use code WELCOME20 and save instantly',
      cta: 'Claim Offer',
      colors: [Color(0xFFFACC15), Color(0xFFFFD84D)],
    ),
    _PromoBannerModel(
      title: 'AC Repair Special',
      subtitle: 'Summer-ready servicing from verified experts',
      cta: 'Explore Deals',
      colors: [Color(0xFF60A5FA), Color(0xFF93C5FD)],
    ),
    _PromoBannerModel(
      title: 'Trusted Experts Near You',
      subtitle: 'Handpicked local professionals with top ratings',
      cta: 'View Experts',
      colors: [Color(0xFF10B981), Color(0xFF34D399)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentPincode = widget.pincode;
    _ecosystem = PincodeEcosystem(_currentPincode);
    _bootstrapHome();
    _startPromoAutoSlide();
    _startSearchHintLoop();
  }

  Future<void> _bootstrapHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) setState(() => _isLoading = false);
  }

  void _startPromoAutoSlide() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_promoPageController.hasClients) return;
      final next = (_currentPromoPage + 1) % _promoBanners.length;
      _promoPageController.animateToPage(
        next,
        duration: AppTheme.durationMedium,
        curve: AppTheme.curveDefault,
      );
    });
  }

  void _startSearchHintLoop() {
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _currentSearchHint = (_currentSearchHint + 1) % _searchHints.length;
      });
    });
  }

  List<ServiceProvider> get _nearbyProviders {
    var list = dummyProviders
        .where((p) => p.servesPincode(_currentPincode))
        .toList();
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _toggleFavorite(ServiceProvider provider) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_favoriteProviderIds.contains(provider.id)) {
        _favoriteProviderIds.remove(provider.id);
      } else {
        _favoriteProviderIds.add(provider.id);
      }
    });
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

  void _openCategory(String category) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ProviderListScreen(category: category, pincode: _currentPincode),
      ),
    );
  }

  void _openProviderDetail(ServiceProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderDetailScreen(provider: provider),
      ),
    );
  }

  Future<void> _openSearchExperience() async {
    HapticFeedback.lightImpact();
    await Navigator.pushNamed(context, AppRoutes.search);
  }

  Future<void> _openLocationSelector() async {
    final newPincode = await showLocationSelectorSheet(
      context,
      currentPincode: _currentPincode,
    );
    if (newPincode != null && newPincode != _currentPincode && mounted) {
      setState(() {
        _currentPincode = newPincode;
        _ecosystem = PincodeEcosystem(_currentPincode);
      });
      _showPremiumSnack('Location updated to $_currentPincode');
    }
  }

  void _openMicroZone(String category) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MicroZoneScreen(category: category, pincode: _currentPincode),
      ),
    );
  }

  Future<void> _refreshHome() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _unreadCount = (_unreadCount + 1) % 5;
    });
    _showPremiumSnack('Home feed refreshed');
  }

  void _showPremiumSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _promoPageController.dispose();
    _promoTimer?.cancel();
    _placeholderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryDeep,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshHome,
            color: AppTheme.accentGold,
            backgroundColor: AppTheme.primaryDark,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Hero Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 10, pad, 12),
                    child: _PremiumHeroHeader(
                      pincode: _currentPincode,
                      greeting: _getGreeting(),
                      unreadCount: _unreadCount,
                      onLocationTap: _openLocationSelector,
                      onNotificationTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                      onAvatarTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: 320.ms),
                ),

                // ── Search Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: _SmartSearchBar(
                      placeholder: _searchHints[_currentSearchHint],
                      onTap: _openSearchExperience,
                    ),
                  ).animate(delay: 80.ms).fadeIn(duration: 320.ms),
                ),

                // ── Categories Section ──
                SliverToBoxAdapter(
                  child: _CategoriesSection(
                    categories: _categories,
                    onTapCategory: _openCategory,
                  ),
                ),

                // ── Promo Banner ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                    child: _PromoBannerCarousel(
                      pageController: _promoPageController,
                      items: _promoBanners,
                      currentPage: _currentPromoPage,
                      onPageChanged: (i) =>
                          setState(() => _currentPromoPage = i),
                      onTapCta: (i) {
                        HapticFeedback.selectionClick();
                        Navigator.pushNamed(context, AppRoutes.offers);
                      },
                    ),
                  ),
                ),

                // ── Top Rated Rail ──
                SliverToBoxAdapter(
                  child: _CompactProviderRail(
                    title: 'Top Rated',
                    items: _ecosystem.topRated,
                    accentColor: AppTheme.accentGold,
                    onTapItem: _openProviderDetail,
                    onSeeAll: () => _openMicroZone('Top Rated'),
                    onCallTap: (p) => _makeCall(p.phone),
                    onChatTap: _openChat,
                    onFavoriteTap: _toggleFavorite,
                    favoriteIds: _favoriteProviderIds,
                  ),
                ),

                // ── Available Now Rail ──
                SliverToBoxAdapter(
                  child: _CompactProviderRail(
                    title: '${_ecosystem.onlineCount} Available Now',
                    items: _ecosystem.availableNow,
                    accentColor: AppTheme.accentTeal,
                    onTapItem: _openProviderDetail,
                    onCallTap: (p) => _makeCall(p.phone),
                    onChatTap: _openChat,
                    onFavoriteTap: _toggleFavorite,
                    favoriteIds: _favoriteProviderIds,
                  ),
                ),

                // ── Recommended Rail ──
                SliverToBoxAdapter(
                  child: _CompactProviderRail(
                    title: 'Recommended for You',
                    items: _ecosystem.trustedByFamilies,
                    accentColor: AppTheme.accentBlue,
                    onTapItem: _openProviderDetail,
                    onSeeAll: () => _openMicroZone('Trusted'),
                    onCallTap: (p) => _makeCall(p.phone),
                    onChatTap: _openChat,
                    onFavoriteTap: _toggleFavorite,
                    favoriteIds: _favoriteProviderIds,
                  ),
                ),

                // ── Nearby Providers Section ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 18, pad, 8),
                    child: _SectionHeader(
                      title: 'Nearby Providers',
                      trailing: '${_nearbyProviders.length} found',
                    ),
                  ),
                ),

                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: const _ProviderSkeletonList(),
                    ),
                  )
                else if (_nearbyProviders.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(pad, 20, pad, 40),
                      child: _EmptyStateCard(
                        onReset: () => _showPremiumSnack('Filters reset'),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(pad, 4, pad, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final provider = _nearbyProviders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ProviderCard(
                              provider: provider,
                              index: index,
                              isFavorite: _favoriteProviderIds.contains(
                                provider.id,
                              ),
                              onFavoriteTap: () => _toggleFavorite(provider),
                              onTap: () => _openProviderDetail(provider),
                              onCallTap: () => _makeCall(provider.phone),
                              onChatTap: () => _openChat(provider),
                              onBookTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.selectSlot,
                                  arguments: {'providerName': provider.name},
                                );
                              },
                            ),
                          );
                        },
                        childCount: _nearbyProviders.length.clamp(0, 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, Alok ☀️';
    if (hour < 17) return 'Good Afternoon, Alok 🌤';
    return 'Good Evening, Alok 🌙';
  }
}

// ═══════════════════════════════════════════════════════
//  PREMIUM HERO HEADER — Compact & focused
// ═══════════════════════════════════════════════════════

class _PremiumHeroHeader extends StatelessWidget {
  final String pincode;
  final String greeting;
  final int unreadCount;
  final VoidCallback? onLocationTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;

  const _PremiumHeroHeader({
    required this.pincode,
    required this.greeting,
    required this.unreadCount,
    this.onLocationTap,
    required this.onNotificationTap,
    required this.onAvatarTap,
  });

  static (String, String) _splitGreeting(String greeting) {
    final idx = greeting.lastIndexOf(' ');
    if (idx < 0) return (greeting, '');
    return (greeting.substring(0, idx), greeting.substring(idx + 1));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;
    final (greetText, greetEmoji) = _splitGreeting(greeting);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top row: location + actions ──
        Row(
          children: [
            GestureDetector(
              onTap: onLocationTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isCompact ? 7 : 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      boxShadow: AppTheme.goldGlow,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.textOnAccent,
                      size: isCompact ? 16 : 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Current Location', style: tt.labelSmall),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                        ],
                      ),
                      Text(
                        'PIN $pincode',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            _NotificationIconButton(
              unreadCount: unreadCount,
              onTap: onNotificationTap,
            ),
            SizedBox(width: isCompact ? 6 : 8),
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: isCompact ? 34 : 38,
                height: isCompact ? 34 : 38,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  boxShadow: AppTheme.goldGlow,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: AppTheme.textOnAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 12 : 16),
        // ── Greeting ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                greetText,
                style: tt.headlineLarge?.copyWith(
                  fontSize: isCompact ? 20 : 24,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (greetEmoji.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                greetEmoji,
                style: TextStyle(fontSize: isCompact ? 20 : 24, height: 1.1),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  NOTIFICATION ICON BUTTON
// ═══════════════════════════════════════════════════════

class _NotificationIconButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationIconButton({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCoral,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: AppTheme.primaryDeep, width: 1),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SMART SEARCH BAR — Clean single-purpose
// ═══════════════════════════════════════════════════════

class _SmartSearchBar extends StatelessWidget {
  final String placeholder;
  final VoidCallback onTap;

  const _SmartSearchBar({required this.placeholder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.glassBorderLight, width: 0.6),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppTheme.accentGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  placeholder,
                  key: ValueKey<String>(placeholder),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                color: AppTheme.accentBlue,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CATEGORIES SECTION — Premium 2-row grid
// ═══════════════════════════════════════════════════════

class _CategoriesSection extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<String> onTapCategory;

  const _CategoriesSection({
    required this.categories,
    required this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;
    final screenW = MediaQuery.of(context).size.width;
    final cardSize = ((screenW - pad * 2 - 36) / 5).clamp(58.0, 72.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 18, pad, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Categories',
                style: tt.headlineMedium?.copyWith(fontSize: 17),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onTapCategory('More'),
                child: Text(
                  'See all',
                  style: tt.labelLarge?.copyWith(color: AppTheme.accentGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 12,
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              final catData = CategoryIcons.get(cat);
              final isMore = cat == 'More';
              return _CategoryTile(
                name: cat,
                icon: isMore ? Icons.grid_view_rounded : catData.icon,
                colors: isMore
                    ? [AppTheme.textMuted, AppTheme.textMuted]
                    : catData.colors,
                size: cardSize,
                index: i,
                onTap: () => onTapCategory(cat),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final String name;
  final IconData icon;
  final List<Color> colors;
  final double size;
  final int index;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.name,
    required this.icon,
    required this.colors,
    required this.size,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.colors.first;

    return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              width: widget.size,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withAlpha(_pressed ? 50 : 28),
                          primary.withAlpha(10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(
                        color: primary.withAlpha(_pressed ? 100 : 50),
                        width: 0.6,
                      ),
                      boxShadow: _pressed
                          ? [
                              BoxShadow(
                                color: primary.withAlpha(40),
                                blurRadius: 12,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      widget.icon,
                      color: primary,
                      size: widget.size * 0.38,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 35).ms)
        .fadeIn(duration: 250.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}

// ═══════════════════════════════════════════════════════
//  COMPACT PROVIDER RAIL — Premium horizontal cards (Section 4)
// ═══════════════════════════════════════════════════════

class _CompactProviderRail extends StatelessWidget {
  final String title;
  final List<ServiceProvider> items;
  final Color accentColor;
  final ValueChanged<ServiceProvider> onTapItem;
  final VoidCallback? onSeeAll;
  final ValueChanged<ServiceProvider> onCallTap;
  final ValueChanged<ServiceProvider> onChatTap;
  final ValueChanged<ServiceProvider> onFavoriteTap;
  final Set<String> favoriteIds;

  const _CompactProviderRail({
    required this.title,
    required this.items,
    required this.accentColor,
    required this.onTapItem,
    this.onSeeAll,
    required this.onCallTap,
    required this.onChatTap,
    required this.onFavoriteTap,
    required this.favoriteIds,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final pad = AppTheme.responsivePadding(context);

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: _SectionHeader(
              title: title,
              actionText: onSeeAll != null ? 'See all' : null,
              accentColor: accentColor,
              onActionTap: onSeeAll,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: pad),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final p = items[index];
                return _CompactProviderCard(
                  provider: p,
                  index: index,
                  isFavorite: favoriteIds.contains(p.id),
                  onTap: () => onTapItem(p),
                  onCallTap: () => onCallTap(p),
                  onChatTap: () => onChatTap(p),
                  onFavoriteTap: () => onFavoriteTap(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactProviderCard extends StatefulWidget {
  final ServiceProvider provider;
  final int index;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;
  final VoidCallback onFavoriteTap;

  const _CompactProviderCard({
    required this.provider,
    required this.index,
    required this.isFavorite,
    required this.onTap,
    required this.onCallTap,
    required this.onChatTap,
    required this.onFavoriteTap,
  });

  @override
  State<_CompactProviderCard> createState() => _CompactProviderCardState();
}

class _CompactProviderCardState extends State<_CompactProviderCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW < 360 ? 170.0 : 185.0;

    return GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: GlassContainer(
              width: cardW,
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar + Name + Favorite ──
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldSubtleGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
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
                                  fontSize: 15,
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
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            Text(
                              p.service,
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onFavoriteTap,
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: widget.isFavorite
                              ? AppTheme.accentCoral
                              : AppTheme.textMuted,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ── Rating + Distance ──
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
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
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
                  const Spacer(),
                  // ── CTA Buttons ──
                  Row(
                    children: [
                      _MiniCTA(
                        icon: Icons.call_rounded,
                        color: AppTheme.accentTeal,
                        onTap: widget.onCallTap,
                      ),
                      const SizedBox(width: 6),
                      _MiniCTA(
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppTheme.accentBlue,
                        onTap: widget.onChatTap,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldSubtleGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                              border: Border.all(
                                color: AppTheme.accentGold.withAlpha(60),
                                width: 0.5,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: AppTheme.accentGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 45).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.08);
  }
}

class _MiniCTA extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniCTA({
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

// ═══════════════════════════════════════════════════════
//  SECTION HEADER — Reusable
// ═══════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final String? actionText;
  final Color? accentColor;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.trailing,
    this.actionText,
    this.accentColor,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: tt.headlineMedium?.copyWith(fontSize: 17),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null)
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: Text(
              trailing!,
              style: tt.labelSmall?.copyWith(
                color: accentColor ?? AppTheme.accentGold,
              ),
            ),
          ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                actionText!,
                style: tt.labelLarge?.copyWith(
                  color: accentColor ?? AppTheme.accentGold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PROMO BANNER CAROUSEL
// ═══════════════════════════════════════════════════════

class _PromoBannerCarousel extends StatelessWidget {
  final PageController pageController;
  final List<_PromoBannerModel> items;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTapCta;

  const _PromoBannerCarousel({
    required this.pageController,
    required this.items,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTapCta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: pageController,
            itemCount: items.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                    gradient: LinearGradient(
                      colors: item.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.colors.first.withAlpha(70),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: -10,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(32),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: AppTheme.textOnAccent,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                color: AppTheme.textOnAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => onTapCta(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSM,
                                  ),
                                ),
                                child: Text(
                                  item.cta,
                                  style: const TextStyle(
                                    color: AppTheme.primaryDeep,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (index) => AnimatedContainer(
              duration: AppTheme.durationFast,
              width: currentPage == index ? 20 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: currentPage == index
                    ? AppTheme.accentGold
                    : AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SKELETON + EMPTY STATE
// ═══════════════════════════════════════════════════════

class _ProviderSkeletonList extends StatelessWidget {
  const _ProviderSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: AppTheme.surfaceCard,
            highlightColor: AppTheme.surfaceElevated,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyStateCard({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppTheme.accentGold,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text('No providers found', style: tt.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Try changing your location or explore more categories.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════

class _PromoBannerModel {
  final String title;
  final String subtitle;
  final String cta;
  final List<Color> colors;

  const _PromoBannerModel({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.colors,
  });
}
