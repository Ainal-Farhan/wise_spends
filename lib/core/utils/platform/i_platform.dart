import 'dart:io' show Platform;
import 'package:wise_spends/core/utils/platform/android_platform.dart';
import 'package:wise_spends/core/utils/platform/ios_platform.dart';
import 'package:wise_spends/core/utils/platform/unknown_platform.dart';

abstract class IPlatform {
  factory IPlatform() {
    if (Platform.isAndroid) {
      return AndroidPlatform();
    }
    if (Platform.isIOS) {
      return IOSPlatform();
    }

    return UnknownPlatform();
  }
}
