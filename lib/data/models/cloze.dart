import 'package:cloze_call/data/models/i_model.dart';

import '../enums/rank.dart';

class Cloze implements IModel {
  final int? id;
  final DateTime timestamp;
  final String original;
  final String translated;
  final String answer;
  final List<String> words;
  final String languageCode;
  final Rank rank;

  Cloze(
      {this.id,
      required this.timestamp,
      required this.original,
      required this.translated,
      required this.answer,
      required this.words,
      required this.languageCode,
      required this.rank});

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'original': original,
      'translated': translated,
      'answer': answer,
      'words': words.join(','),
      'language_code': languageCode,
      'rank': rank.index,
    };
  }

  factory Cloze.fromMap(Map<String, dynamic> data) {
    return Cloze(
        id: data['id'] as int?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int,
            isUtc: true),
        original: data['original'] as String,
        translated: data['translated'] as String,
        answer: data['answer'] as String,
        words: (data['words'] as String).split(','),
        languageCode: data['language_code'] as String,
        rank: Rank.get(data['rank'] as int));
  }

  Cloze copyWith(
      {int? id,
      DateTime? timestamp,
      String? original,
      String? translated,
      String? answer,
      List<String>? words,
      String? languageCode,
      Rank? rank}) {
    return Cloze(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        original: original ?? this.original,
        translated: translated ?? this.translated,
        answer: answer ?? this.answer,
        words: words ?? this.words,
        languageCode: languageCode ?? this.languageCode,
        rank: rank ?? this.rank);
  }
}
