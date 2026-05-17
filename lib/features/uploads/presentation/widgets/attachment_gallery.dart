import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/sentra_tokens.dart';
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
            'No attachments',
            style: TextStyle(color: kTextMuted, fontSize: 14.sp),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return GestureDetector(
            onTap: () => _showFullScreen(context, attachment),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 100.h,
                height: 100.h,
                color: kBorderMuted,
                child: Hero(
                  tag: 'attachment-${attachment.id}',
                  child: attachment.isLocal
                      ? buildLocalAttachmentImage(
                          path: attachment.filePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) =>
                              const Icon(Icons.broken_image, color: kTextMuted),
                        )
                      : Image.network(
                          attachment.fileUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) =>
                              const Icon(Icons.broken_image, color: kTextMuted),
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
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
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
