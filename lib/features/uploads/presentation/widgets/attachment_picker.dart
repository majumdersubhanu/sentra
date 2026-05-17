import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/sentra_tokens.dart';
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
              backgroundColor: kCritical,
            ),
          ),
          (_) {
            // Refresh the gallery
            ref.invalidate(attachmentsProvider(entityId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image queued for upload'),
                backgroundColor: kPositive,
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
            backgroundColor: kCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrand,
              foregroundColor: kSurface,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => _pickImage(context, ref, ImageSource.camera),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kBrand,
              side: const BorderSide(color: kBrand),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => _pickImage(context, ref, ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}
