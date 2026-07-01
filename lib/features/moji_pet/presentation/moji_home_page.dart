import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/moji_memory_service.dart';
import '../../../services/moji_speech_service.dart';
import '../domain/moji_action.dart';
import '../domain/moji_animation.dart';
import '../domain/moji_brain.dart';
import '../domain/moji_mood.dart';
import '../widgets/moji_character_motion.dart';
import '../widgets/moji_dialog_bubble.dart';

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
  int _tabIndex = 0;

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
    setState(() => _voiceEnabled = !_voiceEnabled);
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
          backgroundColor: const Color(0xFF050812),
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.35,
                colors: [Color(0xFF172554), Color(0xFF070B18), Color(0xFF030610)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PremiumHeader(
                            brain: _brain,
                            voiceEnabled: _voiceEnabled,
                            onToggleVoice: _toggleVoice,
                          ),
                          const SizedBox(height: 18),
                          _HeroStage(brain: _brain),
                          const SizedBox(height: 16),
                          MojiDialogBubble(message: _brain.message),
                          const SizedBox(height: 16),
                          _StatsGrid(brain: _brain),
                          const SizedBox(height: 16),
                          _ActionGrid(brain: _brain),
                          const SizedBox(height: 16),
                          _InsightRow(brain: _brain),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  _BottomNav(index: _tabIndex, onChanged: (value) => setState(() => _tabIndex = value)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({required this.brain, required this.voiceEnabled, required this.onToggleVoice});

  final MojiBrain brain;
  final bool voiceEnabled;
  final VoidCallback onToggleVoice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
            ),
            boxShadow: [
              BoxShadow(color: const Color(0xFF22D3EE).withOpacity(0.28), blurRadius: 30, offset: const Offset(0, 14)),
            ],
          ),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MOJI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 3)),
              const SizedBox(height: 2),
              Text(
                'Pet Virtual • Humor: ${brain.mood.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withOpacity(0.68), fontWeight: FontWeight.w800, fontSize: 14),
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
        _LevelPill(level: brain.level, value: brain.xpValue),
      ],
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level, required this.value});

  final int level;
  final double value;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nível $level', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            width: 76,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: value,
                backgroundColor: Colors.white.withOpacity(0.10),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFC084FC)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStage extends StatelessWidget {
  const _HeroStage({required this.brain});

  final MojiBrain brain;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
            ),
          ),
          Positioned(
            bottom: 34,
            child: Container(
              width: 250,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.42), width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.35), blurRadius: 30)],
              ),
            ),
          ),
          Positioned(
            top: 26,
            child: _StatusChip(icon: Icons.auto_awesome_rounded, label: brain.animation.profile.name),
          ),
          Positioned(
            left: 16,
            top: 76,
            child: Column(
              children: [
                _StageAction(icon: Icons.videogame_asset_rounded, label: 'Brincar', onTap: brain.play),
                const SizedBox(height: 18),
                _StageAction(icon: Icons.restaurant_rounded, label: 'Comida', onTap: brain.feed),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 76,
            child: Column(
              children: [
                _StageAction(icon: Icons.nightlight_round, label: 'Dormir', onTap: brain.sleep),
                const SizedBox(height: 18),
                _StageAction(icon: Icons.chat_bubble_rounded, label: 'Falar', onTap: brain.talk),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 52),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: brain.petHead,
              onDoubleTap: brain.poke,
              onLongPress: brain.talk,
              onVerticalDragEnd: (_) => brain.shakeReaction(),
              child: Hero(
                tag: 'moji-character',
                child: MojiCharacterMotion(mood: brain.mood, animation: brain.animation),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageAction extends StatelessWidget {
  const _StageAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: _GlassCard(
        width: 82,
        height: 92,
        radius: 24,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF22D3EE), size: 30),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFC084FC)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
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
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: [
        _StatTile(label: 'Fome', icon: Icons.restaurant_rounded, value: 1 - brain.hungerValue, color: const Color(0xFF8B5CF6), percent: '${((1 - brain.hungerValue) * 100).round()}%'),
        _StatTile(label: 'Energia', icon: Icons.bolt_rounded, value: brain.energyValue, color: const Color(0xFF22D3EE), percent: '${(brain.energyValue * 100).round()}%'),
        _StatTile(label: 'Carinho', icon: Icons.favorite_rounded, value: brain.affectionValue, color: const Color(0xFFFF5CA8), percent: '${(brain.affectionValue * 100).round()}%'),
        _StatTile(label: 'Diversão', icon: Icons.sports_esports_rounded, value: brain.funValue, color: const Color(0xFFFF8A3D), percent: '${(brain.funValue * 100).round()}%'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.icon, required this.value, required this.color, required this.percent});

  final String label;
  final IconData icon;
  final double value;
  final Color color;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
              Text(percent, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.brain});

  final MojiBrain brain;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Atividades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              _StatusChip(icon: Icons.memory_rounded, label: brain.lastAction?.profile.label ?? 'Pronto'),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              _ActivityCard(icon: Icons.lunch_dining_rounded, title: 'Dar comida', subtitle: '+Energia', onTap: brain.feed, color: const Color(0xFFFFC857)),
              _ActivityCard(icon: Icons.gamepad_rounded, title: 'Jogar', subtitle: '+Diversão', onTap: brain.play, color: const Color(0xFF8B5CF6)),
              _ActivityCard(icon: Icons.nightlight_round, title: 'Dormir', subtitle: '+Energia', onTap: brain.sleep, color: const Color(0xFF60A5FA)),
              _ActivityCard(icon: Icons.record_voice_over_rounded, title: 'Ouvir', subtitle: 'Listening', onTap: () => brain.runAction(MojiAction.listening), color: const Color(0xFF22D3EE)),
              _ActivityCard(icon: Icons.music_note_rounded, title: 'Música', subtitle: 'Playing', onTap: () => brain.runAction(MojiAction.playingMusic), color: const Color(0xFF34D399)),
              _ActivityCard(icon: Icons.auto_awesome_rounded, title: 'Dançar', subtitle: 'Dancing', onTap: () => brain.runAction(MojiAction.dancing), color: const Color(0xFFFF5CA8)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.icon, required this.title, required this.subtitle, required this.onTap, required this.color});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.10), Colors.white.withOpacity(0.035)]),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: color.withOpacity(0.85), fontWeight: FontWeight.w700, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.brain});

  final MojiBrain brain;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _GlassCard(
            height: 118,
            padding: const EdgeInsets.all(18),
            radius: 26,
            child: Row(
              children: [
                Text(_moodEmoji(brain.mood), style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(brain.mood.label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                      const SizedBox(height: 6),
                      Text('MOJI está em modo ${brain.animation.profile.name}.', style: TextStyle(color: Colors.white.withOpacity(0.68), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassCard(
            height: 118,
            padding: const EdgeInsets.all(18),
            radius: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('+${(brain.xpValue * 100).round()} XP', style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                Text('Progresso do nível', style: TextStyle(color: Colors.white.withOpacity(0.66), fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 8),
                const Text('🏆 ✨ 💜', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _moodEmoji(MojiMood mood) {
    switch (mood) {
      case MojiMood.happy:
      case MojiMood.love:
        return '😊';
      case MojiMood.sad:
        return '😢';
      case MojiMood.angry:
        return '😠';
      case MojiMood.excited:
        return '🤩';
      case MojiMood.sleepy:
        return '😴';
      case MojiMood.bored:
        return '😐';
      case MojiMood.curious:
        return '👀';
      case MojiMood.neutral:
        return '🙂';
    }
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Início'),
      (Icons.favorite_border_rounded, 'Cuidados'),
      (Icons.explore_rounded, 'Descobrir'),
      (Icons.person_outline_rounded, 'Perfil'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF070B18).withOpacity(0.94),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].$1, color: i == index ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.58)),
                    const SizedBox(height: 4),
                    Text(items[i].$2, style: TextStyle(color: i == index ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.58), fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding, this.radius = 24, this.width, this.height});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.105), Colors.white.withOpacity(0.035)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.085)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 22, offset: const Offset(0, 14))],
      ),
      child: child,
    );
  }
}
