class Language {
  final String name;
  final String url;

  Language({required this.name, required this.url});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['language'],
      url: json['url'],
    );
  }
}
