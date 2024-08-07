import 'package:wise_spends/manager/i_manager.dart';

abstract class ILoginManager extends IManager {
  Future<void> loadAsync(String token);
  Future<void> saveAsync(String token);
  void test(bool isError);
}
