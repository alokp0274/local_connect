// shared/widgets/glass_container.dart
//
// Premium dark glassmorphic card container with blur, glow borders, and soft shadows.

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:local_connect/core/theme/app_theme.dart';

/// Reusable dark glass card surface with optional backdrop blur.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 12,
    this.color,
    this.border,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLG);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppTheme.surface) : null,
        gradient: gradient,
        borderRadius: radius,
        border: border ?? Border.all(color: AppTheme.border, width: 0.5),
        boxShadow: boxShadow ?? AppTheme.cardShadow,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withAlpha(5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4],
        ),
      ),
      child: child,
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    return Container(margin: margin, child: content);
  }
}
