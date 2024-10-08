import 'package:cloze_call/data/enums/language.dart';
import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:cloze_call/utils/file_downloader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final _fileDownloader = FileDownloader();
  late ClozeService _clozeService;
  @override
  void initState() {
    super.initState();
    _clozeService = Provider.of<ClozeService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            languages(),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () async {
                var path = await _clozeService.pickLanguageFile();
                await _clozeService.setLanguageFile(path);
                await _clozeService.initialize();
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
              child: const Text('Select language file'),
            ),
          ],
        ),
      ),
    );
  }

  Widget languages() {
    return Column(children: [
      for (var language in Language.values)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
              onPressed: () async {
                // TODO: progress bar
                var fileName = _fileDownloader.getFileNameFromUrl(language.url);
                var path =
                    await _fileDownloader.downloadFile(language.url, fileName);

                if (path != null) {
                  await _clozeService.setLanguageFile(path);
                  await _clozeService.initialize();
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
              child: Text(language.name)),
        )
    ]);
  }
}
