import 'dart:async';

import 'package:wise_spends/manager/i_transaction_manager.dart';

class TransactionManager extends ITransactionManager {
  @override
  Future<void> loadAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<void> saveAsync(String token) async {
    /// write from keystore/keychain
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void test(bool isError) {
    if (isError == true) {
      throw Exception('manual error');
    }
  }
}
