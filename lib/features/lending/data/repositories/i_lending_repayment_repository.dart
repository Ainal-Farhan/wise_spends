import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/lending/lending_repayment_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ILendingRepaymentRepository
    extends
        ICrudRepository<
          LendingRepaymentTable,
          $LendingRepaymentTableTable,
          LendingRepaymentTableCompanion,
          LndngRepayment
        > {
  ILendingRepaymentRepository(AppDatabase db)
      : super(db, db.lendingRepaymentTable);

  Future<List<LndngRepayment>> getRepaymentsForLending(String lendingId);
  Future<void> addRepayment({
    required String lendingId,
    required double amount,
    required String destinationSavingId,
    required DateTime repaymentDate,
    String? note,
  });
  Future<void> deleteRepayment(String id);
}
