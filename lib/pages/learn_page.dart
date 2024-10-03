import 'dart:collection';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:edge_tts/edge_tts.dart' as edge_tts;
import 'package:translator/translator.dart';

import '../services/cloze/cloze.dart';

class LearnPage extends StatefulWidget {
  final IClozeService clozeService;

  const LearnPage({super.key, required this.clozeService});

  @override
  State createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late AudioPlayer _player;
  final _translator = GoogleTranslator();
  var _cloze = Cloze(original: '', translated: '', answer: '', words: []);
  var _answered = '';
  ({String text, Uint8List audio})? _ttsState;
  final _translatedCache = HashMap<String, String>();
  int _correct = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    if (!widget.clozeService.initialized) {
      Navigator.pop(context);
      return;
    }

    _cloze = getCloze();
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

  Cloze getCloze() {
    try {
      return widget.clozeService.getRandomCloze();
    } on ClozeServiceException {
      Navigator.pop(context);
    }
    throw Exception("Unreachable");
  }

  Future<void> onSelected(String selectedWord) async {
    playTTS(_cloze.original);
    setState(() {
      _answered = selectedWord;
    });
  }

  Future<void> onNext() async {
    await _player.stop();

    setState(() {
      if (_answered == _cloze.answer) {
        _correct++;
      }
      _answered = '';
      _total++;
      _cloze = getCloze();
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          counter(_correct, _total - _correct),
          const SizedBox(height: 32),
          Expanded(child: _answered.isNotEmpty ? answeredCloze() : cloze())
        ]),
      )),
    );
  }

  Widget counter(int correct, int incorrect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Correct counter
        Row(
          children: [
            const Icon(Icons.check, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              '$correct',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Incorrect counter
        Row(
          children: [
            const Icon(Icons.close, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              '$incorrect',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget cloze() {
    return Column(children: [
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
    ]);
  }

  Widget answeredCloze() {
    return Column(children: [
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
        onPressed: () async {
          await onNext();
        },
        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
        child: Text('Next', style: Theme.of(context).textTheme.titleLarge),
      ),
    ]);
  }
}
