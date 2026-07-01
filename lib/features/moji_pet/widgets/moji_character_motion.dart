import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/moji_animation.dart';
import '../domain/moji_mood.dart';
import 'moji_character.dart' as base;

class MojiCharacterMotion extends StatefulWidget {
  const MojiCharacterMotion({required this.mood, required this.animation, super.key});

  final MojiMood mood;
  final MojiAnimation animation;

  @override
  State<MojiCharacterMotion> createState() => _MojiCharacterMotionState();
}

class _MojiCharacterMotionState extends State<MojiCharacterMotion> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animation.profile.duration)..repeat();
  }

  @override
  void didUpdateWidget(covariant MojiCharacterMotion oldWidget) {
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
        final wave = math.sin(t * math.pi * 2);
        final frame = (t * widget.animation.profile.frames).floor();
        final motion = _motion(widget.animation, t, wave, frame);

        return Transform.translate(
          offset: Offset(motion.dx, motion.dy),
          child: Transform.rotate(
            angle: motion.angle,
            child: Transform.scale(
              scale: motion.scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (motion.glow > 0)
                    Container(
                      width: 185,
                      height: 185,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: motion.color.withOpacity(motion.glow),
                            blurRadius: motion.blur,
                            spreadRadius: motion.spread,
                          ),
                        ],
                      ),
                    ),
                  base.MojiCharacter(
                    key: ValueKey('${widget.mood.name}-${widget.animation.name}'),
                    mood: widget.mood,
                  ),
                  if (motion.text.isNotEmpty)
                    Positioned(
                      top: 18 + motion.textDy,
                      child: Text(
                        motion.text,
                        style: TextStyle(
                          color: motion.color.withOpacity(0.85),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: motion.textSize,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _MojiMotion _motion(MojiAnimation animation, double t, double wave, int frame) {
    switch (animation) {
      case MojiAnimation.bootup3:
        return _MojiMotion(
          dy: (1 - t) * 50,
          scale: 0.72 + t * 0.28,
          angle: math.sin(t * math.pi * 6) * 0.025,
          glow: 0.28,
          blur: 48,
          spread: 8,
          color: const Color(0xFF22D3EE),
          text: 'BOOT',
          textDy: wave * 4,
          textSize: 16,
        );
      case MojiAnimation.neutral:
        return _MojiMotion(dy: wave * 4, glow: 0.12, blur: 30, spread: 2, color: const Color(0xFF22D3EE));
      case MojiAnimation.blink:
        return _MojiMotion(scale: frame % 39 < 8 ? 0.94 : 1, dy: wave * 2, color: const Color(0xFF22D3EE));
      case MojiAnimation.blink2:
        return _MojiMotion(scale: frame % 20 > 14 ? 0.92 : 1, dy: wave * 3, glow: 0.10, blur: 22, spread: 1, color: const Color(0xFF38BDF8));
      case MojiAnimation.happy:
        return _MojiMotion(dy: wave * 12, angle: wave * 0.035, glow: 0.22, blur: 38, spread: 4, color: const Color(0xFF22D3EE));
      case MojiAnimation.happy2:
        return _MojiMotion(dy: -math.sin(t * math.pi) * 24, scale: 1 + math.sin(t * math.pi) * 0.08, glow: 0.22, blur: 42, spread: 5, color: const Color(0xFF7C3AED), text: '+XP', textDy: -t * 30);
      case MojiAnimation.happy3:
        return _MojiMotion(dy: wave * 7, scale: 1 + wave.abs() * 0.05, angle: wave * 0.025, glow: 0.26, blur: 44, spread: 6, color: const Color(0xFFFF5CA8), text: 'LOVE', textDy: -math.sin(t * math.pi) * 18, textSize: 16);
      case MojiAnimation.sad:
        return _MojiMotion(dy: 18 + math.sin(t * math.pi) * 3, angle: -0.04, scale: 0.96, glow: 0.12, blur: 26, spread: 1, color: const Color(0xFF60A5FA));
      case MojiAnimation.dizzy:
        return _MojiMotion(dx: wave * 12, dy: math.cos(t * math.pi * 2) * 6, angle: wave * 0.16, scale: 1 + wave.abs() * 0.04, glow: 0.22, blur: 34, spread: 4, color: const Color(0xFFFBBF24), text: '???', textDy: wave * 8, textSize: 16);
      case MojiAnimation.excited:
        return _MojiMotion(dy: wave * 16, angle: wave * 0.07, scale: 1 + wave.abs() * 0.07, glow: 0.28, blur: 48, spread: 7, color: const Color(0xFF34D399), text: 'WOW', textDy: -math.sin(t * math.pi) * 24, textSize: 15);
      case MojiAnimation.angry:
        return _MojiMotion(dx: frame.isEven ? -8 : 8, angle: frame.isEven ? -0.055 : 0.055, glow: 0.30, blur: 36, spread: 4, color: const Color(0xFFFF4D6D), text: '!', textDy: -math.sin(t * math.pi) * 18, textSize: 24);
    }
  }
}

class _MojiMotion {
  const _MojiMotion({
    this.dx = 0,
    this.dy = 0,
    this.angle = 0,
    this.scale = 1,
    this.glow = 0,
    this.blur = 0,
    this.spread = 0,
    this.color = Colors.cyan,
    this.text = '',
    this.textDy = 0,
    this.textSize = 14,
  });

  final double dx;
  final double dy;
  final double angle;
  final double scale;
  final double glow;
  final double blur;
  final double spread;
  final Color color;
  final String text;
  final double textDy;
  final double textSize;
}
