import 'package:cloze_call/data/database_helper.dart';
import 'package:cloze_call/data/repositories/cloze_review_repository.dart';
import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/data/streams/cloze_stream_service.dart';
import 'package:cloze_call/pages/home/home_page.dart';
import 'package:cloze_call/pages/language/language_page.dart';
import 'package:cloze_call/pages/learn/learn_page.dart';
import 'package:cloze_call/services/cloze/cloze_review_service.dart';
import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:cloze_call/services/connectivity_service.dart';
import 'package:cloze_call/services/tts_service.dart';
import 'package:cloze_call/utils/path_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PathManager.instance.initialize();
  final dbHelper = DatabaseHelper();
  final connectivityService = ConnectivityService();
  final configRepo = ConfigRepository(await dbHelper.database);
  final clozeRepo = ClozeReviewRepository(await dbHelper.database);
  final clozeStreamService = ClozeStreamService(clozeRepo);
  final clozeService = ClozeService(configRepo, clozeStreamService);
  final clozeReviewService = ClozeReviewService(clozeStreamService);
  await clozeReviewService.initialize();
  final ttsService = TTSService(connectivityService);
  await ttsService.initialize();

  runApp(MultiProvider(
    providers: [
      Provider<ClozeService>(create: (_) => clozeService),
      Provider<ClozeReviewService>(create: (_) => clozeReviewService),
      Provider<TTSService>(create: (_) => ttsService),
      Provider<ConfigRepository>(create: (_) => configRepo),
      Provider<ClozeStreamService>(create: (_) => clozeStreamService),
      Provider<ConnectivityService>(create: (_) => connectivityService)
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var clozeService = Provider.of<ClozeService>(context, listen: false);
    var clozeReviewService =
        Provider.of<ClozeReviewService>(context, listen: false);

    return MaterialApp(
      title: 'Cloze Call',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange, brightness: Brightness.dark),
          useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/learn': (context) => LearnPage(clozeService: clozeService),
        '/language': (context) => const LanguagePage(),
        '/review': (context) => LearnPage(clozeService: clozeReviewService),
        '/handsfree': (context) =>
            LearnPage(clozeService: clozeService, handsFree: true)
      },
    );
  }
}
