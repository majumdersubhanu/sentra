import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentra/core/storage/database_providers.dart';

part 'conflicts_view_model.g.dart';

@riverpod
class ConflictsViewModel extends _$ConflictsViewModel {
  @override
  bool build() {
    return true;
  }

  Future<void> resolveWithLocal(String id, String entityType) async {
    final db = ref.read(sentraDatabaseProvider);
    // Mark as resolved and trigger a retry in SyncEngine
    await db.conflictDao.resolveConflict(id, entityType);
  }

  Future<void> resolveWithRemote(String id, String entityType) async {
    final db = ref.read(sentraDatabaseProvider);

    // 1. Remove the local mutation from SyncQueue
    await db.syncQueueDao.deleteMutation(id, entityType);

    // 2. Mark as resolved
    await db.conflictDao.resolveConflict(id, entityType);
  }
}
