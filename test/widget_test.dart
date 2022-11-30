import 'package:flutter_test/flutter_test.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/impl/user_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/uuid_generator.dart';

void main() {
  test('Test User Service', () async {
    UserService userService = UserService();
    CmnUser user = CmnUser(
      id: UuidGenerator().v4(),
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
      name: "Ainal",
    );

    await userService.add(user);
    expect(1, (await userService.get()).length);

    await userService.delete(user);
    expect(0, (await userService.get()).length);
  });
}
