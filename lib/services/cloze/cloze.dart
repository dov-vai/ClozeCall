import '../../data/models/cloze_review.dart';

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

  factory Cloze.fromClozeReview(ClozeReview cloze) {
    return Cloze(
        original: cloze.original,
        translated: cloze.translated,
        answer: cloze.answer,
        words: cloze.words);
  }
}