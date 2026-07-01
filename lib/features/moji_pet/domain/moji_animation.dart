enum MojiAnimation {
  bootup3,
  neutral,
  blink,
  blink2,
  happy,
  happy2,
  happy3,
  sad,
  dizzy,
  excited,
  angry,
}

class MojiAnimationProfile {
  const MojiAnimationProfile({
    required this.name,
    required this.frames,
    required this.loops,
    required this.intensity,
    required this.duration,
  });

  final String name;
  final int frames;
  final int loops;
  final double intensity;
  final Duration duration;
}

extension MojiAnimationData on MojiAnimation {
  MojiAnimationProfile get profile {
    switch (this) {
      case MojiAnimation.bootup3:
        return const MojiAnimationProfile(name: 'bootup3', frames: 124, loops: 1, intensity: 1.0, duration: Duration(milliseconds: 2600));
      case MojiAnimation.neutral:
        return const MojiAnimationProfile(name: 'neutral', frames: 61, loops: 4, intensity: 0.25, duration: Duration(milliseconds: 1800));
      case MojiAnimation.blink:
        return const MojiAnimationProfile(name: 'blink', frames: 39, loops: 1, intensity: 0.15, duration: Duration(milliseconds: 720));
      case MojiAnimation.blink2:
        return const MojiAnimationProfile(name: 'blink2', frames: 20, loops: 3, intensity: 0.2, duration: Duration(milliseconds: 950));
      case MojiAnimation.happy:
        return const MojiAnimationProfile(name: 'happy', frames: 60, loops: 4, intensity: 1.0, duration: Duration(milliseconds: 1900));
      case MojiAnimation.happy2:
        return const MojiAnimationProfile(name: 'happy2', frames: 20, loops: 2, intensity: 0.8, duration: Duration(milliseconds: 1200));
      case MojiAnimation.happy3:
        return const MojiAnimationProfile(name: 'happy3', frames: 26, loops: 2, intensity: 0.9, duration: Duration(milliseconds: 1300));
      case MojiAnimation.sad:
        return const MojiAnimationProfile(name: 'sad', frames: 47, loops: 4, intensity: 0.55, duration: Duration(milliseconds: 2300));
      case MojiAnimation.dizzy:
        return const MojiAnimationProfile(name: 'dizzy', frames: 67, loops: 2, intensity: 1.15, duration: Duration(milliseconds: 2200));
      case MojiAnimation.excited:
        return const MojiAnimationProfile(name: 'excited', frames: 24, loops: 4, intensity: 1.25, duration: Duration(milliseconds: 1350));
      case MojiAnimation.angry:
        return const MojiAnimationProfile(name: 'angry', frames: 20, loops: 4, intensity: 1.05, duration: Duration(milliseconds: 1600));
    }
  }
}
