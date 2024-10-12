import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:edge_tts/edge_tts.dart' as edge_tts;
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

import '../services/cloze/cloze.dart';
import '../services/cloze/cloze_exceptions.dart';

class LearnPage extends StatefulWidget {
  final IClozeService clozeService;
  final bool handsFree;
  const LearnPage(
      {super.key, required this.clozeService, this.handsFree = false});

  @override
  State createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final AudioPlayer _player = AudioPlayer();
  final _random = Random();
  final _translator = GoogleTranslator();
  late edge_tts.VoicesManager _voices;
  var _cloze = Cloze(
      original: '', translated: '', answer: '', words: [], languageCode: '');
  var _answered = '';
  ({String text, Uint8List audio})? _ttsState;
  final _translatedCache = HashMap<String, String>();
  int _correct = 0;
  int _total = 0;
  bool _empty = false;
  bool _stopped = false;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _voices = Provider.of<edge_tts.VoicesManager>(context, listen: false);

    if (!widget.clozeService.initialized) {
      Navigator.pop(context);
      return;
    }

    _cloze = getCloze();

    if (widget.handsFree) {
      handsFreeLoop();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _stopped = true;
    super.dispose();
  }

  Future<void> wait(int seconds) async {
    for (int i = seconds; i >= 0 && !_stopped; i--) {
      setState(() {
        _timeLeft = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> handsFreeLoop() async {
    while (!_stopped) {
      // TODO: timer options for the user
      await wait(20);
      if (_stopped) break;
      onSelected(_cloze.answer);
      await wait(10);
      if (_stopped) break;
      onNext();
    }
  }

  Future<void> playTTS(String text, String languageCode) async {
    if (_ttsState == null || _ttsState?.text != text) {
      var audio = await getTTS(text, languageCode);
      _ttsState = (text: text, audio: audio);
    }
    await _player.play(BytesSource(_ttsState!.audio));
  }

  Future<Uint8List> getTTS(String text, String languageCode) async {
    BytesBuilder builder = BytesBuilder();
    // FIXME: probably not very efficient doing this every tts run
    var voices = _voices.find(locale: languageCode);
    var communicate = edge_tts.Communicate(
        text: text, voice: voices[_random.nextInt(voices.length)].shortName);
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
    playTTS(_cloze.original, _cloze.languageCode);
    setState(() {
      _answered = selectedWord;
    });
  }

  Future<void> onNext() async {
    await _player.stop();

    late Cloze cloze;
    try {
      cloze = getCloze();
    } on ClozeServiceEmptyException {
      setState(() {
        _empty = true;
      });
      return;
    }

    setState(() {
      if (_answered == _cloze.answer) {
        _correct++;
      }
      _answered = '';
      _total++;
      _cloze = cloze;
    });
  }

  Future<void> onWordTooltip(String word, String languageCode) async {
    if (_translatedCache[word] != null) {
      return;
    }

    var translation =
        await _translator.translate(word, from: languageCode, to: 'en');
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
              child: _empty ? empty() : quiz())),
    );
  }

  Widget empty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.sentiment_satisfied_alt,
          size: 100,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(height: 20),
        const Text(
          "All done!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "You've completed everything for now.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget quiz() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      !widget.handsFree
          ? counter(_correct, _total - _correct)
          : timer(_timeLeft),
      const SizedBox(height: 32),
      Expanded(child: _answered.isNotEmpty ? answeredCloze() : cloze())
    ]);
  }

  Widget timer(int time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$time",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
      ],
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
              if (!widget.handsFree) {
                onSelected(word);
              }
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
                await onWordTooltip(
                    TextUtils.sanitizeWord(word), _cloze.languageCode);
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
                  await onWordTooltip(
                      TextUtils.sanitizeWord(word), _cloze.languageCode);
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
            await playTTS(_cloze.original, _cloze.languageCode);
          },
          icon: const Icon(Icons.audiotrack)),
      for (var word in _cloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
              onPressed: () {},
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
      if (!widget.handsFree) nextButton()
    ]);
  }

  Widget nextButton() {
    return ElevatedButton(
      onPressed: () async {
        await onNext();
      },
      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
      child: Text('Next', style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
