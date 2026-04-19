// features/chat/screens/video_call_screen.dart
// Feature: Messaging & Communication
//
// In-app video call screen with camera toggle and picture-in-picture.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';

class VideoCallScreen extends StatefulWidget {
  final ServiceProvider provider;
  const VideoCallScreen({super.key, required this.provider});
  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  int _seconds = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isConnected = false;
  bool _isSpeaker = false;
  bool _showControls = true;
  bool _isFrontCamera = true;
  late final AnimationController _pulseController;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
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
    _bgController.dispose();
    super.dispose();
  }

  String get _time {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // ── BACKGROUND ──
            Positioned.fill(child: _VideoBackground(controller: _bgController)),

            // ── REMOTE VIDEO AREA / AVATAR ──
            Positioned.fill(
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppTheme.durationMedium,
                  child: _isConnected
                      ? _buildConnectedState()
                      : _buildConnectingState(),
                ),
              ),
            ),

            // ── TOP OVERLAY ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              top: _showControls ? topPad + 10 : -(80 + topPad),
              left: 14,
              right: 14,
              child: _buildTopBar(),
            ),

            // ── SELF PREVIEW ──
            Positioned(
              top: topPad + 70,
              right: 14,
              child: _buildSelfPreview(screenW),
            ),

            // ── BOTTOM CONTROLS ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: 14,
              right: 14,
              bottom: _showControls
                  ? (bottomPad > 0 ? bottomPad : 16)
                  : -(120 + bottomPad),
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedState() {
    return Column(
      key: const ValueKey('connected'),
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentTeal.withAlpha(
                      (30 * _pulseController.value).round(),
                    ),
                    blurRadius: 40 + (20 * _pulseController.value),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2347), Color(0xFF2A3060)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withAlpha(20),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.provider.name.isNotEmpty
                    ? widget.provider.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.provider.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.provider.service,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildConnectingState() {
    return Column(
      key: const ValueKey('connecting'),
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150 + (20 * _pulseController.value),
                  height: 150 + (20 * _pulseController.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentGold.withAlpha(
                      (10 * _pulseController.value).round(),
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primarySubtleGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentGold.withAlpha(40),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.accentGold),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Connecting...',
          style: TextStyle(
            color: AppTheme.accentGold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.provider.name,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          color: const Color(0xAA0E1228),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isConnected
                      ? AppTheme.accentTeal
                      : AppTheme.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isConnected ? _time : 'Connecting',
                style: TextStyle(
                  color: _isConnected
                      ? AppTheme.accentTeal
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (_isConnected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.lock_rounded,
                  size: 11,
                  color: AppTheme.accentTeal,
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        GlassContainer(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          color: const Color(0xAA0E1228),
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
    ).animate().fadeIn(duration: 260.ms);
  }

  Widget _buildSelfPreview(double screenW) {
    final previewW = screenW < 360 ? 100.0 : 120.0;
    final previewH = previewW * 1.4;

    return GlassContainer(
      width: previewW,
      height: previewH,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      color: const Color(0xCC121730),
      border: Border.all(color: AppTheme.border, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(80),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraOff)
            const Center(
              child: Icon(
                Icons.videocam_off_rounded,
                color: AppTheme.textMuted,
                size: 28,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isFrontCamera
                        ? Icons.person_rounded
                        : Icons.camera_rear_rounded,
                    color: AppTheme.textSecondary,
                    size: 36,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isMuted)
                    const Icon(
                      Icons.mic_off_rounded,
                      size: 10,
                      color: AppTheme.accentCoral,
                    )
                  else
                    const Icon(
                      Icons.mic_rounded,
                      size: 10,
                      color: AppTheme.accentTeal,
                    ),
                  const SizedBox(width: 3),
                  Text(
                    _isMuted ? 'Muted' : 'You',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.15);
  }

  Widget _buildControls() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      color: const Color(0xCC0E1228),
      border: Border.all(color: AppTheme.glassBorder.withAlpha(40), width: 0.7),
      boxShadow: const [
        BoxShadow(
          color: Color(0x60000000),
          blurRadius: 30,
          offset: Offset(0, 10),
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _VideoControl(
            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: 'Mic',
            active: _isMuted,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isMuted = !_isMuted);
            },
          ),
          _VideoControl(
            icon: _isCameraOff
                ? Icons.videocam_off_rounded
                : Icons.videocam_rounded,
            label: 'Camera',
            active: _isCameraOff,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isCameraOff = !_isCameraOff);
            },
          ),
          _VideoControl(
            icon: _isSpeaker ? Icons.volume_up_rounded : Icons.hearing_rounded,
            label: 'Speaker',
            active: _isSpeaker,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isSpeaker = !_isSpeaker);
            },
          ),
          _VideoControl(
            icon: Icons.flip_camera_ios_rounded,
            label: 'Flip',
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isFrontCamera = !_isFrontCamera);
            },
          ),
          _VideoControl(
            icon: Icons.call_end_rounded,
            label: 'End',
            danger: true,
            onTap: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// VIDEO CONTROL BUTTON
// ─────────────────────────────────────────
class _VideoControl extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool danger;
  final VoidCallback onTap;
  const _VideoControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.danger = false,
  });
  @override
  State<_VideoControl> createState() => _VideoControlState();
}

class _VideoControlState extends State<_VideoControl> {
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
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppTheme.durationFast,
                width: 48,
                height: 48,
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
                      : AppTheme.glassWhite.withAlpha(18),
                  border: Border.all(
                    color: widget.danger
                        ? Colors.transparent
                        : color.withAlpha(100),
                    width: widget.active ? 1.0 : 0.5,
                  ),
                  boxShadow: widget.danger
                      ? [
                          BoxShadow(
                            color: AppTheme.accentCoral.withAlpha(90),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.danger ? Colors.white : color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.danger
                      ? AppTheme.accentCoral
                      : AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
// VIDEO BACKGROUND
// ─────────────────────────────────────────
class _VideoBackground extends StatelessWidget {
  final AnimationController controller;
  const _VideoBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF080C20), Color(0xFF121830), Color(0xFF0D1028)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -60 + (25 * sin(controller.value * 2 * pi)),
                left: -40 + (20 * cos(controller.value * 2 * pi * 0.7)),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withAlpha(8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -80 + (20 * cos(controller.value * 2 * pi)),
                right: -50 + (15 * sin(controller.value * 2 * pi * 0.8)),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withAlpha(6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                right: MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withAlpha(4),
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
