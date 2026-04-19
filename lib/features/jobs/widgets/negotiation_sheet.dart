// features/jobs/widgets/negotiation_sheet.dart
// Feature: Jobs Feed — Negotiation Flow
//
// Bottom sheet for accepting or counter-offering a provider bid.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/jobs/models/job_model.dart';

/// Shows the "Accept or Negotiate?" bottom sheet.
/// Returns the action taken via [onAccept] / [onCounterOffer].
Future<void> showNegotiationSheet(
  BuildContext context, {
  required JobBid bid,
  required VoidCallback onAccept,
  required void Function(int amount, String note) onCounterOffer,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NegotiationSheet(
      bid: bid,
      onAccept: onAccept,
      onCounterOffer: onCounterOffer,
    ),
  );
}

class _NegotiationSheet extends StatefulWidget {
  final JobBid bid;
  final VoidCallback onAccept;
  final void Function(int amount, String note) onCounterOffer;

  const _NegotiationSheet({
    required this.bid,
    required this.onAccept,
    required this.onCounterOffer,
  });

  @override
  State<_NegotiationSheet> createState() => _NegotiationSheetState();
}

class _NegotiationSheetState extends State<_NegotiationSheet> {
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  bool _showCounterForm = false;
  String? _error;

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isMaxRounds => widget.bid.negotiationRound >= 3;

  void _sendCounter() {
    final raw = _priceController.text.trim();
    final amount = int.tryParse(raw.replaceAll(RegExp(r'[^\d]'), ''));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid price');
      return;
    }
    if (amount >= widget.bid.bidAmount) {
      setState(
        () => _error = 'Counter must be less than ₹${widget.bid.bidAmount}',
      );
      return;
    }
    Navigator.pop(context);
    widget.onCounterOffer(amount, _noteController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1628),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Text(
            '${widget.bid.providerName.split(' ').first} is offering ₹${widget.bid.bidAmount}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          // ── Accept button ──
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              widget.onAccept();
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withAlpha(22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.accentTeal.withAlpha(100),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentTeal,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Accept Bid',
                    style: TextStyle(
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!_isMaxRounds) ...[
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFF1E2A40))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or make a counter offer',
                      style: TextStyle(
                        color: AppTheme.textMuted.withAlpha(180),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFF1E2A40))),
                ],
              ),
            ),

            // Counter offer form (expandable)
            if (!_showCounterForm)
              GestureDetector(
                onTap: () => setState(() => _showCounterForm = true),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.accentGold.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sync_alt_rounded,
                        color: AppTheme.accentGold,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Make Counter Offer',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Price field
              _FieldLabel('Your counter price'),
              const SizedBox(height: 6),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 300',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(
                    Icons.currency_rupee_rounded,
                    color: AppTheme.accentGold,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A2235),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E2A40),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.accentGold,
                      width: 1.2,
                    ),
                  ),
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 12),

              // Note field
              _FieldLabel('Add a note (optional)'),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Can you do it for less?',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: const Color(0xFF1A2235),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E2A40),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.accentGold,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Send button
              GestureDetector(
                onTap: _sendCounter,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withAlpha(60),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        color: AppTheme.textOnAccent,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Send Counter Offer',
                        style: TextStyle(
                          color: AppTheme.textOnAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEF4444).withAlpha(50),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Maximum 3 negotiation rounds reached. You can only Accept or Decline.',
                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
