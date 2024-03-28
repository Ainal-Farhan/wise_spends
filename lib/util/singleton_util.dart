import 'package:get_it/get_it.dart';

abstract class SingletonUtil {
  static void registerSingleton<T extends Object>(T instance) {
    GetIt.instance.registerSingleton<T>(instance, signalsReady: true);
  }

  static T getSingleton<T extends Object>() {
    return GetIt.instance<T>();
  }
}
