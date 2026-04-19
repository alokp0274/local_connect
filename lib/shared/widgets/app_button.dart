// shared/widgets/app_button.dart
// Layer: Shared (reusable across features)
//
// Premium dark luxury action button with gold gradient, press animation, and loading state.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';

/// Premium gradient button with press animation and optional loading state.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.height = 54,
    this.width,
    this.outlined = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && !widget.isLoading;

    if (widget.outlined) {
      return SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: OutlinedButton(
          onPressed: enabled ? widget.onTap : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: enabled ? AppTheme.border : AppTheme.textMuted,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
          child: _buildContent(widget.textColor ?? AppTheme.textPrimary),
        ),
      );
    }

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppTheme.primaryGradient,
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: enabled ? AppTheme.goldGlow : [],
            ),
            child: Center(
              child: _buildContent(widget.textColor ?? AppTheme.textOnAccent),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1800.ms,
                delay: 3200.ms,
                color: Colors.white.withAlpha(28),
              ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
