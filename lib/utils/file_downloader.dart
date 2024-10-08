import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  Dio dio = Dio();

  Future<String?> downloadFile(String url, String fileName,
      {Function(int, int)? onReceiveProgress}) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/.ClozeCall/files/$fileName';

      await dio.download(url, savePath, onReceiveProgress: onReceiveProgress);

      return savePath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error: $e');
      }
    }
    return null;
  }

  String getFileNameFromUrl(String url) {
    return Uri.parse(url).pathSegments.last;
  }
}
