// features/search/screens/filter_screen.dart
// Feature: Search & Discovery
//
// Filter panel for refining search by category, rating, distance, and price.

import 'package:flutter/material.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

/// Full-page premium filter screen with multiple filter categories.
class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // ── Filter State ──
  String _serviceType = 'All'; // All, Individual, Company
  String _sorting =
      'Relevance'; // Relevance, Top Rated, Nearest, Newest, Most Popular
  String _availability = 'Any'; // Any, Available Now, Today, Weekend
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _experience = 'Any'; // Any, 1+, 3+, 5+, 10+
  String _minRating = 'Any'; // Any, 3+, 3.5+, 4+, 4.5+, 5
  String _language = 'Any'; // Any, Hindi, English, Tamil, Telugu, etc.
  String _gender = 'Any'; // Any, Male, Female
  bool _verifiedOnly = false;
  String _city = 'Any';

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      final f = widget.initialFilters!;
      _serviceType = f['serviceType'] ?? _serviceType;
      _sorting = f['sorting'] ?? _sorting;
      _availability = f['availability'] ?? _availability;
      _priceRange = f['priceRange'] ?? _priceRange;
      _experience = f['experience'] ?? _experience;
      _minRating = f['minRating'] ?? _minRating;
      _language = f['language'] ?? _language;
      _gender = f['gender'] ?? _gender;
      _verifiedOnly = f['verifiedOnly'] ?? _verifiedOnly;
      _city = f['city'] ?? _city;
    }
  }

  void _resetAll() {
    setState(() {
      _serviceType = 'All';
      _sorting = 'Relevance';
      _availability = 'Any';
      _priceRange = const RangeValues(0, 5000);
      _experience = 'Any';
      _minRating = 'Any';
      _language = 'Any';
      _gender = 'Any';
      _verifiedOnly = false;
      _city = 'Any';
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop({
      'serviceType': _serviceType,
      'sorting': _sorting,
      'availability': _availability,
      'priceRange': _priceRange,
      'experience': _experience,
      'minRating': _minRating,
      'language': _language,
      'gender': _gender,
      'verifiedOnly': _verifiedOnly,
      'city': _city,
    });
  }

  bool get _hasActiveFilters =>
      _serviceType != 'All' ||
      _sorting != 'Relevance' ||
      _availability != 'Any' ||
      _priceRange != const RangeValues(0, 5000) ||
      _experience != 'Any' ||
      _minRating != 'Any' ||
      _language != 'Any' ||
      _gender != 'Any' ||
      _verifiedOnly ||
      _city != 'Any';

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Filters', style: tt.headlineMedium),
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _resetAll,
              child: const Text(
                'Reset All',
                style: TextStyle(
                  color: AppTheme.accentCoral,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
                children: [
                  // ── Service Type ──
                  _SectionHeader(
                    title: 'Service Type',
                    icon: Icons.category_rounded,
                  ),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const ['All', 'Individual', 'Company'],
                    selected: _serviceType,
                    onSelected: (v) => setState(() => _serviceType = v),
                    icons: const {
                      'Individual': Icons.person_rounded,
                      'Company': Icons.business_rounded,
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Sorting ──
                  _SectionHeader(title: 'Sort By', icon: Icons.sort_rounded),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const [
                      'Relevance',
                      'Top Rated',
                      'Nearest',
                      'Newest',
                      'Most Popular',
                    ],
                    selected: _sorting,
                    onSelected: (v) => setState(() => _sorting = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Availability ──
                  _SectionHeader(
                    title: 'Availability',
                    icon: Icons.schedule_rounded,
                  ),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const ['Any', 'Available Now', 'Today', 'Weekend'],
                    selected: _availability,
                    onSelected: (v) => setState(() => _availability = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Price Range ──
                  _SectionHeader(
                    title: 'Price Range',
                    icon: Icons.currency_rupee_rounded,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${_priceRange.start.round()}',
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '₹${_priceRange.end.round()}',
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppTheme.accentGold,
                            inactiveTrackColor: AppTheme.surfaceDivider,
                            thumbColor: AppTheme.accentGold,
                            overlayColor: AppTheme.accentGold.withAlpha(30),
                            trackHeight: 4,
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 5000,
                            divisions: 50,
                            onChanged: (v) => setState(() => _priceRange = v),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Experience ──
                  _SectionHeader(
                    title: 'Experience',
                    icon: Icons.work_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const [
                      'Any',
                      '1+ yrs',
                      '3+ yrs',
                      '5+ yrs',
                      '10+ yrs',
                    ],
                    selected: _experience,
                    onSelected: (v) => setState(() => _experience = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Ratings ──
                  _SectionHeader(
                    title: 'Minimum Rating',
                    icon: Icons.star_rounded,
                  ),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const [
                      'Any',
                      '3★+',
                      '3.5★+',
                      '4★+',
                      '4.5★+',
                      '5★',
                    ],
                    selected: _minRating,
                    onSelected: (v) => setState(() => _minRating = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Language ──
                  _SectionHeader(
                    title: 'Language',
                    icon: Icons.translate_rounded,
                  ),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const [
                      'Any',
                      'Hindi',
                      'English',
                      'Tamil',
                      'Telugu',
                      'Bengali',
                      'Marathi',
                    ],
                    selected: _language,
                    onSelected: (v) => setState(() => _language = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Gender ──
                  _SectionHeader(title: 'Gender', icon: Icons.people_rounded),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const ['Any', 'Male', 'Female'],
                    selected: _gender,
                    onSelected: (v) => setState(() => _gender = v),
                    icons: const {
                      'Male': Icons.male_rounded,
                      'Female': Icons.female_rounded,
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── City ──
                  _SectionHeader(
                    title: 'City',
                    icon: Icons.location_city_rounded,
                  ),
                  const SizedBox(height: 10),
                  _ChipRow(
                    options: const [
                      'Any',
                      'New Delhi',
                      'Bangalore',
                      'Mumbai',
                      'Chennai',
                      'Hyderabad',
                      'Pune',
                    ],
                    selected: _city,
                    onSelected: (v) => setState(() => _city = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Verified Toggle ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withAlpha(25),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: AppTheme.accentTeal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified Only',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Show only verified providers',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _verifiedOnly,
                          onChanged: (v) => setState(() => _verifiedOnly = v),
                          activeThumbColor: AppTheme.accentTeal,
                          activeTrackColor: AppTheme.accentTeal.withAlpha(60),
                          inactiveThumbColor: AppTheme.textMuted,
                          inactiveTrackColor: AppTheme.surfaceDivider,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),

            // ── Bottom Apply Button ──
            Container(
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryDark,
                border: Border(
                  top: BorderSide(color: AppTheme.surfaceDivider, width: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Reset Button
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: _resetAll,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                            border: Border.all(color: AppTheme.surfaceDivider),
                          ),
                          child: const Center(
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Apply Button
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _applyFilters,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                            boxShadow: AppTheme.softGlow,
                          ),
                          child: const Center(
                            child: Text(
                              'Apply Filters',
                              style: TextStyle(
                                color: AppTheme.textOnAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ──
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentGold, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Chip Row ──
class _ChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, IconData>? icons;

  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final active = selected == opt;
        final hasIcon = icons != null && icons!.containsKey(opt);
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: active ? AppTheme.primaryGradient : null,
              color: active ? null : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: active
                  ? null
                  : Border.all(color: AppTheme.surfaceDivider, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasIcon) ...[
                  Icon(
                    icons![opt],
                    size: 14,
                    color: active
                        ? AppTheme.textOnAccent
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppTheme.textOnAccent
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
