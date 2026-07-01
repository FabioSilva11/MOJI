import 'moji_lines.dart';
import 'moji_mood.dart';

class MojiDialogContext {
  const MojiDialogContext({
    required this.mood,
    required this.hunger,
    required this.energy,
    required this.affection,
    required this.fun,
    required this.level,
  });

  final MojiMood mood;
  final int hunger;
  final int energy;
  final int affection;
  final int fun;
  final int level;
}

class MojiDialogPlanner {
  const MojiDialogPlanner._();

  static String think(MojiDialogContext context) {
    if (context.hunger > 78) {
      return MojiLines.any(MojiLines.hungry);
    }
    if (context.energy < 22) {
      return MojiLines.any(MojiLines.sleep);
    }
    if (context.fun < 22) {
      return MojiLines.any(MojiLines.bored);
    }
    if (context.affection > 84) {
      return MojiLines.any(MojiLines.love);
    }
    if (context.level > 1 && context.level % 3 == 0) {
      return 'Eu estou no nível ${context.level}. Acho que estou ficando mais esperto.';
    }
    return MojiLines.any(MojiLines.talk);
  }
}
