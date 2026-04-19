// shared/widgets/category_card.dart
// Layer: Shared (reusable across features)
//
// Category tile with icon, gradient background, and tap handler.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/category_icons.dart';

/// Premium square category card with hover/press effects and entrance animation.
class CategoryCard extends StatefulWidget {
  final String name;
  final VoidCallback onTap;
  final int index;

  const CategoryCard({
    super.key,
    required this.name,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = CategoryIcons.getCategoryGradient(widget.name);
    final icon = CategoryIcons.getIcon(widget.name);

    return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
              onTapDown: (_) {
                setState(() => _isPressed = true);
                HapticFeedback.selectionClick();
              },
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : (_isHovered ? 1.08 : 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: Colors.white.withAlpha(48),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 60).ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 250.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 250.ms);
  }
}
