import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';

class Cloze {
  final String original;
  final String translated;
  final String removedWord;
  final List<String> randomWords;

  Cloze({required this.original, required this.translated, required this.removedWord, required this.randomWords});
}

class ClozeService {
  late File? _file;
  late List<String> _lines;
  final Random _random = Random();

  Future<void> initialize() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tsv'],
    );

    if (result != null) {
      _file = File(result.files.single.path!);
      _lines = await _file!.readAsLines();
    } else {
      throw Exception('No file selected.');
    }
  }

  Future<Cloze> getRandomCloze() async {
    if (_file == null){
      throw Exception("Cloze Service is not initialized!");
    }
    String line = _lines[_random.nextInt(_lines.length)];
    return _generateCloze(line);
  }

  Cloze _generateCloze(String line) {
    final sentences = line.split('\t');
    List<String> words = sentences[0].split(' ');
    String removedWord = words.removeAt(_random.nextInt(words.length));

    List<String> randomWords = [];
    while (randomWords.length < 3) {
      String randomLine = _lines[_random.nextInt(_lines.length)];
      List<String> randomWords = randomLine.split(' ');
      String randomWord = randomWords[_random.nextInt(randomWords.length)];

      if (randomLine != line && !randomWords.contains(randomWord)) {
        randomWords.add(randomWord);
      }
    }

    return Cloze(
        original: sentences[0],
        translated: sentences[1],
        removedWord: removedWord,
        randomWords: randomWords
    );
  }
}
