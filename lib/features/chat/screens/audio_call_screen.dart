// features/chat/screens/audio_call_screen.dart
// Feature: Messaging & Communication
//
// In-app audio call screen with timer, mute, and speaker controls.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class AudioCallScreen extends StatefulWidget {
  final ServiceProvider provider;
  const AudioCallScreen({super.key, required this.provider});
  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen>
    with TickerProviderStateMixin {
  int _seconds = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isConnected = false;
  bool _showKeypad = false;
  late final AnimationController _pulseController;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _isConnected = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String get _timerText {
    final h = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return h == '00' ? '$m:$s' : '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── AMBIENT BACKGROUND ──
          Positioned.fill(
            child: _AmbientBackground(controller: _waveController),
          ),

          // ── CONTENT ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 12,
                              color: _isConnected
                                  ? AppTheme.accentTeal
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'End-to-end encrypted',
                              style: TextStyle(
                                color: _isConnected
                                    ? AppTheme.accentTeal
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GlassContainer(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const Spacer(flex: 2),

                  // ── CALLER AVATAR WITH PULSE WAVES ──
                  _buildCallerAvatar(),
                  const SizedBox(height: 24),

                  // Name
                  Text(
                    widget.provider.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    widget.provider.service,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                  const SizedBox(height: 12),

                  // Timer / status
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isConnected
                        ? Container(
                            key: const ValueKey('timer'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal.withAlpha(20),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                              border: Border.all(
                                color: AppTheme.accentTeal.withAlpha(40),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentTeal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timerText,
                                  style: const TextStyle(
                                    color: AppTheme.accentTeal,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            key: const ValueKey('connecting'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withAlpha(15),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppTheme.accentGold.withAlpha(180),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Connecting...',
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const Spacer(flex: 3),

                  // ── CONTROLS ──
                  _buildControls(),

                  // ── KEYPAD MOCK ──
                  if (_showKeypad) _buildKeypad(),

                  SizedBox(height: bottomPad > 0 ? 8 : 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallerAvatar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Container(
              width: 200 + (20 * _pulseController.value),
              height: 200 + (20 * _pulseController.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      (_isConnected ? AppTheme.accentTeal : AppTheme.accentGold)
                          .withAlpha(
                            (30 * (1 - _pulseController.value)).round(),
                          ),
                ),
              ),
            ),
            // Mid pulse ring
            Container(
              width: 170 + (12 * _pulseController.value),
              height: 170 + (12 * _pulseController.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    (_isConnected ? AppTheme.accentTeal : AppTheme.accentGold)
                        .withAlpha((15 * _pulseController.value).round()),
              ),
            ),
            // Avatar
            child!,
          ],
        );
      },
      child:
          Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: _isConnected
                      ? const LinearGradient(
                          colors: [Color(0xFF06D6A0), Color(0xFF04A87F)],
                        )
                      : AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isConnected
                                  ? AppTheme.accentTeal
                                  : AppTheme.accentGold)
                              .withAlpha(80),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.provider.name.isNotEmpty
                        ? widget.provider.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 350.ms),
    );
  }

  Widget _buildControls() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      alignment: WrapAlignment.center,
      children: [
        _CallControl(
          icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: _isMuted ? 'Unmute' : 'Mute',
          active: _isMuted,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isMuted = !_isMuted);
          },
        ),
        _CallControl(
          icon: _isSpeaker
              ? Icons.volume_up_rounded
              : Icons.volume_down_rounded,
          label: 'Speaker',
          active: _isSpeaker,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isSpeaker = !_isSpeaker);
          },
        ),
        _CallControl(
          icon: Icons.dialpad_rounded,
          label: 'Keypad',
          active: _showKeypad,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _showKeypad = !_showKeypad);
          },
        ),
        _CallControl(
          icon: Icons.note_add_rounded,
          label: 'Note',
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Notes feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          },
        ),
        _CallControl(
          icon: Icons.call_end_rounded,
          label: 'End',
          danger: true,
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
        ),
      ],
    ).animate(delay: 200.ms).fadeIn(duration: 350.ms).slideY(begin: 0.1);
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: Wrap(
          spacing: 20,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
              .map(
                (key) => GestureDetector(
                  onTap: () => HapticFeedback.selectionClick(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.border,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        key,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),
    );
  }
}

// ─────────────────────────────────────────
// CALL CONTROL BUTTON
// ─────────────────────────────────────────
class _CallControl extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool danger;
  final VoidCallback onTap;
  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.danger = false,
  });
  @override
  State<_CallControl> createState() => _CallControlState();
}

class _CallControlState extends State<_CallControl> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.danger
        ? AppTheme.accentCoral
        : widget.active
        ? AppTheme.accentGold
        : AppTheme.textSecondary;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppTheme.durationFast,
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.danger
                      ? const LinearGradient(
                          colors: [AppTheme.accentCoral, Color(0xFFFF8A80)],
                        )
                      : null,
                  color: widget.danger
                      ? null
                      : widget.active
                      ? AppTheme.accentGold.withAlpha(30)
                      : AppTheme.surfaceElevated,
                  border: Border.all(
                    color: widget.danger
                        ? Colors.transparent
                        : color.withAlpha(100),
                    width: widget.active ? 1.2 : 0.6,
                  ),
                  boxShadow: widget.danger
                      ? [
                          BoxShadow(
                            color: AppTheme.accentCoral.withAlpha(100),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : widget.active
                      ? [BoxShadow(color: color.withAlpha(30), blurRadius: 12)]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.danger ? Colors.white : color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.danger
                      ? AppTheme.accentCoral
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// AMBIENT BACKGROUND
// ─────────────────────────────────────────
class _AmbientBackground extends StatelessWidget {
  final AnimationController controller;
  const _AmbientBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0E27), Color(0xFF141832), Color(0xFF0A0E27)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40 + (20 * sin(controller.value * 2 * pi)),
                right: -30 + (15 * cos(controller.value * 2 * pi)),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -50 + (18 * cos(controller.value * 2 * pi)),
                left: -40 + (12 * sin(controller.value * 2 * pi)),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: MediaQuery.of(context).size.width * 0.6,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withAlpha(6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
