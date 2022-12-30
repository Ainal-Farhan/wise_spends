import 'dart:io';

import 'package:intl/intl.dart';

abstract class FileUtil {
  static String getFileExtension(File file) {
    return RegExp(r'\.[^.]{1,}$').firstMatch(file.path)?[0] ?? '';
  }

  static bool isMatchCustomExtensions(
      {required File file, required List<String> allowedExtensions}) {
    return RegExp('\\.${allowedExtensions.join("|")}\$').hasMatch(file.path);
  }

  // format file name is as below
  // filename_DD-MM-YYYY_HH-MM-SS-MS.extension
  static String appendFileNameWithCurrentDateTime({
    required String fileName,
    required String extension,
  }) {
    DateTime dateTime = DateTime.now();

    NumberFormat twoDigitsFormatter = NumberFormat("00");
    NumberFormat threeDigitsFormatter = NumberFormat("00");

    String day = twoDigitsFormatter.format(dateTime.day);
    String month = twoDigitsFormatter.format(dateTime.month);
    String year = '${dateTime.year}';

    String date = '$day-$month-$year';

    String hh = twoDigitsFormatter.format(dateTime.hour);
    String mm = twoDigitsFormatter.format(dateTime.minute);
    String ss = twoDigitsFormatter.format(dateTime.second);
    String ms = threeDigitsFormatter.format(dateTime.millisecond);

    String time = '$hh-$mm-$ss-$ms';

    return '${fileName}_${date}_$time.$extension';
  }

  static File createFile({
    required String path,
    required String fileName,
    required String extension,
  }) {
    return File('$path/$fileName.$extension');
  }

  static File createFileWithCurrentDateTime({
    required String path,
    required String fileName,
    required String extension,
  }) {
    String newFileName = appendFileNameWithCurrentDateTime(
      fileName: fileName,
      extension: extension,
    );
    return File('$path/$newFileName');
  }

  static Future createFileIntoDirectory(File file) async {
    await file.create(recursive: true);
  }
}
