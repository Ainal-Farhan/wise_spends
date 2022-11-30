import 'package:wise_spends/com/ainal/wise/spends/manager/i_manager.dart';

abstract class IHomeLoggedInManager extends IManager {
  Future<void> loadAsync(String token);
  Future<void> saveAsync(String token);
  void test(bool isError);
}
