// features/profile/screens/profile_screen.dart
// Feature: User Profile & Account
//
// User profile overview with avatar, stats, settings links, and mode switch.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/account_mode.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/provider_mode/widgets/provider_mode_content.dart';
import 'package:local_connect/features/profile/screens/edit_profile_screen.dart';
import 'package:local_connect/features/profile/screens/favorites_screen.dart';
import 'package:local_connect/features/jobs/screens/my_requests_screen.dart';
import 'package:local_connect/features/jobs/data/job_post_data.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/features/profile/screens/my_reviews_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_onboarding_screen.dart';
import 'package:local_connect/features/profile/screens/saved_addresses_screen.dart';
import 'package:local_connect/features/settings/screens/settings_screen.dart';

// ─────────────────────────────────────────────────────────
//  PROFILE SCREEN — Dual Mode (User / Provider)
// ─────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _isOnline = true;
  late AnimationController _glowController;
  late AnimationController _switchAnimController;
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _switchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0, // start fully visible
    );
    accountMode.addListener(_onModeChange);
  }

  @override
  void dispose() {
    accountMode.removeListener(_onModeChange);
    _glowController.dispose();
    _switchAnimController.dispose();
    super.dispose();
  }

  void _onModeChange() {
    if (mounted) setState(() {});
  }

  Color get _modeAccent =>
      accountMode.isProviderMode ? AppTheme.accentTeal : AppTheme.accentGold;

  Future<void> _handleModeSwitch() async {
    if (_isSwitching) return;

    // If switching to provider and no profile created, open onboarding
    if (accountMode.isUserMode && !accountMode.providerProfileCreated) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const ProviderOnboardingScreen()),
      );
      if (result == true && mounted) {
        _animateSwitch();
        _showSwitchSnackbar(AccountMode.provider);
      }
      return;
    }

    _animateSwitch();
    accountMode.toggleMode();
    _showSwitchSnackbar(accountMode.mode);
  }

  Future<void> _animateSwitch() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSwitching = true);
    await _switchAnimController.reverse();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    await _switchAnimController.forward();
    setState(() => _isSwitching = false);
  }

  void _showSwitchSnackbar(AccountMode mode) {
    if (!mounted) return;
    final isProvider = mode == AccountMode.provider;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceElevated,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isProvider ? AppTheme.accentTeal : AppTheme.accentGold)
                    .withAlpha(25),
                borderRadius: BorderRadius.circular(AppTheme.radiusXS),
              ),
              child: Icon(
                isProvider ? Icons.business_rounded : Icons.person_rounded,
                color: isProvider ? AppTheme.accentTeal : AppTheme.accentGold,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isProvider
                    ? 'Switched to Provider Mode'
                    : 'Switched to User Mode',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: RefreshIndicator(
          color: _modeAccent,
          backgroundColor: AppTheme.surfaceCard,
          onRefresh: () async =>
              await Future<void>.delayed(const Duration(seconds: 1)),
          child: FadeTransition(
            opacity: _switchAnimController,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // ── Avatar + Name (shared) ──
                    _buildSharedHero(tt, pad),

                    // ── Mode Switch Card ──
                    _buildModeSwitchCard(tt, pad),

                    // ── Mode-specific content ──
                    if (accountMode.isUserMode)
                      _buildUserContent(tt, pad)
                    else
                      ProviderModeContent(
                        onEditProfile: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                        onSettings: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                      ),

                    // ── Shared footer ──
                    _buildSharedFooter(tt, pad),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── SHARED HERO (avatar, name, badge — always visible) ──
  Widget _buildSharedHero(TextTheme tt, double pad) {
    final isProvider = accountMode.isProviderMode;
    final accentColor = _modeAccent;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, isCompact ? 50 : 60, pad, 12),
      child: Column(
        children: [
          // Avatar with animated glow
          AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withAlpha(
                            (60 * _glowController.value).round(),
                          ),
                          blurRadius: 40 + (20 * _glowController.value),
                          spreadRadius: 4 + (8 * _glowController.value),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  child: Hero(
                    tag: 'profile-avatar',
                    child: AnimatedContainer(
                      duration: AppTheme.durationMedium,
                      width: isCompact ? 90 : 100,
                      height: isCompact ? 90 : 100,
                      decoration: BoxDecoration(
                        gradient: isProvider
                            ? AppTheme.tealGradient
                            : AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: isProvider
                            ? AppTheme.tealGlow
                            : AppTheme.softGlow,
                      ),
                      child: Icon(
                        isProvider ? Icons.business_rounded : Icons.person,
                        color: isProvider
                            ? Colors.white
                            : AppTheme.textOnAccent,
                        size: isCompact ? 42 : 48,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 350.ms),
          SizedBox(height: isCompact ? 12 : 16),

          // Name
          Text(
            isProvider && accountMode.providerName.isNotEmpty
                ? accountMode.providerName
                : 'John Doe',
            style: tt.displayMedium?.copyWith(fontSize: isCompact ? 22 : 26),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 6),

          // Mode badge
          AnimatedContainer(
            duration: AppTheme.durationMedium,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              gradient: isProvider
                  ? LinearGradient(
                      colors: [
                        AppTheme.accentTeal.withAlpha(30),
                        AppTheme.accentTeal.withAlpha(12),
                      ],
                    )
                  : AppTheme.primarySubtleGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: accentColor.withAlpha(100), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProvider
                      ? Icons.verified_rounded
                      : Icons.workspace_premium_rounded,
                  color: accentColor,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  isProvider ? 'Professional Account' : 'Gold Member',
                  style: tt.labelLarge?.copyWith(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2),
          const SizedBox(height: 6),

          // Location
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppTheme.textMuted,
                size: 14,
              ),
              const SizedBox(width: 3),
              Text(
                'New Delhi, India',
                style: tt.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
          SizedBox(height: isCompact ? 10 : 14),

          // Status + Edit
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isOnline = !_isOnline);
                },
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  color: _isOnline
                      ? AppTheme.accentTeal.withAlpha(30)
                      : AppTheme.glassDark,
                  border: Border.all(
                    color: _isOnline
                        ? AppTheme.accentTeal
                        : AppTheme.border,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: AppTheme.durationFast,
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _isOnline
                              ? AppTheme.accentTeal
                              : AppTheme.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isOnline
                              ? AppTheme.accentTeal
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: accentColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  // ── MODE SWITCH CARD ──
  Widget _buildModeSwitchCard(TextTheme tt, double pad) {
    final isProvider = accountMode.isProviderMode;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, 16),
      child: GestureDetector(
        onTap: _isSwitching ? null : _handleModeSwitch,
        child: AnimatedContainer(
          duration: AppTheme.durationMedium,
          padding: EdgeInsets.all(isCompact ? 14 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isProvider
                  ? [
                      AppTheme.accentGold.withAlpha(12),
                      AppTheme.accentGold.withAlpha(5),
                    ]
                  : [
                      AppTheme.accentTeal.withAlpha(12),
                      AppTheme.accentTeal.withAlpha(5),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: isProvider
                  ? AppTheme.accentGold.withAlpha(50)
                  : AppTheme.accentTeal.withAlpha(50),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: (isProvider ? AppTheme.accentGold : AppTheme.accentTeal)
                    .withAlpha(15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon for target mode
              AnimatedContainer(
                duration: AppTheme.durationMedium,
                width: isCompact ? 42 : 48,
                height: isCompact ? 42 : 48,
                decoration: BoxDecoration(
                  color:
                      (isProvider ? AppTheme.accentGold : AppTheme.accentTeal)
                          .withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color:
                        (isProvider ? AppTheme.accentGold : AppTheme.accentTeal)
                            .withAlpha(60),
                  ),
                ),
                child: Icon(
                  isProvider ? Icons.person_rounded : Icons.business_rounded,
                  color: isProvider ? AppTheme.accentGold : AppTheme.accentTeal,
                  size: isCompact ? 20 : 22,
                ),
              ),
              SizedBox(width: isCompact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProvider
                          ? 'Switch to User Mode'
                          : 'Switch to Provider Mode',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isProvider
                            ? AppTheme.accentGold
                            : AppTheme.accentTeal,
                        fontSize: isCompact ? 13 : 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isProvider
                          ? 'Find trusted nearby services'
                          : 'Grow your business & receive leads',
                      style: tt.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: isCompact ? 11 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: AppTheme.durationFast,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (isProvider ? AppTheme.accentGold : AppTheme.accentTeal)
                          .withAlpha(15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: isProvider ? AppTheme.accentGold : AppTheme.accentTeal,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06);
  }

  // ── USER MODE CONTENT ──
  Widget _buildUserContent(TextTheme tt, double pad) {
    return Column(
      children: [
        _buildInsightsSection(tt, pad),
        _buildQuickAccessGrid(tt, pad),
        _buildRecentActivity(tt, pad),
        _buildMenuSections(tt, pad),
      ],
    );
  }

  Widget _buildInsightsSection(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: Row(
          children: const [
            _InsightCard(
              icon: Icons.calendar_today_rounded,
              value: '24',
              label: 'Bookings',
              color: AppTheme.accentBlue,
            ),
            _InsightCard(
              icon: Icons.savings_rounded,
              value: '\u20b91,280',
              label: 'Saved',
              color: AppTheme.accentTeal,
            ),
            _InsightCard(
              icon: Icons.star_rounded,
              value: '8',
              label: 'Reviews',
              color: AppTheme.accentGold,
            ),
            _InsightCard(
              icon: Icons.favorite_rounded,
              value: '5',
              label: 'Favorites',
              color: AppTheme.accentCoral,
            ),
          ],
        ),
      ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildQuickAccessGrid(TextTheme tt, double pad) {
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;
    final items = [
      _QuickAction(
        icon: Icons.calendar_month_rounded,
        label: 'Bookings',
        color: AppTheme.accentBlue,
        onTap: () => Navigator.pushNamed(context, AppRoutes.mainShell),
      ),
      _QuickAction(
        icon: Icons.favorite_rounded,
        label: 'Favorites',
        color: AppTheme.accentCoral,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
      ),
      _QuickAction(
        icon: Icons.location_on_rounded,
        label: 'Addresses',
        color: AppTheme.accentTeal,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SavedAddressesScreen())),
      ),
      _QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
        color: AppTheme.accentGold,
        onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
      ),
      _QuickAction(
        icon: Icons.emoji_events_rounded,
        label: 'Rewards',
        color: AppTheme.accentPurple,
        onTap: () => Navigator.pushNamed(context, AppRoutes.rewards),
      ),
      _QuickAction(
        icon: Icons.headset_mic_rounded,
        label: 'Support',
        color: AppTheme.accentBlue,
        onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
      ),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: isCompact ? 1.0 : 1.15,
            children: List.generate(items.length, (i) {
              final item = items[i];
              return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      item.onTap();
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: item.color.withAlpha(25),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                            child: Icon(item.icon, color: item.color, size: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelLarge?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (350 + i * 60).ms)
                  .fadeIn(duration: 300.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    curve: Curves.easeOutBack,
                  );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: tt.headlineMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 14),
          const _ActivityTile(
                icon: Icons.calendar_today_rounded,
                iconColor: AppTheme.accentBlue,
                title: 'AC Service booked',
                subtitle: 'Rajesh Kumar \u2022 Yesterday',
                trailing: '\u20b9699',
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.05),
          const _ActivityTile(
                icon: Icons.star_rounded,
                iconColor: AppTheme.accentGold,
                title: 'Reviewed Priya Sharma',
                subtitle: 'Salon & Spa \u2022 2 days ago',
                trailing: '\u2b50 4.5',
              )
              .animate(delay: 560.ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.05),
          const _ActivityTile(
                icon: Icons.visibility_rounded,
                iconColor: AppTheme.accentPurple,
                title: 'Viewed Amit Singh',
                subtitle: 'Plumbing Expert \u2022 3 days ago',
                trailing: '',
              )
              .animate(delay: 620.ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.05),
        ],
      ),
    );
  }

  Widget _buildMenuSections(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _MenuItem(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavedAddressesScreen()),
            ),
          ),
          _MenuItem(
            icon: Icons.favorite_outline_rounded,
            title: 'Favorites',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
          _MenuItem(
            icon: Icons.star_outline_rounded,
            title: 'My Reviews',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MyReviewsScreen())),
          ),
          _MenuItem(
            icon: Icons.post_add_rounded,
            title: 'My Requests',
            subtitle: 'Track your job posts',
            badge:
                '${getJobsByStatus(JobStatus.active).length + getJobsByStatus(JobStatus.inProgress).length} active',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MyRequestsScreen())),
          ),
          _MenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            badge: '\u20b9520',
            onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
          ),
          _MenuItem(
            icon: Icons.emoji_events_outlined,
            title: 'Rewards',
            badge: '1,250 pts',
            onTap: () => Navigator.pushNamed(context, AppRoutes.rewards),
          ),
          const SizedBox(height: 16),
          Text(
            'Offers & Growth',
            style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.local_offer_outlined,
            title: 'Offers & Coupons',
            onTap: () => Navigator.pushNamed(context, AppRoutes.offers),
          ),
          _MenuItem(
            icon: Icons.people_outline_rounded,
            title: 'Refer & Earn',
            subtitle: 'Earn \u20b9100 per referral',
            onTap: () => Navigator.pushNamed(context, AppRoutes.referral),
          ),
          const SizedBox(height: 16),
          Text(
            'Support',
            style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          _MenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
          ),
          _MenuItem(
            icon: Icons.info_outline_rounded,
            title: 'About',
            onTap: () => Navigator.pushNamed(context, AppRoutes.aboutApp),
          ),
        ],
      ),
    );
  }

  // ── SHARED FOOTER ──
  Widget _buildSharedFooter(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.logout_rounded,
                color: AppTheme.accentCoral,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.accentCoral),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentCoral),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('LocalConnect v2.0.0', style: tt.labelSmall)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  HELPER WIDGETS (private)
// ─────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(22),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: tt.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: tt.labelLarge?.copyWith(
                color: AppTheme.accentGold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.surfaceElevated : AppTheme.glassDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: _isHovered
                ? AppTheme.glassBorder
                : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: AppTheme.accentGold),
          title: Text(widget.title, style: tt.titleMedium),
          subtitle: widget.subtitle != null
              ? Text(
                  widget.subtitle!,
                  style: tt.labelSmall?.copyWith(
                    color: AppTheme.accentTeal,
                    fontSize: 11,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
            ],
          ),
          onTap: widget.onTap ?? () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
        ),
      ),
    );
  }
}
