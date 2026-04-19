// features/auth/screens/location_screen.dart
// Feature: Authentication & Onboarding
//
// Location/pincode selection screen shown during onboarding.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';

/// Premium location/PIN picker screen.
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _pincodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedQuickPinIndex = -1;

  final List<Map<String, String>> _quickPins = [
    {'pin': '110001', 'city': 'New Delhi'},
    {'pin': '560001', 'city': 'Bangalore'},
    {'pin': '400001', 'city': 'Mumbai'},
  ];

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.mainShell,
        arguments: _pincodeController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: AnimatedMeshBackground(
        type: BackgroundType.mesh,
        subtle: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Illustration
                Center(
                  child:
                      Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppTheme.heroGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLG,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 64,
                              color: AppTheme.accentGold,
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.08, 1.08),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),
                ),
                const SizedBox(height: 24),
                Text('Where do you need help?', style: tt.headlineLarge)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2, curve: Curves.easeOut),
                const SizedBox(height: 4),
                Text(
                  'Enter your PIN code or choose a city',
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: 28),
                // PIN input
                TextFormField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter 6-digit PIN code',
                    prefixIcon: Icon(
                      Icons.pin_drop_rounded,
                      color: AppTheme.accentGold,
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a PIN code';
                    }
                    if (value.trim().length < 5) {
                      return 'PIN code must be at least 5 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Divider
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppTheme.surfaceDivider),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or choose a city', style: tt.labelSmall),
                    ),
                    const Expanded(
                      child: Divider(color: AppTheme.surfaceDivider),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Quick picks
                ...List.generate(_quickPins.length, (i) {
                  final pin = _quickPins[i];
                  final isSelected = _selectedQuickPinIndex == i;
                  return _QuickPinTile(
                    city: pin['city']!,
                    pincode: pin['pin']!,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedQuickPinIndex = i;
                        _pincodeController.text = pin['pin']!;
                      });
                    },
                    index: i,
                  );
                }),
                const SizedBox(height: 28),
                // Continue button
                SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          boxShadow: AppTheme.softGlow,
                        ),
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSM,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Find Providers',
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textOnAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: AppTheme.textOnAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickPinTile extends StatefulWidget {
  final String city;
  final String pincode;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _QuickPinTile({
    required this.city,
    required this.pincode,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<_QuickPinTile> createState() => _QuickPinTileState();
}

class _QuickPinTileState extends State<_QuickPinTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _isHovered || widget.isSelected
                    ? AppTheme.surfaceElevated
                    : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border(
                  left: BorderSide(
                    color: widget.isSelected
                        ? AppTheme.accentGold
                        : (_isHovered
                              ? AppTheme.accentTeal
                              : Colors.transparent),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: widget.isSelected
                        ? AppTheme.accentGold
                        : AppTheme.accentTeal,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.city,
                    style: tt.titleMedium?.copyWith(
                      color: widget.isSelected
                          ? AppTheme.accentGold
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(widget.pincode, style: tt.labelSmall),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 80).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, curve: Curves.easeOut);
  }
}
