// features/home/screens/main_shell.dart
// Feature: Home & Dashboard
//
// Bottom navigation shell that hosts Home, Search, Bookings, and Profile tabs.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/home/screens/home_screen.dart';
import 'package:local_connect/features/chat/screens/messages_screen.dart';
import 'package:local_connect/features/booking/screens/bookings_screen.dart';
import 'package:local_connect/features/profile/screens/profile_screen.dart';
import 'package:local_connect/features/jobs/screens/requests_screen.dart';

class MainShell extends StatefulWidget {
  final String pincode;
  const MainShell({super.key, required this.pincode});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late final AnimationController _pillController;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(pincode: widget.pincode),
      const MessagesScreen(),
      const RequestsScreen(),
      const BookingsScreen(),
      const ProfileScreen(),
    ];
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  bool get _hasUnread => activeChats.any((t) => t.hasUnread);

  void _onTab(int i) {
    if (i == _currentIndex) return;
    HapticFeedback.selectionClick();
    _pillController.forward(from: 0);
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenW = MediaQuery.of(context).size.width;
    final isCompact = screenW < 360;
    final navMargin = isCompact ? 8.0 : 14.0;

    return Scaffold(
      backgroundColor: AppTheme.primaryDeep,
      body: AnimatedMeshBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: IndexedStack(
            key: ValueKey(_currentIndex),
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(
          navMargin + 4,
          0,
          navMargin + 4,
          bottomPad > 0 ? 6 : 12,
        ),
        child: GlassContainer(
          padding: EdgeInsets.symmetric(vertical: isCompact ? 5 : 7),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          gradient: const LinearGradient(
            colors: [Color(0x900B1445), Color(0x80050B2D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0x18FFFFFF), width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: 'Discover',
                isActive: _currentIndex == 0,
                onTap: () => _onTab(0),
                isCompact: isCompact,
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'Messages',
                isActive: _currentIndex == 1,
                onTap: () => _onTab(1),
                showBadge: _hasUnread,
                isCompact: isCompact,
              ),
              _NavItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
                label: 'Requests',
                isActive: _currentIndex == 2,
                onTap: () => _onTab(2),
                isCenter: true,
                isCompact: isCompact,
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today_rounded,
                label: 'Bookings',
                isActive: _currentIndex == 3,
                onTap: () => _onTab(3),
                isCompact: isCompact,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                isActive: _currentIndex == 4,
                onTap: () => _onTab(4),
                isCompact: isCompact,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.15),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showBadge;
  final bool isCenter;
  final bool isCompact;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showBadge = false,
    this.isCenter = false,
    this.isCompact = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.isCompact ? 56.0 : 64.0;
    final iconSize = widget.isCenter ? 28.0 : 23.0;

    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() => _pressed = true);
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) setState(() => _pressed = false);
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active pill indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: widget.isActive ? 28 : 0,
                height: 3.5,
                decoration: BoxDecoration(
                  gradient: widget.isActive ? AppTheme.goldGradient : null,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: AppTheme.accentGold.withAlpha(120),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              SizedBox(height: widget.isCompact ? 4 : 5),
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _bounceController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: widget.isActive
                            ? [
                                BoxShadow(
                                  color:
                                      AppTheme.accentGold.withAlpha(50),
                                  blurRadius: 16,
                                ),
                              ]
                            : [],
                      ),
                      child: AnimatedScale(
                        scale: widget.isActive ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          widget.isActive ? widget.activeIcon : widget.icon,
                          color: widget.isActive
                              ? AppTheme.accentGold
                              : (widget.isCenter
                                    ? AppTheme.textSecondary
                                    : AppTheme.textMuted),
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                  if (widget.showBadge)
                    Positioned(
                      right: -5,
                      top: -4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.accentCoral, Color(0xFFFF8A80)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryDeep,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentCoral.withAlpha(130),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: widget.isCompact ? 2 : 3),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: widget.isCompact ? 9 : 10,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: widget.isActive
                      ? AppTheme.accentGold
                      : AppTheme.textMuted,
                  letterSpacing: widget.isActive ? 0.2 : 0,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
