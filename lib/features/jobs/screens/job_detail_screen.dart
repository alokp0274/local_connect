// features/jobs/screens/job_detail_screen.dart
// Feature: Jobs Feed — Job Detail + Bids + Negotiation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/jobs/models/job_model.dart';
import 'package:local_connect/features/jobs/widgets/bid_card.dart';
import 'package:local_connect/features/jobs/widgets/negotiation_sheet.dart';


class JobDetailScreen extends StatefulWidget {
  final JobPost job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late JobPost _job;
  bool _bidFormOpen = false;
  final _bidMsgController = TextEditingController();
  final _bidAmountController = TextEditingController();
  String? _bidError;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  @override
  void dispose() {
    _bidMsgController.dispose();
    _bidAmountController.dispose();
    super.dispose();
  }

  void _openNegotiation(JobBid bid) {
    showNegotiationSheet(
      context,
      bid: bid,
      onAccept: () => _acceptBid(bid),
      onCounterOffer: (amount, note) => _sendCounter(bid, amount, note),
    );
  }

  void _acceptBid(JobBid bid) {
    final newBid = JobBid(
      providerId: bid.providerId,
      providerName: bid.providerName,
      providerRating: bid.providerRating,
      providerReviews: bid.providerReviews,
      providerExperience: bid.providerExperience,
      providerJobsDone: bid.providerJobsDone,
      providerVerified: bid.providerVerified,
      message: bid.message,
      bidAmount: bid.bidAmount,
      postedAgo: bid.postedAgo,
      status: 'accepted',
      counterAmount: bid.counterAmount,
      counterNote: bid.counterNote,
      negotiationRound: bid.negotiationRound,
    );
    setState(() {
      final bids = List<JobBid>.from(_job.bids);
      final idx = bids.indexWhere((b) => b.providerId == bid.providerId);
      if (idx != -1) bids[idx] = newBid;
      _job = JobPost(
        id: _job.id,
        customerId: _job.customerId,
        customerName: _job.customerName,
        customerRating: _job.customerRating,
        customerVerified: _job.customerVerified,
        title: _job.title,
        description: _job.description,
        category: _job.category,
        urgency: _job.urgency,
        location: _job.location,
        pincode: _job.pincode,
        distanceKm: _job.distanceKm,
        budgetMin: _job.budgetMin,
        budgetMax: _job.budgetMax,
        preferredDate: _job.preferredDate,
        preferredTime: _job.preferredTime,
        postedAgo: _job.postedAgo,
        status: 'inProgress',
        bids: bids,
        imageUrl: _job.imageUrl,
      );
    });
    _showSnack('Bid accepted! 🎉 Job is now in progress.');
  }

  void _sendCounter(JobBid bid, int amount, String note) {
    final newBid = JobBid(
      providerId: bid.providerId,
      providerName: bid.providerName,
      providerRating: bid.providerRating,
      providerReviews: bid.providerReviews,
      providerExperience: bid.providerExperience,
      providerJobsDone: bid.providerJobsDone,
      providerVerified: bid.providerVerified,
      message: bid.message,
      bidAmount: bid.bidAmount,
      postedAgo: bid.postedAgo,
      status: 'negotiating',
      counterAmount: amount,
      counterNote: note.isEmpty ? null : note,
      negotiationRound: bid.negotiationRound + 1,
    );
    setState(() {
      final bids = List<JobBid>.from(_job.bids);
      final idx = bids.indexWhere((b) => b.providerId == bid.providerId);
      if (idx != -1) bids[idx] = newBid;
      _job = JobPost(
        id: _job.id,
        customerId: _job.customerId,
        customerName: _job.customerName,
        customerRating: _job.customerRating,
        customerVerified: _job.customerVerified,
        title: _job.title,
        description: _job.description,
        category: _job.category,
        urgency: _job.urgency,
        location: _job.location,
        pincode: _job.pincode,
        distanceKm: _job.distanceKm,
        budgetMin: _job.budgetMin,
        budgetMax: _job.budgetMax,
        preferredDate: _job.preferredDate,
        preferredTime: _job.preferredTime,
        postedAgo: _job.postedAgo,
        status: _job.status,
        bids: bids,
        imageUrl: _job.imageUrl,
      );
    });
    _showSnack('Counter offer of ₹$amount sent!');
  }

  void _submitBid() {
    final msg = _bidMsgController.text.trim();
    final raw = _bidAmountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = int.tryParse(raw);
    if (msg.isEmpty) {
      setState(() => _bidError = 'Add a message for your bid');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _bidError = 'Enter a valid bid amount');
      return;
    }
    final newBid = JobBid(
      providerId: 'provider-you',
      providerName: 'You',
      providerRating: 4.7,
      providerReviews: 24,
      providerExperience: 3,
      providerJobsDone: 24,
      providerVerified: true,
      message: msg,
      bidAmount: amount,
      postedAgo: 'Just now',
      status: 'pending',
      negotiationRound: 0,
    );
    setState(() {
      final bids = List<JobBid>.from(_job.bids)..add(newBid);
      _job = JobPost(
        id: _job.id,
        customerId: _job.customerId,
        customerName: _job.customerName,
        customerRating: _job.customerRating,
        customerVerified: _job.customerVerified,
        title: _job.title,
        description: _job.description,
        category: _job.category,
        urgency: _job.urgency,
        location: _job.location,
        pincode: _job.pincode,
        distanceKm: _job.distanceKm,
        budgetMin: _job.budgetMin,
        budgetMax: _job.budgetMax,
        preferredDate: _job.preferredDate,
        preferredTime: _job.preferredTime,
        postedAgo: _job.postedAgo,
        status: _job.status,
        bids: bids,
        imageUrl: _job.imageUrl,
      );
      _bidFormOpen = false;
      _bidError = null;
    });
    _bidMsgController.clear();
    _bidAmountController.clear();
    _showSnack('Your bid of ₹$amount has been sent!');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool get _isOwnJob => _job.customerId == 'user-current';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──
          SliverToBoxAdapter(
            child: _DetailHeader(job: _job, topPad: topPad),
          ),

