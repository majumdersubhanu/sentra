/// A comment on a work order. Supports threaded discussion.
class WorkOrderComment {
  final String id;
  final String workOrderId;
  final String? authorId;
  final String authorName; // Denormalized for offline display
  final String content;
  final DateTime createdAt;

  const WorkOrderComment({
    required this.id,
    required this.workOrderId,
    this.authorId,
    this.authorName = '',
    required this.content,
    required this.createdAt,
  });

  WorkOrderComment copyWith({
    String? id,
    String? workOrderId,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
  }) {
    return WorkOrderComment(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
