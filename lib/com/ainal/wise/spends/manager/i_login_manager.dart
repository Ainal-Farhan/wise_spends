import 'package:wise_spends/com/ainal/wise/spends/manager/i_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/login_manager.dart';

abstract class ILoginManager extends IManager {
  factory ILoginManager() {
    return LoginManager();
  }

  Future<void> loadAsync(String token);
  Future<void> saveAsync(String token);
  void test(bool isError);
}
