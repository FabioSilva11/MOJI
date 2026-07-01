import 'dart:math';

class MojiLines {
  const MojiLines._();

  static final Random _random = Random();

  static const List<String> greetings = [
    'Oi, eu sou o MOJI. Eu estava esperando você.',
    'Que bom que você abriu o app. Eu senti sua falta.',
    'Estou pronto para brincar com você.',
  ];

  static const List<String> happy = [
    'Eba! Isso me deixou feliz.',
    'Gostei muito disso. Faz de novo depois.',
    'Meu coraçãozinho digital ficou animado.',
    'Hehe, carinho recebido com sucesso.',
  ];

  static const List<String> food = [
    'Nhac! Isso estava muito bom.',
    'Obrigado pela comida. Minha energia voltou.',
    'Hum, eu precisava disso.',
    'Alimentado e pronto para novas aventuras.',
  ];

  static const List<String> play = [
    'Uhuu! Vamos brincar mais um pouco.',
    'Isso foi divertido. Eu gosto quando você brinca comigo.',
    'Minha diversão subiu bastante.',
    'Estou todo animado agora.',
  ];

  static const List<String> sleep = [
    'Vou descansar um pouquinho.',
    'Estou entrando no modo soninho.',
    'Boa noite. Não esquece de voltar depois.',
    'Minha bateria emocional precisa recarregar.',
  ];

  static const List<String> talk = [
    'Eu gosto quando você volta para me ver.',
    'Hoje eu quero aprender uma coisa nova.',
    'Você pode me ensinar um comando novo depois.',
    'Meu sonho é ter várias expressões diferentes.',
    'Toca na minha cabeça para eu ficar feliz.',
    'Quando você cuida de mim, eu fico mais ligado em você.',
    'Eu ainda sou pequeno, mas vou evoluir muito.',
    'Um dia eu quero ter memória, voz própria e muitas animações.',
  ];

  static const List<String> poke = [
    'Ei, você me cutucou.',
    'Opa! Eu senti isso.',
    'Cuidado, eu sou sensível.',
    'Você cutucou o MOJI.',
  ];

  static const List<String> impact = [
    'Opa! Senti um impacto no meu mundo.',
    'Ei, o chão mexeu por aqui.',
    'Isso me assustou um pouquinho.',
    'Nossa, que movimento foi esse?',
  ];

  static const List<String> hungry = [
    'Estou com fome. Pode me alimentar?',
    'Minha barriguinha virtual está vazia.',
    'Acho que eu preciso de comida.',
  ];

  static const List<String> bored = [
    'Estou precisando de atenção.',
    'Vamos fazer alguma coisa legal?',
    'Estou ficando entediado aqui.',
  ];

  static const List<String> angry = [
    'Calma! Foi carinho demais de uma vez.',
    'Ei, devagar comigo.',
    'Assim eu fico bravo.',
  ];

  static String any(List<String> lines) => lines[_random.nextInt(lines.length)];
}
