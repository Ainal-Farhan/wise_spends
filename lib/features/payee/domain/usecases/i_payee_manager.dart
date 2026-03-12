import 'package:wise_spends/domain/usecases/i_manager.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';

abstract class IPayeeManager extends IManager {
  Future<List<PayeeVO>> loadPayeeVOList();

  Future<PayeeVO> addPayee({
    required String name,
    String? accountNumber,
    String? bankName,
    String? note,
  });

  Future<void> updatePayee(PayeeVO payeeVO);

  Future<void> deletePayee(String payeeId);
}
