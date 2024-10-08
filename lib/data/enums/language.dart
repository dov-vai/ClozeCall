// FIXME: hardcoding...
const String _baseUrl =
    "https://github.com/dov-vai/ClozeCall-Languages/raw/refs/heads/main/";

enum Language {
  russian(name: "Russian", url: "${_baseUrl}russian.tsv"),
  french(name: "French", url: "${_baseUrl}french.tsv"),
  german(name: "German", url: "${_baseUrl}german.tsv"),
  spanish(name: "Spanish", url: "${_baseUrl}spanish.tsv"),
  portuguese(name: "Portuguese", url: "${_baseUrl}portuguese.tsv");

  const Language({required this.name, required this.url});

  final String name;
  final String url;
}
