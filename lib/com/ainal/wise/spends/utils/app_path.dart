import 'dart:io' show Directory;
import 'dart:async';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:wise_spends/com/ainal/wise/spends/utils/platform/i_platform.dart';

class AppPath {
  static final AppPath _appPath = AppPath._internal();
  factory AppPath() {
    return _appPath;
  }
  AppPath._internal();

  final IPlatform platform = IPlatform();

  Future<Directory> getTemporaryDirectory() async =>
      await path_provider.getTemporaryDirectory();

  Future<Directory> getApplicationDocumentsDirectory() async =>
      await path_provider.getApplicationDocumentsDirectory();

  Future<Directory?> getDownloadsDirectory() async =>
      await path_provider.getDownloadsDirectory();

  String setFilePath({
    required Directory directory,
    required String fileName,
  }) {
    return path.join(directory.path, fileName);
  }
}
