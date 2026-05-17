import 'package:drift/drift.dart';

/// Local SQLite table for work orders, mirrors Supabase `work_orders`.
class WorkOrderEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get assetId => text().nullable()();
  TextColumn get assignedTo => text().nullable()();
  TextColumn get organizationId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for assets, mirrors Supabase `assets`.
class AssetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get qrCode => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  TextColumn get serialNumber => text().withDefault(const Constant(''))();
  TextColumn get locationCoordinates =>
      text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('operational'))();
  DateTimeColumn get lastMaintenanceDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get organizationId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table for inspections, mirrors Supabase `inspections`.
class InspectionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get templateName => text().withDefault(const Constant(''))();
  TextColumn get workOrderId => text().withDefault(const Constant(''))();
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
  TextColumn get entityType => text()();
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
