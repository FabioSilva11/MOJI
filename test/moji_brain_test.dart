import 'package:flutter_test/flutter_test.dart';
import 'package:moji_pet/features/moji_pet/domain/moji_brain.dart';
import 'package:moji_pet/features/moji_pet/domain/moji_mood.dart';

void main() {
  test('feeding lowers hunger and makes MOJI happy', () {
    final brain = MojiBrain();
    final initialHunger = brain.hunger;

    brain.feed();

    expect(brain.hunger, lessThan(initialHunger));
    expect(brain.mood, MojiMood.happy);
  });

  test('petting increases affection', () {
    final brain = MojiBrain();
    final initialAffection = brain.affection;

    brain.petHead();

    expect(brain.affection, greaterThan(initialAffection));
  });
}
