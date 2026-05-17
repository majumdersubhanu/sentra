import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/env/env.dart';
import '../../../core/error/failures.dart';
import '../../../core/storage/database.dart';
import '../domain/asset.dart';
import '../domain/asset_repository.dart';

/// Network-aware repository for assets.
@LazySingleton(as: AssetRepository)
class AssetRepositoryImpl implements AssetRepository {
  final SentraDatabase _db;

  AssetRepositoryImpl(this._db);

  static final List<Asset> _mockAssets = [
    Asset(
      id: 'AST-502',
      name: 'Heavy Industrial HVAC Unit Alpha',
      qrCode: 'QR-HV9000',
      modelNumber: 'HV-9000X',
      serialNumber: 'SN-998234-A',
      locationCoordinates: 'Building B, Roof Sector 4',
      status: AssetOperationalStatus.maintenance,
      lastServicedDate: DateTime.now().subtract(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Asset(
      id: 'AST-104',
      name: 'High-Voltage Substation Step-Down',
      qrCode: 'QR-TX500',
      modelNumber: 'TX-500KVA',
      serialNumber: 'SN-102938-B',
      locationCoordinates: 'Sector 1, Enclosure C',
      status: AssetOperationalStatus.online,
      lastServicedDate: DateTime.now().subtract(const Duration(days: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
  ];

  final List<Asset> _localMockAssets = List.from(_mockAssets);

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<Asset>>> getAssets() async {
    if (Env.bypassAuth) return Right(List.unmodifiable(_localMockAssets));

    try {
      final client = _client;
      if (client != null) {
        final response = await client
            .from('assets')
            .select()
            .order('created_at', ascending: false);
        final assets = (response as List)
            .map((json) => _fromJson(json as Map<String, dynamic>))
            .toList();
        _cacheToLocal(assets);
        return Right(assets);
      }
    } catch (_) {}

    try {
      final entries = await _db.assetDao.getAllAssets();
      return Right(entries.map(_fromEntry).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to read local cache: $e'));
    }
  }

  @override
  Future<Either<Failure, Asset>> getAssetById(String id) async {
    if (Env.bypassAuth) {
      final asset = _localMockAssets.where((a) => a.id == id).firstOrNull;
      if (asset != null) return Right(asset);
      return const Left(CacheFailure('Asset not found.'));
    }

    try {
      final client = _client;
      if (client != null) {
        final response = await client
            .from('assets')
            .select()
            .eq('id', id)
            .single();
        return Right(_fromJson(response));
      }
    } catch (_) {}

    try {
      final entry = await _db.assetDao.getById(id);
      if (entry != null) return Right(_fromEntry(entry));
      return const Left(CacheFailure('Asset not found locally.'));
    } catch (e) {
      return Left(CacheFailure('Failed to read local cache: $e'));
    }
  }

  @override
  Future<Either<Failure, Asset>> createAsset(Asset asset) async {
    try {
      final companion = _toCompanion(asset, syncStatus: 'pending');
      await _db.assetDao.upsertAsset(companion);

      await _db.syncQueueDao.enqueue(
        entityType: 'asset',
        entityId: asset.id,
        mutationType: 'create',
        payload: jsonEncode(_assetToJson(asset)),
      );

      return Right(asset);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create asset: $e'));
    }
  }

  Future<void> _cacheToLocal(List<Asset> assets) async {
    try {
      final companions = assets
          .map((a) => _toCompanion(a, syncStatus: 'synced'))
          .toList();
      await _db.assetDao.bulkUpsert(companions);
    } catch (_) {}
  }

  static Map<String, dynamic> _assetToJson(Asset asset) {
    return {
      'id': asset.id,
      'name': asset.name,
      'qr_code': asset.qrCode,
      'model_number': asset.modelNumber,
      'serial_number': asset.serialNumber,
      'location_coordinates': asset.locationCoordinates,
      'operational_status': asset.status.name,
      'last_maintenance_date': asset.lastServicedDate.toIso8601String(),
      'created_at': asset.createdAt.toIso8601String(),
      'organization_id': asset.organizationId,
    };
  }

  static Asset _fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      name: json['name'] as String,
      qrCode: json['qr_code'] as String? ?? '',
      modelNumber: json['model_number'] as String? ?? '',
      serialNumber: json['serial_number'] as String? ?? '',
      locationCoordinates: json['location_coordinates'] as String? ?? '',
      status: _parseStatus(json['operational_status'] as String?),
      lastServicedDate: json['last_maintenance_date'] != null
          ? DateTime.parse(json['last_maintenance_date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      organizationId: json['organization_id'] as String?,
    );
  }

  static Asset _fromEntry(AssetEntry entry) {
    return Asset(
      id: entry.id,
      name: entry.name,
      qrCode: entry.qrCode,
      modelNumber: entry.modelNumber,
      serialNumber: entry.serialNumber,
      locationCoordinates: entry.locationCoordinates,
      status: _parseStatus(entry.operationalStatus),
      lastServicedDate: entry.lastMaintenanceDate ?? DateTime.now(),
      createdAt: entry.createdAt,
      organizationId: entry.organizationId,
    );
  }

  static AssetEntriesCompanion _toCompanion(
    Asset a, {
    required String syncStatus,
  }) {
    return AssetEntriesCompanion(
      id: Value(a.id),
      name: Value(a.name),
      qrCode: Value(a.qrCode),
      modelNumber: Value(a.modelNumber),
      serialNumber: Value(a.serialNumber),
      locationCoordinates: Value(a.locationCoordinates),
      operationalStatus: Value(a.status.name),
      lastMaintenanceDate: Value(a.lastServicedDate),
      createdAt: Value(a.createdAt),
      organizationId: Value(a.organizationId),
      syncStatus: Value(syncStatus),
    );
  }

  static AssetOperationalStatus _parseStatus(String? status) {
    return AssetOperationalStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AssetOperationalStatus.online,
    );
  }
}
