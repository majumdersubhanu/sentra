import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import 'asset.dart';

abstract interface class AssetRepository {
  Future<Either<Failure, List<Asset>>> getAssets();
  Future<Either<Failure, Asset>> getAssetById(String id);
  Future<Either<Failure, Asset>> createAsset(Asset asset);
}
