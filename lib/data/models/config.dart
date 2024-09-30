import 'package:cloze_call/data/models/i_model.dart';

class Config implements IModel {
  final String key;
  final String value;

  const Config({required this.key, required this.value});

  @override
  Map<String, dynamic> toMap() {
    return {'key': key, 'value': value};
  }

  @override
  factory Config.fromMap(Map<String, dynamic> data) {
    return Config(key: data['key'] as String, value: data['value'] as String);
  }
}
