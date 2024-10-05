import 'package:cloze_call/data/database_helper.dart';
import 'package:cloze_call/data/repositories/cloze_review_repository.dart';
import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/pages/language_page.dart';
import 'package:cloze_call/pages/learn_page.dart';
import 'package:cloze_call/services/cloze/cloze_review_service.dart';
import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:edge_tts/edge_tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final configRepo = ConfigRepository(await dbHelper.database);
  final clozeRepo = ClozeReviewRepository(await dbHelper.database);
  final clozeService = ClozeService(configRepo, clozeRepo);
  await clozeService.initialize();
  final clozeReviewService = ClozeReviewService(clozeRepo);
  await clozeReviewService.initialize();
  final voiceManager = await VoicesManager.create();

  runApp(MultiProvider(
    providers: [
      Provider<ClozeService>(create: (_) => clozeService),
      Provider<ClozeReviewService>(create: (_) => clozeReviewService),
      Provider<VoicesManager>(create: (_) => voiceManager)
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
      },
    );
  }
}
