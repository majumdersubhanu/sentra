import 'package:drift/drift.dart';

/// Local SQLite table for work orders, expanded for professional FSM.
class WorkOrderEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get priority => text().withDefault(const Constant('medium'))();

  // Header Info
  TextColumn get parentWorkOrderId => text().nullable()();
  TextColumn get serviceRequestId => text().nullable()();
  TextColumn get workType =>
      text().nullable()(); // Preventive, Corrective, Emergency, Inspection
  TextColumn get maintenanceStrategy => text().nullable()();
  TextColumn get riskClassification => text().nullable()();
  TextColumn get workflowStage => text().nullable()();

  DateTimeColumn get scheduledDate =>
      dateTime().nullable()(); // Keep for compatibility
  DateTimeColumn get scheduledStart => dateTime().nullable()();
  DateTimeColumn get scheduledFinish => dateTime().nullable()();
  DateTimeColumn get slaTarget => dateTime().nullable()();

  RealColumn get estimatedLaborHours => real().nullable()();
  TextColumn get siteRegion => text().nullable()();
  TextColumn get siteLocation => text().nullable()();
  TextColumn get gpsCoordinates => text().nullable()();
  TextColumn get businessUnit => text().nullable()();
  TextColumn get department => text().nullable()();
  TextColumn get costCenter => text().nullable()();

  // Safety Flags
  BoolColumn get permitRequirement =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get confinedSpaceEntry =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hotWorkRequired =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get lockoutTagoutRequired =>
      boolean().withDefault(const Constant(false))();

  TextColumn get environmentalSensitivity => text().nullable()();
  TextColumn get regulatoryComplianceScope => text().nullable()();
  TextColumn get escalationTier => text().nullable()();

  // Request Origin
  TextColumn get requestedBy => text().nullable()();
  TextColumn get reportedThrough => text().nullable()();
  TextColumn get customerImpact => text().nullable()();
  TextColumn get impactSeverity => text().nullable()();

  // Execution / Closure
  DateTimeColumn get actualStart => dateTime().nullable()();
  DateTimeColumn get actualFinish => dateTime().nullable()();
  TextColumn get technicianNotes => text().nullable()();
  TextColumn get customerSignaturePath => text().nullable()();

  // Relations & Meta
  TextColumn get assetId => text().nullable()();
  TextColumn get assignedTo => text().nullable()(); // User ID
  TextColumn get organizationId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for assets, expanded for professional FSM.
class AssetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()(); // Pump, HVAC, etc.
  TextColumn get manufacturer => text().nullable()();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  TextColumn get serialNumber => text().withDefault(const Constant(''))();
  DateTimeColumn get installationDate => dateTime().nullable()();
  TextColumn get warrantyStatus => text().nullable()();
  TextColumn get criticality => text().nullable()();
  TextColumn get operationalStatus =>
      text().withDefault(const Constant('operational'))();
  RealColumn get runtimeSinceLastService => real().nullable()();
  TextColumn get mtbfReference => text().nullable()();
  DateTimeColumn get lastMaintenanceDate => dateTime().nullable()();
  TextColumn get lastFailureIncident => text().nullable()();
  TextColumn get connectedSystems => text().nullable()(); // SCADA, IoT
  TextColumn get owner => text().nullable()();

  TextColumn get qrCode => text().withDefault(const Constant(''))();
  TextColumn get locationCoordinates =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get organizationId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for work order materials/parts.
class WorkOrderMaterialEntries extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text().references(WorkOrderEntries, #id)();
  TextColumn get partNumber => text()();
  TextColumn get description => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unitOfMeasure => text().withDefault(const Constant('EA'))();
  RealColumn get unitCost => real().nullable()();
  TextColumn get warehouseLocation => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for inspections, mirrors Supabase `inspections`.
class InspectionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get templateName => text().withDefault(const Constant(''))();
  TextColumn get workOrderId => text().nullable()();
  TextColumn get inspectorName => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get submittedBy => text().nullable()();
  TextColumn get organizationId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for inspection checklist items.
class InspectionItemEntries extends Table {
  TextColumn get id => text()();
  TextColumn get inspectionId => text().references(InspectionEntries, #id)();
  TextColumn get question => text()();
  BoolColumn get isPass => boolean().withDefault(const Constant(true))();
  TextColumn get comments => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for work order comments.
class WorkOrderCommentEntries extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text()();
  TextColumn get authorId => text().nullable()();
  TextColumn get authorName => text().withDefault(const Constant(''))();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for file attachments.
class AttachmentEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // 'work_order', 'inspection', 'asset'
  TextColumn get entityId => text()();
  TextColumn get filePath => text()();
  TextColumn get fileName => text()();
  IntColumn get fileSizeBytes => integer().nullable()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get uploadedBy => text().nullable()();
  TextColumn get organizationId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local sync queue — mutations pending upload to Supabase.
class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get mutationType => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text()(); // JSON-encoded entity
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get processedAt => dateTime().nullable()();
}

/// Local table for storing data conflicts that require manual resolution.
class ConflictEntries extends Table {
  TextColumn get id => text()(); // The unique ID of the entity in conflict
  TextColumn get entityType => text()(); // 'work_order', 'inspection', etc.
  TextColumn get localData => text()(); // JSON string of the local version
  TextColumn get remoteData => text()(); // JSON string of the remote version
  TextColumn get conflictingUserId => text().nullable()();
  TextColumn get conflictingUserName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id, entityType};
}

/// Local SQLite table for notifications.
class NotificationEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get type => text()(); // 'assignment', 'sla_breach', 'system'
  TextColumn get entityType => text().nullable()(); // 'work_order', 'asset'
  TextColumn get entityId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get organizationId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local table for users, mirrors Supabase `users`.
class UserEntries extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get role => text()();
  TextColumn get organizationId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
