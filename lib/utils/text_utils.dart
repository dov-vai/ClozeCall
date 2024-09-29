class TextUtils {
  TextUtils._();

  static String removePunctuation(String input) {
    return input.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '');
  }

  static String sanitizeWord(String word) {
    return removePunctuation(word).toLowerCase();
  }
}
