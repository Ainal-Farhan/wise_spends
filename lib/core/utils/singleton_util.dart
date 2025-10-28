import 'package:get_it/get_it.dart';
import 'package:wise_spends/core/di/i_singleton.dart';

abstract class SingletonUtil {
  static void registerSingleton<T extends ISingleton>(T instance) {
    GetIt.instance.registerSingleton<T>(instance, signalsReady: true);
  }

  static void unregisterSingleton<T extends ISingleton>() {
    T? instance = SingletonUtil.getSingleton<T>();
    if (instance != null) {
      GetIt.instance.unregister<T>(
        disposingFunction: (instance) {
          instance.dispose();
        },
      );
    }
  }

  static T? getSingleton<T extends ISingleton>() {
    try {
      return GetIt.instance<T>();
    } catch (e) {
      return null;
    }
  }
}
