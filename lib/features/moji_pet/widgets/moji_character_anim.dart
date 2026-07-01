import 'package:flutter/material.dart';

import '../domain/moji_animation.dart';
import '../domain/moji_mood.dart';
import 'moji_character.dart' as old;

class MojiCharacterAnim extends StatelessWidget {
  const MojiCharacterAnim({required this.mood, required this.animation, super.key});

  final MojiMood mood;
  final MojiAnimation animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animation.profile.duration,
      child: old.MojiCharacter(
        key: ValueKey('${mood.name}-${animation.name}'),
        mood: mood,
      ),
    );
  }
}
