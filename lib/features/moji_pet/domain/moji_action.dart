import 'moji_animation.dart';
import 'moji_mood.dart';

enum MojiAction {
  petted,
  shaking,
  lifted,
  falling,
  charging,
  lowPower,
  obstacleDetected,
  soundDetected,
  listening,
  speaking,
  answeringSmalltalk,
  answeringUtility,
  answeringQuestion,
  playingMusic,
  dancing,
  playingGame,
  moving,
  lookingAtFace,
  seesNonhuman,
  staying,
  sleeping,
  wakeup,
  lookingAround,
  exploring,
  searching,
}

class MojiActionProfile {
  const MojiActionProfile({required this.label, required this.mood, required this.animation, required this.message});

  final String label;
  final MojiMood mood;
  final MojiAnimation animation;
  final String message;
}

extension MojiActionData on MojiAction {
  MojiActionProfile get profile {
    switch (this) {
      case MojiAction.petted:
        return const MojiActionProfile(label: 'Being petted', mood: MojiMood.happy, animation: MojiAnimation.happy, message: 'Carinho detectado. Eu gostei disso.');
      case MojiAction.shaking:
        return const MojiActionProfile(label: 'Being shaken', mood: MojiMood.angry, animation: MojiAnimation.angry, message: 'Ei, devagar comigo.');
      case MojiAction.lifted:
        return const MojiActionProfile(label: 'Picked up', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Você me levantou.');
      case MojiAction.falling:
        return const MojiActionProfile(label: 'Falls down', mood: MojiMood.sad, animation: MojiAnimation.dizzy, message: 'Ops... eu caí.');
      case MojiAction.charging:
        return const MojiActionProfile(label: 'Charging', mood: MojiMood.happy, animation: MojiAnimation.happy2, message: 'Estou recarregando minha energia.');
      case MojiAction.lowPower:
        return const MojiActionProfile(label: 'Low power', mood: MojiMood.sleepy, animation: MojiAnimation.blink, message: 'Minha energia está baixa.');
      case MojiAction.obstacleDetected:
        return const MojiActionProfile(label: 'Obstacles detected', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Detectei algo na minha frente.');
      case MojiAction.soundDetected:
        return const MojiActionProfile(label: 'Sound detected', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Ouvi alguma coisa.');
      case MojiAction.listening:
        return const MojiActionProfile(label: 'Listening', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Estou ouvindo você.');
      case MojiAction.speaking:
        return const MojiActionProfile(label: 'Speaking', mood: MojiMood.happy, animation: MojiAnimation.happy2, message: 'Vou responder agora.');
      case MojiAction.answeringSmalltalk:
        return const MojiActionProfile(label: 'Smalltalk answer', mood: MojiMood.happy, animation: MojiAnimation.happy, message: 'Eu gosto de conversar com você.');
      case MojiAction.answeringUtility:
        return const MojiActionProfile(label: 'Utility answer', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Vou tentar ajudar com isso.');
      case MojiAction.answeringQuestion:
        return const MojiActionProfile(label: 'Answering questions', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Essa é uma boa pergunta.');
      case MojiAction.playingMusic:
        return const MojiActionProfile(label: 'Playing music', mood: MojiMood.excited, animation: MojiAnimation.excited, message: 'Tocando música.');
      case MojiAction.dancing:
        return const MojiActionProfile(label: 'Dancing', mood: MojiMood.excited, animation: MojiAnimation.excited, message: 'Vamos dançar.');
      case MojiAction.playingGame:
        return const MojiActionProfile(label: 'Playing games', mood: MojiMood.excited, animation: MojiAnimation.happy2, message: 'Hora de jogar.');
      case MojiAction.moving:
        return const MojiActionProfile(label: 'Moving', mood: MojiMood.curious, animation: MojiAnimation.neutral, message: 'Estou me movendo.');
      case MojiAction.lookingAtFace:
        return const MojiActionProfile(label: 'Looking at face', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Estou olhando para você.');
      case MojiAction.seesNonhuman:
        return const MojiActionProfile(label: 'Sees nonhuman', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Vi alguma coisa diferente.');
      case MojiAction.staying:
        return const MojiActionProfile(label: 'Staying', mood: MojiMood.neutral, animation: MojiAnimation.neutral, message: 'Vou ficar quietinho aqui.');
      case MojiAction.sleeping:
        return const MojiActionProfile(label: 'Sleeping', mood: MojiMood.sleepy, animation: MojiAnimation.blink, message: 'Estou dormindo.');
      case MojiAction.wakeup:
        return const MojiActionProfile(label: 'Wake up', mood: MojiMood.happy, animation: MojiAnimation.bootup3, message: 'Acordei.');
      case MojiAction.lookingAround:
        return const MojiActionProfile(label: 'Looking around', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Estou olhando ao redor.');
      case MojiAction.exploring:
        return const MojiActionProfile(label: 'Exploring', mood: MojiMood.curious, animation: MojiAnimation.neutral, message: 'Estou explorando.');
      case MojiAction.searching:
        return const MojiActionProfile(label: 'Searching', mood: MojiMood.curious, animation: MojiAnimation.blink2, message: 'Estou procurando.');
    }
  }
}
