// features/provider_mode/screens/provider_availability_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Schedule and availability management for the provider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/account_mode.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({super.key});
  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState
    extends State<ProviderAvailabilityScreen> {
  late String _status;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _lunchStart = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _lunchEnd = const TimeOfDay(hour: 14, minute: 0);
  bool _lunchBreak = true;
  final Map<String, bool> _weekDays = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': true,
    'Sun': false,
  };

  @override
  void initState() {
    super.initState();
    _status = accountMode.providerAvailable ? 'Available Now' : 'Offline';
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
                      _buildStatusSection(tt),
                      const SizedBox(height: 24),
                      _buildWorkingHours(tt),
                      const SizedBox(height: 16),
                      _buildLunchBreak(tt),
                      const SizedBox(height: 16),
                      _buildWeekDays(tt),
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
              'Availability',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildStatusSection(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Status',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Available Now', 'Busy', 'Offline', 'Scheduled'].map((s) {
            final selected = _status == s;
            final color = _statusColor(s);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _status = s);
                if (s == 'Available Now') {
                  if (!accountMode.providerAvailable) {
                    accountMode.toggleAvailability();
                  }
                } else {
                  if (accountMode.providerAvailable) {
                    accountMode.toggleAvailability();
                  }
                }
              },
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? color.withAlpha(25) : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color: selected ? color : AppTheme.border,
                    width: selected ? 1.2 : 0.5,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: color.withAlpha(30), blurRadius: 12)]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: selected ? color : AppTheme.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s,
                      style: TextStyle(
                        color: selected ? color : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildWorkingHours(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working Hours',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          child: Column(
            children: [
              _buildTimeRow('Start Time', _startTime, (t) {
                setState(() => _startTime = t);
              }),
              const Divider(color: AppTheme.border, height: 20),
              _buildTimeRow('End Time', _endTime, (t) {
                setState(() => _endTime = t);
              }),
            ],
          ),
        ),
      ],
    ).animate(delay: 150.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildTimeRow(
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onChanged(t);
      },
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: AppTheme.accentTeal,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusXS),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              time.format(context),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLunchBreak(TextTheme tt) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lunch Break',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Switch.adaptive(
                value: _lunchBreak,
                onChanged: (v) => setState(() => _lunchBreak = v),
                activeTrackColor: AppTheme.accentTeal,
              ),
            ],
          ),
          if (_lunchBreak) ...[
            const SizedBox(height: 8),
            _buildTimeRow('From', _lunchStart, (t) {
              setState(() => _lunchStart = t);
            }),
            const Divider(color: AppTheme.border, height: 16),
            _buildTimeRow('To', _lunchEnd, (t) {
              setState(() => _lunchEnd = t);
            }),
          ],
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildWeekDays(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working Days',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekDays.entries.map((e) {
            final active = e.value;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _weekDays[e.key] = !e.value);
              },
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.accentTeal.withAlpha(25)
                      : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color: active
                        ? AppTheme.accentTeal
                        : AppTheme.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    e.key,
                    style: TextStyle(
                      color: active ? AppTheme.accentTeal : AppTheme.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate(delay: 250.ms).fadeIn(duration: 300.ms);
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
              content: const Text('Availability updated!'),
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

  Color _statusColor(String s) {
    switch (s) {
      case 'Available Now':
        return AppTheme.accentTeal;
      case 'Busy':
        return AppTheme.accentGold;
      case 'Offline':
        return AppTheme.accentCoral;
      case 'Scheduled':
        return AppTheme.accentBlue;
      default:
        return AppTheme.textMuted;
    }
  }
}
