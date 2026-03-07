import 'package:drift/drift.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/impl/expense/payee_vo.dart';
import 'package:wise_spends/domain/usecases/i_payee_manager.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';

class PayeeManager extends IPayeeManager {
  @override
  Future<List<PayeeVO>> loadPayeeVOList() async {
    final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getPayeeRepository();

    final List<ExpnsPayee> rows = await payeeRepo.findAll();
    return rows.map(PayeeVO.fromExpnsPayee).toList();
  }

  @override
  Future<PayeeVO> addPayee({
    required String name,
    String? accountNumber,
    String? bankName,
    String? note,
  }) async {
    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getPayeeRepository();

    final companion = PayeeTableCompanion.insert(
      createdBy: startupManager.currentUser.name,
      dateUpdated: DateTime.now(),
      lastModifiedBy: startupManager.currentUser.name,
      name: name,
      accountNumber: Value(accountNumber),
      bankName: Value(bankName),
      note: Value(note),
    );

    final inserted = await payeeRepo.insertOne(companion);
    return PayeeVO.fromExpnsPayee(inserted);
  }

  @override
  Future<void> updatePayee(PayeeVO payeeVO) async {
    if (payeeVO.id == null) return;

    final startupManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getStartupManager();
    final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getPayeeRepository();

    final companion = PayeeTableCompanion.insert(
      id: Value(payeeVO.id!),
      createdBy: startupManager.currentUser.name,
      dateUpdated: DateTime.now(),
      lastModifiedBy: startupManager.currentUser.name,
      name: payeeVO.name ?? '',
      accountNumber: Value(payeeVO.accountNumber),
      bankName: Value(payeeVO.bankName),
      note: Value(payeeVO.note),
    );

    await payeeRepo.updatePart(tableCompanion: companion, id: payeeVO.id!);
  }

  @override
  Future<void> deletePayee(String payeeId) async {
    final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getPayeeRepository();
    await payeeRepo.deleteById(id: payeeId);
  }
}
