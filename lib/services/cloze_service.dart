import 'dart:io';
import 'dart:math';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:file_picker/file_picker.dart';

class Cloze {
  final String original;
  final String translated;
  final String answer;
  final List<String> words;

  Cloze(
      {required this.original,
      required this.translated,
      required this.answer,
      required this.words});
}

class ClozeService {
  late File? _file;
  late List<String> _lines;
  final Random _random = Random();
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tsv'],
    );

    if (result != null) {
      _file = File(result.files.single.path!);
      _lines = await _file!.readAsLines();
      _initialized = true;
    } else {
      throw Exception('No file selected.');
    }
  }

  Cloze getRandomCloze() {
    if (!_initialized) {
      throw Exception("Cloze Service is not initialized!");
    }
    String line = _lines[_random.nextInt(_lines.length)];
    return _generateCloze(line);
  }

  Cloze _generateCloze(String line) {
    final sentences = line.split('\t');
    List<String> words = sentences[0].split(' ');
    String removedWord = TextUtils.removePunctuation(
        words.removeAt(_random.nextInt(words.length)));

    List<String> randomWords = [removedWord];
    while (randomWords.length < 4) {
      String randomLine = _lines[_random.nextInt(_lines.length)].split('\t')[0];
      List<String> words = randomLine.split(' ');
      String word =
          TextUtils.sanitizeWord(words[_random.nextInt(words.length)]);

      if (randomLine != line && !randomWords.contains(word)) {
        randomWords.add(word);
      }
    }

    return Cloze(
        original: sentences[0],
        translated: sentences[1],
        answer: removedWord,
        words: randomWords);
  }
}
