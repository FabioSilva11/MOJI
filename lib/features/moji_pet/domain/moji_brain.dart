import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../services/moji_memory_service.dart';
import 'moji_animation.dart';
import 'moji_dialog_planner.dart';
import 'moji_lines.dart';
import 'moji_mood.dart';

class MojiBrain extends ChangeNotifier {
  final Random _random = Random();

  MojiMood mood = MojiMood.curious;
  MojiAnimation animation = MojiAnimation.bootup3;
  String message = MojiLines.any(MojiLines.boot);

  int hunger = 28;
  int energy = 82;
  int affection = 55;
  int fun = 58;
  int level = 1;
  int xp = 0;

  int _touchCombo = 0;
  int _idleTicks = 0;
  bool hasBooted = false;

  Future<void> restore(MojiMemoryService memory) async {
    final snapshot = await memory.load();
    if (snapshot == null) {
      bootUp();
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final awayMinutes = ((now - snapshot.savedAtMillis) / 60000).clamp(0, 240).round();

    mood = snapshot.mood;
    message = snapshot.message;
    hunger = snapshot.hunger + awayMinutes ~/ 8;
    energy = snapshot.energy - awayMinutes ~/ 12;
    affection = snapshot.affection - awayMinutes ~/ 18;
    fun = snapshot.fun - awayMinutes ~/ 10;
    level = snapshot.level;
    xp = snapshot.xp;
    animation = MojiAnimation.neutral;
    hasBooted = true;

    if (awayMinutes > 20) {
      message = 'Você voltou! Eu fiquei esperando por $awayMinutes minutos.';
      mood = MojiMood.happy;
      animation = MojiAnimation.happy2;
    }

    _normalize();
    notifyListeners();
  }

  Future<void> save(MojiMemoryService memory) async {
    await memory.save(
      MojiMemorySnapshot(
        mood: mood,
        message: message,
        hunger: hunger,
        energy: energy,
        affection: affection,
        fun: fun,
        level: level,
        xp: xp,
        savedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  void bootUp() {
    hasBooted = true;
    _touchCombo = 0;
    _setMood(MojiMood.curious, customMessage: MojiLines.any(MojiLines.boot), nextAnimation: MojiAnimation.bootup3);
    notifyListeners();
  }

  void tick() {
    _idleTicks++;
    hunger += 2;
    energy -= 1;
    fun -= 2;
    affection -= _idleTicks % 6 == 0 ? 1 : 0;

    if (_idleTicks % 5 == 0) {
      _setMood(MojiMood.neutral, customMessage: MojiLines.any(MojiLines.idle), nextAnimation: MojiAnimation.blink2);
    } else if (_idleTicks % 3 == 0 && mood == MojiMood.neutral) {
      _setMood(_random.nextBool() ? MojiMood.curious : MojiMood.neutral, nextAnimation: MojiAnimation.neutral);
    }

    if (hunger > 82) {
      _setMood(MojiMood.sad, customMessage: MojiLines.any(MojiLines.hungry), nextAnimation: MojiAnimation.sad);
    } else if (energy < 18) {
      _setMood(MojiMood.sleepy, customMessage: MojiLines.any(MojiLines.sleep), nextAnimation: MojiAnimation.blink);
    } else if (fun < 18) {
      _setMood(MojiMood.bored, customMessage: MojiLines.any(MojiLines.bored), nextAnimation: MojiAnimation.sad);
    }

    _normalize();
    notifyListeners();
  }

  void petHead() {
    _touchCombo++;
    affection += 8;
    fun += 4;
    energy -= 1;
    _gainXp(4);

    if (_touchCombo >= 5) {
      _touchCombo = 0;
      _setMood(MojiMood.angry, customMessage: MojiLines.any(MojiLines.angry), nextAnimation: MojiAnimation.angry);
    } else if (affection > 82) {
      _setMood(MojiMood.love, customMessage: MojiLines.any(MojiLines.love), nextAnimation: MojiAnimation.happy3);
    } else {
      final happyAnimations = <MojiAnimation>[MojiAnimation.happy, MojiAnimation.happy2, MojiAnimation.happy3];
      _setMood(
        MojiMood.happy,
        customMessage: MojiLines.any(MojiLines.happy),
        nextAnimation: happyAnimations[_random.nextInt(happyAnimations.length)],
      );
    }

    _normalize();
    notifyListeners();
  }

  void poke() {
    fun += 3;
    energy -= 2;
    final moods = <MojiMood>[MojiMood.curious, MojiMood.angry, MojiMood.excited];
    final selected = moods[_random.nextInt(moods.length)];
    _setMood(selected, customMessage: MojiLines.any(MojiLines.poke));
    _gainXp(2);
    _normalize();
    notifyListeners();
  }

  void feed() {
    hunger -= 28;
    energy += 4;
    affection += 3;
    _setMood(MojiMood.happy, customMessage: MojiLines.any(MojiLines.food), nextAnimation: MojiAnimation.happy2);
    _gainXp(8);
    _normalize();
    notifyListeners();
  }

  void play() {
    fun += 30;
    energy -= 16;
    hunger += 8;
    affection += 7;
    _setMood(
      energy > 18 ? MojiMood.excited : MojiMood.sleepy,
      customMessage: energy > 18 ? MojiLines.any(MojiLines.play) : MojiLines.any(MojiLines.sleep),
      nextAnimation: energy > 18 ? MojiAnimation.excited : MojiAnimation.blink,
    );
    _gainXp(10);
    _normalize();
    notifyListeners();
  }

  void sleep() {
    energy += 34;
    hunger += 3;
    fun -= 2;
    _setMood(MojiMood.sleepy, customMessage: MojiLines.any(MojiLines.sleep), nextAnimation: MojiAnimation.blink);
    _gainXp(3);
    _normalize();
    notifyListeners();
  }

  void talk() {
    final line = MojiDialogPlanner.think(
      MojiDialogContext(
        mood: mood,
        hunger: hunger,
        energy: energy,
        affection: affection,
        fun: fun,
        level: level,
      ),
    );
    _setMood(MojiMood.curious, customMessage: line, nextAnimation: MojiAnimation.blink2);
    affection += 3;
    _gainXp(4);
    _normalize();
    notifyListeners();
  }

  void shakeReaction() {
    final roll = _random.nextInt(4);
    if (roll == 0) {
      _setMood(MojiMood.excited, customMessage: MojiLines.any(MojiLines.dizzy), nextAnimation: MojiAnimation.dizzy);
    } else {
      final moods = <MojiMood>[MojiMood.angry, MojiMood.sad, MojiMood.excited];
      final reaction = moods[_random.nextInt(moods.length)];
      _setMood(reaction, customMessage: MojiLines.any(MojiLines.impact));
    }
    energy -= 5;
    fun += 4;
    _normalize();
    notifyListeners();
  }

  void calmDown() {
    _touchCombo = 0;
    _setMood(MojiMood.neutral, customMessage: MojiLines.any(MojiLines.idle), nextAnimation: MojiAnimation.neutral);
    notifyListeners();
  }

  double get hungerValue => hunger / 100;
  double get energyValue => energy / 100;
  double get affectionValue => affection / 100;
  double get funValue => fun / 100;
  double get xpValue => xp / 100;

  void _setMood(MojiMood nextMood, {String? customMessage, MojiAnimation? nextAnimation}) {
    mood = nextMood;
    animation = nextAnimation ?? _animationForMood(nextMood);
    message = customMessage ?? nextMood.defaultMessage;
    _idleTicks = 0;
  }

  MojiAnimation _animationForMood(MojiMood value) {
    switch (value) {
      case MojiMood.happy:
        return MojiAnimation.happy;
      case MojiMood.love:
        return MojiAnimation.happy3;
      case MojiMood.sad:
        return MojiAnimation.sad;
      case MojiMood.angry:
        return MojiAnimation.angry;
      case MojiMood.excited:
        return MojiAnimation.excited;
      case MojiMood.sleepy:
        return MojiAnimation.blink;
      case MojiMood.curious:
        return MojiAnimation.blink2;
      case MojiMood.bored:
        return MojiAnimation.sad;
      case MojiMood.neutral:
        return MojiAnimation.neutral;
    }
  }

  void _gainXp(int amount) {
    xp += amount;
    while (xp >= 100) {
      xp -= 100;
      level++;
      _setMood(MojiMood.excited, customMessage: 'Subi para o nível $level!', nextAnimation: MojiAnimation.excited);
    }
  }

  void _normalize() {
    hunger = hunger.clamp(0, 100).toInt();
    energy = energy.clamp(0, 100).toInt();
    affection = affection.clamp(0, 100).toInt();
    fun = fun.clamp(0, 100).toInt();
    xp = xp.clamp(0, 100).toInt();
  }
}
