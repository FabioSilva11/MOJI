import 'package:shared_preferences/shared_preferences.dart';

import '../features/moji_pet/domain/moji_mood.dart';

class MojiMemorySnapshot {
  const MojiMemorySnapshot({
    required this.mood,
    required this.message,
    required this.hunger,
    required this.energy,
    required this.affection,
    required this.fun,
    required this.level,
    required this.xp,
    required this.savedAtMillis,
  });

  final MojiMood mood;
  final String message;
  final int hunger;
  final int energy;
  final int affection;
  final int fun;
  final int level;
  final int xp;
  final int savedAtMillis;
}

class MojiMemoryService {
  static const String _moodKey = 'moji.mood';
  static const String _messageKey = 'moji.message';
  static const String _hungerKey = 'moji.hunger';
  static const String _energyKey = 'moji.energy';
  static const String _affectionKey = 'moji.affection';
  static const String _funKey = 'moji.fun';
  static const String _levelKey = 'moji.level';
  static const String _xpKey = 'moji.xp';
  static const String _savedAtKey = 'moji.savedAtMillis';

  Future<MojiMemorySnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final moodName = prefs.getString(_moodKey);
    if (moodName == null) return null;

    final mood = MojiMood.values.firstWhere(
      (item) => item.name == moodName,
      orElse: () => MojiMood.curious,
    );

    return MojiMemorySnapshot(
      mood: mood,
      message: prefs.getString(_messageKey) ?? mood.defaultMessage,
      hunger: prefs.getInt(_hungerKey) ?? 28,
      energy: prefs.getInt(_energyKey) ?? 82,
      affection: prefs.getInt(_affectionKey) ?? 55,
      fun: prefs.getInt(_funKey) ?? 58,
      level: prefs.getInt(_levelKey) ?? 1,
      xp: prefs.getInt(_xpKey) ?? 0,
      savedAtMillis: prefs.getInt(_savedAtKey) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> save(MojiMemorySnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_moodKey, snapshot.mood.name);
    await prefs.setString(_messageKey, snapshot.message);
    await prefs.setInt(_hungerKey, snapshot.hunger);
    await prefs.setInt(_energyKey, snapshot.energy);
    await prefs.setInt(_affectionKey, snapshot.affection);
    await prefs.setInt(_funKey, snapshot.fun);
    await prefs.setInt(_levelKey, snapshot.level);
    await prefs.setInt(_xpKey, snapshot.xp);
    await prefs.setInt(_savedAtKey, snapshot.savedAtMillis);
  }
}
