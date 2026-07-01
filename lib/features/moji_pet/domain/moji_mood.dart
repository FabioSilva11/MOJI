enum MojiMood {
  neutral,
  happy,
  sad,
  angry,
  excited,
  sleepy,
  curious,
  bored,
  love,
}

extension MojiMoodText on MojiMood {
  String get label {
    switch (this) {
      case MojiMood.neutral:
        return 'Neutro';
      case MojiMood.happy:
        return 'Feliz';
      case MojiMood.sad:
        return 'Triste';
      case MojiMood.angry:
        return 'Bravo';
      case MojiMood.excited:
        return 'Animado';
      case MojiMood.sleepy:
        return 'Sonolento';
      case MojiMood.curious:
        return 'Curioso';
      case MojiMood.bored:
        return 'Entediado';
      case MojiMood.love:
        return 'Carinhoso';
    }
  }

  String get defaultMessage {
    switch (this) {
      case MojiMood.neutral:
        return 'Estou aqui com você.';
      case MojiMood.happy:
        return 'Hehe! Gostei disso!';
      case MojiMood.sad:
        return 'Fiquei meio quietinho...';
      case MojiMood.angry:
        return 'Ei! Não precisa me assustar.';
      case MojiMood.excited:
        return 'Uhuu! Vamos brincar!';
      case MojiMood.sleepy:
        return 'Estou com soninho...';
      case MojiMood.curious:
        return 'O que será que vamos fazer agora?';
      case MojiMood.bored:
        return 'Estou precisando de atenção.';
      case MojiMood.love:
        return 'Gosto muito quando você cuida de mim.';
    }
  }
}
