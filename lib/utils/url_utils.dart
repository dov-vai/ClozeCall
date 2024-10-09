class UrlUtils {
  UrlUtils._();

  static String getFileNameFromUrl(String url) {
    return Uri.parse(url).pathSegments.last;
  }
}
