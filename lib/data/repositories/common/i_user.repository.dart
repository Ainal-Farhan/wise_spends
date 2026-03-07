import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/common/user_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';

/// User Repository Interface
abstract class IUserRepository
    extends
        ICrudRepository<
          UserTable,
          $UserTableTable,
          UserTableCompanion,
          CmmnUser
        > {
  IUserRepository(AppDatabase db) : super(db, db.userTable);

  /// Get current user
  Future<CmmnUser?> getCurrentUser();

  /// Watch current user
  Stream<CmmnUser?> watchCurrentUser();

  /// Find user by name
  Future<CmmnUser?> findByName(String name);

  /// Find anyone user (random)
  Future<CmmnUser?> findAnyone();

  /// Update user profile
  Future<bool> updateProfile(UserProfile profile);
}
