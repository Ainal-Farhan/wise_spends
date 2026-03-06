import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';

/// Payee Value Object
class PayeeVO extends IVO {
  String? id;
  String? name;
  String? accountNumber;
  String? bankName;
  String? note;

  PayeeVO();

  PayeeVO.fromExpnsPayee(ExpnsPayee payee) {
    id = payee.id;
    name = payee.name;
    accountNumber = payee.accountNumber;
    bankName = payee.bankName;
    note = payee.note;
  }

  PayeeVO.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    accountNumber = data['accountNumber'];
    bankName = data['bankName'];
    note = data['note'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'note': note,
      };
}
