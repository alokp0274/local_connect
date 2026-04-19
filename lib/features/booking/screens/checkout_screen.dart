// features/booking/screens/checkout_screen.dart
// Feature: Booking & Payment Flow
//
// Checkout summary with price breakdown, coupon entry, and payment options.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class CheckoutScreen extends StatefulWidget {
  final String providerName;
  final String serviceName;
  final String date;
  final String time;
  final String price;

  const CheckoutScreen({
    super.key,
    required this.providerName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.price,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _loading = false;
  int _paymentMethod = 0;
  int _addressIndex = 0;
  final _promoController = TextEditingController();

  final List<String> _addresses = const [
    '42, MG Road, Sector 14',
    'Office - 21, Grand Towers',
    'Home - 118, Park Avenue',
  ];

  Future<void> _confirm() async {
    HapticFeedback.selectionClick();
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushNamed(context, AppRoutes.paymentSuccess);
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  int get _basePrice {
    final raw = widget.price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 499;
  }

  int get _platformFee => 29;
  int get _tax => (_basePrice * 0.05).round();
  int get _discount =>
      _promoController.text.trim().toUpperCase() == 'SAVE50' ? 50 : 0;
  int get _total => _basePrice + _platformFee + _tax - _discount;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Checkout'),
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 110),
          children: [
            _SectionCard(
              title: 'Service Summary',
              child: Column(
                children: [
                  _SummaryRow(label: 'Provider', value: widget.providerName),
                  _SummaryRow(label: 'Service', value: widget.serviceName),
                  _SummaryRow(label: 'Date', value: widget.date),
                  _SummaryRow(label: 'Time', value: widget.time),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Address',
              child: Column(
                children: List.generate(_addresses.length, (i) {
                  final selected = _addressIndex == i;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _addressIndex = i);
                    },
                    child: AnimatedContainer(
                      duration: AppTheme.durationFast,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accentBlue.withAlpha(18)
                            : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        border: Border.all(
                          color: selected
                              ? AppTheme.accentBlue
                              : AppTheme.border,
                          width: 0.7,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: selected
                                ? AppTheme.accentBlue
                                : AppTheme.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _addresses[i],
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Promo Code',
              child: Column(
                children: [
                  TextField(
                    controller: _promoController,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Enter code (try SAVE50)',
                      prefixIcon: Icon(Icons.local_offer_rounded),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _discount > 0
                          ? 'Promo applied: -₹$_discount'
                          : 'No discount applied',
                      style: TextStyle(
                        color: _discount > 0
                            ? AppTheme.accentTeal
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Payment Method',
              child: Column(
                children: [
                  _PaymentOption(
                    value: 0,
                    group: _paymentMethod,
                    icon: Icons.credit_card_rounded,
                    label: 'Card',
                    onTap: () => setState(() => _paymentMethod = 0),
                  ),
                  _PaymentOption(
                    value: 1,
                    group: _paymentMethod,
                    icon: Icons.qr_code_2_rounded,
                    label: 'UPI',
                    onTap: () => setState(() => _paymentMethod = 1),
                  ),
                  _PaymentOption(
                    value: 2,
                    group: _paymentMethod,
                    icon: Icons.payments_rounded,
                    label: 'Cash',
                    onTap: () => setState(() => _paymentMethod = 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Price Breakdown',
              child: Column(
                children: [
                  _SummaryRow(label: 'Service', value: '₹$_basePrice'),
                  _SummaryRow(label: 'Platform Fee', value: '₹$_platformFee'),
                  _SummaryRow(label: 'Taxes', value: '₹$_tax'),
                  _SummaryRow(
                    label: 'Discount',
                    value: '-₹$_discount',
                    valueColor: _discount > 0
                        ? AppTheme.accentTeal
                        : AppTheme.textMuted,
                  ),
                  const Divider(color: AppTheme.surfaceDivider),
                  _SummaryRow(
                    label: 'Total Amount',
                    value: '₹$_total',
                    highlight: true,
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 260.ms),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 8, pad, 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: tt.labelSmall),
                      Text(
                        '₹$_total',
                        style: tt.headlineMedium?.copyWith(
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirm,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm Booking'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              color:
                  valueColor ??
                  (highlight ? AppTheme.accentGold : AppTheme.textPrimary),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final int value;
  final int group;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.value,
    required this.group,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentGold.withAlpha(15)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: selected ? AppTheme.accentGold : AppTheme.border,
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.accentGold : AppTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppTheme.accentGold : AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
