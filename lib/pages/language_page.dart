import 'dart:io';

import 'package:cloze_call/data/enums/language.dart';
import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:cloze_call/utils/file_downloader.dart';
import 'package:cloze_call/utils/path_manager.dart';
import 'package:cloze_call/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final _fileDownloader = FileDownloader();
  late ClozeService _clozeService;
  String? _languageFilePath;
  @override
  void initState() {
    super.initState();
    _clozeService = Provider.of<ClozeService>(context, listen: false);
    refreshLanguageFilePath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  languages(),
                  const SizedBox(height: 64),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final path = await _clozeService.pickLanguageFile();
                      progressDialog();
                      await _clozeService.setLanguageFile(path);
                      await _clozeService.initialize();
                      refreshLanguageFilePath();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 64)),
                    label: const Text('Select language file'),
                    icon: isCustomLanguageSelectedIcon(),
                  ),
                ],
              ))),
    );
  }

  void refreshLanguageFilePath() {
    _clozeService.languageFilePath.then((path) {
      setState(() {
        _languageFilePath = path;
      });
    });
  }

  Widget languages() {
    return Column(children: [
      for (var language in Language.values)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
                onPressed: () async {
                  progressDialog();
                  final fileName = UrlUtils.getFileNameFromUrl(language.url);

                  String? filePath =
                      path.join(PathManager.instance.filesDir, fileName);
                  if (!await File(filePath).exists()) {
                    filePath = await _fileDownloader.downloadFile(
                        language.url, fileName);
                  }

                  if (filePath != null) {
                    await _clozeService.setLanguageFile(filePath);
                    await _clozeService.initialize();
                    refreshLanguageFilePath();
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64)),
                label: Text(language.name),
                icon: isLanguageSelectedIcon(language)))
    ]);
  }

  Icon? isLanguageSelectedIcon(Language language) {
    final filePath = path.join(PathManager.instance.filesDir,
        UrlUtils.getFileNameFromUrl(language.url));

    if (_languageFilePath != null && _languageFilePath!.contains(filePath)) {
      return const Icon(Icons.check);
    }

    return null;
  }

  Icon isCustomLanguageSelectedIcon() {
    if (_languageFilePath != null &&
        !_languageFilePath!.contains(PathManager.instance.filesDir)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.file_open);
  }

  Future<void> progressDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
              title: Text('Please wait'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Loading language'),
                  SizedBox(height: 16),
                  LinearProgressIndicator()
                ],
              ));
        });
  }
}
