// features/booking/screens/invoice_screen.dart
// Feature: Booking & Payment Flow
//
// Detailed invoice view for a completed booking with download option.

import 'package:flutter/material.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class InvoiceScreen extends StatelessWidget {
  final String bookingId;

  const InvoiceScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Invoice'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share invoice (mock)')),
              );
            },
            icon: const Icon(Icons.share_rounded, color: AppTheme.accentGold),
          ),
        ],
      ),
      body: AnimatedMeshBackground(
        subtle: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 24),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              gradient: AppTheme.cardGradient,
              child: Column(
                children: [
                  const Text(
                    'LOCALCONNECT',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookingId,
                    style: tt.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Tax Invoice', style: tt.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InvoiceCard(
              title: 'Booking Details',
              rows: const [
                _InvoiceRow('Provider', 'Rajesh Kumar'),
                _InvoiceRow('Service', 'Plumber'),
                _InvoiceRow('Date', '15 Jul 2026'),
                _InvoiceRow('Time', '10:00 AM'),
                _InvoiceRow('Address', '42, MG Road, Sector 14'),
              ],
            ),
            const SizedBox(height: 12),
            _InvoiceCard(
              title: 'Charges',
              rows: const [
                _InvoiceRow('Service Charge', '₹899'),
                _InvoiceRow('Platform Fee', '₹29'),
                _InvoiceRow('GST (5%)', '₹45'),
                _InvoiceRow('Discount', '-₹0'),
                _InvoiceRow('Total Paid', '₹973', highlight: true),
              ],
            ),
            const SizedBox(height: 12),
            _InvoiceCard(
              title: 'Payment Details',
              rows: const [
                _InvoiceRow('Method', 'UPI'),
                _InvoiceRow('Status', 'Paid'),
                _InvoiceRow('Txn ID', 'TXN-9583021'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download invoice (mock)'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shared successfully (mock)'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final String title;
  final List<_InvoiceRow> rows;

  const _InvoiceCard({required this.title, required this.rows});

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
          ...rows.map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.label,
                      style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted),
                    ),
                  ),
                  Text(
                    r.value,
                    style: tt.titleMedium?.copyWith(
                      color: r.highlight
                          ? AppTheme.accentGold
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InvoiceRow {
  final String label;
  final String value;
  final bool highlight;

  const _InvoiceRow(this.label, this.value, {this.highlight = false});
}
