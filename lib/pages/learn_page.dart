import 'dart:collection';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloze_call/services/cloze_service.dart';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edge_tts/edge_tts.dart' as edge_tts;
import 'package:translator/translator.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late ClozeService _clozeService;
  late AudioPlayer _player;
  final _translator = GoogleTranslator();
  var _cloze = Cloze(original: '', translated: '', answer: '', words: []);
  var _answered = '';
  ({String text, Uint8List audio})? _ttsState;
  final _translatedCache = HashMap<String, String>();

  @override
  void initState() {
    super.initState();
    _clozeService = Provider.of<ClozeService>(context, listen: false);
    _player = AudioPlayer();

    if (!_clozeService.initialized) {
      Navigator.pop(context);
      return;
    }

    _cloze = _clozeService.getRandomCloze();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> playTTS(String text) async {
    if (_ttsState == null || _ttsState?.text != text) {
      var audio = await getTTS(text);
      _ttsState = (text: text, audio: audio);
    }
    await _player.play(BytesSource(_ttsState!.audio));
  }

  Future<Uint8List> getTTS(String text) async {
    BytesBuilder builder = BytesBuilder();
    // TODO: voice selection by language code
    var communicate =
        edge_tts.Communicate(text: text, voice: 'ru-RU-DmitryNeural');
    await for (var message in communicate.stream()) {
      if (message['type'] == 'audio') {
        builder.add(message['data']);
      }
    }
    return builder.toBytes();
  }

  void onSelected(String selectedWord) async {
    playTTS(_cloze.original);
    setState(() {
      _answered = selectedWord;
    });
  }

  void onNext() {
    _player.stop();
    setState(() {
      _answered = '';
      _cloze = _clozeService.getRandomCloze();
    });
  }

  Future<void> onWordTooltip(String word) async {
    if (_translatedCache[word] != null) {
      return;
    }
    // TODO: language codes selection here too
    var translation = await _translator.translate(word, from: 'ru', to: 'en');
    setState(() {
      _translatedCache[word] = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _answered.isNotEmpty ? buildAnsweredCloze() : buildCloze(),
        ),
      )),
    );
  }

  List<Widget> buildCloze() {
    return [
      Text(_cloze.original.replaceFirst(_cloze.answer, '_____'),
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center),
      const SizedBox(height: 16),
      Text(_cloze.translated,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center),
      const SizedBox(height: 32),
      for (var word in _cloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              onSelected(word);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64)),
            child: Text(word.toLowerCase(),
                style: Theme.of(context).textTheme.titleLarge),
          ),
        )
    ];
  }

  List<Widget> buildAnsweredCloze() {
    return [
      Wrap(alignment: WrapAlignment.center, children: [
        for (var word in _cloze.original.split(' '))
          Wrap(alignment: WrapAlignment.center, children: [
            // use mouse region as hovering over the tooltip doesn't call onTrigger (hack)
            MouseRegion(
              onEnter: (_) async {
                await onWordTooltip(TextUtils.sanitizeWord(word));
              },
              child: Tooltip(
                message: _translatedCache[TextUtils.sanitizeWord(word)] ??
                    'Translating...',
                height: 25,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(8.0),
                preferBelow: true,
                textStyle: const TextStyle(
                  color: ThemeMode.system == ThemeMode.light
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18,
                ),
                showDuration: const Duration(seconds: 2),
                waitDuration: const Duration(milliseconds: 200),
                onTriggered: () async {
                  await onWordTooltip(TextUtils.sanitizeWord(word));
                },
                child: Text(
                  word,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ),
            const Text('  '),
          ]),
      ]),
      const SizedBox(height: 16),
      Text(_cloze.translated,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center),
      IconButton(
          onPressed: () async {
            await _player.stop();
            await playTTS(_cloze.original);
          },
          icon: const Icon(Icons.audiotrack)),
      for (var word in _cloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
              onPressed: () {
                onSelected(word);
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  backgroundColor: word == _cloze.answer
                      ? Colors.green
                      : word == _answered
                          ? Colors.red
                          : null),
              child: Text(word.toLowerCase(),
                  style: Theme.of(context).textTheme.titleLarge)),
        ),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
        child: Text('Next ➡️', style: Theme.of(context).textTheme.titleLarge),
      ),
    ];
  }
}
