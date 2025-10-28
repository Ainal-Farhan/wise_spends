import 'package:drift/drift.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';

@DataClassName("${DomainTableConstant.commonTablePrefix}User")
class UserTable extends BaseEntityTable {
  TextColumn get name => text()();
  
  TextColumn get email => text().nullable()();
  
  TextColumn get phoneNumber => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name}
      ];

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.toString(),
      'email': email.toString(),
      'phoneNumber': phoneNumber.toString(),
    };
  }
}
