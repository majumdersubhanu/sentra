import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/di/injection.dart';
import '../domain/notification.dart';

part 'notifications_view_model.g.dart';

@riverpod
class NotificationsViewModel extends _$NotificationsViewModel {
  late final NotificationRepository _repository;

  @override
  FutureOr<List<SentraNotification>> build() {
    _repository = getIt<NotificationRepository>();
    return _fetchNotifications();
  }

  Future<List<SentraNotification>> _fetchNotifications() async {
    final result = await _repository.getNotifications();
    return result.fold((l) => throw l, (r) => r);
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }
}

@riverpod
Stream<List<SentraNotification>> unreadNotifications(Ref ref) {
  final repo = getIt<NotificationRepository>();
  return repo.watchUnreadNotifications();
}
