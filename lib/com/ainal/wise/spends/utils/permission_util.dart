import 'package:permission_handler/permission_handler.dart';

abstract class PermissionUtil {
  static Future<bool> isStoragePermissionGranted() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> isManageExternalStoragePermissionGranted() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      return true;
    }
    return false;
  }
}
