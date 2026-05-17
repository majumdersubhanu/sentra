import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/di/injection.dart';
import '../../../core/error/failures.dart';
import '../../../core/mixins/crud_view_model_mixin.dart';
import '../../../core/storage/database_providers.dart';
import '../application/asset_coordinator.dart';
import '../domain/asset.dart';

part 'assets_view_model.g.dart';

final localAssetsProvider = StreamProvider.autoDispose<List<Asset>>((ref) {
  final db = ref.watch(sentraDatabaseProvider);
  return db.assetDao.watchAllAssets().map(
    (rows) => rows
        .map(
          (entry) => Asset(
            id: entry.id,
            name: entry.name,
            qrCode: entry.qrCode,
            modelNumber: entry.modelNumber,
            serialNumber: entry.serialNumber,
            locationCoordinates: entry.locationCoordinates,
            status: AssetOperationalStatus.values.firstWhere(
              (s) => s.name == entry.status,
              orElse: () => AssetOperationalStatus.online,
            ),
            lastServicedDate: entry.lastMaintenanceDate ?? DateTime.now(),
            createdAt: entry.createdAt,
            organizationId: entry.organizationId,
          ),
        )
        .toList(),
  );
});

@riverpod
class AssetsViewModel extends _$AssetsViewModel with CrudViewModelMixin<Asset> {
  late final AssetCoordinator _coordinator;

  @override
  FutureOr<List<Asset>> build() async {
    _coordinator = getIt<AssetCoordinator>();
    return performFetch();
  }

  @override
  Future<Either<Failure, List<Asset>>> fetchAll() => _coordinator.fetchAssets();
}
