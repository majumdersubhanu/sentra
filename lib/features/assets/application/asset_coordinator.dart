import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../domain/asset.dart';
import '../domain/asset_repository.dart';

@lazySingleton
class AssetCoordinator {
  final AssetRepository _repository;

  AssetCoordinator(this._repository);

  Future<Either<Failure, List<Asset>>> fetchAssets() {
    return _repository.getAssets();
  }

  Future<Either<Failure, Asset>> fetchAssetDetails(String id) {
    return _repository.getAssetById(id);
  }

  Future<Either<Failure, Asset>> createAsset(Asset asset) {
    return _repository.createAsset(asset);
  }
}
