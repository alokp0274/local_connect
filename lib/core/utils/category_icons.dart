// core/utils/category_icons.dart
// Layer: Core (app-wide infrastructure)
//
// Maps service category names to Material Icons and gradient color pairs
// for consistent visual representation across screens.

import 'package:flutter/material.dart';

/// Maps category names to Material Icons and premium gradient pairs.
class CategoryIcons {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumber':
        return Icons.plumbing;
      case 'electrician':
        return Icons.electrical_services;
      case 'bike repair':
        return Icons.two_wheeler;
      case 'tutor':
        return Icons.school;
      case 'ac repair':
        return Icons.ac_unit;
      case 'carpenter':
        return Icons.carpenter;
      case 'painter':
        return Icons.format_paint;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'salon':
        return Icons.content_cut;
      case 'more':
        return Icons.more_horiz;
      default:
        return Icons.handyman;
    }
  }

  /// Returns a gradient color pair for each category.
  static List<Color> getGradient(String category) {
    switch (category.toLowerCase()) {
      case 'plumber':
        return [const Color(0xFF06D6A0), const Color(0xFF048A66)];
      case 'electrician':
        return [const Color(0xFFFFB800), const Color(0xFFCC9200)];
      case 'bike repair':
        return [const Color(0xFF90A4AE), const Color(0xFF546E7A)];
      case 'tutor':
        return [const Color(0xFF7B5EA7), const Color(0xFF5A3F8A)];
      case 'ac repair':
        return [const Color(0xFF4FC3F7), const Color(0xFF0288D1)];
      case 'carpenter':
        return [const Color(0xFFFF8A65), const Color(0xFFE64A19)];
      case 'painter':
        return [const Color(0xFFFF6B6B), const Color(0xFFD32F2F)];
      case 'cleaning':
        return [const Color(0xFF81C784), const Color(0xFF388E3C)];
      case 'salon':
        return [const Color(0xFFE040FB), const Color(0xFF9C27B0)];
      case 'more':
        return [const Color(0xFF78909C), const Color(0xFF455A64)];
      default:
        return [const Color(0xFFFFB800), const Color(0xFFCC9200)];
    }
  }

  /// Returns a [LinearGradient] for the given category.
  static LinearGradient getCategoryGradient(String category) {
    final colors = getGradient(category);
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Returns icon + color pair as a record for convenient destructuring.
  static ({IconData icon, List<Color> colors}) get(String category) {
    return (icon: getIcon(category), colors: getGradient(category));
  }
}
