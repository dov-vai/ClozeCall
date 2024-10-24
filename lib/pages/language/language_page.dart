import 'dart:convert';
import 'dart:io';

import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:cloze_call/utils/file_downloader.dart';
import 'package:cloze_call/utils/path_manager.dart';
import 'package:cloze_call/utils/url_utils.dart';
import 'package:cloze_call/widgets/card_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'language.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final fileDownloader = FileDownloader();
  late ClozeService clozeService;
  String? languageFilePath;
  List<Language> languages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    clozeService = Provider.of<ClozeService>(context, listen: false);
    refreshLanguageFilePath();
    fetchLanguages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick language'),
      ),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  languageList(),
                  CardButton(
                      title: "Custom language file",
                      leftIcon: Icons.file_open,
                      rightIcon: isCustomLanguageSelectedIcon(),
                      onTap: () async {
                        final path = await clozeService.pickLanguageFile();
                        progressDialog();
                        await clozeService.setLanguageFile(path);
                        await clozeService.initialize();
                        refreshLanguageFilePath();
                        Navigator.of(context).pop();
                      }),
                ],
              ))),
    );
  }

  void refreshLanguageFilePath() {
    clozeService.languageFilePath.then((path) {
      setState(() {
        languageFilePath = path;
      });
    });
  }

  Future<void> fetchLanguages() async {
    const languagesUrl =
        "https://github.com/dov-vai/ClozeCall-Languages/raw/refs/heads/main/languages.json";
    final response = await http.get(Uri.parse(languagesUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        languages = jsonList.map((json) => Language.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load languages');
    }
  }

  Widget languageList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
        child: GridView.count(
            childAspectRatio: 1.7,
            crossAxisSpacing: 8,
            crossAxisCount: 2,
            children: [
          for (var language in languages)
            CardButton(
                title: language.name,
                rightIcon: isLanguageSelectedIcon(language),
                onTap: () async {
                  progressDialog();
                  final fileName = UrlUtils.getFileNameFromUrl(language.url);

                  String? filePath =
                      path.join(PathManager.instance.filesDir, fileName);
                  if (!await File(filePath).exists()) {
                    filePath = await fileDownloader.downloadFile(
                        language.url, fileName);
                  }

                  if (filePath != null) {
                    await clozeService.setLanguageFile(filePath);
                    await clozeService.initialize();
                    refreshLanguageFilePath();
                  }
                  Navigator.of(context).pop();
                })
        ]));
  }

  IconData isLanguageSelectedIcon(Language language) {
    final filePath = path.join(PathManager.instance.filesDir,
        UrlUtils.getFileNameFromUrl(language.url));

    if (languageFilePath != null && languageFilePath!.contains(filePath)) {
      return Icons.check;
    }

    return Icons.chevron_right;
  }

  IconData isCustomLanguageSelectedIcon() {
    if (languageFilePath != null &&
        !languageFilePath!.contains(PathManager.instance.filesDir)) {
      return Icons.check;
    }
    return Icons.chevron_right;
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
