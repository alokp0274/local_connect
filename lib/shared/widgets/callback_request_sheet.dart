// shared/widgets/callback_request_sheet.dart
// Layer: Shared (reusable across features)
//
// Bottom sheet for requesting a callback from a service provider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
//  REQUEST CALLBACK BOTTOM SHEET
// ─────────────────────────────────────────────────────────

/// Shows a premium bottom sheet for requesting a callback from a provider.
/// Returns true if callback was confirmed.
Future<bool?> showCallbackRequestSheet(
  BuildContext context, {
  required String providerName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _CallbackRequestContent(providerName: providerName),
  );
}

class _CallbackRequestContent extends StatefulWidget {
  final String providerName;
  const _CallbackRequestContent({required this.providerName});

  @override
  State<_CallbackRequestContent> createState() =>
      _CallbackRequestContentState();
}

class _CallbackRequestContentState extends State<_CallbackRequestContent> {
  int _selectedTime = 0;
  final _noteController = TextEditingController();
  bool _isConfirming = false;
  bool _isSuccess = false;

  final List<_TimeOption> _timeOptions = const [
    _TimeOption(label: 'Now', subtitle: 'ASAP', icon: Icons.flash_on_rounded),
    _TimeOption(
      label: 'In 15 min',
      subtitle: 'Short wait',
      icon: Icons.timer_rounded,
    ),
    _TimeOption(
      label: 'Evening',
      subtitle: 'After 5 PM',
      icon: Icons.wb_twilight_rounded,
    ),
    _TimeOption(
      label: 'Tomorrow',
      subtitle: 'Next day',
      icon: Icons.today_rounded,
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    HapticFeedback.mediumImpact();
    setState(() => _isConfirming = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isConfirming = false;
      _isSuccess = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSolid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedCrossFade(
          duration: AppTheme.durationMedium,
          crossFadeState: _isSuccess
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: _buildForm(tt),
          secondChild: _buildSuccess(tt),
        ),
      ),
    );
  }

  Widget _buildForm(TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
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
          // Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withAlpha(22),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.phone_callback_rounded,
                  color: AppTheme.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Callback',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'from ',
                      style: tt.bodySmall?.copyWith(color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppTheme.textMuted,
                ),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Time options
          Text(
            'Preferred Time',
            style: tt.labelLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_timeOptions.length, (i) {
              final opt = _timeOptions[i];
              final selected = _selectedTime == i;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTime = i);
                    },
                    child: AnimatedContainer(
                      duration: AppTheme.durationFast,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? AppTheme.primarySubtleGradient
                            : null,
                        color: selected ? null : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        border: Border.all(
                          color: selected
                              ? AppTheme.accentGold.withAlpha(120)
                              : AppTheme.border,
                          width: selected ? 1 : 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            opt.icon,
                            size: 18,
                            color: selected
                                ? AppTheme.accentGold
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppTheme.accentGold
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            opt.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: selected
                                  ? AppTheme.accentGold.withAlpha(160)
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          // Note
          Text(
            'Note (optional)',
            style: tt.labelLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            maxLength: 100,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Urgent repair needed, kitchen leak...',
              hintStyle: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppTheme.surfaceInput,
              counterStyle: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                borderSide: const BorderSide(
                  color: AppTheme.border,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                borderSide: const BorderSide(
                  color: AppTheme.border,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                borderSide: const BorderSide(
                  color: AppTheme.accentGold,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.textOnAccent,
                disabledBackgroundColor: AppTheme.accentGold.withAlpha(120),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                elevation: 0,
              ),
              child: _isConfirming
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textOnAccent,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_callback_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Confirm Callback Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softGlow,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppTheme.textOnAccent,
              size: 36,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'Callback Requested!',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Text(
            ' will contact you .',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 6),
          Text(
            'You\u0027ll receive a notification when they call.',
            style: tt.bodySmall?.copyWith(color: AppTheme.textMuted),
          ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

class _TimeOption {
  final String label;
  final String subtitle;
  final IconData icon;
  const _TimeOption({
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}
