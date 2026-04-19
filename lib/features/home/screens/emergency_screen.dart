// features/home/screens/emergency_screen.dart
// Feature: Home & Dashboard
//
// Emergency services screen for urgent/on-demand service requests.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/shared/widgets/callback_request_sheet.dart';
import 'package:local_connect/shared/widgets/instant_connect_actions.dart';
import 'package:local_connect/features/chat/screens/chat_detail_screen.dart';
import 'package:local_connect/features/provider/screens/provider_detail_screen.dart';

class EmergencyScreen extends StatefulWidget {
  final String pincode;
  final String? preselectedCategory;
  const EmergencyScreen({super.key, required this.pincode, this.preselectedCategory});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategory = -1;
  bool _isLoading = false;
  List<ServiceProvider> _results = [];
  late AnimationController _pulseController;

  static const _categories = [
    _EmergencyCategory('Water Leak', Icons.water_damage_rounded, 'Plumber', Color(0xFF5B8DEF)),
    _EmergencyCategory('Power Failure', Icons.flash_on_rounded, 'Electrician', Color(0xFFFFB800)),
    _EmergencyCategory('Lock Problem', Icons.lock_rounded, 'Carpenter', Color(0xFF7B5EA7)),
    _EmergencyCategory('AC Urgent Repair', Icons.ac_unit_rounded, 'AC Repair', Color(0xFF06D6A0)),
    _EmergencyCategory('Cleaning Needed', Icons.cleaning_services_rounded, 'Cleaning', Color(0xFFFF6B6B)),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    if (widget.preselectedCategory != null) {
      final idx = _categories.indexWhere((c) => c.serviceType == widget.preselectedCategory);
      if (idx >= 0) { _selectedCategory = idx; _loadResults(idx); }
    }
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

  Future<void> _loadResults(int idx) async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final cat = _categories[idx];
    var list = dummyProviders.where((p) =>
      p.service.toLowerCase().contains(cat.serviceType.toLowerCase()) &&
      p.servesPincode(widget.pincode)).toList();
    list.sort((a, b) {
      if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
      final aT = a.responseTimeMinutes > 0 ? a.responseTimeMinutes : 30;
      final bT = b.responseTimeMinutes > 0 ? b.responseTimeMinutes : 30;
      if (aT != bT) return aT.compareTo(bT);
      return b.rating.compareTo(a.rating);
    });
    if (list.length < 2) {
      final broader = dummyProviders.where((p) =>
        p.service.toLowerCase().contains(cat.serviceType.toLowerCase())).toList();
      broader.sort((a, b) {
        if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
      for (final p in broader) { if (!list.any((e) => e.id == p.id)) list.add(p); }
    }
    setState(() { _results = list.take(8).toList(); _isLoading = false; });
  }

  Future<void> _makeCall(String phone) async {
    HapticFeedback.selectionClick();
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openChat(ServiceProvider provider) {
    var thread = activeChats.cast<ChatThread?>().firstWhere(
      (t) => t!.provider.id == provider.id, orElse: () => null);
    if (thread == null) {
      thread = ChatThread(provider: provider, messages: []);
      activeChats.add(thread);
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatDetailScreen(thread: thread!)));
  }

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.responsivePadding(context);
    final tt = Theme.of(context).textTheme;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // ── Top bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(10),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Emergency Help', style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800, color: AppTheme.accentCoral)),
                            Text('Fastest available near PIN ${widget.pincode}',
                              style: tt.bodySmall?.copyWith(color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) => Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.accentCoral.withAlpha((180 + 75 * _pulseController.value).round()),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: AppTheme.accentCoral.withAlpha((80 * _pulseController.value).round()),
                              blurRadius: 8 + 6 * _pulseController.value)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Alert banner ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentCoral.withAlpha(25), AppTheme.accentCoral.withAlpha(8)]),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(color: AppTheme.accentCoral.withAlpha(60), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.accentCoral.withAlpha(30),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
                          child: const Icon(Icons.priority_high_rounded, color: AppTheme.accentCoral, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select your emergency', style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700, color: AppTheme.accentCoral)),
                              const SizedBox(height: 2),
                              Text('We\u0027ll find fastest responders near you',
                                style: tt.bodySmall?.copyWith(color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 350.ms).slideY(begin: 0.05),
                ),
              ),

              // ── Categories ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = screenW < 360 ? 2 : (screenW < 480 ? 3 : 5);
                      return Wrap(
                        spacing: 10, runSpacing: 10,
                        children: List.generate(_categories.length, (i) {
                          final cat = _categories[i];
                          final selected = _selectedCategory == i;
                          final w = (constraints.maxWidth - (cols - 1) * 10) / cols;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = i);
                              _loadResults(i);
                            },
                            child: AnimatedContainer(
                              duration: AppTheme.durationFast,
                              width: w,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: selected ? cat.color.withAlpha(25) : AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                border: Border.all(
                                  color: selected ? cat.color.withAlpha(150) : AppTheme.border,
                                  width: selected ? 1.2 : 0.5),
                                boxShadow: selected
                                  ? [BoxShadow(color: cat.color.withAlpha(40), blurRadius: 16)] : null,
                              ),
                              child: Column(children: [
                                Icon(cat.icon, color: selected ? cat.color : AppTheme.textMuted, size: 26),
                                const SizedBox(height: 8),
                                Text(cat.label, textAlign: TextAlign.center, maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                    color: selected ? cat.color : AppTheme.textSecondary)),
                              ]),
                            ),
                          ).animate(delay: (150 + i * 60).ms).fadeIn(duration: 280.ms)
                            .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack);
                        }),
                      );
                    },
                  ),
                ),
              ),

              // ── Results header ──
              if (_selectedCategory >= 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCoral.withAlpha(20),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(color: AppTheme.accentCoral.withAlpha(60))),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.flash_on_rounded, color: AppTheme.accentCoral, size: 13),
                            SizedBox(width: 4),
                            Text('URGENT', style: TextStyle(color: AppTheme.accentCoral,
                              fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                          ]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          _isLoading ? 'Finding fastest responders...'
                            : '${_results.length} available in your area',
                          style: tt.bodySmall?.copyWith(color: AppTheme.textMuted))),
                      ],
                    ).animate().fadeIn(duration: 250.ms),
                  ),
                ),

              // ── Loading skeleton ──
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 12, pad, 20),
                    child: Column(children: List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Shimmer.fromColors(
                        baseColor: AppTheme.surfaceCard, highlightColor: AppTheme.surfaceElevated,
                        child: Container(height: 100, decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.radiusMD)))),
                    ))),
                  ),
                ),

              // ── Results ──
              if (!_isLoading && _selectedCategory >= 0)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 12, pad, 32),
                  sliver: _results.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState(tt))
                    : SliverList(delegate: SliverChildBuilderDelegate(
                        (context, index) => _EmergencyProviderCard(
                          provider: _results[index], pincode: widget.pincode, index: index,
                          cat: _categories[_selectedCategory],
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ProviderDetailScreen(provider: _results[index]))),
                          onCall: () => _makeCall(_results[index].phone),
                          onChat: () => _openChat(_results[index]),
                          onCallback: () => showCallbackRequestSheet(context,
                            providerName: _results[index].name),
                        ), childCount: _results.length)),
                ),

              // ── Idle state ──
              if (!_isLoading && _selectedCategory < 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 40, pad, 40),
                    child: Column(children: [
                      Icon(Icons.touch_app_rounded, color: AppTheme.textMuted.withAlpha(80), size: 48),
                      const SizedBox(height: 12),
                      Text('Tap a category above', style: tt.bodyMedium?.copyWith(color: AppTheme.textMuted)),
                      const SizedBox(height: 4),
                      Text('to find nearby emergency providers',
                        style: tt.bodySmall?.copyWith(color: AppTheme.textMuted)),
                    ]).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme tt) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Column(children: [
        const Icon(Icons.search_off_rounded, color: AppTheme.textMuted, size: 40),
        const SizedBox(height: 12),
        Text('No providers found', style: tt.titleSmall, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text('Try a different category or check back soon',
          style: tt.bodySmall?.copyWith(color: AppTheme.textMuted), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _EmergencyCategory {
  final String label;
  final IconData icon;
  final String serviceType;
  final Color color;
  const _EmergencyCategory(this.label, this.icon, this.serviceType, this.color);
}

class _EmergencyProviderCard extends StatefulWidget {
  final ServiceProvider provider;
  final String pincode;
  final int index;
  final _EmergencyCategory cat;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onCallback;

  const _EmergencyProviderCard({
    required this.provider, required this.pincode, required this.index,
    required this.cat, required this.onTap, required this.onCall,
    required this.onChat, required this.onCallback,
  });

  @override
  State<_EmergencyProviderCard> createState() => _EmergencyProviderCardState();
}

class _EmergencyProviderCardState extends State<_EmergencyProviderCard> {
  bool _pressed = false;

  String get _eta {
    final m = widget.provider.responseTimeMinutes;
    if (m > 0 && m <= 15) return '$m min';
    if (widget.provider.isOnline) return '~10 min';
    return '~30 min';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final tt = Theme.of(context).textTheme;
    final isSmall = MediaQuery.of(context).size.width < 360;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1, duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isSmall ? 12 : 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: widget.index == 0 ? AppTheme.accentCoral.withAlpha(80) : AppTheme.border,
              width: widget.index == 0 ? 1 : 0.5),
            boxShadow: widget.index == 0
              ? [BoxShadow(color: AppTheme.accentCoral.withAlpha(25), blurRadius: 16)] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primarySubtleGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(color: p.isOnline ? AppTheme.accentTeal.withAlpha(80) : AppTheme.border)),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Center(child: Text(p.name.isNotEmpty ? p.name[0] : '?',
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 20))),
                    if (p.isOnline) Positioned(right: -2, bottom: -2,
                      child: Container(width: 12, height: 12,
                        decoration: BoxDecoration(color: AppTheme.accentTeal, shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceCard, width: 2)))),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                      if (p.isVerified) ...[const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: AppTheme.accentBlue, size: 14)],
                    ]),
                    const SizedBox(height: 3),
                    Wrap(spacing: 8, runSpacing: 2, children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded, size: 13, color: AppTheme.accentGold),
                        const SizedBox(width: 2),
                        Text('${p.rating}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                      Text(p.distance, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      Text(p.experience, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ]),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: widget.index == 0
                      ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8A8A)]) : null,
                    color: widget.index == 0 ? null : AppTheme.accentTeal.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: widget.index == 0 ? null : Border.all(color: AppTheme.accentTeal.withAlpha(60))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.flash_on_rounded, size: 11,
                      color: widget.index == 0 ? Colors.white : AppTheme.accentTeal),
                    const SizedBox(width: 3),
                    Text(_eta, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                      color: widget.index == 0 ? Colors.white : AppTheme.accentTeal)),
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 4, children: [
                if (p.isOnline) _chip('Available Now', AppTheme.accentTeal),
                if (p.isVerified) _chip('Verified', AppTheme.accentBlue),
                if (p.backgroundChecked) _chip('BG Checked', AppTheme.accentPurple),
                if (p.hiredNearbyCount > 5) _chip('${p.hiredNearbyCount} hired nearby', AppTheme.accentGold),
              ]),
              const SizedBox(height: 10),
              Text(getContactHint(p.responseTimeMinutes, p.isOnline, p.rating),
                style: const TextStyle(color: AppTheme.accentTeal, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(spacing: isSmall ? 6 : 8, runSpacing: 6, children: [
                _actionBtn('Call Now', Icons.phone_rounded, AppTheme.accentCoral, widget.onCall, primary: true),
                _actionBtn('Chat', Icons.chat_bubble_outline_rounded, AppTheme.accentTeal, widget.onChat),
                _actionBtn('Callback', Icons.phone_callback_rounded, AppTheme.accentPurple, widget.onCallback),
              ]),
            ],
          ),
        ),
      ),
    ).animate(delay: (widget.index * 80).ms).fadeIn(duration: 300.ms).slideY(begin: 0.06);
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(15), borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      border: Border.all(color: color.withAlpha(50), width: 0.5)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap, {bool primary = false}) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: primary ? LinearGradient(colors: [color, color.withAlpha(180)]) : null,
          color: primary ? null : color.withAlpha(18),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: primary ? Colors.transparent : color.withAlpha(60), width: 0.7)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: primary ? Colors.white : color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: primary ? Colors.white : color)),
        ]),
      ),
    );
  }
}
