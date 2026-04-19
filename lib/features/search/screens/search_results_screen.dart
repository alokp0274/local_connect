// features/search/screens/search_results_screen.dart
// Feature: Search & Discovery
//
// Search results list with provider cards, sort controls, and empty state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/search_engine.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/shared/widgets/provider_card.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/features/chat/screens/chat_detail_screen.dart';
import 'package:local_connect/features/provider/screens/provider_detail_screen.dart';

/// Premium search results with smart matching, quick filters, sort, and
/// hyperlocal contextual headers.
class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  static const _userPincode = '110001';

  late List<ServiceProvider> _results;
  final Set<String> _favoriteIds = <String>{};
  final Set<String> _activeFilters = <String>{};
  String _sortBy = 'best_match';
  bool _isLoading = true;

  static const _filterOptions = <_FilterDef>[
    _FilterDef('verified', 'Verified', Icons.verified_rounded),
    _FilterDef('available_now', 'Available Now', Icons.schedule_rounded),
    _FilterDef('under_500', 'Under \u20b9500', Icons.savings_rounded),
    _FilterDef('top_rated', 'Top Rated', Icons.star_rounded),
    _FilterDef('nearby', 'Nearby', Icons.near_me_rounded),
    _FilterDef('fast_response', 'Fast Response', Icons.flash_on_rounded),
    _FilterDef('same_pin', 'Same PIN', Icons.pin_drop_rounded),
    _FilterDef('individual', 'Individual', Icons.person_rounded),
    _FilterDef('company', 'Company', Icons.business_rounded),
  ];

  static const _sortOptions = <_SortDef>[
    _SortDef('best_match', 'Best Match', Icons.auto_awesome_rounded),
    _SortDef('nearest', 'Nearest', Icons.near_me_rounded),
    _SortDef('top_rated', 'Top Rated', Icons.star_rounded),
    _SortDef('lowest_price', 'Lowest Price', Icons.savings_rounded),
    _SortDef('fastest_response', 'Fastest Response', Icons.flash_on_rounded),
    _SortDef(
      'most_experienced',
      'Most Experienced',
      Icons.workspace_premium_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  Future<void> _runSearch() async {
    setState(() => _isLoading = true);
    // Simulate a fast load feel
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    _results = SearchEngine.search(
      query: widget.query,
      userPincode: _userPincode,
      activeFilters: _activeFilters,
      sortBy: _sortBy,
    );
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    _results = SearchEngine.search(
      query: widget.query,
      userPincode: _userPincode,
      activeFilters: _activeFilters,
      sortBy: _sortBy,
    );
    setState(() {});
  }

  void _toggleFilter(String key) {
    HapticFeedback.selectionClick();
    if (_activeFilters.contains(key)) {
      _activeFilters.remove(key);
    } else {
      _activeFilters.add(key);
    }
    _applyFilters();
  }

  void _clearFilters() {
    HapticFeedback.selectionClick();
    _activeFilters.clear();
    _applyFilters();
  }

  void _setSort(String key) {
    HapticFeedback.selectionClick();
    _sortBy = key;
    _applyFilters();
    Navigator.pop(context);
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

  void _toggleFavorite(ServiceProvider p) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_favoriteIds.contains(p.id)) {
        _favoriteIds.remove(p.id);
      } else {
        _favoriteIds.add(p.id);
      }
    });
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SortBottomSheet(
        options: _sortOptions,
        selected: _sortBy,
        onSelect: _setSort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final localHeader = SearchEngine.getLocalHeader(
      widget.query,
      _userPincode,
      _results.length,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── TOP BAR ──
              _buildTopBar(tt, pad),

              // ── FILTER CHIPS ──
              _buildFilterChips(pad),

              // ── META BAR ──
              if (!_isLoading) _buildMetaBar(tt, pad, localHeader),

              // ── RESULTS ──
              Expanded(
                child: _isLoading
                    ? _buildSkeletonLoading(pad)
                    : _results.isEmpty
                    ? _buildEmptyState(tt, pad)
                    : _buildResultsList(pad),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad - 4, 6, pad, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textPrimary,
              size: 22,
            ),
            splashRadius: 22,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                color: AppTheme.surfaceElevated,
                border: Border.all(color: AppTheme.border, width: 0.7),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppTheme.accentGold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.query,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.edit_rounded,
                      color: AppTheme.textMuted,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ActionButton(icon: Icons.sort_rounded, onTap: _showSortSheet),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildFilterChips(double pad) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: pad),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filterOptions.length + (_activeFilters.isNotEmpty ? 1 : 0),
        separatorBuilder: (_, i2) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          // Clear all button
          if (_activeFilters.isNotEmpty && i == 0) {
            return _FilterChip(
              label: 'Clear All',
              icon: Icons.close_rounded,
              isActive: false,
              isDanger: true,
              onTap: _clearFilters,
            );
          }
          final idx = _activeFilters.isNotEmpty ? i - 1 : i;
          final f = _filterOptions[idx];
          return _FilterChip(
            label: f.label,
            icon: f.icon,
            isActive: _activeFilters.contains(f.key),
            onTap: () => _toggleFilter(f.key),
          );
        },
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildMetaBar(TextTheme tt, double pad, String localHeader) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localHeader,
            style: tt.titleMedium?.copyWith(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${_results.length} provider${_results.length == 1 ? '' : 's'} found',
                style: tt.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              if (_activeFilters.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    '${_activeFilters.length} filter${_activeFilters.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: _showSortSheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sort_rounded,
                      size: 14,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _sortOptions.firstWhere((s) => s.key == _sortBy).label,
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildResultsList(double pad) {
    return RefreshIndicator(
      onRefresh: _runSearch,
      color: AppTheme.accentGold,
      backgroundColor: AppTheme.surfaceCard,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(pad, 12, pad, 24),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _results.length,
        itemBuilder: (_, i) {
          final p = _results[i];
          return ProviderCard(
            provider: p,
            index: i,
            isFavorite: _favoriteIds.contains(p.id),
            onFavoriteTap: () => _toggleFavorite(p),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProviderDetailScreen(provider: p),
              ),
            ),
            onCallTap: () => _makeCall(p.phone),
            onChatTap: () => _openChat(p),
            onBookTap: () => Navigator.pushNamed(
              context,
              AppRoutes.selectSlot,
              arguments: {'providerName': p.name},
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoading(double pad) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (_, i) =>
          Container(
                height: 160,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 12,
                                  color: AppTheme.surfaceElevated,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 80,
                                  height: 10,
                                  color: AppTheme.surfaceElevated,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        height: 10,
                        color: AppTheme.surfaceElevated,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 10,
                        color: AppTheme.surfaceElevated,
                      ),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                color: AppTheme.glassWhite.withAlpha(30),
              ),
    );
  }

  Widget _buildEmptyState(TextTheme tt, double pad) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppTheme.accentGold,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No providers found',
            style: tt.headlineMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find providers for "${widget.query}" with your current filters.',
            style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Quick actions
          _EmptyAction(
            icon: Icons.pin_drop_rounded,
            label: 'Try nearby pincode',
            color: AppTheme.accentBlue,
            onTap: () => Navigator.pop(context),
          ),
          _EmptyAction(
            icon: Icons.search_rounded,
            label: 'Try another service',
            color: AppTheme.accentTeal,
            onTap: () => Navigator.pop(context),
          ),
          _EmptyAction(
            icon: Icons.category_rounded,
            label: 'Browse categories',
            color: AppTheme.accentPurple,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          if (_activeFilters.isNotEmpty)
            _EmptyAction(
              icon: Icons.filter_alt_off_rounded,
              label: 'Clear all filters',
              color: AppTheme.accentCoral,
              onTap: _clearFilters,
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Provider request feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Request a Provider'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.textOnAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
    );
  }
}

// ═════════════════════════════════════════
// REUSABLE WIDGETS
// ═════════════════════════════════════════

class _FilterDef {
  final String key;
  final String label;
  final IconData icon;
  const _FilterDef(this.key, this.label, this.icon);
}

class _SortDef {
  final String key;
  final String label;
  final IconData icon;
  const _SortDef(this.key, this.label, this.icon);
}

class _FilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDanger;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isDanger = false,
  });
  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDanger
        ? AppTheme.accentCoral
        : widget.isActive
        ? AppTheme.accentGold
        : AppTheme.textSecondary;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppTheme.accentGold.withAlpha(20)
                : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: widget.isActive
                  ? AppTheme.accentGold.withAlpha(100)
                  : widget.isDanger
                  ? AppTheme.accentCoral.withAlpha(80)
                  : AppTheme.border,
              width: widget.isActive ? 1.0 : 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: GlassContainer(
          width: 40,
          height: 40,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Icon(widget.icon, color: AppTheme.accentGold, size: 20),
        ),
      ),
    );
  }
}

class _EmptyAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _EmptyAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(10),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(color: color.withAlpha(40), width: 0.6),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withAlpha(120),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortBottomSheet extends StatelessWidget {
  final List<_SortDef> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _SortBottomSheet({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, bottom + 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: AppTheme.glassBorder.withAlpha(40),
          width: 0.7,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 30,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 8),
            child: Row(
              children: [
                Text(
                  'Sort Results',
                  style: tt.headlineMedium?.copyWith(fontSize: 18),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.surfaceDivider),
          ...options.map((o) {
            final isSelected = o.key == selected;
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: pad),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentGold.withAlpha(20)
                      : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
                child: Icon(
                  o.icon,
                  color: isSelected ? AppTheme.accentGold : AppTheme.textMuted,
                  size: 18,
                ),
              ),
              title: Text(
                o.label,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.accentGold
                      : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppTheme.accentGold,
                      size: 20,
                    )
                  : null,
              onTap: () => onSelect(o.key),
            );
          }),
          SizedBox(height: bottom > 0 ? 8 : 16),
        ],
      ),
    );
  }
}
