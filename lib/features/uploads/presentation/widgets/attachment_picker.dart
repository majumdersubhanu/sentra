import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/di/injection.dart';
import '../../domain/attachment_repository.dart';
import '../attachments_provider.dart';

class AttachmentPicker extends ConsumerWidget {
  final String entityId;
  final String entityType;

  const AttachmentPicker({
    super.key,
    required this.entityId,
    required this.entityType,
  });

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        final bytes = await image.length();
        final id = const Uuid().v4();

        final repo = getIt<AttachmentRepository>();
        final result = await repo.queueAttachment(
          id: id,
          entityId: entityId,
          entityType: entityType,
          filePath: image.path,
          fileName: image.name,
          contentType: 'image/jpeg',
          byteSize: bytes,
        );

        if (!context.mounted) return;
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to queue: ${failure.message}'),
              backgroundColor: SentraColors.error,
            ),
          ),
          (_) {
            ref.invalidate(attachmentsProvider(entityId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image queued for upload'),
                backgroundColor: SentraColors.success,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: SentraColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Attachment', style: SentraTypography.h3),
        const SizedBox(height: SentraSpacing.m),
        Row(
          children: [
            Expanded(
              child: SentraButton(
                label: 'Camera',
                icon: const Icon(
                  LucideIcons.camera,
                  size: 16,
                  color: Colors.white,
                ),
                onPressed: () => _pickImage(context, ref, ImageSource.camera),
              ),
            ),
            const SizedBox(width: SentraSpacing.m),
            Expanded(
              child: SentraButton(
                label: 'Gallery',
                isPrimary: false,
                icon: const Icon(
                  LucideIcons.image,
                  size: 16,
                  color: SentraColors.primary700,
                ),
                onPressed: () => _pickImage(context, ref, ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
