// shared/widgets/animated_mesh_background.dart
//
// Animated background system with three modes:
//   mesh     — drifting blurred circles for Splash, Login, Register, Location
//   static   — subtle warm gradient for HomeScreen, cards
//   particles — floating dots for Urgent tab

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Background type selector.
enum BackgroundType { mesh, staticGradient, particles }

/// Wrap any screen body with this widget to add a branded background.
class AnimatedMeshBackground extends StatelessWidget {
  final Widget child;
  final bool subtle;
  final BackgroundType type;

  const AnimatedMeshBackground({
    super.key,
    required this.child,
    this.subtle = false,
    this.type = BackgroundType.staticGradient,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      BackgroundType.mesh => _MeshBackground(subtle: subtle, child: child),
      BackgroundType.staticGradient => _StaticBackground(child: child),
      BackgroundType.particles => _ParticleBackground(child: child),
    };
  }
}

// ────────────────── Type 1: Mesh Gradient ──────────────────
class _MeshBackground extends StatelessWidget {
  final Widget child;
  final bool subtle;
  const _MeshBackground({required this.child, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    final a = subtle ? 0.4 : 1.0;
    return Stack(
      children: [
        // Deep navy base gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF050B2D),
                  Color(0xFF0B1445),
                  Color(0xFF050B2D),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Blue accent orb – top left
        Positioned(
          top: -100,
          left: -60,
          child: _GlowOrb(
            size: 240,
            color: const Color(0xFF60A5FA).withAlpha((40 * a).round()),
            durationMs: 10000,
            moveRange: 16,
          ),
        ),
        // Gold accent orb – right
        Positioned(
          right: -80,
          bottom: 100,
          child: _GlowOrb(
            size: 200,
            color: const Color(0xFFFACC15).withAlpha((25 * a).round()),
            durationMs: 12000,
            moveRange: 18,
          ),
        ),
        // Purple orb – bottom left
        Positioned(
          left: 100,
          bottom: -80,
          child: _GlowOrb(
            size: 180,
            color: const Color(0xFFA78BFA).withAlpha((30 * a).round()),
            durationMs: 9000,
            moveRange: 14,
          ),
        ),
        // Teal orb – upper right
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          right: 30,
          child: _GlowOrb(
            size: 140,
            color: const Color(0xFF10B981).withAlpha((22 * a).round()),
            durationMs: 11000,
            moveRange: 12,
          ),
        ),
        // Warm white depth orb – center
        Positioned(
          top: MediaQuery.of(context).size.height * 0.45,
          left: MediaQuery.of(context).size.width * 0.3,
          child: _GlowOrb(
            size: 160,
            color: Colors.white.withAlpha((12 * a).round()),
            durationMs: 15000,
            moveRange: 10,
          ),
        ),
        // Glass particle overlay
        Positioned.fill(
          child: _GlassParticleOverlay(intensity: a),
        ),
        // BackdropFilter blur
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: const SizedBox.expand(),
          ),
        ),
        // Subtle vignette for depth
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF050B2D).withAlpha(40),
                ],
                radius: 1.2,
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

