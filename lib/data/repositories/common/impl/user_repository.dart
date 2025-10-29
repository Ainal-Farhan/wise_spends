import 'package:drift/drift.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';

class UserRepository extends IUserRepository {
  UserRepository() : super(AppDatabase());

  @override
  Future<CmmnUser?> findByName(final String name) async {
    return (db.select(
      db.userTable,
    )..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  @override
  Future<CmmnUser?> findAnyone() async {
    return await (db.select(db.userTable)).getSingleOrNull();
  }

  @override
  String getTypeName() => 'UserTable';

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      final startupManager = SingletonUtil.getSingleton<IManagerLocator>()
          ?.getStartupManager();
      if (startupManager?.currentUser == null) {
        return null;
      }

      final cmmnUser = startupManager!.currentUser;
      return UserProfile.fromCmmnUser(cmmnUser);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<bool> updateProfile(UserProfile profile) async {
    try {
      // Get the user repository from the locator
      final repositoryLocator =
          SingletonUtil.getSingleton<IRepositoryLocator>()!;
      final userRepository = repositoryLocator.getUserRepository();

      // Update the user in the database using partial update
      await userRepository.updatePart(
        tableCompanion: UserTableCompanion(
          name: Value(profile.name),
          email: profile.email != null
              ? Value(profile.email!)
              : const Value.absent(),
          phoneNumber: profile.phone != null
              ? Value(profile.phone!)
              : const Value.absent(),
          dateUpdated: Value(DateTime.now()),
          lastModifiedBy: Value(profile.id),
        ),
        id: profile.id,
      );

      final startupManager = SingletonUtil.getSingleton<IManagerLocator>()
          ?.getStartupManager();
      await startupManager!.refreshCurrentUser();

      return true;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
