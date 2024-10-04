import 'dart:io';
import 'dart:math';
import 'package:cloze_call/data/models/cloze_review.dart';
import 'package:cloze_call/data/models/config.dart';
import 'package:cloze_call/data/repositories/cloze_review_repository.dart';
import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:file_picker/file_picker.dart';

import 'cloze.dart';
import 'cloze_exceptions.dart';

class ClozeService implements IClozeService {
  late List<String> _lines;
  final Random _random = Random();
  bool _initialized = false;
  final ConfigRepository _config;
  final ClozeReviewRepository _clozeRepo;

  @override
  bool get initialized => _initialized;

  ClozeService(this._config, this._clozeRepo);

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

  @override
  Cloze getRandomCloze() {
    if (!_initialized) {
      throw ClozeServiceException("Not initialized!");
    }
    String line = _lines[_random.nextInt(_lines.length)];
    var cloze = _generateCloze(line);
    _clozeRepo.insert(ClozeReview.fromCloze(cloze));
    return _generateCloze(line);
  }

  bool _containsWord(List<String> words, String word) {
    final wordToFind = word.toLowerCase();
    for (var word in words) {
      if (word.toLowerCase() == wordToFind) {
        return true;
      }
    }
    return false;
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
          TextUtils.removePunctuation(words[_random.nextInt(words.length)]);

      if (word.isNotEmpty &&
          randomLine != line &&
          !_containsWord(randomWords, word)) {
        randomWords.add(word);
      }
    }

    randomWords.shuffle();

    return Cloze(
        original: sentences[0],
        translated: sentences[1],
        answer: removedWord,
        words: randomWords);
  }
}