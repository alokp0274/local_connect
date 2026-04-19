// features/provider_mode/screens/provider_earnings_screen.dart
// Feature: Provider Mode (Business Dashboard)
//
// Earnings summary with charts, withdrawal, and transaction history.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/provider_mode/data/provider_dummy_data.dart';
import 'package:local_connect/features/provider_mode/models/lead_model.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({super.key});
  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> {
  String _period = 'This Month';

  double get _totalEarnings => dummyEarnings
      .where((e) => e.status == EarningStatus.completed)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get _pendingEarnings => dummyEarnings
      .where((e) => e.status != EarningStatus.completed)
      .fold(0.0, (sum, e) => sum + e.amount);

  int get _completedJobs =>
      dummyEarnings.where((e) => e.status == EarningStatus.completed).length;

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
                      _buildHeroCard(tt),
                      const SizedBox(height: 16),
                      _buildPeriodSelector(tt),
                      const SizedBox(height: 16),
                      _buildStatsRow(tt),
                      const SizedBox(height: 16),
                      _buildMiniChart(tt),
                      const SizedBox(height: 20),
                      _buildTransactionList(tt),
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
              'Earnings',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildHeroCard(TextTheme tt) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      gradient: LinearGradient(
        colors: [
          AppTheme.accentGold.withAlpha(20),
          AppTheme.accentGold.withAlpha(5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\u20b9${_totalEarnings.toStringAsFixed(0)}',
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppTheme.accentTeal,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+18% vs last month',
                      style: TextStyle(
                        color: AppTheme.accentTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildPeriodSelector(TextTheme tt) {
    return Row(
      children: ['Today', 'This Week', 'This Month', 'All Time'].map((p) {
        final sel = _period == p;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _period = p),
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? AppTheme.accentGold.withAlpha(25)
                    : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(
                  color: sel ? AppTheme.accentGold : AppTheme.border,
                  width: sel ? 1.0 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  p,
                  style: TextStyle(
                    color: sel ? AppTheme.accentGold : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).animate(delay: 150.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildStatsRow(TextTheme tt) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Completed Jobs',
            value: '$_completedJobs',
            color: AppTheme.accentTeal,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Pending Payout',
            value: '\u20b9${_pendingEarnings.toStringAsFixed(0)}',
            color: AppTheme.accentBlue,
            icon: Icons.hourglass_top_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Avg / Job',
            value:
                '\u20b9${_completedJobs > 0 ? (_totalEarnings / _completedJobs).toStringAsFixed(0) : '0'}',
            color: AppTheme.accentPurple,
            icon: Icons.analytics_outlined,
          ),
        ),
      ],
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildMiniChart(TextTheme tt) {
    // Simplified bar chart
    final weekData = [3200, 2800, 4100, 3600, 4800, 3900, 2500];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = weekData.reduce((a, b) => a > b ? a : b).toDouble();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Overview',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weekData.length, (i) {
                final h = (weekData[i] / maxVal) * 80;
                final isToday = i == DateTime.now().weekday - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\u20b9${(weekData[i] / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            color: isToday
                                ? AppTheme.accentGold
                                : AppTheme.textMuted,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: AppTheme.durationMedium,
                          height: h,
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? AppTheme.primaryGradient
                                : LinearGradient(
                                    colors: [
                                      AppTheme.accentTeal.withAlpha(80),
                                      AppTheme.accentTeal.withAlpha(40),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusXS,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days[i],
                          style: TextStyle(
                            color: isToday
                                ? AppTheme.accentGold
                                : AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 300.ms);
  }

  Widget _buildTransactionList(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: tt.labelLarge?.copyWith(color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        ...List.generate(dummyEarnings.length, (i) {
          final e = dummyEarnings[i];
          final statusColor = e.status == EarningStatus.completed
              ? AppTheme.accentTeal
              : e.status == EarningStatus.pending
              ? AppTheme.accentGold
              : AppTheme.accentBlue;
          final statusText = e.status == EarningStatus.completed
              ? 'Completed'
              : e.status == EarningStatus.pending
              ? 'Pending'
              : 'Processing';

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
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Icon(
                    e.status == EarningStatus.completed
                        ? Icons.check_circle_rounded
                        : Icons.hourglass_top_rounded,
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.service,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${e.customerName} \u2022 ${e.date}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\u20b9${e.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor.withAlpha(150),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: (300 + i * 50).ms).fadeIn(duration: 250.ms);
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
