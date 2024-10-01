import 'package:cloze_call/data/models/i_model.dart';

class ClozeReview implements IModel {
  final int id;
  final DateTime timestamp;
  final String original;
  final String translated;
  final String answer;
  final List<String> words;

  ClozeReview({
    required this.id,
    required this.timestamp,
    required this.original,
    required this.translated,
    required this.answer,
    required this.words,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'original': original,
      'translated': translated,
      'answer': answer,
      'words': words.join(','),
    };
  }

  factory ClozeReview.fromMap(Map<String, dynamic> data) {
    return ClozeReview(
      id: data['id'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
      original: data['original'] as String,
      translated: data['translated'] as String,
      answer: data['answer'] as String,
      words: (data['words'] as String).split(','),
    );
  }
}
