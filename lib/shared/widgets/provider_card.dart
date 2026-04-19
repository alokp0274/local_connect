// shared/widgets/provider_card.dart
// Layer: Shared (reusable across features)
//
// Provider listing card showing name, rating, service, distance, and actions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

/// Reusable premium provider card with trust-first design.
/// Used across Home, Nearby, Search, Favorites, and List surfaces.
class ProviderCard extends StatefulWidget {
  final ServiceProvider provider;
  final VoidCallback onTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onBookTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool showFavorite;
  final bool showCtas;
  final int index;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onTap,
    this.onCallTap,
    this.onChatTap,
    this.onBookTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.showFavorite = true,
    this.showCtas = true,
    this.index = 0,
  });

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard> {
  bool _isPressed = false;

  String get _responseTime {
    final mins = widget.provider.responseTimeMinutes;
    if (mins > 0) return '~ min';
    final rating = widget.provider.rating;
    if (rating >= 4.8) return '~5 min';
    if (rating >= 4.5) return '~10 min';
    if (rating >= 4.0) return '~18 min';
    return '~30 min';
  }

  String get _startingPrice {
    if (widget.provider.pricing.isNotEmpty) {
      final matches = RegExp(r'\d+').allMatches(widget.provider.pricing);
      if (matches.isNotEmpty) {
        return '\u20b9+';
      }
    }
    return '\u20b9299+';
  }

  List<_TrustChipData> get _trustChips {
    final p = widget.provider;
    final chips = <_TrustChipData>[];
    if (p.isVerified) {
      chips.add(
        _TrustChipData(
          'Verified Pro',
          Icons.verified_rounded,
          AppTheme.accentBlue,
        ),
      );
    }
    if (p.backgroundChecked) {
      chips.add(
        _TrustChipData('BG Checked', Icons.shield_rounded, AppTheme.accentTeal),
      );
    }
    if (p.responseTimeMinutes <= 10) {
      chips.add(
        _TrustChipData(
          'Fast Response',
          Icons.flash_on_rounded,
          AppTheme.accentGold,
        ),
      );
    }
    if (p.reviewCount >= 40 || p.hiredNearbyCount >= 20) {
      chips.add(
        _TrustChipData(
          'Popular Nearby',
          Icons.trending_up_rounded,
          AppTheme.accentCoral,
        ),
      );
    }
    if (p.isOnline) {
      chips.add(
        _TrustChipData(
          'Available Now',
          Icons.schedule_rounded,
          AppTheme.accentTeal,
        ),
      );
    }
    return chips.take(3).toList();
  }

  String get _localTrustSignal {
    final p = widget.provider;
    if (p.hiredNearbyCount > 0) {
      return ' people hired nearby';
    }
    if (p.rating >= 4.7 && p.pincode.isNotEmpty) {
      return 'Top rated in PIN ';
    }
    if (p.isVerified) return 'Trusted in your area';
    return 'Serving your pincode';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;

    return GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) {
            setState(() => _isPressed = true);
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: AppTheme.accentGold.withAlpha(30),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: AnimatedScale(
              scale: _isPressed ? 0.985 : 1,
              duration: AppTheme.durationFast,
              curve: AppTheme.curveDefault,
              child: GlassContainer(
              margin: const EdgeInsets.only(bottom: 14),
              padding: EdgeInsets.all(isCompact ? 12 : 14),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              color: AppTheme.surface,
              boxShadow: AppTheme.cardShadow,
              border: Border.all(color: AppTheme.border, width: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(p, isCompact),
                  const SizedBox(height: 10),
                  _buildLocalTrustSignal(),
                  const SizedBox(height: 10),
                  _buildMetadataRow(p, isCompact),
                  const SizedBox(height: 10),
                  if (_trustChips.isNotEmpty) ...[
                    _buildTrustChips(isCompact),
                    const SizedBox(height: 10),
                  ],
                  _buildInfoTiles(),
                  if (widget.showCtas) ...[
                    const SizedBox(height: 12),
                    _buildCtaRow(isCompact),
                  ],
                ],
              ),
            ),
          ),
          ),
        )
        .animate(delay: (widget.index.clamp(0, 8) * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.08, curve: Curves.easeOut);
  }

  Widget _buildTopRow(ServiceProvider p, bool isCompact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'provider-avatar-${p.id}',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isCompact ? 50 : 56,
                height: isCompact ? 50 : 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primarySubtleGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color: p.isVerified
                        ? AppTheme.accentBlue.withAlpha(80)
                        : AppTheme.border,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: isCompact ? 20 : 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (p.isOnline)
                Positioned(
                  right: -3,
                  bottom: -3,
                  child:
                      Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.surface,
                                width: 2.5,
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            duration: 750.ms,
                            begin: const Offset(1, 1),
                            end: const Offset(1.18, 1.18),
                          ),
                ),
            ],
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
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: isCompact ? 14 : 15,
                      ),
                    ),
                  ),
                  if (p.isVerified) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppTheme.accentBlue,
                      size: 16,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                p.service,
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                p.aboutHighlight.isNotEmpty
                    ? p.aboutHighlight
                    : ' experience \u2022  away',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (widget.showFavorite)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onFavoriteTap?.call();
            },
            child:
                AnimatedContainer(
                      duration: AppTheme.durationFast,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.isFavorite
                            ? AppTheme.accentCoral.withAlpha(30)
                            : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        border: Border.all(
                          color: widget.isFavorite
                              ? AppTheme.accentCoral.withAlpha(60)
                              : AppTheme.border,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: widget.isFavorite
                            ? AppTheme.accentCoral
                            : AppTheme.textMuted,
                        size: 18,
                      ),
                    )
                    .animate(target: widget.isFavorite ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 180.ms,
                    ),
          ),
      ],
    );
  }

  Widget _buildLocalTrustSignal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withAlpha(12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
        border: Border.all(
          color: AppTheme.accentTeal.withAlpha(30),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppTheme.accentTeal,
            size: 13,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              _localTrustSignal,
              style: const TextStyle(
                color: AppTheme.accentTeal,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(ServiceProvider p, bool isCompact) {
    return Wrap(
      spacing: isCompact ? 8 : 12,
      runSpacing: 6,
      children: [
        _MetaPill(
          icon: Icons.star_rounded,
          text: p.rating.toStringAsFixed(1),
          color: AppTheme.accentGold,
        ),
        _MetaPill(
          icon: Icons.reviews_rounded,
          text: ' reviews',
          color: AppTheme.accentPurple,
        ),
        _MetaPill(
          icon: Icons.route_rounded,
          text: p.distance,
          color: AppTheme.accentBlue,
        ),
        _MetaPill(
          icon: Icons.workspace_premium_rounded,
          text: p.experience,
          color: AppTheme.accentCoral,
        ),
        _MetaPill(
          icon: Icons.flash_on_rounded,
          text: _responseTime,
          color: AppTheme.accentTeal,
        ),
      ],
    );
  }

  Widget _buildTrustChips(bool isCompact) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _trustChips
          .map((chip) => _TrustChip(data: chip, compact: isCompact))
          .toList(),
    );
  }

  Widget _buildInfoTiles() {
    return Row(
      children: [
        _MetaTile(
          icon: Icons.currency_rupee_rounded,
          label: 'Starting',
          value: _startingPrice,
        ),
        const SizedBox(width: 8),
        _MetaTile(
          icon: Icons.flash_on_rounded,
          label: 'Response',
          value: _responseTime,
        ),
      ],
    );
  }

  Widget _buildCtaRow(bool isCompact) {
    return Row(
      children: [
        if (widget.onCallTap != null)
          Expanded(
            child: _CardActionButton(
              label: 'Call',
              icon: Icons.phone_rounded,
              color: AppTheme.accentGold,
              onTap: widget.onCallTap!,
              compact: isCompact,
            ),
          ),
        if (widget.onCallTap != null && widget.onChatTap != null)
          const SizedBox(width: 8),
        if (widget.onChatTap != null)
          Expanded(
            child: _CardActionButton(
              label: 'Chat',
              icon: Icons.chat_bubble_outline_rounded,
              color: AppTheme.accentTeal,
              onTap: widget.onChatTap!,
              compact: isCompact,
            ),
          ),
        if ((widget.onCallTap != null || widget.onChatTap != null) &&
            widget.onBookTap != null)
          const SizedBox(width: 8),
        if (widget.onBookTap != null)
          Expanded(
            child: _CardActionButton(
              label: 'Book Now',
              icon: Icons.event_available_rounded,
              color: AppTheme.accentGold,
              onTap: widget.onBookTap!,
              compact: isCompact,
              isPrimary: true,
            ),
          ),
      ],
    );
  }
}

class _TrustChipData {
  final String label;
  final IconData icon;
  final Color color;
  const _TrustChipData(this.label, this.icon, this.color);
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _MetaPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  final _TrustChipData data;
  final bool compact;
  const _TrustChip({required this.data, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: data.color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: data.color.withAlpha(50), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 11, color: data.color),
          const SizedBox(width: 4),
          Text(
            data.label,
            style: TextStyle(
              color: data.color,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.accentGold),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool compact;
  final bool isPrimary;

  const _CardActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.compact = false,
    this.isPrimary = false,
  });

  @override
  State<_CardActionButton> createState() => _CardActionButtonState();
}

class _CardActionButtonState extends State<_CardActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: widget.compact ? 8 : 10),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [widget.color, widget.color.withAlpha(180)],
                  )
                : null,
            color: widget.isPrimary ? null : widget.color.withAlpha(22),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(
              color: widget.color.withAlpha(widget.isPrimary ? 0 : 100),
              width: 0.7,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isPrimary ? Colors.white : widget.color,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isPrimary ? Colors.white : widget.color,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.compact ? 10 : 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
