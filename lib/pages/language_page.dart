import 'package:cloze_call/services/cloze_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final clozeService = Provider.of<ClozeService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await clozeService.pickLanguageFile();
                await clozeService.initialize();
              },
              child: const Text('Select language file'),
            ),
          ],
        ),
      ),
    );
  }
}
