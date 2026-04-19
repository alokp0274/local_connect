// features/jobs/widgets/apply_bottom_sheet.dart
// Feature: Job Posts & Service Requests
//
// Bottom sheet for a provider to apply/respond to a job posting.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/jobs/data/job_post_data.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

// ─────────────────────────────────────────────────────────
//  APPLY BOTTOM SHEET — Provider applies to a job post
// ─────────────────────────────────────────────────────────

class ApplyBottomSheet extends StatefulWidget {
  final JobPost jobPost;
  const ApplyBottomSheet({super.key, required this.jobPost});

  @override
  State<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends State<ApplyBottomSheet> {
  final _priceCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _eta = 'Within 30 mins';
  bool _canStartNow = false;
  bool _submitting = false;
  bool _submitted = false;

  static const _etaOptions = [
    'Within 30 mins',
    'Within 1 hour',
    'Within 2 hours',
    'Today',
    'Tomorrow',
  ];

  @override
  void dispose() {
    _priceCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.surfaceCard,
          content: Text(
            'Please enter your price offer',
            style: TextStyle(color: AppTheme.accentCoral),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final newApp = JobApplication(
      id: 'app-new-${DateTime.now().millisecondsSinceEpoch}',
      jobId: widget.jobPost.id,
      providerName: 'You',
      providerService: widget.jobPost.category,
      providerInitial: 'Y',
      providerRating: 4.8,
      providerReviewCount: 45,
      providerDistance: '1.2 km',
      providerExperience: '5 yrs',
      providerVerified: true,
      priceOffer: '₹${_priceCtrl.text.trim()}',
      message: _messageCtrl.text.trim(),
      eta: _eta,
      canStartNow: _canStartNow,
      appliedTime: 'Just now',
      status: ApplicationStatus.pending,
    );

    dummyApplications.add(newApp);

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
    });

    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.jobPost;
    final bot = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bot),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: _submitted ? _buildSuccess() : _buildForm(j),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.tealGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ).animate().scale(
            begin: const Offset(0, 0),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 16),
          const Text(
            'Application Sent!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You applied for "${widget.jobPost.title}"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildForm(JobPost j) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ──
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),

            // ── Header ──
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Apply for Job',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(6),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Job summary ──
            GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          j.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${j.category} · ${j.area}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (j.budget != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primarySubtleGradient,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        j.budget!,
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Price offer ──
            const Text(
              'Your Price Offer *',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. 500',
                hintStyle: TextStyle(color: AppTheme.textMuted.withAlpha(100)),
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Message ──
            const Text(
              'Message (optional)',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _messageCtrl,
              maxLines: 3,
              maxLength: 200,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Introduce yourself and share relevant experience...',
                hintStyle: TextStyle(color: AppTheme.textMuted.withAlpha(100)),
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
                counterStyle: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── ETA ──
            const Text(
              'Estimated Arrival',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _etaOptions.map((e) {
                final active = _eta == e;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _eta = e);
                  },
                  child: AnimatedContainer(
                    duration: AppTheme.durationFast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: active ? AppTheme.primarySubtleGradient : null,
                      color: active ? null : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: active
                          ? Border.all(color: AppTheme.accentGold.withAlpha(50))
                          : null,
                    ),
                    child: Text(
                      e,
                      style: TextStyle(
                        color: active
                            ? AppTheme.accentGold
                            : AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // ── Can start now toggle ──
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _canStartNow = !_canStartNow);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _canStartNow
                      ? AppTheme.accentTeal.withAlpha(10)
                      : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: _canStartNow
                      ? Border.all(color: AppTheme.accentTeal.withAlpha(40))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _canStartNow
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: _canStartNow
                          ? AppTheme.accentTeal
                          : AppTheme.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'I can start immediately',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _submitting ? null : _submit,
                child: AnimatedContainer(
                  duration: AppTheme.durationFast,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: _submitting ? null : AppTheme.primaryGradient,
                    color: _submitting ? AppTheme.surfaceElevated : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Center(
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppTheme.accentGold,
                              ),
                            ),
                          )
                        : const Text(
                            'Send Application',
                            style: TextStyle(
                              color: AppTheme.textOnAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
