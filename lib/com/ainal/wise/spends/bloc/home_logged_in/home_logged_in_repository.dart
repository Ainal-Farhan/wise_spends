import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';

class HomeLoggedInRepository {
  final HomeLoggedInProvider _homeLoggedInProvider = HomeLoggedInProvider();

  HomeLoggedInRepository();

  void test(bool isError) {
    _homeLoggedInProvider.test(isError);
  }
}