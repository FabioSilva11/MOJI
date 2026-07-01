import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/moji_animation.dart';
import '../domain/moji_mood.dart';
import 'moji_character.dart' as old;

class MojiCharacterAnim extends StatefulWidget {
  const MojiCharacterAnim({required this.mood, required this.animation, super.key});

  final MojiMood mood;
  final MojiAnimation animation;

  @override
  State<MojiCharacterAnim> createState() => _MojiCharacterAnimState();
}

class _MojiCharacterAnimState extends State<MojiCharacterAnim> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animation.profile.duration)..repeat();
  }

  @override
  void didUpdateWidget(covariant MojiCharacterAnim oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _controller
        ..duration = widget.animation.profile.duration
        ..forward(from: 0)
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final p = math.sin(t * math.pi * 2);
        final f = (t * widget.animation.profile.frames).floor();
        final values = _values(widget.animation, t, p, f);

        return Transform.translate(
          offset: Offset(values.dx, values.dy),
          child: Transform.rotate(
            angle: values.angle,
            child: Transform.scale(
              scale: values.scale,
              child: Opacity(
                opacity: values.opacity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (values.glow)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: values.glowColor.withOpacity(values.glowOpacity),
                              blurRadius: values.glowRadius,
                              spreadRadius: values.glowSpread,
                            ),
                          ],
                        ),
                        child: const SizedBox(width: 170, height: 170),
                      ),
                    old.MojiCharacter(
                      key: ValueKey('${widget.mood.name}-${widget.animation.name}'),
                      mood: widget.mood,
                    ),
                    if (values.label != null)
                      Positioned(
                        top: 18 + values.labelDy,
                        child: Text(
                          values.label!,
                          style: TextStyle(
                            color: values.glowColor.withOpacity(0.85),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: values.labelSize,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _AnimValues _values(MojiAnimation animation, double t, double pulse, int frame) {
    switch (animation) {
      case MojiAnimation.bootup3:
        return _AnimValues(
          dy: (1 - t) * 48,
          scale: 0.72 + t * 0.28,
          opacity: (0.35 + t * 0.65).clamp(0.0, 1.0),
          angle: math.sin(t * math.pi * 6) * 0.025,
          glow: true,
          glowColor: const Color(0xFF22D3EE),
          glowOpacity: 0.25 + t * 0.25,
          glowRadius: 45,
          glowSpread: 8,
          label: 'BOOT',
          labelDy: math.sin(t * math.pi * 8) * 4,
          labelSize: 16,
        );
      case MojiAnimation.neutral:
        return _AnimValues(dy: pulse * 4, glow: true, glowColor: const Color(0xFF22D3EE), glowOpacity: 0.12, glowRadius: 30, glowSpread: 2);
      case MojiAnimation.blink:
        return _AnimValues(scaleY: 0.92 + ((frame % 39) < 8 ? -0.08 : 0.0), dy: pulse * 2);
      case MojiAnimation.blink2:
        return _AnimValues(scaleY: (frame % 20) > 14 ? 0.86 : 1.0, dy: pulse * 3, glow: true, glowColor: const Color(0xFF38BDF8), glowOpacity: 0.1, glowRadius: 22, glowSpread: 1);
      case MojiAnimation.happy:
        return _AnimValues(dy: pulse * 12, angle: pulse * 0.035, glow: true, glowColor: const Color(0xFF22D3EE), glowOpacity: 0.22, glowRadius: 38, glowSpread: 4);
      case MojiAnimation.happy2:
        return _AnimValues(dy: -math.sin(t * math.pi) * 24, scale: 1 + math.sin(t * math.pi) * 0.08, glow: true, glowColor: const Color(0xFF7C3AED), glowOpacity: 0.22, glowRadius: 42, glowSpread: 5, label: '+XP', labelDy: -t * 30, labelSize: 14);
      case MojiAnimation.happy3:
        return _AnimValues(dy: pulse * 7, scale: 1 + pulse.abs() * 0.05, angle: pulse * 0.025, glow: true, glowColor: const Color(0xFFFF5CA8), glowOpacity: 0.26, glowRadius: 44, glowSpread: 6, label: '♥', labelDy: -math.sin(t * math.pi) * 18, labelSize: 26);
      case MojiAnimation.sad:
        return _AnimValues(dy: 18 + math.sin(t * math.pi) * 3, angle: -0.04, scale: 0.96, glow: true, glowColor: const Color(0xFF60A5FA), glowOpacity: 0.12, glowRadius: 26, glowSpread: 1);
      case MojiAnimation.dizzy:
        return _AnimValues(dx: pulse * 12, dy: math.cos(t * math.pi * 2) * 6, angle: pulse * 0.16, scale: 0.98 + pulse.abs() * 0.04, glow: true, glowColor: const Color(0xFFFBBF24), glowOpacity: 0.22, glowRadius: 34, glowSpread: 4, label: '???', labelDy: pulse * 8, labelSize: 16);
      case MojiAnimation.excited:
        return _AnimValues(dy: pulse * 16, angle: pulse * 0.07, scale: 1 + pulse.abs() * 0.07, glow: true, glowColor: const Color(0xFF34D399), glowOpacity: 0.28, glowRadius: 48, glowSpread: 7, label: 'WOW', labelDy: -math.sin(t * math.pi) * 24, labelSize: 15);
      case MojiAnimation.angry:
        return _AnimValues(dx: frame.isEven ? -8 : 8, angle: frame.isEven ? -0.055 : 0.055, glow: true, glowColor: const Color(0xFFFF4D6D), glowOpacity: 0.3, glowRadius: 36, glowSpread: 4, label: '!', labelDy: -math.sin(t * math.pi) * 18, labelSize: 24);
    }
  }
}

class _AnimValues {
  const _AnimValues({
    this.dx = 0,
    this.dy = 0,
    this.angle = 0,
    this.scale = 1,
    this.scaleY = 1,
    this.opacity = 1,
    this.glow = false,
    this.glowColor = Colors.cyan,
    this.glowOpacity = 0,
    this.glowRadius = 0,
    this.glowSpread = 0,
    this.label,
    this.labelDy = 0,
    this.labelSize = 14,
  });

  final double dx;
  final double dy;
  final double angle;
  final double scale;
  final double scaleY;
  final double opacity;
  final bool glow;
  final Color glowColor;
  final double glowOpacity;
  final double glowRadius;
  final double glowSpread;
  final String? label;
  final double labelDy;
  final double labelSize;
}
