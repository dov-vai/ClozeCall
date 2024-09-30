import 'package:cloze_call/data/database_helper.dart';
import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/pages/language_page.dart';
import 'package:cloze_call/pages/learn_page.dart';
import 'package:cloze_call/services/cloze_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final configRepo = ConfigRepository(await dbHelper.database);
  final clozeService = ClozeService(configRepo);
  await clozeService.initialize();

  runApp(MultiProvider(
    providers: [Provider<ClozeService>(create: (_) => clozeService)],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloze Call',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/learn': (context) => const LearnPage(),
        '/language': (context) => const LanguagePage(),
      },
    );
  }
}
