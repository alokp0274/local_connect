// shared/widgets/instant_connect_actions.dart
// Layer: Shared (reusable across features)
//
// Quick-action buttons for instant call, chat, and callback with a provider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_connect/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
//  PREMIUM INSTANT CONNECT ACTION BUTTONS
// ─────────────────────────────────────────────────────────

/// A row of premium CTA buttons for provider actions.
/// Adapts to available width, wraps on small screens.
class InstantConnectActions extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onCallback;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool compact;
  final String? responseHint;

  const InstantConnectActions({
    super.key,
    this.onCall,
    this.onChat,
    this.onWhatsApp,
    this.onCallback,
    this.onShare,
    this.onFavorite,
    this.isFavorite = false,
    this.compact = false,
    this.responseHint,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (responseHint != null && responseHint!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ResponseHintChip(text: responseHint!),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final buttonSize = compact || isSmall ? 'small' : 'normal';
            return Wrap(
              spacing: isSmall ? 6 : 8,
              runSpacing: isSmall ? 6 : 8,
              children: [
                if (onCall != null)
                  _ConnectButton(
                    label: 'Call Now',
                    icon: Icons.phone_rounded,
                    gradient: AppTheme.primaryGradient,
                    textColor: AppTheme.textOnAccent,
                    onTap: onCall!,
                    size: buttonSize,
                    isPrimary: true,
                  ),
                if (onChat != null)
                  _ConnectButton(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: AppTheme.accentTeal,
                    onTap: onChat!,
                    size: buttonSize,
                  ),
                if (onWhatsApp != null)
                  _ConnectButton(
                    label: 'WhatsApp',
                    icon: Icons.messenger_outline_rounded,
                    color: const Color(0xFF25D366),
                    onTap: onWhatsApp!,
                    size: buttonSize,
                  ),
                if (onCallback != null)
                  _ConnectButton(
                    label: 'Callback',
                    icon: Icons.phone_callback_rounded,
                    color: AppTheme.accentPurple,
                    onTap: onCallback!,
                    size: buttonSize,
                  ),
                if (onShare != null)
                  _ConnectButton(
                    label: 'Share',
                    icon: Icons.share_rounded,
                    color: AppTheme.accentBlue,
                    onTap: onShare!,
                    size: buttonSize,
                  ),
                if (onFavorite != null)
                  _ConnectButton(
                    label: isFavorite ? 'Saved' : 'Save',
                    icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: AppTheme.accentCoral,
                    onTap: onFavorite!,
                    size: buttonSize,
                    isActive: isFavorite,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ResponseHintChip extends StatelessWidget {
  final String text;
  const _ResponseHintChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.accentTeal.withAlpha(40), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(color: AppTheme.accentTeal, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.accentTeal, fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  final Color? textColor;
  final VoidCallback onTap;
  final String size;
  final bool isPrimary;
  final bool isActive;

  const _ConnectButton({
    required this.label,
    required this.icon,
    this.color,
    this.gradient,
    this.textColor,
    required this.onTap,
    this.size = 'normal',
    this.isPrimary = false,
    this.isActive = false,
  });

  @override
  State<_ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<_ConnectButton> {
  bool _pressed = false;
  bool _loading = false;

  void _handleTap() {
    HapticFeedback.selectionClick();
    setState(() => _loading = true);
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = widget.size == 'small';
    final hPad = isSmall ? 10.0 : 14.0;
    final vPad = isSmall ? 8.0 : 10.0;
    final fontSize = isSmall ? 10.0 : 12.0;
    final iconSize = isSmall ? 14.0 : 16.0;
    final c = widget.color ?? AppTheme.accentGold;

    return GestureDetector(
      onTap: _loading ? null : _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? widget.gradient : null,
            color: widget.isPrimary ? null : (widget.isActive ? c.withAlpha(30) : c.withAlpha(18)),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(
              color: widget.isPrimary ? Colors.transparent : c.withAlpha(widget.isActive ? 100 : 60),
              width: 0.7,
            ),
            boxShadow: widget.isPrimary
                ? [BoxShadow(color: c.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading)
                SizedBox(
                  width: iconSize, height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: widget.isPrimary ? (widget.textColor ?? Colors.white) : c,
                  ),
                )
              else
                Icon(widget.icon, size: iconSize,
                    color: widget.isPrimary ? (widget.textColor ?? Colors.white) : c),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isPrimary ? (widget.textColor ?? Colors.white) : c,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Smart helper text for contact feeling.
String getContactHint(int responseTimeMinutes, bool isOnline, double rating) {
  if (isOnline && responseTimeMinutes <= 5) return 'Active now \u2022 Usually replies instantly';
  if (isOnline && responseTimeMinutes <= 15) return 'Active now \u2022 Usually replies in  min';
  if (isOnline) return 'Active now \u2022 Fast responder';
  if (responseTimeMinutes <= 10) return 'Fast responder \u2022 Avg.  min';
  if (rating >= 4.7) return 'Top rated \u2022 Responds quickly';
  return 'Last active recently \u2022 Will respond soon';
}