// ────────────────── Type 2: Ambient Background ──────────────────
class _StaticBackground extends StatelessWidget {
  final Widget child;
  const _StaticBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // Base gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050B2D), Color(0xFF0B1445)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Subtle ambient blue glow – top right
        Positioned(
          top: -60,
          right: -80,
          child: _AmbientOrb(
            size: 250,
            color: const Color(0xFF60A5FA),
            alpha: 12,
            durationMs: 20000,
            moveRange: 8,
          ),
        ),
        // Subtle ambient gold glow – bottom left
        Positioned(
          bottom: sh * 0.15,
          left: -70,
          child: _AmbientOrb(
            size: 200,
            color: const Color(0xFFFACC15),
            alpha: 8,
            durationMs: 22000,
            moveRange: 6,
          ),
        ),
        // Very subtle teal glow – mid right
        Positioned(
          top: sh * 0.4,
          right: sw * 0.15,
          child: _AmbientOrb(
            size: 160,
            color: const Color(0xFF10B981),
            alpha: 6,
            durationMs: 18000,
            moveRange: 5,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

// ────────────────── Type 3: Particle Shimmer ──────────────────
class _ParticleBackground extends StatefulWidget {
  final Widget child;
  const _ParticleBackground({required this.child});

  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(14, (_) => _Particle(rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050B2D), Color(0xFF0B1445)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ParticlePainter(_particles, _ctrl.value),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _Particle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final int colorIdx;
  _Particle(Random r)
    : x = r.nextDouble(),
      startY = r.nextDouble(),
      speed = 0.3 + r.nextDouble() * 0.7,
      size = 2 + r.nextDouble() * 4,
      colorIdx = r.nextInt(3);

  static const _colors = [
    Color(0xFFFACC15),
    Color(0xFF10B981),
    Color(0xFF60A5FA),
  ];
  Color get color => _colors[colorIdx];
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final y = (p.startY - progress * p.speed) % 1.0;
      final opacity = (1 - (y - 0.5).abs() * 2).clamp(0.2, 1.0);
      paint.color = p.color.withAlpha((40 * opacity).round());
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

// ────────────────── Reusable Glow Orb ──────────────────
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final int durationMs;
  final double moveRange;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.durationMs,
    this.moveRange = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withAlpha(10), Colors.transparent],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.08, 1.08),
          duration: Duration(milliseconds: durationMs),
          curve: Curves.easeInOut,
        )
        .moveY(
          begin: -moveRange,
          end: moveRange,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.easeInOut,
        )
        .moveX(
          begin: -moveRange * 0.5,
          end: moveRange * 0.5,
          duration: Duration(milliseconds: (durationMs * 1.3).round()),
          curve: Curves.easeInOut,
        );
  }
}

// ────────────────── Pre-Blurred Ambient Orb ──────────────────
/// Lightweight orb for ambient backgrounds — uses built-in gradient blur
/// instead of BackdropFilter for better performance.
class _AmbientOrb extends StatelessWidget {
  final double size;
  final Color color;
  final int alpha;
  final int durationMs;
  final double moveRange;

  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.alpha,
    required this.durationMs,
    this.moveRange = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha(alpha),
            color.withAlpha((alpha * 0.4).round()),
            color.withAlpha((alpha * 0.1).round()),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: -moveRange,
          end: moveRange,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.easeInOut,
        )
        .moveX(
          begin: -moveRange * 0.6,
          end: moveRange * 0.6,
          duration: Duration(milliseconds: (durationMs * 1.2).round()),
          curve: Curves.easeInOut,
        )
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1.04, 1.04),
          duration: Duration(milliseconds: durationMs),
          curve: Curves.easeInOut,
        );
  }
}

// ────────────────── Glass Particle Overlay (Mesh Mode) ──────────────────
class _GlassParticleOverlay extends StatefulWidget {
  final double intensity;
  const _GlassParticleOverlay({this.intensity = 1.0});

  @override
  State<_GlassParticleOverlay> createState() => _GlassParticleOverlayState();
}

class _GlassParticleOverlayState extends State<_GlassParticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_GlassParticle> _pts;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _pts = List.generate(16, (_) => _GlassParticle(rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter:
            _GlassParticlePainter(_pts, _ctrl.value, widget.intensity),
      ),
    );
  }
}

class _GlassParticle {
  final double x, startY, speed, size;
  final int colorIdx;
  _GlassParticle(Random r)
      : x = r.nextDouble(),
        startY = r.nextDouble(),
        speed = 0.08 + r.nextDouble() * 0.18,
        size = 1.5 + r.nextDouble() * 3.0,
        colorIdx = r.nextInt(4);

  static const _colors = [
    Color(0xFF60A5FA),
    Color(0xFFFACC15),
    Color(0xFFA78BFA),
    Color(0xFFFFFFFF),
  ];
  Color get color => _colors[colorIdx];
}

class _GlassParticlePainter extends CustomPainter {
  final List<_GlassParticle> pts;
  final double progress;
  final double intensity;
  _GlassParticlePainter(this.pts, this.progress, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pts) {
      final y = (p.startY + progress * p.speed) % 1.0;
      final fade = (1 - (y - 0.5).abs() * 2).clamp(0.3, 1.0);
      paint.color =
          p.color.withAlpha((28 * fade * intensity).round().clamp(0, 255));
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlassParticlePainter old) => true;
}
