import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';

/// User Repository Implementation
class UserRepository extends IUserRepository {
  UserRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'UserTable';

  @override
  Future<CmmnUser?> getCurrentUser() async {
    return (db.select(db.userTable)..limit(1)).getSingleOrNull();
  }

  @override
  Stream<CmmnUser?> watchCurrentUser() {
    return (db.select(db.userTable)..limit(1)).watchSingleOrNull();
  }

  @override
  Future<CmmnUser?> findByName(String name) async {
    return (db.select(db.userTable)
          ..where((tbl) => tbl.name.equals(name))
          ..limit(1))
        .getSingleOrNull();
  }

  @override
  Future<CmmnUser?> findAnyone() async {
    return (db.select(db.userTable)..limit(1)).getSingleOrNull();
  }

  @override
  Future<bool> updateProfile(UserProfile profile) async {
    try {
      final companion = UserTableCompanion(
        name: Value(profile.name),
        email: Value(profile.email),
        phoneNumber: Value(profile.phone),
        occupation: Value(profile.occupation),
        address: Value(profile.address),
        profileImageUrl: Value(profile.profileImageUrl),
        dateUpdated: Value(profile.dateUpdated),
        lastModifiedBy: Value('user'),
      );

      await (db.update(
        db.userTable,
      )..where((tbl) => tbl.id.equals(profile.id))).write(companion);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  CmmnUser fromJson(Map<String, dynamic> json) => CmmnUser.fromJson(json);
}
