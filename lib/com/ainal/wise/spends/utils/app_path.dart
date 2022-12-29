import 'dart:io';
import 'dart:io' show Directory;
import 'dart:async';

import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
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

  Future<String> getDownloadsDirectory() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      return await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
    }
    return "";
  }

  String setFilePath({
    required Directory directory,
    required String fileName,
  }) {
    return path.join(directory.path, fileName);
  }
}
