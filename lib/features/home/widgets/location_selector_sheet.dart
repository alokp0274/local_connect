// features/home/widgets/location_selector_sheet.dart
// Feature: Home & Dashboard
//
// Premium location selector supporting city, area, locality, and PIN code search.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

/// Shows premium location selector bottom sheet.
/// Returns selected pincode string or null.
Future<String?> showLocationSelectorSheet(
  BuildContext context, {
  required String currentPincode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _LocationSelectorContent(currentPincode: currentPincode),
  );
}

class _LocationSelectorContent extends StatefulWidget {
  final String currentPincode;
  const _LocationSelectorContent({required this.currentPincode});
  @override
  State<_LocationSelectorContent> createState() =>
      _LocationSelectorContentState();
}

class _LocationSelectorContentState extends State<_LocationSelectorContent> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _detecting = false;
  String _query = '';

  // Unified location database: city, area, locality + pincode
  static const _allLocations = [
    _LocationEntry('110001', 'Connaught Place', 'New Delhi', 'Central Delhi'),
    _LocationEntry('110025', 'Okhla Phase 1', 'New Delhi', 'South Delhi'),
    _LocationEntry('110017', 'Malviya Nagar', 'New Delhi', 'South Delhi'),
    _LocationEntry('110020', 'Hauz Khas', 'New Delhi', 'South Delhi'),
    _LocationEntry('110019', 'Kalkaji', 'New Delhi', 'South Delhi'),
    _LocationEntry('110049', 'East of Kailash', 'New Delhi', 'South Delhi'),
    _LocationEntry('110048', 'Nehru Place', 'New Delhi', 'South Delhi'),
    _LocationEntry('110044', 'Laxmi Nagar', 'New Delhi', 'East Delhi'),
    _LocationEntry('110085', 'Shahdara', 'New Delhi', 'North East Delhi'),
    _LocationEntry('110092', 'Patparganj', 'New Delhi', 'East Delhi'),
    _LocationEntry('110034', 'Pitampura', 'New Delhi', 'North West Delhi'),
    _LocationEntry('110016', 'Karol Bagh', 'New Delhi', 'Central Delhi'),
    _LocationEntry('400001', 'Fort', 'Mumbai', 'South Mumbai'),
    _LocationEntry('400050', 'Bandra West', 'Mumbai', 'Western Suburbs'),
    _LocationEntry('400076', 'Powai', 'Mumbai', 'Eastern Suburbs'),
    _LocationEntry('560001', 'MG Road', 'Bangalore', 'Central Bangalore'),
    _LocationEntry('560034', 'Koramangala', 'Bangalore', 'South Bangalore'),
    _LocationEntry('600001', 'Parrys Corner', 'Chennai', 'Central Chennai'),
    _LocationEntry('500001', 'Abids', 'Hyderabad', 'Central Hyderabad'),
    _LocationEntry('700001', 'BBD Bagh', 'Kolkata', 'Central Kolkata'),
    _LocationEntry('411001', 'Shivaji Nagar', 'Pune', 'Central Pune'),
  ];

  static const _recentLocations = [
    _LocationEntry('110001', 'Connaught Place', 'New Delhi', 'Central Delhi'),
    _LocationEntry('110025', 'Okhla Phase 1', 'New Delhi', 'South Delhi'),
    _LocationEntry('110017', 'Malviya Nagar', 'New Delhi', 'South Delhi'),
  ];

  static const _savedPlaces = [
    _SavedPlace('Home', '110001', 'Connaught Place, New Delhi', Icons.home_rounded),
    _SavedPlace('Office', '110020', 'Hauz Khas, New Delhi', Icons.business_rounded),
  ];

  List<_LocationEntry> get _searchResults {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _allLocations.where((loc) {
      return loc.area.toLowerCase().contains(q) ||
          loc.city.toLowerCase().contains(q) ||
          loc.locality.toLowerCase().contains(q) ||
          loc.pincode.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.trim();
      if (text != _query) setState(() => _query = text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _select(String pincode) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(pincode);
  }

  Future<void> _detectLocation() async {
    HapticFeedback.mediumImpact();
    setState(() => _detecting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _detecting = false);
    _select('110001');
  }

  void _submitPincode() {
    final pin = _controller.text.trim();
    if (pin.length == 6 && RegExp(r'^\d{6}$').hasMatch(pin)) {
      _select(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final tt = Theme.of(context).textTheme;
    final screenH = MediaQuery.of(context).size.height;
    final showResults = _query.isNotEmpty;
    final results = _searchResults;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.85),
      margin: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ──
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppTheme.accentGold, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Change Location',
                            style: tt.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text('Current: PIN ${widget.currentPincode}',
                            style: tt.bodySmall
                                ?.copyWith(color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textMuted),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Unified Search Field ──
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
                onSubmitted: (_) => _submitPincode(),
                decoration: InputDecoration(
                  hintText: 'Search city, area, or PIN code',
                  hintStyle: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 14),
                  filled: true,
                  fillColor: AppTheme.surfaceElevated,
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.accentGold, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear_rounded,
                              color: AppTheme.textMuted, size: 18),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    borderSide:
                        const BorderSide(color: AppTheme.border, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    borderSide:
                        const BorderSide(color: AppTheme.border, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    borderSide:
                        const BorderSide(color: AppTheme.accentGold, width: 1),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 14),

              // ── Detect Location Button ──
              GestureDetector(
                onTap: _detecting ? null : _detectLocation,
                child: GlassContainer(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  color: AppTheme.accentBlue.withAlpha(12),
                  border:
                      Border.all(color: AppTheme.accentBlue.withAlpha(60)),
                  child: Row(
                    children: [
                      _detecting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accentBlue))
                          : const Icon(Icons.my_location_rounded,
                              color: AppTheme.accentBlue, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        _detecting
                            ? 'Detecting your location...'
                            : 'Use current location',
                        style: const TextStyle(
                            color: AppTheme.accentBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Dynamic Search Results ──
              if (showResults) ...[
                const SizedBox(height: 18),
                _sectionLabel(tt, '${results.length} results'),
                const SizedBox(height: 8),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No locations found for "$_query"',
                        style: tt.bodyMedium
                            ?.copyWith(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else
                  ...List.generate(results.length.clamp(0, 8), (i) {
                    final loc = results[i];
                    return _LocationResultTile(
                      entry: loc,
                      isActive: loc.pincode == widget.currentPincode,
                      onTap: () => _select(loc.pincode),
                    ).animate(delay: (i * 35).ms).fadeIn(duration: 200.ms);
                  }),
              ],

              // ── Default Content (when not searching) ──
              if (!showResults) ...[
                const SizedBox(height: 20),

                // Saved Places
                if (_savedPlaces.isNotEmpty) ...[
                  _sectionLabel(tt, 'Saved Places'),
                  const SizedBox(height: 8),
                  ...List.generate(_savedPlaces.length, (i) {
                    final place = _savedPlaces[i];
                    return _SavedPlaceTile(
                      place: place,
                      isActive: place.pincode == widget.currentPincode,
                      onTap: () => _select(place.pincode),
                    ).animate(delay: (i * 40).ms).fadeIn(duration: 200.ms);
                  }),
                  const SizedBox(height: 16),
                ],

                // Recent Locations
                _sectionLabel(tt, 'Recent Locations'),
                const SizedBox(height: 8),
                ...List.generate(_recentLocations.length, (i) {
                  final loc = _recentLocations[i];
                  return _LocationResultTile(
                    entry: loc,
                    icon: Icons.history_rounded,
                    isActive: loc.pincode == widget.currentPincode,
                    onTap: () => _select(loc.pincode),
                  ).animate(delay: (i * 40).ms).fadeIn(duration: 200.ms);
                }),
                const SizedBox(height: 16),

                // Popular Nearby
                _sectionLabel(tt, 'Popular Nearby'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    _allLocations.length.clamp(0, 8),
                    (i) {
                      final loc = _allLocations[i];
                      final isActive =
                          loc.pincode == widget.currentPincode;
                      return GestureDetector(
                        onTap: () => _select(loc.pincode),
                        child: AnimatedContainer(
                          duration: AppTheme.durationFast,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? AppTheme.primarySubtleGradient
                                : null,
                            color: isActive ? null : AppTheme.surfaceCard,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: isActive
                                  ? AppTheme.accentGold.withAlpha(120)
                                  : AppTheme.border,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '${loc.area} · ${loc.pincode}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppTheme.accentGold
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      )
                          .animate(delay: (i * 30).ms)
                          .fadeIn(duration: 200.ms);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(TextTheme tt, String text) => Text(
        text,
        style: tt.labelLarge
            ?.copyWith(color: AppTheme.textMuted, fontSize: 12),
      );
}

// ─────────────────────────────────────────
// Location Result Tile
// ─────────────────────────────────────────

class _LocationResultTile extends StatelessWidget {
  final _LocationEntry entry;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _LocationResultTile({
    required this.entry,
    this.icon = Icons.location_on_outlined,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentGold.withAlpha(10)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: isActive
                ? AppTheme.accentGold.withAlpha(80)
                : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? AppTheme.accentGold : AppTheme.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.area,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppTheme.accentGold
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${entry.locality}, ${entry.city} · PIN ${entry.pincode}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? AppTheme.accentGold.withAlpha(160)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text('Current',
                    style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Saved Place Tile
// ─────────────────────────────────────────

class _SavedPlaceTile extends StatelessWidget {
  final _SavedPlace place;
  final bool isActive;
  final VoidCallback onTap;

  const _SavedPlaceTile({
    required this.place,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentGold.withAlpha(10)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: isActive
                ? AppTheme.accentGold.withAlpha(80)
                : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withAlpha(15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(place.icon, size: 16, color: AppTheme.accentGold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppTheme.accentGold
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    place.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? AppTheme.accentGold.withAlpha(160)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text('Current',
                    style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Models
// ─────────────────────────────────────────

class _LocationEntry {
  final String pincode;
  final String area;
  final String city;
  final String locality;

  const _LocationEntry(this.pincode, this.area, this.city, this.locality);
}

class _SavedPlace {
  final String label;
  final String pincode;
  final String subtitle;
  final IconData icon;

  const _SavedPlace(this.label, this.pincode, this.subtitle, this.icon);
}
