import 'package:wise_spends/domain/usecases/i_manager.dart';

abstract class IHomeLoggedInManager extends IManager {
  Future<void> loadAsync(String token);
  Future<void> saveAsync(String token);
  void test(bool isError);
}
