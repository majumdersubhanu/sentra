enum AssetOperationalStatus { online, maintenance, offline, decommissioned }

class Asset {
  final String id;
  final String name;
  final String qrCode;
  final String modelNumber;
  final String serialNumber;
  final String locationCoordinates;
  final AssetOperationalStatus status;
  final DateTime lastServicedDate;
  final DateTime createdAt;
  final String? organizationId;

  const Asset({
    required this.id,
    required this.name,
    this.qrCode = '',
    this.modelNumber = '',
    this.serialNumber = '',
    this.locationCoordinates = '',
    required this.status,
    required this.lastServicedDate,
    required this.createdAt,
    this.organizationId,
  });

  Asset copyWith({
    String? id,
    String? name,
    String? qrCode,
    String? modelNumber,
    String? serialNumber,
    String? locationCoordinates,
    AssetOperationalStatus? status,
    DateTime? lastServicedDate,
    DateTime? createdAt,
    String? organizationId,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      qrCode: qrCode ?? this.qrCode,
      modelNumber: modelNumber ?? this.modelNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      status: status ?? this.status,
      lastServicedDate: lastServicedDate ?? this.lastServicedDate,
      createdAt: createdAt ?? this.createdAt,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}
