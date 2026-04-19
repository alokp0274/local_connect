// features/search/screens/search_screen.dart
// Feature: Search & Discovery
//
// Full search interface with live suggestions, recent/trending, and filters.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/search_engine.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

/// Premium full-screen search with recent, trending, live suggestions,
/// popular categories, and quick problem chips.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  List<SearchSuggestion> _suggestions = [];
  bool _isFocused = false;

  final List<String> _recentSearches = List.of(SearchEngine.recentSearches);

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _isFocused = _focus.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        _suggestions = SearchEngine.getSuggestions(value);
      });
    });
  }

  void _go(String query) {
    if (query.trim().isEmpty) return;
    // Add to recent
    _recentSearches.remove(query.trim());
    _recentSearches.insert(0, query.trim());
    if (_recentSearches.length > 8) _recentSearches.removeLast();
    Navigator.pushNamed(
      context,
      AppRoutes.searchResults,
      arguments: query.trim(),
    );
  }

  void _clearHistory() {
    HapticFeedback.selectionClick();
    setState(() => _recentSearches.clear());
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasQuery = _ctrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── TOP BAR ──
            Padding(
              padding: EdgeInsets.fromLTRB(pad - 4, 8, pad, 8),
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
                  Expanded(child: _buildSearchField()),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),

            // ── CONTENT ──
            Expanded(
              child: hasQuery && _suggestions.isNotEmpty
                  ? _buildSuggestionsList(tt, pad)
                  : hasQuery && _suggestions.isEmpty
                  ? _buildNoSuggestions(tt, pad)
                  : _buildIdleContent(tt, pad),
            ),

            SizedBox(height: bottomInset > 0 ? 0 : 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: AppTheme.durationFast,
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: _isFocused
              ? AppTheme.accentGold.withAlpha(120)
              : AppTheme.border,
          width: _isFocused ? 1.2 : 0.7,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.accentGold.withAlpha(20),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _ctrl,
        focusNode: _focus,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        textInputAction: TextInputAction.search,
        onChanged: _onChanged,
        onSubmitted: _go,
        decoration: InputDecoration(
          hintText: 'Search services, providers, problems...',
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.accentGold,
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_ctrl.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _ctrl.clear();
                    _onChanged('');
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textMuted,
                    size: 18,
                  ),
                  splashRadius: 18,
                ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Voice search coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                icon: const Icon(
                  Icons.mic_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
                splashRadius: 18,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // IDLE CONTENT (no query typed)
  // ─────────────────────────────────────
  Widget _buildIdleContent(TextTheme tt, double pad) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: pad),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 12),

        // Recent Searches
        if (_recentSearches.isNotEmpty) ...[
          _SectionHeader(
            title: 'Recent Searches',
            trailing: GestureDetector(
              onTap: _clearHistory,
              child: Text(
                'Clear',
                style: TextStyle(
                  color: AppTheme.accentGold.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._recentSearches
              .take(5)
              .toList()
              .asMap()
              .entries
              .map(
                (e) =>
                    _RecentTile(
                          text: e.value,
                          onTap: () => _go(e.value),
                          onRemove: () {
                            setState(() => _recentSearches.removeAt(e.key));
                          },
                        )
                        .animate(delay: (60 * e.key).ms)
                        .fadeIn(duration: 200.ms)
                        .slideX(begin: -0.04),
              ),
          const SizedBox(height: 20),
        ],

        // Trending Searches
        _SectionHeader(
          title: 'Trending Now',
          icon: Icons.trending_up_rounded,
          iconColor: AppTheme.accentCoral,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchEngine.trendingSearches
              .asMap()
              .entries
              .map(
                (e) =>
                    _PremiumChip(
                          label: e.value,
                          icon: Icons.trending_up_rounded,
                          color: AppTheme.accentCoral,
                          onTap: () => _go(e.value),
                        )
                        .animate(delay: (80 + 40 * e.key).ms)
                        .fadeIn(duration: 200.ms)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          curve: Curves.easeOutBack,
                        ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),

        // Popular Categories
        _SectionHeader(
          title: 'Popular Categories',
          icon: Icons.category_rounded,
          iconColor: AppTheme.accentBlue,
        ),
        const SizedBox(height: 12),
        _buildCategoryGrid(tt),
        const SizedBox(height: 24),

        // Quick Problem Searches
        _SectionHeader(
          title: 'Quick Problem Search',
          icon: Icons.build_circle_rounded,
          iconColor: AppTheme.accentTeal,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchEngine.quickProblems
              .asMap()
              .entries
              .map(
                (e) =>
                    _PremiumChip(
                          label: e.value,
                          icon: Icons.search_rounded,
                          color: AppTheme.accentTeal,
                          onTap: () => _go(e.value),
                        )
                        .animate(delay: (200 + 40 * e.key).ms)
                        .fadeIn(duration: 200.ms)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          curve: Curves.easeOutBack,
                        ),
              )
              .toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCategoryGrid(TextTheme tt) {
    final cats = SearchEngine.popularCategories;
    final icons = <String, IconData>{
      'Plumber': Icons.plumbing_rounded,
      'Electrician': Icons.electrical_services_rounded,
      'Tutor': Icons.school_rounded,
      'AC Repair': Icons.ac_unit_rounded,
      'Salon': Icons.content_cut_rounded,
      'Cleaning': Icons.cleaning_services_rounded,
      'Carpenter': Icons.carpenter_rounded,
      'Painter': Icons.format_paint_rounded,
      'Bike Repair': Icons.two_wheeler_rounded,
    };
    final colors = <String, Color>{
      'Plumber': AppTheme.accentBlue,
      'Electrician': AppTheme.accentGold,
      'Tutor': AppTheme.accentPurple,
      'AC Repair': AppTheme.accentTeal,
      'Salon': AppTheme.accentCoral,
      'Cleaning': const Color(0xFF63E6BE),
      'Carpenter': const Color(0xFFD4A76A),
      'Painter': const Color(0xFF8FB0FF),
      'Bike Repair': const Color(0xFFFFA07A),
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.15,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: cats.length,
      itemBuilder: (context, i) {
        final cat = cats[i];
        final color = colors[cat] ?? AppTheme.accentGold;
        return _CategoryTile(
              label: cat,
              icon: icons[cat] ?? Icons.work_rounded,
              color: color,
              onTap: () => _go(cat),
            )
            .animate(delay: (150 + 40 * i).ms)
            .fadeIn(duration: 250.ms)
            .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
      },
    );
  }

  // ─────────────────────────────────────
  // LIVE SUGGESTIONS LIST
  // ─────────────────────────────────────
  Widget _buildSuggestionsList(TextTheme tt, double pad) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _suggestions.length,
      itemBuilder: (context, i) {
        final s = _suggestions[i];
        return _SuggestionTile(
              suggestion: s,
              query: _ctrl.text,
              onTap: () => _go(s.text),
            )
            .animate(delay: (40 * i).ms)
            .fadeIn(duration: 150.ms)
            .slideX(begin: -0.03);
      },
    );
  }

  Widget _buildNoSuggestions(TextTheme tt, double pad) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppTheme.accentGold.withAlpha(120),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No suggestions',
              style: tt.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Press enter to search for "${_ctrl.text}"',
              style: tt.bodySmall?.copyWith(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════
// REUSABLE WIDGETS
// ═════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  const _SectionHeader({
    required this.title,
    this.icon,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon case final ic?) ...[
          Icon(ic, color: iconColor ?? AppTheme.textMuted, size: 16),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

class _RecentTile extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _RecentTile({
    required this.text,
    required this.onTap,
    required this.onRemove,
  });
  @override
  State<_RecentTile> createState() => _RecentTileState();
}

class _RecentTileState extends State<_RecentTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: _pressed ? AppTheme.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Row(
            children: [
              Icon(Icons.history_rounded, color: AppTheme.textMuted, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.textMuted.withAlpha(120),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.north_west_rounded,
                color: AppTheme.textMuted.withAlpha(100),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _PremiumChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  State<_PremiumChip> createState() => _PremiumChipState();
}

class _PremiumChipState extends State<_PremiumChip> {
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
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(15),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: widget.color.withAlpha(50), width: 0.7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: widget.color.withAlpha(150)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
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
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 80),
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
                  color: widget.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
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

class _SuggestionTile extends StatefulWidget {
  final SearchSuggestion suggestion;
  final String query;
  final VoidCallback onTap;
  const _SuggestionTile({
    required this.suggestion,
    required this.query,
    required this.onTap,
  });
  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _pressed = false;

  IconData get _icon {
    switch (widget.suggestion.type) {
      case SuggestionType.service:
        return Icons.work_rounded;
      case SuggestionType.problem:
        return Icons.build_rounded;
      case SuggestionType.provider:
        return Icons.person_rounded;
      case SuggestionType.area:
        return Icons.location_on_rounded;
      case SuggestionType.pincode:
        return Icons.pin_drop_rounded;
    }
  }

  Color get _color {
    switch (widget.suggestion.type) {
      case SuggestionType.service:
        return AppTheme.accentGold;
      case SuggestionType.problem:
        return AppTheme.accentTeal;
      case SuggestionType.provider:
        return AppTheme.accentBlue;
      case SuggestionType.area:
        return AppTheme.accentCoral;
      case SuggestionType.pincode:
        return AppTheme.accentPurple;
    }
  }

  String get _typeLabel {
    switch (widget.suggestion.type) {
      case SuggestionType.service:
        return 'SERVICE';
      case SuggestionType.problem:
        return 'PROBLEM';
      case SuggestionType.provider:
        return 'PROVIDER';
      case SuggestionType.area:
        return 'AREA';
      case SuggestionType.pincode:
        return 'PINCODE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: _pressed ? AppTheme.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _color.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                ),
                child: Icon(_icon, color: _color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedText(s.text, widget.query),
                    if (s.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        s.subtitle!,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withAlpha(12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  _typeLabel,
                  style: TextStyle(
                    color: _color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.north_west_rounded,
                color: AppTheme.textMuted.withAlpha(100),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final idx = lowerText.indexOf(lowerQuery);
    if (idx < 0) {
      return Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}
