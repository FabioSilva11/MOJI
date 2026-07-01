# MOJI Pet — Flutter MVP

MOJI é um pet virtual em Flutter inspirado na lógica de um robô companheiro: ele pisca, muda de humor, reage a toque, fica com fome, perde energia, ganha carinho e evolui de nível.

Este MVP não usa hardware. A ideia é transformar a lógica de um robô físico em um app 100% virtual.

## O que já vem pronto

- Personagem MOJI desenhado com `CustomPainter`, sem depender de imagens externas.
- Sistema de humor:
  - neutro
  - feliz
  - triste
  - bravo
  - animado
  - sonolento
  - curioso
  - entediado
  - carinhoso
- Sistema de vida:
  - fome
  - energia
  - carinho
  - diversão
  - XP e nível
- Interações:
  - toque simples: carinho
  - toque duplo: cutucar
  - toque longo: conversar
  - arrastar verticalmente: simular impacto/reação
  - botões para comida, brincar, dormir e falar

## Como rodar

Se você ainda não criou as plataformas Android/iOS/Web, entre na pasta do projeto e rode:

```bash
flutter create .
flutter pub get
flutter run
```

Se o Flutter perguntar se deve sobrescrever arquivos, preserve a pasta `lib/` e o `pubspec.yaml` deste projeto.

## Estrutura

```text
lib/
├── main.dart
└── features/
    └── moji_pet/
        ├── domain/
        │   ├── moji_brain.dart
        │   └── moji_mood.dart
        ├── presentation/
        │   └── moji_home_page.dart
        └── widgets/
            ├── moji_action_button.dart
            ├── moji_character.dart
            ├── moji_dialog_bubble.dart
            └── moji_stat_bar.dart
```

## Próximos passos recomendados

1. Adicionar persistência local para salvar fome, energia, nível e última interação.
2. Adicionar sons curtos para cada emoção.
3. Criar animações mais avançadas com Rive, Lottie ou sprites.
4. Adicionar sensor de movimento real com `sensors_plus` para detectar quando o usuário chacoalha o celular.
5. Adicionar modo conversa com IA.
6. Adicionar loja de acessórios visuais para o MOJI.
7. Adicionar notificações: “MOJI está com fome”, “MOJI quer brincar”.

## Identidade visual

O MOJI deve ter identidade própria. Ele pode ser inspirado na ideia de um pet robô emocional, mas evite copiar nome, artes, sons e elementos protegidos de produtos comerciais existentes.
## GitHub Actions / APK automático

Este repositório já inclui o workflow `.github/workflows/android-release.yml`.

Ele faz automaticamente:

1. Gera os arquivos Android com `flutter create --platforms=android --org com.fabiosilva.moji .`.
2. Instala as dependências com `flutter pub get`.
3. Executa `flutter analyze` e `flutter test`.
4. Compila o APK release com `flutter build apk --release`.
5. Salva o APK como artifact.
6. Publica o arquivo `MOJI-Pet.apk` em uma GitHub Release quando houver push na `main`, tag `v*` ou execução manual.

Para criar uma versão manual:

```bash
git tag v0.1.0
git push origin v0.1.0
```

Também dá para ir em **Actions → Build Android APK → Run workflow** para gerar uma release de build.

