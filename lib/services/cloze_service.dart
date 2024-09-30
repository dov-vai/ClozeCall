import 'dart:io';
import 'dart:math';
import 'package:cloze_call/data/models/config.dart';
import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:file_picker/file_picker.dart';

class ClozeServiceException implements Exception {
  final String message;

  ClozeServiceException(
      [this.message = "An error occured in the cloze service!"]);

  @override
  String toString() => "ClozeServiceException: $message";
}

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
  late List<String> _lines;
  final Random _random = Random();
  bool _initialized = false;
  final ConfigRepository _config;

  bool get initialized => _initialized;

  ClozeService(this._config);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    var path = await _config.get('language_file') ?? await pickLanguageFile();

    // file location moved?
    if (!await File(path).exists()) {
      path = await pickLanguageFile();
    }

    _lines = await File(path).readAsLines();
    _initialized = true;
  }

  Future<String> pickLanguageFile() async {
    // clear cache of previously selected language file
    FilePicker.platform.clearTemporaryFiles();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select the language file",
      type: FileType.custom,
      allowedExtensions: ['tsv'],
    );

    final path = result?.files.single.path;

    if (path == null) {
      throw ClozeServiceException("No file selected!");
    }

    await _config.insert(Config(key: 'language_file', value: path));
    _initialized = false;

    return path;
  }

  Cloze getRandomCloze() {
    if (!_initialized) {
      throw ClozeServiceException("Not initialized!");
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
