import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import 'inspection.dart';

abstract interface class InspectionRepository {
  Future<Either<Failure, List<Inspection>>> getInspections();
  Future<Either<Failure, Unit>> saveInspection(Inspection inspection);
}
