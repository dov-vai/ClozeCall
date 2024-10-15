import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloze_call/data/models/cloze.dart';
import 'package:cloze_call/data/models/config.dart';
import 'package:cloze_call/data/repositories/cloze_review_repository.dart';
import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/enums/rank.dart';
import 'cloze_exceptions.dart';

class ClozeService implements IClozeService {
  List<String> _lines = List.empty(growable: true);
  final Random _random = Random();
  bool _initialized = false;
  final ConfigRepository _config;
  final ClozeReviewRepository _clozeRepo;
  final _languageFileKey = 'language_file';

  @override
  bool get initialized => _initialized;

  Future<String?> get languageFilePath async {
    return await _config.get(_languageFileKey);
  }

  ClozeService(this._config, this._clozeRepo);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    var path = await _config.get(_languageFileKey);

    // file location moved?
    if (path == null || !await File(path).exists()) {
      return;
    }

    _lines = List.empty(growable: true);

    var lines = File(path)
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (var line in lines) {
      // filter by word length because some sentences can get too large
      if (line.split('\t')[0].split(' ').length <= 25) {
        _lines.add(line);
      }
    }
    _initialized = true;
  }

  Future<String> pickLanguageFile() async {
    // clear cache of previously selected language file
    if (Platform.isAndroid || Platform.isIOS) {
      FilePicker.platform.clearTemporaryFiles();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select the language file",
      type: FileType.custom,
      allowedExtensions: ['tsv'],
    );

    final path = result?.files.single.path;

    if (path == null) {
      throw ClozeServiceException("No file selected!");
    }

    return path;
  }

  Future<void> setLanguageFile(String path) async {
    await _config.insert(Config(key: _languageFileKey, value: path));
    _initialized = false;
  }

  @override
  Cloze getRandomCloze() {
    if (!_initialized) {
      throw ClozeServiceException("Not initialized!");
    }
    String line = _lines[_random.nextInt(_lines.length)];

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

  @override
  Future<void> addForReview(Cloze cloze) async {
    await _clozeRepo.insert(cloze);
  }

  Cloze _generateCloze(String line) {
    final columns = line.split('\t');
    List<String> words = columns[0].split(' ');
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
        timestamp: DateTime.now().toUtc(),
        original: columns[0],
        translated: columns[1],
        answer: removedWord,
        words: randomWords,
        languageCode: columns[2],
        rank: Rank.zero);
  }
}
