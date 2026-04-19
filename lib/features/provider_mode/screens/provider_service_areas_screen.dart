// features/provider_mode/screens/provider_service_areas_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Configure service area pincodes and coverage zone.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/account_mode.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderServiceAreasScreen extends StatefulWidget {
  const ProviderServiceAreasScreen({super.key});
  @override
  State<ProviderServiceAreasScreen> createState() =>
      _ProviderServiceAreasScreenState();
}

class _ProviderServiceAreasScreenState
    extends State<ProviderServiceAreasScreen> {
  late List<String> _pincodes;
  final _controller = TextEditingController();
  String _radius = '5 km';

  static const _popularAreas = [
    {'pin': '110001', 'name': 'Connaught Place'},
    {'pin': '110002', 'name': 'Rajiv Chowk'},
    {'pin': '110003', 'name': 'Lodhi Colony'},
    {'pin': '110005', 'name': 'Karol Bagh'},
    {'pin': '110006', 'name': 'Civil Lines'},
    {'pin': '110011', 'name': 'Laxmi Nagar'},
  ];

  static const _demandZones = [
    {'area': 'Connaught Place', 'demand': 'Very High', 'color': 'coral'},
    {'area': 'Rajiv Chowk', 'demand': 'High', 'color': 'gold'},
    {'area': 'Khan Market', 'demand': 'High', 'color': 'gold'},
    {'area': 'Janpath', 'demand': 'Medium', 'color': 'teal'},
  ];

  @override
  void initState() {
    super.initState();
    _pincodes = List.from(accountMode.providerPincodes);
    if (_pincodes.isEmpty) _pincodes = ['110001', '110002'];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPincode(String pin) {
    if (pin.length == 6 && !_pincodes.contains(pin)) {
      HapticFeedback.selectionClick();
      setState(() => _pincodes.add(pin));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(tt, pad),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActivePincodes(tt),
                      const SizedBox(height: 20),
                      _buildCoverageRadius(tt),
                      const SizedBox(height: 20),
                      _buildPopularAreas(tt),
                      const SizedBox(height: 20),
                      _buildDemandZones(tt),
                      const SizedBox(height: 20),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              padding: const EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Service Areas',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildActivePincodes(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active PIN Codes',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pincodes
                    .map(
                      (pin) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          border: Border.all(
                            color: AppTheme.accentTeal.withAlpha(60),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppTheme.accentTeal,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pin,
                              style: const TextStyle(
                                color: AppTheme.accentTeal,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _pincodes.remove(pin));
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: AppTheme.accentTeal.withAlpha(150),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add PIN code...',
                        hintStyle: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: AppTheme.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _addPincode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _addPincode(_controller.text.trim()),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.tealGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildCoverageRadius(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coverage Radius',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['3 km', '5 km', '10 km', '15 km'].map((r) {
            final selected = _radius == r;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _radius = r);
              },
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.accentBlue.withAlpha(25)
                      : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color: selected
                        ? AppTheme.accentBlue
                        : AppTheme.border,
                  ),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    color: selected ? AppTheme.accentBlue : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate(delay: 150.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildPopularAreas(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Areas Nearby',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularAreas.map((a) {
            final added = _pincodes.contains(a['pin']);
            return GestureDetector(
              onTap: added ? null : () => _addPincode(a['pin']!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: added
                      ? AppTheme.accentTeal.withAlpha(12)
                      : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: added
                        ? AppTheme.accentTeal.withAlpha(60)
                        : AppTheme.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${a['pin']}',
                      style: TextStyle(
                        color: added
                            ? AppTheme.accentTeal
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${a['name']}',
                      style: TextStyle(
                        color: added
                            ? AppTheme.accentTeal.withAlpha(180)
                            : AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    if (!added) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: AppTheme.textMuted,
                      ),
                    ],
                    if (added) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppTheme.accentTeal,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildDemandZones(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demand Zones',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        ...List.generate(_demandZones.length, (i) {
          final z = _demandZones[i];
          final color = z['color'] == 'coral'
              ? AppTheme.accentCoral
              : z['color'] == 'gold'
              ? AppTheme.accentGold
              : AppTheme.accentTeal;
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${z['area']}',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Demand: ${z['demand']}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.trending_up_rounded, color: color, size: 18),
              ],
            ),
          ).animate(delay: (250 + i * 60).ms).fadeIn(duration: 280.ms);
        }),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Service areas updated!'),
              backgroundColor: AppTheme.accentTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.tealGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            boxShadow: AppTheme.tealGlow,
          ),
          child: const Center(
            child: Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
