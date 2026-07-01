import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/moji_mood.dart';

class MojiCharacter extends StatefulWidget {
  const MojiCharacter({
    required this.mood,
    super.key,
  });

  final MojiMood mood;

  @override
  State<MojiCharacter> createState() => _MojiCharacterState();
}

class _MojiCharacterState extends State<MojiCharacter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
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
        return CustomPaint(
          painter: _MojiPainter(
            mood: widget.mood,
            progress: _controller.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _MojiPainter extends CustomPainter {
  _MojiPainter({
    required this.mood,
    required this.progress,
  });

  final MojiMood mood;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bob = math.sin(progress * math.pi * 2) * 7;
    final glowPulse = 0.65 + (math.sin(progress * math.pi * 2) + 1) * 0.18;
    final robotCenter = center.translate(0, bob);

    _drawShadow(canvas, size, robotCenter);
    _drawBody(canvas, size, robotCenter, glowPulse);
    _drawHead(canvas, size, robotCenter, glowPulse);
    _drawFace(canvas, size, robotCenter);
    _drawMoodDetails(canvas, size, robotCenter);
  }

  void _drawShadow(Canvas canvas, Size size, Offset c) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx, size.height * 0.82), width: size.width * 0.52, height: 28),
      paint,
    );
  }

  void _drawBody(Canvas canvas, Size size, Offset c, double glowPulse) {
    final bodyW = size.width * 0.37;
    final bodyH = size.height * 0.25;
    final bodyRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + size.height * 0.2),
      width: bodyW,
      height: bodyH,
    );
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(bodyW * 0.28));

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF7FAFF), Color(0xFFB9C4D8), Color(0xFF6B7280)],
      ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, bodyPaint);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.55);
    canvas.drawRRect(bodyRRect, outline);

    final chestRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + size.height * 0.2),
      width: bodyW * 0.58,
      height: bodyH * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chestRect, const Radius.circular(22)),
      Paint()..color = const Color(0xFFF9FAFB).withOpacity(0.92),
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'MOJI',
        style: TextStyle(
          color: Color(0xFF7C3AED),
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(c.dx - textPainter.width / 2, chestRect.center.dy - textPainter.height / 2));

    final armPaint = Paint()..color = const Color(0xFF1F2937);
    canvas.drawCircle(Offset(bodyRect.left - 14, bodyRect.center.dy - 6), 19, armPaint);
    canvas.drawCircle(Offset(bodyRect.right + 14, bodyRect.center.dy - 6), 19, armPaint);

    final wheelPaint = Paint()..color = const Color(0xFF111827);
    canvas.drawCircle(Offset(bodyRect.left + bodyW * 0.18, bodyRect.bottom + 12), 27, wheelPaint);
    canvas.drawCircle(Offset(bodyRect.right - bodyW * 0.18, bodyRect.bottom + 12), 27, wheelPaint);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = _accentColor.withOpacity(glowPulse);
    canvas.drawCircle(Offset(bodyRect.left + bodyW * 0.18, bodyRect.bottom + 12), 16, ringPaint);
    canvas.drawCircle(Offset(bodyRect.right - bodyW * 0.18, bodyRect.bottom + 12), 16, ringPaint);
  }

  void _drawHead(Canvas canvas, Size size, Offset c, double glowPulse) {
    final headW = size.width * 0.52;
    final headH = size.height * 0.34;
    final headRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy - size.height * 0.11),
      width: headW,
      height: headH,
    );
    final headRRect = RRect.fromRectAndRadius(headRect, Radius.circular(headW * 0.2));

    final headPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFE5E7EB), Color(0xFF8B94A6)],
      ).createShader(headRect);
    canvas.drawRRect(headRRect, headPaint);

    canvas.drawRRect(
      headRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withOpacity(0.75),
    );

    final earPaint = Paint()..color = const Color(0xFF1F2937);
    final leftEar = Offset(headRect.left + 6, headRect.center.dy);
    final rightEar = Offset(headRect.right - 6, headRect.center.dy);
    canvas.drawCircle(leftEar, 25, earPaint);
    canvas.drawCircle(rightEar, 25, earPaint);

    final earRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = _accentColor.withOpacity(glowPulse);
    canvas.drawCircle(leftEar, 15, earRing);
    canvas.drawCircle(rightEar, 15, earRing);
  }

  void _drawFace(Canvas canvas, Size size, Offset c) {
    final faceRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy - size.height * 0.11),
      width: size.width * 0.42,
      height: size.height * 0.22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(faceRect.height * 0.42)),
      Paint()..color = const Color(0xFF030712),
    );

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = _accentColor.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(RRect.fromRectAndRadius(faceRect, Radius.circular(faceRect.height * 0.42)), glow);

    final eyeY = faceRect.center.dy - 7;
    final leftEye = Offset(faceRect.center.dx - faceRect.width * 0.22, eyeY);
    final rightEye = Offset(faceRect.center.dx + faceRect.width * 0.22, eyeY);
    final mouthCenter = Offset(faceRect.center.dx, faceRect.center.dy + faceRect.height * 0.24);

    switch (mood) {
      case MojiMood.happy:
      case MojiMood.love:
        _drawHappyEyes(canvas, leftEye, rightEye);
        _drawSmile(canvas, mouthCenter, 1.0);
        break;
      case MojiMood.excited:
        _drawStarEyes(canvas, leftEye, rightEye);
        _drawSmile(canvas, mouthCenter, 1.15);
        break;
      case MojiMood.sad:
        _drawSadEyes(canvas, leftEye, rightEye);
        _drawSadMouth(canvas, mouthCenter);
        break;
      case MojiMood.angry:
        _drawAngryEyes(canvas, leftEye, rightEye);
        _drawFlatMouth(canvas, mouthCenter);
        break;
      case MojiMood.sleepy:
        _drawSleepyEyes(canvas, leftEye, rightEye);
        _drawTinyMouth(canvas, mouthCenter);
        break;
      case MojiMood.curious:
        _drawCuriousEyes(canvas, leftEye, rightEye);
        _drawTinyMouth(canvas, mouthCenter);
        break;
      case MojiMood.bored:
        _drawBoredEyes(canvas, leftEye, rightEye);
        _drawFlatMouth(canvas, mouthCenter);
        break;
      case MojiMood.neutral:
        _drawNeutralEyes(canvas, leftEye, rightEye);
        _drawSmile(canvas, mouthCenter, 0.65);
        break;
    }
  }

  void _drawMoodDetails(Canvas canvas, Size size, Offset c) {
    if (mood == MojiMood.love) {
      final paint = Paint()..color = const Color(0xFFFF5CA8).withOpacity(0.9);
      _drawHeart(canvas, Offset(c.dx + size.width * 0.24, c.dy - size.height * 0.28), 11, paint);
      _drawHeart(canvas, Offset(c.dx - size.width * 0.27, c.dy - size.height * 0.18), 8, paint);
    }

    if (mood == MojiMood.sleepy) {
      final tp = TextPainter(
        text: const TextSpan(
          text: 'Zzz',
          style: TextStyle(color: Color(0xFF7DD3FC), fontSize: 26, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(c.dx + size.width * 0.18, c.dy - size.height * 0.32));
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size)
      ..cubicTo(center.dx - size * 2, center.dy - size * 0.4, center.dx - size, center.dy - size * 1.8, center.dx, center.dy - size * 0.6)
      ..cubicTo(center.dx + size, center.dy - size * 1.8, center.dx + size * 2, center.dy - size * 0.4, center.dx, center.dy + size);
    canvas.drawPath(path, paint);
  }

  void _drawNeutralEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()..color = _accentColor;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: l, width: 24, height: 28), const Radius.circular(9)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: r, width: 24, height: 28), const Radius.circular(9)), paint);
  }

  void _drawHappyEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: l, width: 34, height: 32), math.pi, math.pi, false, paint);
    canvas.drawArc(Rect.fromCenter(center: r, width: 34, height: 32), math.pi, math.pi, false, paint);
  }

  void _drawStarEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()..color = _accentColor;
    _star(canvas, l, 15, paint);
    _star(canvas, r, 15, paint);
  }

  void _drawSadEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: l, width: 32, height: 26), 0, math.pi, false, paint);
    canvas.drawArc(Rect.fromCenter(center: r, width: 32, height: 26), 0, math.pi, false, paint);
  }

  void _drawAngryEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(l.translate(-13, -6), l.translate(13, 5), paint);
    canvas.drawLine(r.translate(-13, 5), r.translate(13, -6), paint);
  }

  void _drawSleepyEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(l.translate(-14, 0), l.translate(14, 0), paint);
    canvas.drawLine(r.translate(-14, 0), r.translate(14, 0), paint);
  }

  void _drawCuriousEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()..color = _accentColor;
    canvas.drawCircle(l, 13, paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: r, width: 25, height: 34), const Radius.circular(10)), paint);
  }

  void _drawBoredEyes(Canvas canvas, Offset l, Offset r) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(l.translate(-12, 0), l.translate(12, -2), paint);
    canvas.drawLine(r.translate(-12, -2), r.translate(12, 0), paint);
  }

  void _drawSmile(Canvas canvas, Offset c, double scale) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: c, width: 38 * scale, height: 26 * scale), 0.15, math.pi - 0.3, false, paint);
  }

  void _drawSadMouth(Canvas canvas, Offset c) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: c.translate(0, 12), width: 34, height: 25), math.pi + 0.15, math.pi - 0.3, false, paint);
  }

  void _drawFlatMouth(Canvas canvas, Offset c) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c.translate(-15, 5), c.translate(15, 5), paint);
  }

  void _drawTinyMouth(Canvas canvas, Offset c) {
    final paint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c.translate(0, 6), 5, paint);
  }

  void _star(Canvas canvas, Offset c, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * 0.45;
      final p = Offset(c.dx + math.cos(angle) * r, c.dy + math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  Color get _accentColor {
    switch (mood) {
      case MojiMood.angry:
        return const Color(0xFFFF4D6D);
      case MojiMood.sad:
        return const Color(0xFF60A5FA);
      case MojiMood.sleepy:
        return const Color(0xFFA78BFA);
      case MojiMood.love:
        return const Color(0xFFFF5CA8);
      case MojiMood.excited:
        return const Color(0xFF34D399);
      default:
        return const Color(0xFF22D3EE);
    }
  }

  @override
  bool shouldRepaint(covariant _MojiPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.mood != mood;
  }
}
