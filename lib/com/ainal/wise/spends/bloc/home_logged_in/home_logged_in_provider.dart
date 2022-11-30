import 'dart:async';

class HomeLoggedInProvider {
  Future<void> loadAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> saveAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(const Duration(seconds: 2));
  }

  void test(bool isError) {
    if (isError == true) {
      throw Exception('manual error');
    }
  }
}
