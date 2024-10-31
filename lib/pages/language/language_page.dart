import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:cloze_call/services/connectivity_service.dart';
import 'package:cloze_call/utils/file_downloader.dart';
import 'package:cloze_call/utils/path_manager.dart';
import 'package:cloze_call/utils/url_utils.dart';
import 'package:cloze_call/widgets/card_button.dart';
import 'package:cloze_call/widgets/network_error.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../../widgets/progress_dialog.dart';
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
  late Future<void> _languagesFuture;
  late ConnectivityService connectivity;
  late StreamSubscription connStream;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    clozeService = Provider.of<ClozeService>(context, listen: false);
    connectivity = Provider.of<ConnectivityService>(context, listen: false);
    refreshLanguageFilePath();
    connStream =
        connectivity.onConnectivityChanged.listen(onConnectivityChanged);
  }

  @override
  void dispose() {
    connStream.cancel();
    super.dispose();
  }

  void onConnectivityChanged(bool connected) {
    setState(() {
      this.connected = connected;

      if (connected) {
        _languagesFuture = fetchLanguages();
      }
    });
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
                  Expanded(child: buildLanguageList()),
                  CardButton(
                      title: "Custom language file",
                      leftIcon: Icons.file_open,
                      rightIcon: isCustomLanguageSelectedIcon(),
                      onTap: () async {
                        final path = await clozeService.pickLanguageFile();
                        progressDialog(context);
                        await clozeService.setLanguageFile(path);
                        await clozeService.initialize();
                        refreshLanguageFilePath();
                        Navigator.of(context).pop();
                      }),
                ],
              ))),
    );
  }

  Widget buildLanguageList() {
    Widget networkError =
        const NetworkErrorWidget(description: "Couldn't fetch languages");

    if (connected) {
      return FutureBuilder(
          future: _languagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return networkError;
              }
              return languageList();
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          });
    }

    return networkError;
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
      });
    } else {
      throw Exception('Failed to load languages');
    }
  }

  Widget languageList() {
    return GridView.count(
        childAspectRatio: 1.7,
        crossAxisSpacing: 8,
        crossAxisCount: 2,
        children: [
          for (var language in languages)
            CardButton(
                title: language.name,
                rightIcon: isLanguageSelectedIcon(language),
                onTap: () async {
                  progressDialog(context);
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
        ]);
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
}
