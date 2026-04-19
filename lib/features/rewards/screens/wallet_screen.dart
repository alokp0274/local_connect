// features/rewards/screens/wallet_screen.dart
// Feature: Rewards, Wallet & Loyalty
//
// Digital wallet with balance, top-up, and transaction history.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/rewards/data/rewards_dummy_data.dart';
import 'package:local_connect/features/rewards/models/rewards_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  WALLET SCREEN — Premium wallet experience
// ─────────────────────────────────────────────────────────

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  List<WalletTransaction> get _filteredTx {
    if (_selectedFilter == 'All') return walletTransactions;
    if (_selectedFilter == 'Credits') {
      return walletTransactions.where((t) => t.isCredit).toList();
    }
    return walletTransactions.where((t) => !t.isCredit).toList();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Wallet', style: tt.headlineMedium)),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Balance Hero ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                  child: AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withAlpha(
                                (35 * _glowCtrl.value).round(),
                              ),
                              blurRadius: 25 + 12 * _glowCtrl.value,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: GlassContainer(
                      padding: EdgeInsets.all(isCompact ? 16 : 22),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      gradient: AppTheme.primarySubtleGradient,
                      border: Border.all(
                        color: AppTheme.accentGold.withAlpha(80),
                        width: 0.8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withAlpha(30),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSM,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: AppTheme.accentGold,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withAlpha(25),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: AppTheme.accentTeal,
                                      size: 8,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Active',
                                      style: TextStyle(
                                        color: AppTheme.accentTeal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Total Balance',
                            style: tt.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\u20b9${walletBalance.toStringAsFixed(0)}',
                            style: tt.displayLarge?.copyWith(
                              fontSize: isCompact ? 34 : 40,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentGold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Breakdown pills
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _BalancePill(
                                label: 'Cashback',
                                value:
                                    '\u20b9${walletCashback.toStringAsFixed(0)}',
                                icon: Icons.savings_rounded,
                                color: AppTheme.accentTeal,
                              ),
                              _BalancePill(
                                label: 'Promo',
                                value:
                                    '\u20b9${walletPromo.toStringAsFixed(0)}',
                                icon: Icons.local_offer_rounded,
                                color: AppTheme.accentPurple,
                              ),
                              _BalancePill(
                                label: 'Rewards',
                                value:
                                    '\u20b9${walletRewards.toStringAsFixed(0)}',
                                icon: Icons.emoji_events_rounded,
                                color: AppTheme.accentGold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
              ),

              // ── Quick Actions ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _WalletAction(
                          label: 'Add Credits',
                          icon: Icons.add_rounded,
                          color: AppTheme.accentGold,
                          onTap: () =>
                              _showSnack('Add credits flow coming soon'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _WalletAction(
                          label: 'Redeem',
                          icon: Icons.redeem_rounded,
                          color: AppTheme.accentPurple,
                          onTap: () =>
                              _showSnack('Credits applied to next booking'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _WalletAction(
                          label: 'History',
                          icon: Icons.receipt_long_rounded,
                          color: AppTheme.accentTeal,
                          onTap: () =>
                              _showSnack('Showing all transactions below'),
                        ),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                ),
              ),

              // ── Filter Chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transactions',
                        style: tt.headlineMedium?.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['All', 'Credits', 'Debits'].map((f) {
                          final selected = _selectedFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedFilter = f);
                              },
                              child: AnimatedContainer(
                                duration: AppTheme.durationFast,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppTheme.accentGold.withAlpha(20)
                                      : AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.accentGold.withAlpha(80)
                                        : AppTheme.border,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: selected
                                        ? AppTheme.accentGold
                                        : AppTheme.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Transaction List ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 12, pad, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final tx = _filteredTx[i];
                    return _TransactionTile(tx: tx, index: i);
                  }, childCount: _filteredTx.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _BalancePill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: color.withAlpha(40), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _WalletAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withAlpha(50), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  final int index;
  const _TransactionTile({required this.tx, required this.index});

  Color get _color {
    switch (tx.type) {
      case WalletTxType.cashback:
        return AppTheme.accentTeal;
      case WalletTxType.promo:
        return AppTheme.accentPurple;
      case WalletTxType.debit:
        return AppTheme.accentCoral;
      case WalletTxType.reward:
        return AppTheme.accentGold;
      case WalletTxType.referral:
        return AppTheme.accentBlue;
    }
  }

  IconData get _icon {
    switch (tx.type) {
      case WalletTxType.cashback:
        return Icons.savings_rounded;
      case WalletTxType.promo:
        return Icons.card_giftcard_rounded;
      case WalletTxType.debit:
        return Icons.arrow_upward_rounded;
      case WalletTxType.reward:
        return Icons.emoji_events_rounded;
      case WalletTxType.referral:
        return Icons.people_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _color.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(_icon, color: _color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (tx.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        tx.subtitle!,
                        style: tt.labelSmall?.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tx.isCredit
                        ? '+\u20b9${tx.amount.abs().toStringAsFixed(0)}'
                        : '-\u20b9${tx.amount.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: tx.isCredit
                          ? AppTheme.accentTeal
                          : AppTheme.accentCoral,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.date,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: (100 + index * 40).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: -0.03);
  }
}
