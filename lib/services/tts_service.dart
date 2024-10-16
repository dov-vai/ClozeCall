import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts/edge_tts.dart';

class TTSService {
  final AudioPlayer _player = AudioPlayer();
  ({String text, Uint8List audio})? _ttsState;
  final _random = Random();
  late VoicesManager _voicesManager;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _voicesManager = await VoicesManager.create();
    _initialized = true;
  }

  Future<void> play(String text, String languageCode) async {
    if (!_initialized) {
      throw Exception("TTS Service is not initialized!");
    }

    if (_ttsState == null || _ttsState?.text != text) {
      var audio = await _getTTS(text, languageCode);
      _ttsState = (text: text, audio: audio);
    }
    await _player.play(BytesSource(_ttsState!.audio));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<Uint8List> _getTTS(String text, String languageCode) async {
    BytesBuilder builder = BytesBuilder();
    // FIXME: probably not very efficient doing this every tts run
    var voices = _voicesManager.find(locale: languageCode);
    var communicate = Communicate(
        text: text, voice: voices[_random.nextInt(voices.length)].shortName);
    await for (var message in communicate.stream()) {
      if (message['type'] == 'audio') {
        builder.add(message['data']);
      }
    }
    return builder.toBytes();
  }
}
