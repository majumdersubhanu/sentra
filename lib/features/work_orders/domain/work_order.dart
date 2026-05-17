/// Full work order lifecycle statuses per spec (Lines 699-706).
enum WorkOrderStatus { open, assigned, inProgress, onHold, completed, verified }

enum WorkOrderPriority { low, medium, high, urgent }

class WorkOrder {
  final String id;
  final String title;
  final String description;
  final WorkOrderStatus status;
  final WorkOrderPriority priority;
  final DateTime scheduledDate;
  final DateTime createdAt;
  final String? assetId;
  final String? assignedTo; // UUID of assigned technician
  final String? organizationId; // Multi-tenant org UUID

  const WorkOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.scheduledDate,
    required this.createdAt,
    this.assetId,
    this.assignedTo,
    this.organizationId,
  });

  WorkOrder copyWith({
    String? id,
    String? title,
    String? description,
    WorkOrderStatus? status,
    WorkOrderPriority? priority,
    DateTime? scheduledDate,
    DateTime? createdAt,
    String? assetId,
    String? assignedTo,
    String? organizationId,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      createdAt: createdAt ?? this.createdAt,
      assetId: assetId ?? this.assetId,
      assignedTo: assignedTo ?? this.assignedTo,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}
