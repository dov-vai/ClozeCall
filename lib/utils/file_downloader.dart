import 'dart:async';
import 'package:cloze_call/utils/path_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class FileDownloader {
  Dio dio = Dio();

  Future<String?> downloadFile(String url, String fileName,
      {Function(int received, int total)? onReceiveProgress}) async {
    try {
      final savePath = path.join(PathManager.instance.filesDir, fileName);

      await dio.download(url, savePath, onReceiveProgress: onReceiveProgress);

      return savePath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error: $e');
      }
    }
    return null;
  }
}
