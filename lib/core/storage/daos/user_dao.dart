import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UserEntries])
class UserDao extends DatabaseAccessor<SentraDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Stream<List<UserEntry>> watchUsersByRole(String role) =>
      (select(userEntries)..where((t) => t.role.equals(role))).watch();

  Future<void> upsertUsers(List<UserEntriesCompanion> users) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(userEntries, users);
    });
  }

  Future<UserEntry?> getUserById(String id) =>
      (select(userEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
}
