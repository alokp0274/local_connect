// features/jobs/widgets/bid_card.dart
// Feature: Jobs Feed — Bid Cards
//
// Reusable bid card with provider info, bid amount, and accept/negotiate CTA.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/jobs/models/job_model.dart';

class BidCard extends StatelessWidget {
  final JobBid bid;
  final int index;
  final VoidCallback? onAccept; // opens negotiation sheet
  final VoidCallback? onCall;

  const BidCard({
    super.key,
    required this.bid,
    this.index = 0,
    this.onAccept,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2235),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E2A40), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Provider info ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primarySubtleGradient,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: bid.providerVerified
                              ? AppTheme.accentBlue.withAlpha(80)
                              : AppTheme.border,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          bid.providerName.isNotEmpty
                              ? bid.providerName[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  bid.providerName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (bid.providerVerified) ...[
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppTheme.accentBlue,
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.accentGold,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${bid.providerRating.toStringAsFixed(1)} (${bid.providerReviews} reviews)',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${bid.providerExperience} yrs  •  ${bid.providerJobsDone} jobs done',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divider ──
              const Divider(height: 1, color: Color(0xFF1E2A40)),

              // ── Bid message ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Text(
                  bid.message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Negotiation status chip (if active) ──
              if (bid.status == 'negotiating' && bid.counterAmount != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: _NegotiationChip(bid: bid),
                ),

              // ── Divider ──
              const Divider(height: 1, color: Color(0xFF1E2A40)),

              // ── Price + time + CTA ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Row(
                  children: [
                    Text(
                      '₹${bid.bidAmount}',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        bid.postedAgo,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Call button
                    if (onCall != null)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onCall!();
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withAlpha(22),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.accentTeal.withAlpha(70),
                              width: 0.7,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                color: AppTheme.accentTeal,
                                size: 14,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Call',
                                style: TextStyle(
                                  color: AppTheme.accentTeal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (onAccept != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onAccept!();
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: bid.status == 'negotiating'
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF34D399),
                                    ],
                                  )
                                : AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                bid.status == 'negotiating'
                                    ? Icons.handshake_rounded
                                    : Icons.check_rounded,
                                color: bid.status == 'negotiating'
                                    ? Colors.white
                                    : AppTheme.textOnAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                bid.status == 'negotiating'
                                    ? 'Negotiate'
                                    : 'Accept Bid',
                                style: TextStyle(
                                  color: bid.status == 'negotiating'
                                      ? Colors.white
                                      : AppTheme.textOnAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────
// NEGOTIATION STATUS CHIP
// ─────────────────────────────────────────

class _NegotiationChip extends StatelessWidget {
  final JobBid bid;
  const _NegotiationChip({required this.bid});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    if (bid.status == 'negotiating') {
      color = const Color(0xFFFACC15);
      icon = Icons.sync_rounded;
      label = 'Counter: ₹${bid.counterAmount} sent — Awaiting response';
    } else if (bid.status == 'accepted') {
      color = AppTheme.accentTeal;
      icon = Icons.check_circle_rounded;
      label = 'Accepted ₹${bid.counterAmount ?? bid.bidAmount} — Book Now';
    } else {
      color = const Color(0xFFEF4444);
      icon = Icons.cancel_rounded;
      label = 'Counter rejected — Original ₹${bid.bidAmount}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60), width: 0.7),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.85, 0.85),
      duration: 200.ms,
      curve: Curves.easeOutBack,
    );
  }
}
