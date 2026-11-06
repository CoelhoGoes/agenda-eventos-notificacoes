import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Com o app em segundo plano/fechado, o próprio Android exibe a notificação
// (título, mensagem e imagem). Este handler só precisa existir.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  runApp(const AgendaApp());
}

class Evento {
  final String id, titulo, data, local, descricao, imagem;
  const Evento(this.id, this.titulo, this.data, this.local, this.descricao, this.imagem);
}

// Dados fixos no código (a atividade dispensa banco de dados).
const eventos = [
  Evento('1', 'Palestra: Flutter na prática', '12/11 às 19h', 'Auditório A',
      'Introdução ao desenvolvimento mobile multiplataforma com Flutter e Dart.',
      'https://picsum.photos/id/0/800/400'),
  Evento('2', 'Hackathon de Apps', '14/11 às 08h', 'Laboratório 3',
      '24 horas para criar um app que resolva um problema do campus. Equipes de até 4 pessoas.',
      'https://picsum.photos/id/180/800/400'),
  Evento('3', 'Workshop de Firebase', '18/11 às 14h', 'Sala 204',
      'Autenticação, Firestore e Cloud Messaging na prática, usando o plano gratuito Spark.',
      'https://picsum.photos/id/119/800/400'),
];

class AgendaApp extends StatelessWidget {
  const AgendaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Agenda de Eventos',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _configurarNotificacoes();
  }

  Future<void> _configurarNotificacoes() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(); // Android 13+ exige permissão em tempo de execução
    fcm.onRegistered.listen((token) {
      debugPrint('FCM token: $token');
      if (mounted) setState(() => _token = token);
    });
    await fcm.register();

    // Desafio 3: app fechado e aberto pelo toque na notificação.
    final inicial = await fcm.getInitialMessage();
    if (inicial != null) _abrirDaNotificacao(inicial);

    // Desafio 3: app em segundo plano e trazido à frente pelo toque.
    FirebaseMessaging.onMessageOpenedApp.listen(_abrirDaNotificacao);

    // Com o app aberto o Android não mostra a notificação; avisamos na tela.
    FirebaseMessaging.onMessage.listen((m) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${m.notification?.title ?? ''}\n${m.notification?.body ?? ''}'),
        action: m.data['evento_id'] == null
            ? null
            : SnackBarAction(label: 'Ver', onPressed: () => _abrirDaNotificacao(m)),
      ));
    });
  }

  void _abrirDaNotificacao(RemoteMessage message) {
    final id = message.data['evento_id'];
    final evento = eventos.where((e) => e.id == id).firstOrNull;
    if (evento == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalhesPage(evento: evento)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Agenda de Eventos')),
        body: ListView(
          children: [
            for (final e in eventos)
              ListTile(
                leading: CircleAvatar(child: Text(e.id)),
                title: Text(e.titulo),
                subtitle: Text('${e.data} · ${e.local}'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetalhesPage(evento: e)),
                ),
              ),
            const Divider(),
            ListTile(
              title: const Text('Token FCM (para testes no Firebase Console)'),
              subtitle: SelectableText(_token ?? 'obtendo...'),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _token == null
                    ? null
                    : () => Clipboard.setData(ClipboardData(text: _token!)),
              ),
            ),
          ],
        ),
      );
}

class DetalhesPage extends StatelessWidget {
  final Evento evento;
  const DetalhesPage({super.key, required this.evento});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(evento.titulo)),
        body: ListView(
          children: [
            Image.network(evento.imagem, height: 200, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.titulo, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('📅 ${evento.data}'),
                  Text('📍 ${evento.local}'),
                  const SizedBox(height: 16),
                  Text(evento.descricao),
                ],
              ),
            ),
          ],
        ),
      );
}
