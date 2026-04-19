// features/booking/screens/select_slot_screen.dart
// Feature: Booking & Payment Flow
//
// Date & time slot picker for scheduling a service appointment.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class SelectSlotScreen extends StatefulWidget {
  final String providerName;

  const SelectSlotScreen({super.key, required this.providerName});

  @override
  State<SelectSlotScreen> createState() => _SelectSlotScreenState();
}

class _SelectSlotScreenState extends State<SelectSlotScreen> {
  int _selectedDateIndex = 0;
  String? _selectedSlot;

  late final List<Map<String, String>> _dates;

  final Map<String, List<String>> _slotGroups = const {
    'Morning': ['09:00 AM', '10:00 AM', '11:30 AM'],
    'Afternoon': ['12:30 PM', '02:00 PM', '03:30 PM'],
    'Evening': ['05:00 PM', '06:30 PM', '08:00 PM'],
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    _dates = List.generate(14, (i) {
      final d = now.add(Duration(days: i));
      return {
        'day': dayNames[d.weekday - 1],
        'date': '${d.day}',
        'month': monthNames[d.month - 1],
        'full': '${d.day} ${monthNames[d.month - 1]} ${d.year}',
      };
    });
  }

  void _jumpToToday() => setState(() => _selectedDateIndex = 0);
  void _jumpToTomorrow() => setState(() => _selectedDateIndex = 1);

  void _continue() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a slot to continue')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.checkout,
      arguments: {
        'providerName': widget.providerName,
        'serviceName': 'Premium Service Package',
        'date': _dates[_selectedDateIndex]['full'],
        'time': _selectedSlot,
        'price': '₹899',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Select Slot'),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 100),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.providerName, style: tt.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your preferred date and time',
                    style: tt.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _ShortcutChip(label: 'Today', onTap: _jumpToToday),
                const SizedBox(width: 8),
                _ShortcutChip(label: 'Tomorrow', onTap: _jumpToTomorrow),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Calendar',
              style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                itemBuilder: (_, i) {
                  final selected = _selectedDateIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = i),
                    child: AnimatedContainer(
                      duration: AppTheme.durationFast,
                      width: 68,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        gradient: selected ? AppTheme.primaryGradient : null,
                        color: selected ? null : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: selected
                            ? null
                            : Border.all(
                                color: AppTheme.border,
                                width: 0.6,
                              ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _dates[i]['day']!,
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.textOnAccent
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _dates[i]['date']!,
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.textOnAccent
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            _dates[i]['month']!,
                            style: TextStyle(
                              color: selected
                                  ? AppTheme.textOnAccent
                                  : AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            ..._slotGroups.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: tt.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((slot) {
                          final selected = _selectedSlot == slot;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedSlot = slot);
                            },
                            child: AnimatedContainer(
                              duration: AppTheme.durationFast,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: selected
                                    ? null
                                    : AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                                border: selected
                                    ? null
                                    : Border.all(
                                        color: AppTheme.border,
                                        width: 0.5,
                                      ),
                                boxShadow: selected ? AppTheme.softGlow : null,
                              ),
                              child: Text(
                                slot,
                                style: TextStyle(
                                  color: selected
                                      ? AppTheme.textOnAccent
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ).animate().fadeIn(duration: 280.ms),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 8, pad, 12),
          child: ElevatedButton.icon(
            onPressed: _continue,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              _selectedSlot == null ? 'Continue' : 'Continue • $_selectedSlot',
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ShortcutChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.border, width: 0.6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
