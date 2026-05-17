import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentra_ui/sentra_ui.dart';
import '../../../../shared/domain/attachment.dart';
import 'local_attachment_image.dart';

class AttachmentGallery extends StatelessWidget {
  final List<Attachment> attachments;

  const AttachmentGallery({super.key, required this.attachments});

  void _showFullScreen(BuildContext context, Attachment attachment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(attachment: attachment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No attachments provided',
            style: SentraTypography.bodySmall.copyWith(
              color: SentraColors.gray500,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: SentraSpacing.s),
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return GestureDetector(
            onTap: () => _showFullScreen(context, attachment),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 100,
                color: SentraColors.gray100,
                child: Hero(
                  tag: 'attachment-${attachment.id}',
                  child: attachment.isLocal
                      ? buildLocalAttachmentImage(
                          path: attachment.filePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => const Icon(
                            Icons.broken_image,
                            color: SentraColors.gray500,
                          ),
                        )
                      : Image.network(
                          attachment.fileUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => const Icon(
                            Icons.broken_image,
                            color: SentraColors.gray500,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final Attachment attachment;

  const _FullScreenImageViewer({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          attachment.fileName,
          style: SentraTypography.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Hero(
            tag: 'attachment-${attachment.id}',
            child: attachment.isLocal
                ? buildLocalAttachmentImage(
                    path: attachment.filePath!,
                    fit: BoxFit.contain,
                  )
                : Image.network(attachment.fileUrl ?? ''),
          ),
        ),
      ),
    );
  }
}
