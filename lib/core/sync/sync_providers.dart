import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/connectivity_service.dart';
import '../storage/database_providers.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../core/di/injection.dart';
import 'sync_engine.dart';
import 'realtime_service.dart';

part 'sync_providers.g.dart';

@riverpod
Stream<bool> connectivity(Ref ref) {
  final service = getIt<ConnectivityService>();
  return service.onConnectivityChanged;
}

@riverpod
bool isOnline(Ref ref) {
  final service = getIt<ConnectivityService>();
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.asData?.value ?? service.isOnline;
}

@riverpod
Stream<int> pendingSyncCount(Ref ref) {
  final db = ref.watch(sentraDatabaseProvider);
  return db.syncQueueDao.watchPendingCount();
}

@riverpod
SyncEngine syncEngine(Ref ref) {
  final db = ref.watch(sentraDatabaseProvider);
  final service = getIt<ConnectivityService>();
  final authRepo = getIt<AuthRepository>();

  final engine = SyncEngine(db, service, authRepo);
  ref.onDispose(() => engine.stop());
  return engine;
}

@riverpod
RealtimeService realtimeService(Ref ref) {
  final db = ref.watch(sentraDatabaseProvider);
  final client = getIt<SupabaseClient>();
  final service = RealtimeService(db, client);
  ref.onDispose(() => service.stop());
  return service;
}

/// Sync state for UI display.
enum SyncStatus { idle, syncing, error, offline }

class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final String? lastError;

  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.lastError,
  });

  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    String? lastError,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
