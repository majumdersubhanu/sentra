enum AssetOperationalStatus { online, maintenance, offline, decommissioned }

class Asset {
  final String id;
  final String name;
  final String? category;
  final String? manufacturer;
  final String modelNumber;
  final String serialNumber;
  final DateTime? installationDate;
  final String? warrantyStatus;
  final String? criticality;
  final AssetOperationalStatus status;
  final double? runtimeSinceLastService;
  final String? mtbfReference;
  final DateTime lastServicedDate;
  final String? lastFailureIncident;
  final String? connectedSystems;
  final String? owner;

  final String qrCode;
  final String locationCoordinates;
  final DateTime createdAt;
  final String? organizationId;

  const Asset({
    required this.id,
    required this.name,
    this.category,
    this.manufacturer,
    this.modelNumber = '',
    this.serialNumber = '',
    this.installationDate,
    this.warrantyStatus,
    this.criticality,
    required this.status,
    this.runtimeSinceLastService,
    this.mtbfReference,
    required this.lastServicedDate,
    this.lastFailureIncident,
    this.connectedSystems,
    this.owner,
    this.qrCode = '',
    this.locationCoordinates = '',
    required this.createdAt,
    this.organizationId,
  });

  Asset copyWith({
    String? id,
    String? name,
    String? category,
    String? manufacturer,
    String? modelNumber,
    String? serialNumber,
    DateTime? installationDate,
    String? warrantyStatus,
    String? criticality,
    AssetOperationalStatus? status,
    double? runtimeSinceLastService,
    String? mtbfReference,
    DateTime? lastServicedDate,
    String? lastFailureIncident,
    String? connectedSystems,
    String? owner,
    String? qrCode,
    String? locationCoordinates,
    DateTime? createdAt,
    String? organizationId,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      modelNumber: modelNumber ?? this.modelNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      installationDate: installationDate ?? this.installationDate,
      warrantyStatus: warrantyStatus ?? this.warrantyStatus,
      criticality: criticality ?? this.criticality,
      status: status ?? this.status,
      runtimeSinceLastService:
          runtimeSinceLastService ?? this.runtimeSinceLastService,
      mtbfReference: mtbfReference ?? this.mtbfReference,
      lastServicedDate: lastServicedDate ?? this.lastServicedDate,
      lastFailureIncident: lastFailureIncident ?? this.lastFailureIncident,
      connectedSystems: connectedSystems ?? this.connectedSystems,
      owner: owner ?? this.owner,
      qrCode: qrCode ?? this.qrCode,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      createdAt: createdAt ?? this.createdAt,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}
