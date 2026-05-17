import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../domain/attachment_repository.dart';
import '../../../shared/domain/attachment.dart';

final attachmentsProvider = FutureProvider.family<List<Attachment>, String>((
  ref,
  entityId,
) async {
  final repo = getIt<AttachmentRepository>();
  final result = await repo.getAttachmentsForEntity(entityId);
  return result.fold((l) => [], (r) => r);
});
