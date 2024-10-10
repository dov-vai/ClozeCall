import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PathManager {
  PathManager._();

  static final PathManager _instance = PathManager._();

  static PathManager get instance => _instance;

  String? _appDir;
  String? _filesDir;

  String get appDir {
    if (_filesDir == null) {
      throw Exception("App directory path has not been initialized");
    }
    return _appDir!;
  }

  String get filesDir {
    if (_filesDir == null) {
      throw Exception("Files directory path has not been initialized");
    }
    return _filesDir!;
  }

  Future<void> initialize() async {
    if (_appDir != null) {
      throw Exception("PathManager can only be initialized once");
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    _appDir = path.join(appDocDir.path, '.ClozeCall');
    _filesDir = path.join(_appDir!, 'files');
  }
}
