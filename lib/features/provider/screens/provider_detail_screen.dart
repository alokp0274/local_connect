// features/provider/screens/provider_detail_screen.dart
// Feature: Provider Browsing & Details
//
// Detailed provider profile with services, reviews, gallery, and booking CTA.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/shared/widgets/provider_card.dart';
import 'package:local_connect/features/chat/screens/chat_detail_screen.dart';
import 'package:local_connect/features/provider/screens/reviews_screen.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ServiceProvider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBottomBar = true;
  bool _isFavorite = false;
  int _selectedPackage = 1;
  int _selectedSlot = 0;
  String _reviewSort = 'Latest';

  final List<Map<String, dynamic>> _packages = const [
    {
      'name': 'Inspection Visit',
      'price': '\u20b9399',
      'duration': '30-45 min',
      'features': [
        'Site inspection',
        'Problem diagnosis',
        'Cost estimate',
        'Quick fix if possible',
      ],
      'badge': '',
    },
    {
      'name': 'Standard Repair',
      'price': '\u20b9899',
      'duration': '60-90 min',
      'features': [
        'Full repair work',
        'Parts replacement',
        'Safety testing',
        'Clean-up included',
      ],
      'badge': 'Most Popular',
    },
    {
      'name': 'Premium Full Service',
      'price': '\u20b91,499',
      'duration': '2-3 hrs',
      'features': [
        'Complete overhaul',
        'All parts included',
        'Priority support',
        '30-day warranty',
        'Follow-up visit',
      ],
      'badge': 'Best Value',
    },
  ];

  final List<String> _slotChips = const [
    '10:00 AM',
    '11:30 AM',
    '01:00 PM',
    '03:30 PM',
    '06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    final shouldShow = direction != ScrollDirection.reverse;
    if (shouldShow != _showBottomBar) {
      setState(() => _showBottomBar = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  ServiceProvider get provider => widget.provider;

  Future<void> _makeCall() async {
    final uri = Uri.parse('tel:${provider.phone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openChat() {
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

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${provider.name} profile refreshed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  double get _averageRating {
    if (provider.reviews.isEmpty) return provider.rating;
    final sum = provider.reviews.fold<double>(0, (acc, r) => acc + r.rating);
    return sum / provider.reviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in provider.reviews) {
      final star = review.rating.round().clamp(1, 5);
      dist[star] = dist[star]! + 1;
    }
    return dist;
  }

  List<ProviderReview> get _sortedReviews {
    final list = [...provider.reviews];
    if (_reviewSort == 'Top Rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  List<ServiceProvider> get _similarProviders {
    return dummyProviders
        .where(
          (p) =>
              p.id != provider.id &&
              (p.service == provider.service ||
                  p.providerType == provider.providerType),
        )
        .take(6)
        .toList();
  }

  String get _responseTime {
    if (provider.responseTimeMinutes > 0) {
      return '~${provider.responseTimeMinutes} min';
    }
    if (provider.rating >= 4.8) return 'within 5 mins';
    if (provider.rating >= 4.5) return 'within 10 mins';
    if (provider.rating >= 4.0) return 'within 20 mins';
    return 'within 30 mins';
  }

  int get _jobsCompleted {
    if (provider.jobsCompleted > 0) return provider.jobsCompleted;
    return provider.reviewCount * 6;
  }

  int get _yearsExp {
    final match = RegExp(r'\d+').firstMatch(provider.experience);
    return int.tryParse(match?.group(0) ?? '0') ?? 0;
  }

  Future<void> _showPortfolioImage(int index) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGold.withAlpha(80),
                    AppTheme.accentBlue.withAlpha(100),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${provider.service} Work ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      index.isEven ? 'Before' : 'After',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.accentGold,
          backgroundColor: AppTheme.surface,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── HERO SECTION ──
              SliverAppBar(
                expandedHeight: 370,
                pinned: true,
                backgroundColor: AppTheme.surface,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Share link copied (mock)'),
                          ),
                        );
                    },
                    icon: const Icon(Icons.share_rounded),
                    tooltip: 'Share',
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isFavorite = !_isFavorite);
                    },
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite ? AppTheme.accentCoral : Colors.white,
                    ),
                    tooltip: 'Favorite',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroBackground(screenW),
                ),
              ),

              // ── BODY CONTENT ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── LOCAL TRUST BANNER ──
                      _buildLocalTrustBanner(),
                      const SizedBox(height: 22),

                      // ── ABOUT + CREDIBILITY ──
                      _buildAboutSection(tt),
                      const SizedBox(height: 22),

                      // ── WHY CHOOSE ME ──
                      _buildWhyChooseMe(tt),
                      const SizedBox(height: 22),

                      // ── SERVICE AREA FOCUS ──
                      _buildServiceArea(tt),
                      const SizedBox(height: 22),

                      // ── SERVICES & PRICING ──
                      _buildServicesSection(tt),
                      const SizedBox(height: 22),

                      // ── AVAILABILITY ──
                      _buildAvailability(tt),
                      const SizedBox(height: 22),

                      // ── GALLERY / PORTFOLIO ──
                      _buildGallery(tt),
                      const SizedBox(height: 22),

                      // ── REVIEWS ──
                      _buildReviews(tt),

                      // ── SIMILAR PROVIDERS ──
                      if (_similarProviders.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _buildSimilarProviders(tt, screenW),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyActionBar(),
    );
  }

  // ────────────────────────────────────────────
  // HERO BACKGROUND
  // ────────────────────────────────────────────
  Widget _buildHeroBackground(double screenW) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -28,
          right: -18,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(40),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withAlpha(30),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            gradient: AppTheme.surfaceGradient,
            border: Border.all(color: AppTheme.border, width: 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'provider-avatar-${provider.id}',
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMD,
                          ),
                          border: Border.all(
                            color: provider.isVerified
                                ? AppTheme.accentBlue.withAlpha(100)
                                : AppTheme.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            provider.name.isNotEmpty
                                ? provider.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  provider.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (provider.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppTheme.accentBlue,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.service,
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: provider.isOnline
                                          ? AppTheme.accentTeal
                                          : AppTheme.textMuted,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scale(
                                    duration: 750.ms,
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.22, 1.22),
                                  ),
                              const SizedBox(width: 6),
                              Text(
                                provider.isOnline
                                    ? 'Available now'
                                    : provider.availability,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.route_rounded,
                                size: 12,
                                color: AppTheme.accentBlue,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                provider.distance,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _HeroStat(
                      icon: Icons.star_rounded,
                      label: 'Rating',
                      value: _averageRating.toStringAsFixed(1),
                      color: AppTheme.accentGold,
                    ),
                    _HeroStat(
                      icon: Icons.work_history_rounded,
                      label: 'Jobs',
                      value: '$_jobsCompleted+',
                      color: AppTheme.accentTeal,
                    ),
                    _HeroStat(
                      icon: Icons.calendar_month_rounded,
                      label: 'Years',
                      value: '${_yearsExp}y',
                      color: AppTheme.accentPurple,
                    ),
                    _HeroStat(
                      icon: Icons.flash_on_rounded,
                      label: 'Response',
                      value: _responseTime,
                      color: AppTheme.accentBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // LOCAL TRUST BANNER
  // ────────────────────────────────────────────
  Widget _buildLocalTrustBanner() {
    final signals = <String>[];
    if (provider.hiredNearbyCount > 0) {
      signals.add('${provider.hiredNearbyCount} people hired nearby');
    }
    if (provider.rating >= 4.5 && provider.pincode.isNotEmpty) {
      signals.add('Top rated in PIN ${provider.pincode}');
    }
    if (provider.responseTimeMinutes <= 10) {
      signals.add('Responds in $_responseTime');
    }
    if (provider.repeatClientPercent > 70) {
      signals.add('${provider.repeatClientPercent}% repeat clients');
    }
    if (signals.isEmpty) {
      signals.add('Serving your pincode');
      signals.add('Trusted local provider');
    }

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      color: AppTheme.accentTeal.withAlpha(10),
      border: Border.all(color: AppTheme.accentTeal.withAlpha(30), width: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppTheme.accentTeal,
                size: 15,
              ),
              SizedBox(width: 6),
              Text(
                'Local Trust Signals',
                style: TextStyle(
                  color: AppTheme.accentTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: signals.map((s) => _LocalSignalChip(text: s)).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1);
  }

  // ────────────────────────────────────────────
  // ABOUT + CREDIBILITY
  // ────────────────────────────────────────────
  Widget _buildAboutSection(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'About Provider',
          subtitle: 'Professional profile and trust summary',
        ),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(provider.description, style: tt.bodyMedium),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (provider.isVerified)
                    _CredBadge(
                      icon: Icons.verified_rounded,
                      text: 'ID Verified',
                      color: AppTheme.accentBlue,
                    ),
                  if (provider.backgroundChecked)
                    _CredBadge(
                      icon: Icons.shield_rounded,
                      text: 'Background Checked',
                      color: AppTheme.accentTeal,
                    ),
                  _CredBadge(
                    icon: Icons.replay_rounded,
                    text: '${provider.repeatClientPercent}% Repeat Clients',
                    color: AppTheme.accentGold,
                  ),
                  _CredBadge(
                    icon: Icons.check_circle_rounded,
                    text: '${provider.completionRate}% Completion',
                    color: AppTheme.accentTeal,
                  ),
                  _CredBadge(
                    icon: Icons.translate_rounded,
                    text: provider.languages.join(', '),
                    color: AppTheme.accentPurple,
                  ),
                ],
              ),
              if (provider.certifications.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Certifications',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ...provider.certifications.map(
                  (cert) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppTheme.accentGold,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cert,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.12),
      ],
    );
  }

  // ────────────────────────────────────────────
  // WHY CHOOSE ME
  // ────────────────────────────────────────────
  Widget _buildWhyChooseMe(TextTheme tt) {
    final highlights = [
      _HighlightItem(
        Icons.flash_on_rounded,
        'Fast Response',
        'Typically responds $_responseTime',
        AppTheme.accentGold,
      ),
      _HighlightItem(
        Icons.workspace_premium_rounded,
        'Experienced',
        '${provider.experience} of professional service',
        AppTheme.accentPurple,
      ),
      _HighlightItem(
        Icons.star_rounded,
        'Highly Rated',
        '${_averageRating.toStringAsFixed(1)} from ${provider.reviewCount} reviews',
        AppTheme.accentGold,
      ),
      _HighlightItem(
        Icons.repeat_rounded,
        'Loyal Clients',
        '${provider.repeatClientPercent}% clients come back',
        AppTheme.accentTeal,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Why Choose ${provider.name.split(' ').first}',
          subtitle: 'Key strengths and service quality',
        ),
        const SizedBox(height: 10),
        ...highlights.asMap().entries.map((entry) {
          final i = entry.key;
          final h = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:
                GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: h.color.withAlpha(20),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusXS,
                              ),
                            ),
                            child: Icon(h.icon, color: h.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.title,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  h.subtitle,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: (200 + i * 60).ms)
                    .fadeIn(duration: 280.ms)
                    .slideX(begin: -0.05),
          );
        }),
      ],
    );
  }

  // ────────────────────────────────────────────
  // SERVICE AREA FOCUS
  // ────────────────────────────────────────────
  Widget _buildServiceArea(TextTheme tt) {
    final areas = provider.serviceAreas.isNotEmpty
        ? provider.serviceAreas
        : ['Your area', 'Nearby localities'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Service Coverage',
          subtitle: 'Areas this provider serves',
        ),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppTheme.accentBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serving PIN ${provider.pincode}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Available today in your area',
                          style: const TextStyle(
                            color: AppTheme.accentTeal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: areas
                    .map(
                      (area) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          border: Border.all(
                            color: AppTheme.border,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppTheme.accentBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              area,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (provider.estimatedArrival.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(
                      color: AppTheme.accentTeal.withAlpha(30),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_run_rounded,
                        size: 14,
                        color: AppTheme.accentTeal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Est. arrival: ${provider.estimatedArrival}',
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.1),
      ],
    );
  }

  // ────────────────────────────────────────────
  // SERVICES & PRICING
  // ────────────────────────────────────────────
  Widget _buildServicesSection(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Services & Pricing',
          subtitle: 'Choose a package that fits your need',
        ),
        const SizedBox(height: 10),
        ..._packages.asMap().entries.map((entry) {
          final i = entry.key;
          final pkg = entry.value;
          final selected = _selectedPackage == i;
          final badge = pkg['badge'] as String;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPackage = i);
            },
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              margin: const EdgeInsets.only(bottom: 10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    gradient: selected
                        ? AppTheme.primarySubtleGradient
                        : AppTheme.surfaceGradient,
                    border: Border.all(
                      color: selected ? AppTheme.accentGold : AppTheme.border,
                      width: selected ? 1.0 : 0.5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pkg['name'] as String,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              pkg['price'] as String,
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pkg['duration'] as String,
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...(pkg['features'] as List<String>).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: selected
                                      ? AppTheme.accentGold
                                      : AppTheme.accentTeal,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: AppTheme.durationFast,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? AppTheme.primaryGradient
                                  : null,
                              color: selected ? null : AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Text(
                              selected ? 'Selected \u2713' : 'Select',
                              style: TextStyle(
                                color: selected
                                    ? AppTheme.textOnAccent
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (badge.isNotEmpty)
                    Positioned(
                      top: -8,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          boxShadow: AppTheme.softGlow,
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: AppTheme.textOnAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ────────────────────────────────────────────
  // AVAILABILITY
  // ────────────────────────────────────────────
  Widget _buildAvailability(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Availability',
          subtitle: 'Book instantly from upcoming slots',
        ),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppTheme.accentTeal,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Available today \u2022 Next slot in 35 mins',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slotChips.asMap().entries.map((entry) {
                  final i = entry.key;
                  final slot = entry.value;
                  final selected = _selectedSlot == i;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSlot = i);
                    },
                    child: AnimatedContainer(
                      duration: AppTheme.durationFast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected ? AppTheme.primaryGradient : null,
                        color: selected ? null : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: selected
                              ? AppTheme.textOnAccent
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // GALLERY / PORTFOLIO
  // ────────────────────────────────────────────
  Widget _buildGallery(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Work Showcase',
          subtitle: 'Before & after portfolio',
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final isBefore = i.isEven;
              return GestureDetector(
                    onTap: () => _showPortfolioImage(i),
                    child: Container(
                      width: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        gradient: LinearGradient(
                          colors: isBefore
                              ? [
                                  AppTheme.accentBlue.withAlpha(90),
                                  AppTheme.accentTeal.withAlpha(90),
                                ]
                              : [
                                  AppTheme.accentGold.withAlpha(80),
                                  AppTheme.accentCoral.withAlpha(80),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isBefore
                                      ? Icons.home_repair_service_rounded
                                      : Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isBefore ? 'Before' : 'After',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Text(
                                '${i + 1}/6',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (i * 50).ms)
                  .fadeIn(duration: 240.ms)
                  .slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // REVIEWS
  // ────────────────────────────────────────────
  Widget _buildReviews(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Reviews & Ratings',
          subtitle: '${provider.reviews.length} verified customer ratings',
        ),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < _averageRating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppTheme.accentGold,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.reviewCount} reviews',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final total = provider.reviews.length;
                        final count = _ratingDistribution[star] ?? 0;
                        final progress = total == 0 ? 0.0 : count / total;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                '$star',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: AppTheme.accentGold,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: progress),
                                    duration: const Duration(milliseconds: 550),
                                    builder: (context, value, child) {
                                      return LinearProgressIndicator(
                                        value: value,
                                        minHeight: 6,
                                        backgroundColor:
                                            AppTheme.surfaceDivider,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              AppTheme.accentGold,
                                            ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 18,
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 10,
                                  ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  _ReviewSortChip(
                    label: 'Latest',
                    selected: _reviewSort == 'Latest',
                    onTap: () => setState(() => _reviewSort = 'Latest'),
                  ),
                  const SizedBox(width: 8),
                  _ReviewSortChip(
                    label: 'Top Rated',
                    selected: _reviewSort == 'Top Rated',
                    onTap: () => setState(() => _reviewSort = 'Top Rated'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._sortedReviews
                  .take(3)
                  .map(
                    (review) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppTheme.accentGold.withAlpha(
                                  25,
                                ),
                                child: Text(
                                  review.reviewerInitials,
                                  style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.reviewerName,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Text(
                                      'Verified Customer',
                                      style: TextStyle(
                                        color: AppTheme.accentTeal,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < review.rating.round()
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: AppTheme.accentGold,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(review.comment, style: tt.bodyMedium),
                        ],
                      ),
                    ),
                  ),
              if (provider.reviews.length > 3)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReviewsScreen(provider: provider),
                      ),
                    ),
                    child: const Text('See all reviews \u2192'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // SIMILAR PROVIDERS
  // ────────────────────────────────────────────
  Widget _buildSimilarProviders(TextTheme tt, double screenW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Similar Providers',
          subtitle: 'Nearby alternatives in this category',
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 310,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _similarProviders.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = _similarProviders[i];
              return SizedBox(
                width: screenW * 0.84,
                child: ProviderCard(
                  provider: item,
                  index: i,
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ProviderDetailScreen(provider: item),
                    ),
                  ),
                  onCallTap: () async {
                    final uri = Uri.parse('tel:${item.phone}');
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  onChatTap: () {
                    var thread = activeChats.cast<ChatThread?>().firstWhere(
                      (t) => t!.provider.id == item.id,
                      orElse: () => null,
                    );
                    if (thread == null) {
                      thread = ChatThread(provider: item, messages: []);
                      activeChats.add(thread);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(thread: thread!),
                      ),
                    );
                  },
                  onBookTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.selectSlot,
                    arguments: {'providerName': item.name},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // STICKY ACTION BAR
  // ────────────────────────────────────────────
  Widget _buildStickyActionBar() {
    return AnimatedSlide(
      duration: AppTheme.durationMedium,
      offset: _showBottomBar ? Offset.zero : const Offset(0, 1.2),
      child: AnimatedOpacity(
        duration: AppTheme.durationMedium,
        opacity: _showBottomBar ? 1 : 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: GlassContainer(
              padding: const EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              gradient: AppTheme.surfaceGradient,
              boxShadow: AppTheme.elevatedShadow,
              border: Border.all(color: AppTheme.border, width: 0.7),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomAction(
                      label: 'Chat',
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppTheme.accentTeal,
                      onTap: _openChat,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BottomAction(
                      label: 'Call',
                      icon: Icons.phone_rounded,
                      color: AppTheme.accentGold,
                      onTap: _makeCall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _BottomAction(
                      label: 'Book Now',
                      icon: Icons.event_available_rounded,
                      color: AppTheme.accentBlue,
                      isPrimary: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.selectSlot,
                        arguments: {'providerName': provider.name},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SUPPORTING WIDGETS
// ─────────────────────────────────────────────────────

class _HighlightItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _HighlightItem(this.icon, this.title, this.subtitle, this.color);
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.headlineMedium),
        const SizedBox(height: 2),
        Text(subtitle, style: tt.labelSmall),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CredBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _CredBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withAlpha(50), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalSignalChip extends StatelessWidget {
  final String text;
  const _LocalSignalChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 11,
            color: AppTheme.accentTeal,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ReviewSortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.textOnAccent : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;
  const _BottomAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<_BottomAction> createState() => _BottomActionState();
}

class _BottomActionState extends State<_BottomAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [widget.color, widget.color.withAlpha(180)],
                  )
                : null,
            color: widget.isPrimary ? null : widget.color.withAlpha(24),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(
              color: widget.color.withAlpha(widget.isPrimary ? 0 : 110),
              width: 0.7,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.white : widget.color,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isPrimary ? Colors.white : widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
