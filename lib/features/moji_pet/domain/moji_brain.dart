import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../services/moji_memory_service.dart';
import 'moji_action.dart';
import 'moji_animation.dart';
import 'moji_dialog_planner.dart';
import 'moji_lines.dart';
import 'moji_mood.dart';

class MojiBrain extends ChangeNotifier {
  final Random _random = Random();

  MojiMood mood = MojiMood.curious;
  MojiAnimation animation = MojiAnimation.bootup3;
  String message = MojiLines.any(MojiLines.boot);
  MojiAction? lastAction;

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

  void runAction(MojiAction action) {
    final profile = action.profile;
    lastAction = action;
    _setMood(profile.mood, customMessage: profile.message, nextAnimation: profile.animation);

    switch (action) {
      case MojiAction.petted:
        affection += 8;
        fun += 3;
        _gainXp(4);
        break;
      case MojiAction.shaking:
      case MojiAction.falling:
        energy -= 6;
        fun -= 2;
        break;
      case MojiAction.charging:
        energy += 18;
        break;
      case MojiAction.lowPower:
        energy -= 4;
        break;
      case MojiAction.playingGame:
      case MojiAction.dancing:
        fun += 18;
        energy -= 10;
        hunger += 5;
        _gainXp(10);
        break;
      case MojiAction.sleeping:
        energy += 20;
        fun -= 2;
        break;
      case MojiAction.wakeup:
        energy += 5;
        break;
      case MojiAction.listening:
      case MojiAction.speaking:
      case MojiAction.answeringSmalltalk:
      case MojiAction.answeringUtility:
      case MojiAction.answeringQuestion:
        affection += 2;
        _gainXp(3);
        break;
      case MojiAction.exploring:
      case MojiAction.searching:
      case MojiAction.moving:
        energy -= 6;
        fun += 4;
        break;
      case MojiAction.lifted:
      case MojiAction.obstacleDetected:
      case MojiAction.soundDetected:
      case MojiAction.playingMusic:
      case MojiAction.lookingAtFace:
      case MojiAction.seesNonhuman:
      case MojiAction.staying:
      case MojiAction.lookingAround:
        break;
    }

    _normalize();
    notifyListeners();
  }

  void tick() {
    _idleTicks++;
    hunger += 2;
    energy -= 1;
    fun -= 2;
    affection -= _idleTicks % 6 == 0 ? 1 : 0;

    if (_idleTicks % 5 == 0) {
      runAction(MojiAction.lookingAround);
    }

    if (hunger > 82) {
      _setMood(MojiMood.sad, customMessage: MojiLines.any(MojiLines.hungry), nextAnimation: MojiAnimation.sad);
    } else if (energy < 18) {
      runAction(MojiAction.lowPower);
    } else if (fun < 18) {
      _setMood(MojiMood.bored, customMessage: MojiLines.any(MojiLines.bored), nextAnimation: MojiAnimation.sad);
    }

    _normalize();
    notifyListeners();
  }

  void petHead() => runAction(MojiAction.petted);

  void poke() {
    _touchCombo++;
    if (_touchCombo >= 5) {
      _touchCombo = 0;
      runAction(MojiAction.shaking);
    } else {
      runAction(MojiAction.soundDetected);
    }
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

  void play() => runAction(MojiAction.playingGame);

  void sleep() => runAction(MojiAction.sleeping);

  void talk() {
    runAction(MojiAction.listening);
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
    final actions = <MojiAction>[MojiAction.shaking, MojiAction.falling, MojiAction.lifted];
    runAction(actions[_random.nextInt(actions.length)]);
  }

  void calmDown() => runAction(MojiAction.staying);

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
