import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mix/mix.dart';

import 'package:sentra/core/mixins/status_color_mixin.dart';
import 'package:sentra/core/theme/sentra_styles.dart';
import 'package:sentra/core/theme/sentra_tokens.dart';
import 'package:sentra/features/work_orders/presentation/work_order_comments_view_model.dart';

/// A comments section widget for the work order detail screen.
class WorkOrderCommentsSection extends ConsumerStatefulWidget {
  final String workOrderId;
  const WorkOrderCommentsSection({super.key, required this.workOrderId});

  @override
  ConsumerState<WorkOrderCommentsSection> createState() =>
      _WorkOrderCommentsSectionState();
}

class _WorkOrderCommentsSectionState
    extends ConsumerState<WorkOrderCommentsSection>
    with StatusColorMixin {
  final _commentCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(workOrderCommentsProvider(widget.workOrderId).notifier)
          .addComment(content: text, authorName: 'You');
      _commentCtrl.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post comment'),
            backgroundColor: kDanger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(
      workOrderCommentsProvider(widget.workOrderId),
    );

    return Box(
      style: $sectionCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment_outlined, color: kAccent, size: 18.0.sp),
              SizedBox(width: 8.0.w),
              Text(
                'Comments',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0.h),

          // Comments list
          commentsAsync.when(
            loading: () => Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0.h),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Text(
              'Failed to load comments',
              style: TextStyle(color: kDanger, fontSize: 12.0.sp),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0.h),
                  child: Center(
                    child: Text(
                      'No comments yet. Be the first to comment.',
                      style: TextStyle(color: kTextMuted, fontSize: 13.0.sp),
                    ),
                  ),
                );
              }

              return Column(
                children: comments.map((comment) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.0.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          width: 32.0.w,
                          height: 32.0.w,
                          decoration: BoxDecoration(
                            color: kAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              comment.authorName.isNotEmpty
                                  ? comment.authorName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: kAccent,
                                fontSize: 13.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0.w),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.authorName.isNotEmpty
                                        ? comment.authorName
                                        : 'Unknown',
                                    style: TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8.0.w),
                                  Text(
                                    Jiffy.parseFromDateTime(
                                      comment.createdAt,
                                    ).fromNow(),
                                    style: TextStyle(
                                      color: kTextMuted,
                                      fontSize: 10.0.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.0.h),
                              Text(
                                comment.content,
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 13.0.sp,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Comment input
          SizedBox(height: 8.0.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _commentCtrl,
                  style: TextStyle(color: kTextPrimary, fontSize: 13.0.sp),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: kTextMuted, fontSize: 13.0.sp),
                    filled: true,
                    fillColor: kSurfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0.r),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0.r),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0.r),
                      borderSide: const BorderSide(color: kAccent, width: 1.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.0.w,
                      vertical: 10.0.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0.w),
              SizedBox(
                width: 40.0.w,
                height: 40.0.w,
                child: IconButton(
                  onPressed: _isSending ? null : _submit,
                  icon: _isSending
                      ? SizedBox(
                          width: 18.0.w,
                          height: 18.0.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kAccent,
                          ),
                        )
                      : Icon(Icons.send_rounded, color: kAccent, size: 20.0.sp),
                  style: IconButton.styleFrom(
                    backgroundColor: kAccent.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