          // ── Job image ──
          if (_job.imageUrl != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 200,
                    color: const Color(0xFF1A2235),
                    child: Image.network(
                      _job.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_rounded, color: AppTheme.textMuted, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Description section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SectionCard(
                children: [
                  const Text('Description', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(_job.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6)),
                ],
              ),
            ),
          ),

          // ── Details section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _SectionCard(
                children: [
                  const Text('Details', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  _DetailRow(icon: Icons.location_on_outlined, label: 'Location', value: _job.location),
                  _DetailRow(icon: Icons.currency_rupee_rounded, label: 'Budget', value: '₹${_job.budgetMin} – ₹${_job.budgetMax}'),
                  _DetailRow(icon: Icons.calendar_today_rounded, label: 'Preferred Date', value: _job.preferredDate),
                  _DetailRow(icon: Icons.access_time_rounded, label: 'Preferred Time', value: _job.preferredTime),
                  _DetailRow(icon: Icons.schedule_rounded, label: 'Closes In', value: _job.closesIn),
                ],
              ),
            ),
          ),

          // ── Bid section header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  const Text('Bids', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withAlpha(20),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${_job.bidCount}',
                      style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bid cards ──
          if (_job.bids.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2235),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E2A40)),
                  ),
                  child: const Center(
                    child: Text('No bids yet. Be the first!', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => BidCard(
                    bid: _job.bids[i],
                    index: i,
                    onAccept: _isOwnJob ? () => _openNegotiation(_job.bids[i]) : null,
                    onCall: null,
                  ),
                  childCount: _job.bids.length,
                ),
              ),
            ),

          // ── Bid submit form (providers only) ──
          if (!_isOwnJob && _job.status == 'open')
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _BidSubmitSection(
                  isOpen: _bidFormOpen,
                  msgController: _bidMsgController,
                  amountController: _bidAmountController,
                  error: _bidError,
                  onToggle: () => setState(() { _bidFormOpen = !_bidFormOpen; _bidError = null; }),
                  onSubmit: _submitBid,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  final JobPost job;
  final double topPad;
  const _DetailHeader({required this.job, required this.topPad});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(job.urgency);
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 10, 20, 16),
      decoration: BoxDecoration(
        gradient: AppTheme.navBarGradient,
        border: const Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 24),
              ),
              const Spacer(),
              if (job.urgency != 'flexible')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: urgencyColor.withAlpha(22),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: urgencyColor.withAlpha(80)),
                  ),
                  child: Text(
                    job.urgency == 'emergency' ? '🚨 Emergency' : job.urgency == 'today' ? 'Today' : 'This Week',
                    style: TextStyle(color: urgencyColor, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            job.title,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 22, height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_rounded, color: AppTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Flexible(child: Text(job.customerName, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
              const SizedBox(width: 8),
              const Icon(Icons.location_on_outlined, color: AppTheme.textMuted, size: 13),
              const SizedBox(width: 3),
              Flexible(child: Text('${job.distanceKm.toStringAsFixed(1)} km away', overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
              const SizedBox(width: 8),
              Flexible(child: Text(job.postedAgo, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'emergency': return const Color(0xFFEF4444);
      case 'today': return const Color(0xFFFACC15);
      case 'thisWeek': return AppTheme.accentBlue;
      default: return AppTheme.textMuted;
    }
  }
}

// ─────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2A40)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

// ─────────────────────────────────────────
// DETAIL ROW
// ─────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 15),
          const SizedBox(width: 8),
          Flexible(child: Text('$label:  ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13))),
          Flexible(
            flex: 2,
            child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 2, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BID SUBMIT SECTION
// ─────────────────────────────────────────

class _BidSubmitSection extends StatelessWidget {
  final bool isOpen;
  final TextEditingController msgController;
  final TextEditingController amountController;
  final String? error;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  const _BidSubmitSection({
    required this.isOpen,
    required this.msgController,
    required this.amountController,
    required this.error,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onToggle();
        },
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppTheme.accentGold.withAlpha(70), blurRadius: 18)],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel_rounded, color: AppTheme.textOnAccent),
              SizedBox(width: 10),
              Text('Place Your Bid', style: TextStyle(color: AppTheme.textOnAccent, fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Place Your Bid', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              GestureDetector(
                onTap: onToggle,
                child: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 20),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: msgController,
            maxLines: 3,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Describe your approach, availability, and why you\'re the best fit…',
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1A2235),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E2A40))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.2)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Your bid amount',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppTheme.accentGold, size: 18),
              filled: true,
              fillColor: const Color(0xFF1A2235),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E2A40))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.2)),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onSubmit();
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: AppTheme.textOnAccent, size: 18),
                  SizedBox(width: 8),
                  Text('Submit Bid', style: TextStyle(color: AppTheme.textOnAccent, fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
