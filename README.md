# Agenda de Eventos — Notificações Push (Flutter + FCM)

App de agenda de eventos acadêmicos. Tela inicial com a lista de eventos e tela de detalhes.
As notificações avisam sobre os eventos: novidades, destaque com imagem e atalho direto para os detalhes.

## Configurar o Firebase (plano Spark, gratuito)

1. Em https://console.firebase.google.com crie um projeto (pode desativar o Analytics).
2. Adicione um app **Android** com o pacote `br.edu.notificacoes.agenda_eventos`.
3. Baixe o `google-services.json` e coloque em `android/app/google-services.json`.
4. Rode no celular/emulador Android (o emulador precisa ter Google Play):
   ```
   flutter run
   ```
5. Aceite a permissão de notificações. O **token FCM** aparece no fim da tela inicial (botão de copiar) e no console do `flutter run`.

## Enviar as notificações

Firebase Console → **Messaging** → *Nova campanha* → *Notificações* → preencha → **Enviar mensagem de teste** → cole o token.
Antes de enviar, **coloque o app em segundo plano** (botão Home).

| Desafio | Título | Texto | Imagem (URL) | Opções adicionais → Dados personalizados |
|---|---|---|---|---|
| 1. Simples | Inscrições abertas! | A Semana Acadêmica começa dia 12/11. Confira a programação. | — | — |
| 2. Com imagem | Hackathon de Apps 🚀 | 24h para criar um app para o campus. Monte sua equipe! | `https://picsum.photos/id/180/800/400` | — |
| 3. Navegação | Começa em 1 hora | Workshop de Firebase na Sala 204. Toque para ver os detalhes. | (opcional) | chave `evento_id`, valor `3` |

No desafio 3, teste os dois casos pedidos:
- **Segundo plano:** app minimizado → toque na notificação → abre os detalhes do evento 3.
- **App fechado:** feche o app (remova dos recentes) → envie → toque → o app inicia já nos detalhes.

`evento_id` aceita `1`, `2` ou `3` (eventos definidos em `lib/main.dart`).

Com o app **aberto**, o Android não exibe a notificação na bandeja; o app mostra um aviso na parte de baixo da tela (com botão "Ver" se houver `evento_id`).

## Onde está cada coisa (`lib/main.dart`)

- `requestPermission()` — permissão de notificações (Android 13+).
- `getInitialMessage()` — app iniciado pelo toque na notificação.
- `onMessageOpenedApp` — app em segundo plano aberto pelo toque.
- `_abrirDaNotificacao` — lê `evento_id` dos dados e abre a `DetalhesPage`.
- A imagem do desafio 2 é exibida pelo próprio Android a partir do campo *Imagem* do FCM, sem código extra.
