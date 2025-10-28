

import 'dart:async';

import 'package:wise_spends/domain/usecases/i_home_logged_in_manager.dart';

class HomeLoggedInManager extends IHomeLoggedInManager {
  @override
  Future<void> loadAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> saveAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void test(bool isError) {
    if (isError == true) {
      throw Exception('manual error');
    }
  }
}
