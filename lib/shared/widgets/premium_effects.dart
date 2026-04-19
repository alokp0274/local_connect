// shared/widgets/premium_effects.dart
//
// Premium interaction effects system for LocalConnect.
// Reusable tap effects, animated list items, loaders, and success animations.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';

// ─── Premium Tap Effect ──────────────────────────────────────────────
/// Wraps any widget with premium tap feedback: scale bounce + glow ring + haptic.
class PremiumTapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressScale;
  final bool enableHaptic;
  final bool enableGlow;
  final Color? glowColor;
  final BorderRadius? borderRadius;

  const PremiumTapEffect({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressScale = 0.96,
    this.enableHaptic = true,
    this.enableGlow = true,
    this.glowColor,
    this.borderRadius,
  });

  @override
  State<PremiumTapEffect> createState() => _PremiumTapEffectState();
}

class _PremiumTapEffectState extends State<PremiumTapEffect>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    if (widget.enableGlow) _glowCtrl.forward(from: 0);
    if (widget.enableHaptic) HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    if (!enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.pressScale : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: widget.enableGlow
            ? AnimatedBuilder(
                animation: _glowCtrl,
                builder: (context, child) {
                  if (_glowCtrl.value == 0) return child!;
                  final glow = widget.glowColor ?? AppTheme.accentGold;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius ??
                          BorderRadius.circular(AppTheme.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: glow
                              .withAlpha((50 * (1 - _glowCtrl.value)).round()),
                          blurRadius: 24 * _glowCtrl.value,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}

// ─── Animated List Item ──────────────────────────────────────────────
/// Staggered entrance wrapper for list items with fade + slide.
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int delayMs;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delayMs = 50,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: Duration(milliseconds: index * delayMs))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ─── Floating Orb Loader ─────────────────────────────────────────────
/// Premium floating orb loading indicator with expanding ring.
class FloatingOrbLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const FloatingOrbLoader({super.key, this.size = 48, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accentGold;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.withAlpha(50), width: 2),
            ),
          )
              .animate(onPlay: (ctrl) => ctrl.repeat())
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1.2, 1.2),
                duration: 1400.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1400.ms),
          // Inner glowing orb
          Container(
            width: size * 0.35,
            height: size * 0.35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [c, c.withAlpha(80)]),
              boxShadow: [BoxShadow(color: c.withAlpha(100), blurRadius: 12)],
            ),
          )
              .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

// ─── Success Check Animation ─────────────────────────────────────────
/// Animated success check mark with burst ring.
class SuccessCheckAnimation extends StatelessWidget {
  final double size;
  final Color? color;

  const SuccessCheckAnimation({super.key, this.size = 64, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accentTeal;
    return SizedBox(
      width: size * 1.4,
      height: size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withAlpha(25),
              border: Border.all(color: c.withAlpha(60), width: 2),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
          // Check icon
          Icon(Icons.check_rounded, size: size * 0.5, color: c)
              .animate(delay: 200.ms)
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 300.ms),
          // Burst ring
          Container(
            width: size * 1.3,
            height: size * 1.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.withAlpha(40), width: 1.5),
            ),
          )
              .animate(delay: 300.ms)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.3, 1.3),
                duration: 600.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ─── Pulse Dots Loader ───────────────────────────────────────────────
/// Three pulsing dots loading indicator.
class PulseDotsLoader extends StatelessWidget {
  final double dotSize;
  final Color? color;

  const PulseDotsLoader({super.key, this.dotSize = 8, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accentGold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: dotSize * 0.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
            boxShadow: [BoxShadow(color: c.withAlpha(60), blurRadius: 4)],
          ),
        )
            .animate(
              onPlay: (ctrl) => ctrl.repeat(reverse: true),
              delay: Duration(milliseconds: i * 150),
            )
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 500.ms,
            )
            .fadeIn(begin: 0.4, duration: 500.ms);
      }),
    );
  }
}

// ─── Shimmer Loading Card ────────────────────────────────────────────
/// Premium shimmer skeleton card for loading states.
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          delay: 500.ms,
          color: Colors.white.withAlpha(15),
        );
  }
}

// ─── Premium Snack Bar ───────────────────────────────────────────────
/// Show a premium animated snackbar with icon.
class PremiumSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (iconColor ?? AppTheme.accentGold).withAlpha(30),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.accentGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppTheme.surfaceSolidLight,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

// ─── Glow Border Wrapper ─────────────────────────────────────────────
/// Wraps a widget with an animated glow border on demand.
class GlowBorder extends StatelessWidget {
  final Widget child;
  final bool active;
  final Color? color;
  final double blurRadius;
  final BorderRadius? borderRadius;

  const GlowBorder({
    super.key,
    required this.child,
    this.active = false,
    this.color,
    this.blurRadius = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: active
            ? [
                BoxShadow(
                  color:
                      (color ?? AppTheme.accentGold).withAlpha(35),
                  blurRadius: blurRadius,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}
