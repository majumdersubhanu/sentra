import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sentra/features/work_orders/presentation/work_order_comments_view_model.dart';

class WorkOrderCommentsSection extends ConsumerStatefulWidget {
  final String workOrderId;
  const WorkOrderCommentsSection({super.key, required this.workOrderId});

  @override
  ConsumerState<WorkOrderCommentsSection> createState() =>
      _WorkOrderCommentsSectionState();
}

class _WorkOrderCommentsSectionState
    extends ConsumerState<WorkOrderCommentsSection> {
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
            backgroundColor: SentraColors.error,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Updates & Communication',
          style: SentraTypography.label.copyWith(color: SentraColors.gray500),
        ),
        const SizedBox(height: SentraSpacing.s),
        SentraCard(
          child: Column(
            children: [
              commentsAsync.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No updates yet.',
                        style: SentraTypography.bodySmall.copyWith(
                          color: SentraColors.gray500,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: SentraColors.primary50,
                            child: Text(
                              comment.authorName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: SentraColors.primary700,
                              ),
                            ),
                          ),
                          const SizedBox(width: SentraSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment.authorName,
                                      style: SentraTypography.label,
                                    ),
                                    Text(
                                      'just now',
                                      style: SentraTypography.bodySmall
                                          .copyWith(
                                            fontSize: 10,
                                            color: SentraColors.gray500,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: SentraTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading comments: $err'),
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentCtrl,
                      style: SentraTypography.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Add an update...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: SentraColors.gray200,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            LucideIcons.send,
                            color: SentraColors.primary500,
                          ),
                    onPressed: _isSending ? null : _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
