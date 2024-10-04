class ClozeServiceException implements Exception {
  final String message;

  ClozeServiceException(
      [this.message = "An error occurred in the cloze service!"]);

  @override
  String toString() => "ClozeServiceException: $message";
}

class ClozeServiceEmptyException implements Exception {
  final String message;

  ClozeServiceEmptyException(
      [this.message = "Cloze service has no values left to return!"]);

  @override
  String toString() => "ClozeServiceEmptyException: $message";
}
