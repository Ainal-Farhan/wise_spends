import 'package:wise_spends/com/ainal/wise/spends/manager/i_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/home_logged_in_manager.dart';

abstract class IHomeLoggedInManager extends IManager {
  factory IHomeLoggedInManager() {
    return HomeLoggedInManager();
  }

  Future<void> loadAsync(String token);
  Future<void> saveAsync(String token);
  void test(bool isError);
}
