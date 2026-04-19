// features/provider_mode/screens/provider_business_profile_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Provider business profile editor (bio, services, photos, certifications).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/account_mode.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderBusinessProfileScreen extends StatefulWidget {
  const ProviderBusinessProfileScreen({super.key});
  @override
  State<ProviderBusinessProfileScreen> createState() =>
      _ProviderBusinessProfileScreenState();
}

class _ProviderBusinessProfileScreenState
    extends State<ProviderBusinessProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _pricingCtrl;
  late TextEditingController _expCtrl;
  String _category = 'Plumber';
  String _responsePromise = 'Within 15 min';
  final List<String> _languages = ['Hindi', 'English'];
  final List<String> _certs = ['Licensed Professional'];

  @override
  void initState() {
    super.initState();
    final am = accountMode;
    _nameCtrl = TextEditingController(text: am.providerName);
    _descCtrl = TextEditingController(text: am.providerDescription);
    _pricingCtrl = TextEditingController(text: '\u20b9300 - \u20b91,500');
    _expCtrl = TextEditingController(text: '5 years');
    if (am.providerService.isNotEmpty) _category = am.providerService;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _pricingCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
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
                      _buildPhotoSection(tt),
                      const SizedBox(height: 20),
                      _buildField('Business Name', _nameCtrl, tt),
                      const SizedBox(height: 14),
                      _buildCategoryPicker(tt),
                      const SizedBox(height: 14),
                      _buildField('Description', _descCtrl, tt, maxLines: 4),
                      const SizedBox(height: 14),
                      _buildField('Pricing', _pricingCtrl, tt),
                      const SizedBox(height: 14),
                      _buildField('Experience', _expCtrl, tt),
                      const SizedBox(height: 14),
                      _buildResponseTime(tt),
                      const SizedBox(height: 14),
                      _buildLanguages(tt),
                      const SizedBox(height: 14),
                      _buildCertificates(tt),
                      const SizedBox(height: 24),
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
              'Business Profile',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildPhotoSection(TextTheme tt) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos',
            style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.tealGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      3,
                      (i) => Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMD,
                          ),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              color: AppTheme.textMuted.withAlpha(120),
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Work ${i + 1}',
                              style: TextStyle(
                                color: AppTheme.textMuted.withAlpha(120),
                                fontSize: 10,
                              ),
                            ),
                          ],
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
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildCategoryPicker(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Category',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Plumber',
                'Electrician',
                'AC Repair',
                'Carpenter',
                'Painter',
                'Cleaning',
                'Salon',
                'Tutor',
              ].map((c) {
                final sel = _category == c;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _category = c);
                  },
                  child: AnimatedContainer(
                    duration: AppTheme.durationFast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.accentTeal.withAlpha(25)
                          : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: sel
                            ? AppTheme.accentTeal
                            : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        color: sel ? AppTheme.accentTeal : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildResponseTime(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response Time Promise',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Within 5 min',
                'Within 15 min',
                'Within 30 min',
                'Within 1 hr',
              ].map((r) {
                final sel = _responsePromise == r;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _responsePromise = r);
                  },
                  child: AnimatedContainer(
                    duration: AppTheme.durationFast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.accentBlue.withAlpha(25)
                          : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: sel
                            ? AppTheme.accentBlue
                            : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      r,
                      style: TextStyle(
                        color: sel ? AppTheme.accentBlue : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguages(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Hindi', 'English', 'Punjabi', 'Bengali', 'Tamil'].map((
            l,
          ) {
            final sel = _languages.contains(l);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  sel ? _languages.remove(l) : _languages.add(l);
                });
              },
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.accentPurple.withAlpha(20)
                      : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: sel
                        ? AppTheme.accentPurple
                        : AppTheme.border,
                  ),
                ),
                child: Text(
                  l,
                  style: TextStyle(
                    color: sel ? AppTheme.accentPurple : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCertificates(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificates',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._certs.map(
              (c) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: AppTheme.accentGold.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppTheme.accentGold,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      c,
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Certificate upload coming soon!'),
                    backgroundColor: AppTheme.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppTheme.textMuted,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              content: const Text('Profile saved!'),
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
              'Save Profile',
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

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    TextTheme tt, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelLarge?.copyWith(color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
