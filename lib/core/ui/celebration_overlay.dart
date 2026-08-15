import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

void showCelebration(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  HapticFeedback.mediumImpact();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _CelebrationOverlay(
      title: title,
      message: message,
      onCompleted: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({
    required this.title,
    required this.message,
    required this.onCompleted,
  });

  final String title;
  final String message;
  final VoidCallback onCompleted;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random(42);
    _particles = List.generate(84, (index) {
      return _ConfettiParticle(
        startX: random.nextDouble(),
        drift: (random.nextDouble() - 0.5) * 260,
        fall: 220 + random.nextDouble() * 520,
        size: 5 + random.nextDouble() * 8,
        rotation: random.nextDouble() * math.pi * 2,
        color: _confettiColors[index % _confettiColors.length],
      );
    });

    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2600),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onCompleted();
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 14;

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final value = _controller.value;
            final bannerOpacity = value < 0.82 ? 1.0 : (1 - value) / 0.18;
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: value,
                    ),
                  ),
                ),
                Positioned(
                  top: top,
                  left: 18,
                  right: 18,
                  child: Opacity(
                    opacity: bannerOpacity.clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        -12 * (1 - Curves.easeOut.transform(value)),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dark.withValues(alpha: 0.24),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final opacity = (1 - progress).clamp(0, 1);

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity.toDouble());
      final x = (particle.startX * size.width) + (particle.drift * eased);
      final y = -24 + (particle.fall * eased) + (120 * progress * progress);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + (progress * math.pi * 3));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 1.8,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.startX,
    required this.drift,
    required this.fall,
    required this.size,
    required this.rotation,
    required this.color,
  });

  final double startX;
  final double drift;
  final double fall;
  final double size;
  final double rotation;
  final Color color;
}

const _confettiColors = [
  AppColors.primary,
  AppColors.accent,
  AppColors.gps,
  AppColors.danger,
  Color(0xFF7C4DFF),
  Color(0xFF00C2A8),
];
