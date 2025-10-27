import 'dart:io';
import 'dart:io' show Directory;
import 'dart:async';

import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:wise_spends/utils/permission_util.dart';
import 'package:wise_spends/utils/platform/android_platform.dart';
import 'package:wise_spends/utils/platform/i_platform.dart';

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
    if (await PermissionUtil.isStoragePermissionGranted()) {
      if (platform is AndroidPlatform) {
        return '${await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD)}/wise_spends';
      }
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
