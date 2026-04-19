// features/provider_mode/screens/provider_onboarding_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Step-by-step onboarding flow for new provider registration.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/account_mode.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  PROVIDER ONBOARDING — Multi-step premium flow
// ─────────────────────────────────────────────────────────

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  static const _totalSteps = 6;

  // Form data
  String _selectedService = '';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  final _pincodeController = TextEditingController();
  final List<String> _pincodes = [];
  bool _isFinishing = false;

  late AnimationController _progressController;

  static const _services = [
    _ServiceOption('Plumber', Icons.plumbing_rounded, AppTheme.accentBlue),
    _ServiceOption(
      'Electrician',
      Icons.electrical_services_rounded,
      AppTheme.accentGold,
    ),
    _ServiceOption('AC Repair', Icons.ac_unit_rounded, AppTheme.accentTeal),
    _ServiceOption('Carpenter', Icons.carpenter_rounded, AppTheme.accentPurple),
    _ServiceOption('Painter', Icons.format_paint_rounded, AppTheme.accentCoral),
    _ServiceOption(
      'Cleaning',
      Icons.cleaning_services_rounded,
      AppTheme.accentBlue,
    ),
    _ServiceOption('Salon', Icons.content_cut_rounded, AppTheme.accentGold),
    _ServiceOption('Tutor', Icons.school_rounded, AppTheme.accentTeal),
    _ServiceOption(
      'Bike Repair',
      Icons.two_wheeler_rounded,
      AppTheme.accentPurple,
    ),
    _ServiceOption('Other', Icons.handyman_rounded, AppTheme.accentCoral),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _updateProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressController.animateTo(
      (_currentStep + 1) / _totalSteps,
      curve: Curves.easeOutCubic,
    );
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedService.isNotEmpty;
      case 1:
        return _nameController.text.trim().length >= 2;
      case 2:
        return _phoneController.text.trim().length >= 10;
      case 3:
        return _pincodes.isNotEmpty;
      case 4:
        return _descController.text.trim().length >= 10;
      case 5:
        return true; // photo step is optional
      default:
        return false;
    }
  }

  void _next() {
    if (!_canProceed) return;
    HapticFeedback.lightImpact();
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _updateProgress();
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      HapticFeedback.selectionClick();
      setState(() => _currentStep--);
      _updateProgress();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finish() async {
    setState(() => _isFinishing = true);
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    accountMode.completeProviderProfile(
      name: _nameController.text.trim().isEmpty
          ? 'John Doe'
          : _nameController.text.trim(),
      service: _selectedService,
      phone: _phoneController.text.trim().isEmpty
          ? '+919876543210'
          : _phoneController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'Professional $_selectedService services'
          : _descController.text.trim(),
      pincodes: _pincodes.isEmpty ? ['110001'] : _pincodes,
    );

    if (mounted) Navigator.pop(context, true);
  }

  void _addPincode() {
    final code = _pincodeController.text.trim();
    if (code.length == 6 &&
        RegExp(r'^\d{6}$').hasMatch(code) &&
        !_pincodes.contains(code)) {
      setState(() {
        _pincodes.add(code);
        _pincodeController.clear();
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _back,
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Become a Provider',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Step ${_currentStep + 1} of $_totalSteps',
                          style: tt.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ──
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: LinearProgressIndicator(
                      value: _progressController.value,
                      minHeight: 4,
                      backgroundColor: AppTheme.surfaceCard,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accentTeal,
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Step content ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentStep),
                  child: _buildStepContent(tt, pad, isCompact),
                ),
              ),
            ),

            // ── Bottom CTA ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                pad,
                0,
                pad,
                bottomPad > 0 ? bottomPad : 16,
              ),
              child: _isFinishing
                  ? _buildFinishingState(tt)
                  : _buildContinueButton(tt, isCompact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(TextTheme tt, double pad, bool isCompact) {
    switch (_currentStep) {
      case 0:
        return _buildServiceStep(tt, pad, isCompact);
      case 1:
        return _buildNameStep(tt, pad);
      case 2:
        return _buildPhoneStep(tt, pad);
      case 3:
        return _buildPincodeStep(tt, pad, isCompact);
      case 4:
        return _buildDescriptionStep(tt, pad);
      case 5:
        return _buildPhotoStep(tt, pad);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Choose Service ──
  Widget _buildServiceStep(TextTheme tt, double pad, bool isCompact) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What service do you offer?',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your primary profession',
            style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _services.map((svc) {
              final selected = _selectedService == svc.label;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedService = svc.label);
                },
                child: AnimatedContainer(
                  duration: AppTheme.durationFast,
                  width: isCompact ? double.infinity : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 14 : 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? svc.color.withAlpha(25)
                        : AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: selected
                          ? svc.color.withAlpha(150)
                          : AppTheme.border,
                      width: selected ? 1.2 : 0.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: svc.color.withAlpha(30),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: isCompact
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                      Icon(
                        svc.icon,
                        color: selected ? svc.color : AppTheme.textMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        svc.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? svc.color : AppTheme.textSecondary,
                        ),
                      ),
                      if (selected) ...[
                        const Spacer(),
                        Icon(
                          Icons.check_circle_rounded,
                          color: svc.color,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Name ──
  Widget _buildNameStep(TextTheme tt, double pad) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your business name',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'This will be visible to customers',
            style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'e.g. Rajesh Kumar or RK Services',
              prefixIcon: const Icon(
                Icons.business_rounded,
                color: AppTheme.accentTeal,
              ),
              suffixIcon: _nameController.text.trim().length >= 2
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.accentTeal,
                      size: 20,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: Use your real name or business name for trust',
            style: tt.labelSmall?.copyWith(
              color: AppTheme.accentTeal,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Phone ──
  Widget _buildPhoneStep(TextTheme tt, double pad) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact number',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Customers will reach you on this number',
            style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: '+91 98765 43210',
              prefixIcon: const Icon(
                Icons.phone_rounded,
                color: AppTheme.accentTeal,
              ),
              suffixIcon: _phoneController.text.trim().length >= 10
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.accentTeal,
                      size: 20,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Pincodes ──
  Widget _buildPincodeStep(TextTheme tt, double pad, bool isCompact) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service areas',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Add PIN codes where you offer services',
            style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter PIN code',
                    counterText: '',
                    prefixIcon: Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.accentTeal,
                    ),
                  ),
                  onSubmitted: (_) => _addPincode(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _addPincode,
                child: Container(
                  padding: const EdgeInsets.all(14),
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
          if (_pincodes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _pincodes.map((pin) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: AppTheme.accentTeal.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pin,
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() => _pincodes.remove(pin));
                          HapticFeedback.selectionClick();
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.accentTeal,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          // Quick add chips
          Text(
            'Popular areas',
            style: tt.labelSmall?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['110001', '110002', '110003', '110005', '110011']
                .where((p) => !_pincodes.contains(p))
                .map((pin) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _pincodes.add(pin));
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        pin,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 5: Description ──
  Widget _buildDescriptionStep(TextTheme tt, double pad) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About your service',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell customers what makes you the best',
            style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _descController,
            onChanged: (_) => setState(() {}),
            maxLines: 4,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              hintText:
                  'e.g. 8+ years experience in residential plumbing. Emergency services available.',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 6: Photos ──
  Widget _buildPhotoStep(TextTheme tt, double pad) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add photos',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Profile photo and work samples (optional)',
            style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          // Profile photo placeholder
          Center(
            child: GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withAlpha(15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentTeal.withAlpha(80),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo_rounded,
                      color: AppTheme.accentTeal,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: AppTheme.accentTeal,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Work photos',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  child: GestureDetector(
                    onTap: () => HapticFeedback.selectionClick(),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          border: Border.all(
                            color: AppTheme.border,
                            width: 0.5,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppTheme.textMuted,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            color: AppTheme.accentTeal.withAlpha(10),
            border: Border.all(color: AppTheme.accentTeal.withAlpha(30)),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.accentTeal,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can skip this and add photos later from your provider dashboard.',
                    style: TextStyle(
                      color: AppTheme.accentTeal,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(TextTheme tt, bool isCompact) {
    final isLast = _currentStep == _totalSteps - 1;
    return SizedBox(
      width: double.infinity,
      height: isCompact ? 48 : 52,
      child: GestureDetector(
        onTap: _canProceed ? _next : null,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          decoration: BoxDecoration(
            gradient: _canProceed ? AppTheme.tealGradient : null,
            color: _canProceed ? null : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            boxShadow: _canProceed
                ? [
                    BoxShadow(
                      color: AppTheme.accentTeal.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              isLast ? 'Finish Setup' : 'Continue',
              style: TextStyle(
                color: _canProceed ? Colors.white : AppTheme.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishingState(TextTheme tt) {
    return SizedBox(
      height: 52,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppTheme.accentTeal),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Setting up your profile...',
              style: tt.bodyMedium?.copyWith(color: AppTheme.accentTeal),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceOption {
  final String label;
  final IconData icon;
  final Color color;
  const _ServiceOption(this.label, this.icon, this.color);
}
