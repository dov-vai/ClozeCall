import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloze_call/services/cloze_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edge_tts/edge_tts.dart' as edge_tts;

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late ClozeService _clozeService;
  late AudioPlayer _player;
  var _cloze = Cloze(original: "", translated: "", answer: "", words: []);
  var _answered = false;
  ({String text, Uint8List audio})? _ttsState;

  @override
  void initState() {
    super.initState();
    _clozeService = Provider.of<ClozeService>(context, listen: false);
    _player = AudioPlayer();
    if (_clozeService.initialized) {
      _cloze = _clozeService.getRandomCloze();
    } else {
      Navigator.pop(context);
    }
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
        edge_tts.Communicate(text: text, voice: "ru-RU-DmitryNeural");
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
      _answered = true;
    });
  }

  void onNext() {
    _player.stop();
    setState(() {
      _answered = false;
      _cloze = _clozeService.getRandomCloze();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _answered ? buildAnsweredCloze() : buildCloze(),
        ),
      ),
    );
  }

  List<Widget> buildCloze() {
    return [
      Text(_cloze.original.replaceFirst(_cloze.answer, '_____')),
      Text(_cloze.translated),
      for (var word in _cloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              onSelected(word);
            },
            child: Text(word.toLowerCase()),
          ),
        )
    ];
  }

  List<Widget> buildAnsweredCloze() {
    return [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(_cloze.original),
        IconButton(
            onPressed: () async {
              await _player.stop();
              await playTTS(_cloze.original);
            },
            icon: const Icon(Icons.audiotrack))
      ]),
      Text(_cloze.translated),
      for (var word in _cloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
              onPressed: () {
                onSelected(word);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      word == _cloze.answer ? Colors.green : Colors.red),
              child: Text(word.toLowerCase())),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: ElevatedButton(
          onPressed: onNext,
          child: const Text("Next ➡️"),
        ),
      )
    ];
  }
}
