enum InspectionStatus { draft, submitted, flagged, approved }

class InspectionItem {
  final String id;
  final String question;
  final bool isPass;
  final String? comments;
  final int sortOrder;

  const InspectionItem({
    required this.id,
    required this.question,
    required this.isPass,
    this.comments,
    this.sortOrder = 0,
  });

  InspectionItem copyWith({
    String? id,
    String? question,
    bool? isPass,
    String? comments,
    int? sortOrder,
  }) {
    return InspectionItem(
      id: id ?? this.id,
      question: question ?? this.question,
      isPass: isPass ?? this.isPass,
      comments: comments ?? this.comments,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class Inspection {
  final String id;
  final String templateName;
  final String workOrderId;
  final String inspectorName;
  final DateTime createdAt;
  final InspectionStatus status;
  final List<InspectionItem> items;
  final String? submittedBy; // UUID
  final String? organizationId;

  const Inspection({
    required this.id,
    this.templateName = '',
    required this.workOrderId,
    required this.inspectorName,
    required this.createdAt,
    required this.status,
    required this.items,
    this.submittedBy,
    this.organizationId,
  });

  Inspection copyWith({
    String? id,
    String? templateName,
    String? workOrderId,
    String? inspectorName,
    DateTime? createdAt,
    InspectionStatus? status,
    List<InspectionItem>? items,
    String? submittedBy,
    String? organizationId,
  }) {
    return Inspection(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      workOrderId: workOrderId ?? this.workOrderId,
      inspectorName: inspectorName ?? this.inspectorName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      items: items ?? this.items,
      submittedBy: submittedBy ?? this.submittedBy,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}
