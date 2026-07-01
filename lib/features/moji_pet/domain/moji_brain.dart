import 'dart:math';

import 'package:flutter/foundation.dart';

import 'moji_mood.dart';

class MojiBrain extends ChangeNotifier {
  final Random _random = Random();

  MojiMood mood = MojiMood.neutral;
  String message = MojiMood.neutral.defaultMessage;

  int hunger = 28; // 0 = cheio, 100 = faminto
  int energy = 82; // 0 = cansado, 100 = cheio de energia
  int affection = 55; // carinho
  int fun = 58; // diversão
  int level = 1;
  int xp = 0;

  int _touchCombo = 0;
  int _idleTicks = 0;

  void tick() {
    _idleTicks++;
    hunger += 2;
    energy -= 1;
    fun -= 2;

    if (_idleTicks % 4 == 0 && mood == MojiMood.neutral) {
      _setMood(_random.nextBool() ? MojiMood.curious : MojiMood.neutral);
    }

    if (hunger > 82) {
      _setMood(MojiMood.sad, customMessage: 'Estou com fome. Pode me alimentar?');
    } else if (energy < 18) {
      _setMood(MojiMood.sleepy, customMessage: 'Minha bateria emocional está baixa.');
    } else if (fun < 18) {
      _setMood(MojiMood.bored, customMessage: 'Vamos fazer alguma coisa legal?');
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
      _setMood(MojiMood.angry, customMessage: 'Calma! Foi carinho demais de uma vez.');
    } else if (affection > 82) {
      _setMood(MojiMood.love);
    } else {
      _setMood(MojiMood.happy, customMessage: 'Carinho recebido!');
    }

    _normalize();
    notifyListeners();
  }

  void poke() {
    fun += 3;
    energy -= 2;
    final reactions = <MojiMood>[MojiMood.curious, MojiMood.angry, MojiMood.excited];
    _setMood(reactions[_random.nextInt(reactions.length)], customMessage: 'Você cutucou o MOJI!');
    _gainXp(2);
    _normalize();
    notifyListeners();
  }

  void feed() {
    hunger -= 28;
    energy += 4;
    affection += 3;
    _setMood(MojiMood.happy, customMessage: 'Nhac! Isso estava bom.');
    _gainXp(8);
    _normalize();
    notifyListeners();
  }

  void play() {
    fun += 30;
    energy -= 16;
    hunger += 8;
    affection += 7;
    _setMood(energy > 18 ? MojiMood.excited : MojiMood.sleepy);
    _gainXp(10);
    _normalize();
    notifyListeners();
  }

  void sleep() {
    energy += 34;
    hunger += 3;
    fun -= 2;
    _setMood(MojiMood.sleepy, customMessage: 'Vou descansar um pouquinho.');
    _gainXp(3);
    _normalize();
    notifyListeners();
  }

  void talk() {
    final messages = <String>[
      'Eu gosto quando você volta para me ver.',
      'Hoje eu quero aprender uma coisa nova.',
      'Você pode me ensinar um comando novo depois.',
      'Meu sonho é ter várias expressões diferentes.',
      'Toca na minha cabeça para eu ficar feliz.',
    ];

    _setMood(MojiMood.curious, customMessage: messages[_random.nextInt(messages.length)]);
    affection += 3;
    _gainXp(4);
    _normalize();
    notifyListeners();
  }

  void shakeReaction() {
    final reactions = <MojiMood>[MojiMood.angry, MojiMood.sad, MojiMood.excited];
    final reaction = reactions[_random.nextInt(reactions.length)];
    _setMood(reaction, customMessage: 'Opa! Senti um impacto no mundo do MOJI.');
    energy -= 5;
    fun += 4;
    _normalize();
    notifyListeners();
  }

  void calmDown() {
    _touchCombo = 0;
    _setMood(MojiMood.neutral);
    notifyListeners();
  }

  double get hungerValue => hunger / 100;
  double get energyValue => energy / 100;
  double get affectionValue => affection / 100;
  double get funValue => fun / 100;
  double get xpValue => xp / 100;

  void _setMood(MojiMood nextMood, {String? customMessage}) {
    mood = nextMood;
    message = customMessage ?? nextMood.defaultMessage;
    _idleTicks = 0;
  }

  void _gainXp(int amount) {
    xp += amount;
    while (xp >= 100) {
      xp -= 100;
      level++;
      _setMood(MojiMood.excited, customMessage: 'Subi para o nível $level!');
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
