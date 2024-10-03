import 'package:cloze_call/data/models/i_model.dart';

import '../../services/cloze/cloze.dart';

class ClozeReview implements IModel {
  final int? id;
  final DateTime timestamp;
  final String original;
  final String translated;
  final String answer;
  final List<String> words;

  ClozeReview({
    this.id,
    required this.timestamp,
    required this.original,
    required this.translated,
    required this.answer,
    required this.words,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'original': original,
      'translated': translated,
      'answer': answer,
      'words': words.join(','),
    };
  }

  factory ClozeReview.fromMap(Map<String, dynamic> data) {
    return ClozeReview(
      id: data['id'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int,
          isUtc: true),
      original: data['original'] as String,
      translated: data['translated'] as String,
      answer: data['answer'] as String,
      words: (data['words'] as String).split(','),
    );
  }

  factory ClozeReview.fromCloze(Cloze cloze) {
    return ClozeReview(
        timestamp: DateTime.now().toUtc(),
        original: cloze.original,
        translated: cloze.translated,
        answer: cloze.answer,
        words: cloze.words);
  }

  ClozeReview copyWith(
      {int? id,
      DateTime? timestamp,
      String? original,
      String? translated,
      String? answer,
      List<String>? words}) {
    return ClozeReview(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        original: original ?? this.original,
        translated: translated ?? this.translated,
        answer: answer ?? this.answer,
        words: words ?? this.words);
  }
}
