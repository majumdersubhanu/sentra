import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';

enum SentraNotificationType { assignment, slaBreach, system }

class SentraNotification {
  final String id;
  final String title;
  final String message;
  final SentraNotificationType type;
  final String? entityType;
  final String? entityId;
  final DateTime createdAt;
  final bool isRead;

  const SentraNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.entityType,
    this.entityId,
    this.isRead = false,
  });
}

abstract interface class NotificationRepository {
  Future<Either<Failure, List<SentraNotification>>> getNotifications();
  Stream<List<SentraNotification>> watchUnreadNotifications();
  Future<Either<Failure, Unit>> markAsRead(String id);
}
