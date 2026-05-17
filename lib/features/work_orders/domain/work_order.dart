import 'package:fpdart/fpdart.dart';

/// Full work order lifecycle statuses per spec.
enum WorkOrderStatus {
  open,
  assigned,
  inProgress,
  onHold,
  completed,
  verified,
  cancelled,
}

enum WorkOrderPriority { low, medium, high, critical }

enum WorkType { preventive, corrective, emergency, inspection }

class WorkOrder {
  final String id;
  final String title;
  final String description;
  final WorkOrderStatus status;
  final WorkOrderPriority priority;

  // Header Info
  final String? parentWorkOrderId;
  final String? serviceRequestId;
  final WorkType? workType;
  final String? maintenanceStrategy;
  final String? riskClassification;
  final String? workflowStage;

  final DateTime? scheduledDate; // Legacy compatibility
  final DateTime? scheduledStart;
  final DateTime? scheduledFinish;
  final DateTime? slaTarget;

  final double? estimatedLaborHours;
  final String? siteRegion;
  final String? siteLocation;
  final String? gpsCoordinates;
  final String? businessUnit;
  final String? department;
  final String? costCenter;

  // Safety Flags
  final bool permitRequirement;
  final bool confinedSpaceEntry;
  final bool hotWorkRequired;
  final bool lockoutTagoutRequired;

  final String? environmentalSensitivity;
  final String? regulatoryComplianceScope;
  final String? escalationTier;

  // Request Origin
  final String? requestedBy;
  final String? reportedThrough;
  final String? customerImpact;
  final String? impactSeverity;

  // Execution / Closure
  final DateTime? actualStart;
  final DateTime? actualFinish;
  final String? technicianNotes;
  final String? customerSignaturePath;

  // Relations & Meta
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
    required this.createdAt,
    this.parentWorkOrderId,
    this.serviceRequestId,
    this.workType,
    this.maintenanceStrategy,
    this.riskClassification,
    this.workflowStage,
    this.scheduledDate,
    this.scheduledStart,
    this.scheduledFinish,
    this.slaTarget,
    this.estimatedLaborHours,
    this.siteRegion,
    this.siteLocation,
    this.gpsCoordinates,
    this.businessUnit,
    this.department,
    this.costCenter,
    this.permitRequirement = false,
    this.confinedSpaceEntry = false,
    this.hotWorkRequired = false,
    this.lockoutTagoutRequired = false,
    this.environmentalSensitivity,
    this.regulatoryComplianceScope,
    this.escalationTier,
    this.requestedBy,
    this.reportedThrough,
    this.customerImpact,
    this.impactSeverity,
    this.actualStart,
    this.actualFinish,
    this.technicianNotes,
    this.customerSignaturePath,
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
    String? parentWorkOrderId,
    String? serviceRequestId,
    WorkType? workType,
    String? maintenanceStrategy,
    String? riskClassification,
    String? workflowStage,
    DateTime? scheduledDate,
    DateTime? scheduledStart,
    DateTime? scheduledFinish,
    DateTime? slaTarget,
    double? estimatedLaborHours,
    String? siteRegion,
    String? siteLocation,
    String? gpsCoordinates,
    String? businessUnit,
    String? department,
    String? costCenter,
    bool? permitRequirement,
    bool? confinedSpaceEntry,
    bool? hotWorkRequired,
    bool? lockoutTagoutRequired,
    String? environmentalSensitivity,
    String? regulatoryComplianceScope,
    String? escalationTier,
    String? requestedBy,
    String? reportedThrough,
    String? customerImpact,
    String? impactSeverity,
    DateTime? actualStart,
    DateTime? actualFinish,
    String? technicianNotes,
    String? customerSignaturePath,
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
      parentWorkOrderId: parentWorkOrderId ?? this.parentWorkOrderId,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      workType: workType ?? this.workType,
      maintenanceStrategy: maintenanceStrategy ?? this.maintenanceStrategy,
      riskClassification: riskClassification ?? this.riskClassification,
      workflowStage: workflowStage ?? this.workflowStage,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledFinish: scheduledFinish ?? this.scheduledFinish,
      slaTarget: slaTarget ?? this.slaTarget,
      estimatedLaborHours: estimatedLaborHours ?? this.estimatedLaborHours,
      siteRegion: siteRegion ?? this.siteRegion,
      siteLocation: siteLocation ?? this.siteLocation,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      businessUnit: businessUnit ?? this.businessUnit,
      department: department ?? this.department,
      costCenter: costCenter ?? this.costCenter,
      permitRequirement: permitRequirement ?? this.permitRequirement,
      confinedSpaceEntry: confinedSpaceEntry ?? this.confinedSpaceEntry,
      hotWorkRequired: hotWorkRequired ?? this.hotWorkRequired,
      lockoutTagoutRequired:
          lockoutTagoutRequired ?? this.lockoutTagoutRequired,
      environmentalSensitivity:
          environmentalSensitivity ?? this.environmentalSensitivity,
      regulatoryComplianceScope:
          regulatoryComplianceScope ?? this.regulatoryComplianceScope,
      escalationTier: escalationTier ?? this.escalationTier,
      requestedBy: requestedBy ?? this.requestedBy,
      reportedThrough: reportedThrough ?? this.reportedThrough,
      customerImpact: customerImpact ?? this.customerImpact,
      impactSeverity: impactSeverity ?? this.impactSeverity,
      actualStart: actualStart ?? this.actualStart,
      actualFinish: actualFinish ?? this.actualFinish,
      technicianNotes: technicianNotes ?? this.technicianNotes,
      customerSignaturePath:
          customerSignaturePath ?? this.customerSignaturePath,
      createdAt: createdAt ?? this.createdAt,
      assetId: assetId ?? this.assetId,
      assignedTo: assignedTo ?? this.assignedTo,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}

class WorkOrderMaterial {
  final String id;
  final String workOrderId;
  final String partNumber;
  final String description;
  final double quantity;
  final String unitOfMeasure;
  final double? unitCost;
  final String? warehouseLocation;

  const WorkOrderMaterial({
    required this.id,
    required this.workOrderId,
    required this.partNumber,
    required this.description,
    this.quantity = 1.0,
    this.unitOfMeasure = 'EA',
    this.unitCost,
    this.warehouseLocation,
  });
}
