import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentra/core/di/injection.dart';
import 'package:sentra/core/storage/database.dart';

part 'database_providers.g.dart';

@riverpod
SentraDatabase sentraDatabase(Ref ref) {
  return getIt<SentraDatabase>();
}

@riverpod
Stream<List<dynamic>> unresolvedConflicts(Ref ref) {
  final db = ref.watch(sentraDatabaseProvider);
  // Workaround: Using List<dynamic> to avoid riverpod_generator InvalidTypeException
  // with Drift-generated types in collections.
  return db.conflictDao.watchUnresolvedConflicts();
}
