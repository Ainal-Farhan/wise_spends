import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';

@DataClassName("${DomainTableConstant.commonTablePrefix}User")
class UserTable extends BaseEntityTable {
  TextColumn get name => text()();

  TextColumn get email => text().nullable()();

  TextColumn get phoneNumber => text().nullable()();

  TextColumn get occupation => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get profileImageUrl => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
  ];

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.name,
      'email': email.name,
      'phoneNumber': phoneNumber.name,
      'occupation': occupation.name,
      'address': address.name,
      'profileImageUrl': profileImageUrl.name,
    };
  }
}
