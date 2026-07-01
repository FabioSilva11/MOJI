import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/moji_memory_service.dart';
import '../../../services/moji_speech_service.dart';
import '../domain/moji_animation.dart';
import '../domain/moji_brain.dart';
import '../domain/moji_mood.dart';
import '../widgets/moji_action_button.dart';
import '../widgets/moji_character_motion.dart';
import '../widgets/moji_dialog_bubble.dart';
import '../widgets/moji_stat_bar.dart';

class MojiHomePage extends StatefulWidget {
  const MojiHomePage({super.key});

  @override
  State<MojiHomePage> createState() => _MojiHomePageState();
}

class _MojiHomePageState extends State<MojiHomePage> {
  late final MojiBrain _brain;
  late final MojiSpeechService _speech;
  late final MojiMemoryService _memory;
  Timer? _lifeTimer;
  Timer? _saveTimer;
  String? _lastSpokenMessage;
  bool _voiceEnabled = true;

  @override
  void initState() {
    super.initState();
    _brain = MojiBrain();
    _speech = MojiSpeechService();
    _memory = MojiMemoryService();
    _brain.addListener(_onBrainChanged);
    _lifeTimer = Timer.periodic(const Duration(seconds: 6), (_) => _brain.tick());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _brain.restore(_memory);
      await _speakCurrentMessage();
    });
  }

  void _onBrainChanged() {
    _speakCurrentMessage();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 700), () {
      _brain.save(_memory);
    });
  }

  Future<void> _speakCurrentMessage() async {
    if (!_voiceEnabled) return;
    if (_lastSpokenMessage == _brain.message) return;

    _lastSpokenMessage = _brain.message;
    await _speech.speak(_brain.message);
  }

  Future<void> _toggleVoice() async {
    setState(() {
      _voiceEnabled = !_voiceEnabled;
    });

    if (_voiceEnabled) {
      _lastSpokenMessage = null;
      await _speakCurrentMessage();
    } else {
      await _speech.stop();
    }
  }

  @override
  void dispose() {
    _lifeTimer?.cancel();
    _saveTimer?.cancel();
    _brain.save(_memory);
    _brain.removeListener(_onBrainChanged);
    _speech.stop();
    _brain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _brain,
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.25,
                  colors: [
                    Color(0xFF172554),
                    Color(0xFF0B1020),
                    Color(0xFF050812),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _Header(
                    brain: _brain,
                    voiceEnabled: _voiceEnabled,
                    onToggleVoice: _toggleVoice,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                      child: Column(
                        children: [
                          _StatsGrid(brain: _brain),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _brain.petHead,
                              onDoubleTap: _brain.poke,
                              onLongPress: _brain.talk,
                              onVerticalDragEnd: (_) => _brain.shakeReaction(),
                              child: Hero(
                                tag: 'moji-character',
                                child: MojiCharacterMotion(
                                  mood: _brain.mood,
                                  animation: _brain.animation,
                                ),
                              ),
                            ),
                          ),
                          MojiDialogBubble(message: _brain.message),
                          const SizedBox(height: 14),
                          _ActionPanel(brain: _brain),
                          const SizedBox(height: 8),
                          Text(
                            'Toque: carinho • duplo toque: cutucar • arraste: impacto • toque longo: fala contextual',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
}

class _Header extends StatelessWidget {
  const _Header({
    required this.brain,
    required this.voiceEnabled,
    required this.onToggleVoice,
  });

  final MojiBrain brain;
  final bool voiceEnabled;
  final VoidCallback onToggleVoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22D3EE).withOpacity(0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MOJI',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Humor: ${brain.mood.label} • Animação: ${brain.animation.profile.name}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: voiceEnabled ? 'Desligar voz' : 'Ligar voz',
            onPressed: onToggleVoice,
            icon: Icon(voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Text(
                  'Nível ${brain.level}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 74,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: brain.xpValue,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.brain});

  final MojiBrain brain;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.3,
      children: [
        MojiStatBar(label: 'Fome', value: 1 - brain.hungerValue, icon: Icons.restaurant_rounded),
        MojiStatBar(label: 'Energia', value: brain.energyValue, icon: Icons.bolt_rounded),
        MojiStatBar(label: 'Carinho', value: brain.affectionValue, icon: Icons.favorite_rounded),
        MojiStatBar(label: 'Diversão', value: brain.funValue, icon: Icons.sports_esports_rounded),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.brain});

  final MojiBrain brain;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MojiActionButton(label: 'Comida', icon: Icons.cookie_rounded, onTap: brain.feed),
        const SizedBox(width: 10),
        MojiActionButton(label: 'Brincar', icon: Icons.celebration_rounded, onTap: brain.play),
        const SizedBox(width: 10),
        MojiActionButton(label: 'Dormir', icon: Icons.bedtime_rounded, onTap: brain.sleep),
        const SizedBox(width: 10),
        MojiActionButton(label: 'Falar', icon: Icons.chat_bubble_rounded, onTap: brain.talk),
      ],
    );
  }
}
